import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/catalog/produit_boutique.dart';
import '../../../services/storage/local_cache_service.dart';
import '../models/boutique_cart_state.dart';

/// Résultat d’un ajout au panier (changement de presta éventuel).
enum BoutiqueCartAddResult {
  added,
  switchedPrestataire,
  outOfStock,
  clampedToStock,
}

class BoutiqueCartNotifier extends Notifier<BoutiqueCartState> {
  @override
  BoutiqueCartState build() {
    final raw = LocalCacheService.instance.boutiqueCartJson;
    if (raw == null || raw.trim().isEmpty) return BoutiqueCartState.empty;
    try {
      final decoded = jsonDecode(raw);
      if (decoded is Map) {
        return BoutiqueCartState.fromJson(
          Map<String, dynamic>.from(decoded),
        );
      }
    } catch (_) {}
    return BoutiqueCartState.empty;
  }

  Future<void> _persist(BoutiqueCartState next) async {
    state = next;
    if (next.isEmpty) {
      await LocalCacheService.instance.clearBoutiqueCart();
      return;
    }
    await LocalCacheService.instance.setBoutiqueCartJson(
      jsonEncode(next.toJson()),
    );
  }

  /// Ajoute un produit. Si le panier appartient à un autre presta, le remplace.
  /// Respecte le stock ([ProduitBoutique.maxOrderableQty]) quand renseigné.
  Future<BoutiqueCartAddResult> addProduit({
    required ProduitBoutique produit,
    String? prestataireName,
    int quantite = 1,
  }) async {
    final qtyWanted = quantite < 1 ? 1 : quantite;
    if (produit.isOutOfStock) {
      return BoutiqueCartAddResult.outOfStock;
    }

    final current = state;
    var result = BoutiqueCartAddResult.added;

    var lines = List<BoutiqueCartLine>.from(current.lines);
    var prestaId = current.prestataireId;
    var prestaName = current.prestataireName;

    if (prestaId != null &&
        prestaId.isNotEmpty &&
        prestaId != produit.prestataireId) {
      lines = [];
      result = BoutiqueCartAddResult.switchedPrestataire;
    }

    prestaId = produit.prestataireId;
    prestaName = prestataireName?.trim().isNotEmpty == true
        ? prestataireName!.trim()
        : prestaName;

    final index = lines.indexWhere((l) => l.produitId == produit.id);
    final existingQty = index >= 0 ? lines[index].quantite : 0;
    final target = clampCartQuantity(
      existingQty + qtyWanted,
      produit.maxOrderableQty,
    );
    if (target <= 0) {
      return BoutiqueCartAddResult.outOfStock;
    }
    if (target < existingQty + qtyWanted) {
      result = BoutiqueCartAddResult.clampedToStock;
    }

    if (index >= 0) {
      lines[index] = lines[index].copyWith(quantite: target);
    } else {
      lines.add(
        BoutiqueCartLine(
          produitId: produit.id,
          nom: produit.nom,
          prix: produit.prix,
          quantite: target,
          conditionnement: produit.conditionnement,
          imageUrl: produit.imageUrl,
        ),
      );
    }

    await _persist(
      BoutiqueCartState(
        prestataireId: prestaId,
        prestataireName: prestaName,
        lines: List.unmodifiable(lines),
      ),
    );
    return result;
  }

  Future<BoutiqueCartAddResult> setQuantity(
    String produitId,
    int quantite, {
    int? maxOrderableQty,
  }) async {
    if (quantite <= 0) {
      await removeProduit(produitId);
      return BoutiqueCartAddResult.added;
    }
    final clamped = clampCartQuantity(quantite, maxOrderableQty);
    if (clamped <= 0) {
      await removeProduit(produitId);
      return BoutiqueCartAddResult.outOfStock;
    }
    var result = BoutiqueCartAddResult.added;
    if (clamped < quantite) {
      result = BoutiqueCartAddResult.clampedToStock;
    }
    final lines = state.lines
        .map(
          (l) => l.produitId == produitId ? l.copyWith(quantite: clamped) : l,
        )
        .toList();
    await _persist(
      BoutiqueCartState(
        prestataireId: state.prestataireId,
        prestataireName: state.prestataireName,
        lines: List.unmodifiable(lines),
      ),
    );
    return result;
  }

  Future<void> removeProduit(String produitId) async {
    final lines =
        state.lines.where((l) => l.produitId != produitId).toList();
    if (lines.isEmpty) {
      await clear();
      return;
    }
    await _persist(
      BoutiqueCartState(
        prestataireId: state.prestataireId,
        prestataireName: state.prestataireName,
        lines: List.unmodifiable(lines),
      ),
    );
  }

  Future<void> clear() => _persist(BoutiqueCartState.empty);

  /// Remplace le panier par un état déjà revalidé côté serveur.
  Future<void> replaceWith(BoutiqueCartState next) => _persist(next);
}

final boutiqueCartProvider =
    NotifierProvider<BoutiqueCartNotifier, BoutiqueCartState>(
  BoutiqueCartNotifier.new,
);

final boutiqueCartItemCountProvider = Provider<int>((ref) {
  return ref.watch(boutiqueCartProvider).totalQuantity;
});
