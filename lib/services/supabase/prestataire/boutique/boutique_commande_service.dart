import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/supabase_error_handler.dart';
import '../../../../core/models/domain/catalog/boutique_commande.dart';
import '../../../../core/models/domain/catalog/produit_boutique.dart';
import '../../../../features/cart/models/boutique_cart_state.dart';
import '../../profile/profile_service.dart';

class BoutiqueCommandeCreateResult {
  const BoutiqueCommandeCreateResult({
    required this.commandeId,
    required this.amountCents,
    required this.statut,
  });

  final String commandeId;
  final int amountCents;
  final String statut;
}

/// Résultat d’une revalidation panier avant checkout.
class BoutiqueCartRevalidateResult {
  const BoutiqueCartRevalidateResult({
    required this.cart,
    this.removedNames = const [],
    this.pricesChanged = false,
    this.quantitiesReduced = false,
  });

  final BoutiqueCartState cart;
  final List<String> removedNames;
  final bool pricesChanged;
  final bool quantitiesReduced;

  bool get hasChanges =>
      removedNames.isNotEmpty || pricesChanged || quantitiesReduced;
}

/// Commandes boutique : création client + gestion prestataire.
class BoutiqueCommandeService {
  BoutiqueCommandeService(
    this._client, {
    ProfileService? profileService,
  }) : _profileService = profileService;

  final SupabaseClient _client;
  final ProfileService? _profileService;

  /// Aligne le panier local sur les prix / dispo / stock DB (mono-presta).
  Future<BoutiqueCartRevalidateResult> revalidateCart(
    BoutiqueCartState cart,
  ) =>
      SupabaseErrorHandler.run(
        operation: 'boutiqueCommande.revalidateCart',
        action: () async {
          final prestaId = cart.prestataireId?.trim();
          if (prestaId == null || prestaId.isEmpty || cart.isEmpty) {
            return BoutiqueCartRevalidateResult(cart: BoutiqueCartState.empty);
          }

          final produitIds = cart.lines.map((l) => l.produitId).toList();
          final produitsResponse = await _client
              .from('produits_boutique')
              .select(
                'id, nom, conditionnement, prix, is_actif, prestataire_id, '
                'image_url, stock_illimite, stock_qty',
              )
              .inFilter('id', produitIds)
              .eq('prestataire_id', prestaId)
              .eq('is_actif', true);

          final byId = <String, Map<String, dynamic>>{};
          for (final row in produitsResponse as List<dynamic>) {
            final m = Map<String, dynamic>.from(row as Map);
            byId[m['id'] as String] = m;
          }

          final nextLines = <BoutiqueCartLine>[];
          final removed = <String>[];
          var pricesChanged = false;
          var quantitiesReduced = false;

          for (final line in cart.lines) {
            final db = byId[line.produitId];
            if (db == null) {
              removed.add(line.nom);
              continue;
            }
            final illimite = db['stock_illimite'] as bool? ?? false;
            final stockQty = (db['stock_qty'] as num?)?.toInt() ?? 0;
            final maxQty = illimite ? null : stockQty;
            if (maxQty != null && maxQty <= 0) {
              removed.add(line.nom);
              continue;
            }
            final prix = (db['prix'] as num?)?.toDouble() ?? 0;
            final nom = (db['nom'] as String?)?.trim() ?? line.nom;
            if ((prix - line.prix).abs() > 0.009) {
              pricesChanged = true;
            }
            final clamped = clampCartQuantity(line.quantite, maxQty);
            if (clamped <= 0) {
              removed.add(line.nom);
              continue;
            }
            if (clamped < line.quantite) {
              quantitiesReduced = true;
            }
            nextLines.add(
              line.copyWith(
                nom: nom,
                prix: prix,
                quantite: clamped,
                conditionnement: (db['conditionnement'] as String?)?.trim(),
                imageUrl: (db['image_url'] as String?)?.trim() ?? line.imageUrl,
              ),
            );
          }

          return BoutiqueCartRevalidateResult(
            cart: BoutiqueCartState(
              prestataireId: nextLines.isEmpty ? null : prestaId,
              prestataireName:
                  nextLines.isEmpty ? null : cart.prestataireName,
              lines: List.unmodifiable(nextLines),
            ),
            removedNames: List.unmodifiable(removed),
            pricesChanged: pricesChanged,
            quantitiesReduced: quantitiesReduced,
          );
        },
      );

  Future<void> expireOwnStalePending() async {
    try {
      await _client.rpc('expire_own_stale_boutique_pending_orders');
    } catch (_) {
      // Non bloquant : la commande peut encore être créée.
    }
  }

  Future<BoutiqueCommandeCreateResult> createFromCart({
    required BoutiqueCartState cart,
    required bool payOnSite,
    String? notesClient,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'boutiqueCommande.createFromCart',
        action: () async {
          final prestaId = cart.prestataireId?.trim();
          if (prestaId == null || prestaId.isEmpty || cart.isEmpty) {
            throw const AppFailure('Panier invalide.');
          }

          final userId = _client.auth.currentUser?.id;
          if (userId == null) {
            throw const AppFailure('Connecte-toi pour commander.');
          }

          final payload = <String, dynamic>{
            'prestataire_id': prestaId,
            'pay_on_site': payOnSite,
            if (notesClient != null && notesClient.trim().isNotEmpty)
              'notes_client': notesClient.trim(),
            'items': [
              for (final line in cart.lines)
                {
                  'produit_id': line.produitId,
                  'quantite': line.quantite,
                },
            ],
          };

          final raw = await _client.rpc(
            'create_boutique_commande_from_cart',
            params: {'p_payload': payload},
          );

          final map = raw is Map
              ? Map<String, dynamic>.from(raw)
              : <String, dynamic>{};
          final commandeId = map['commande_id'] as String?;
          final amountCents = (map['amount_cents'] as num?)?.toInt();
          final statut = map['statut'] as String?;
          if (commandeId == null ||
              amountCents == null ||
              statut == null ||
              statut.isEmpty) {
            throw const AppFailure('Réponse commande invalide.');
          }

          return BoutiqueCommandeCreateResult(
            commandeId: commandeId,
            amountCents: amountCents,
            statut: statut,
          );
        },
      );

  Future<List<BoutiqueCommande>> listForClient(String clientId) =>
      SupabaseErrorHandler.run(
        operation: 'boutiqueCommande.listForClient',
        action: () async {
          List<dynamic> rows;
          try {
            final response = await _client
                .from('boutique_commandes')
                .select(
                  '*, boutique_commande_items(*), '
                  'prestataire_profiles(id, nom_salon, nom_affiche), '
                  'avis_boutique(id)',
                )
                .eq('client_id', clientId)
                .order('created_at', ascending: false);
            rows = response as List<dynamic>;
          } catch (_) {
            final response = await _client
                .from('boutique_commandes')
                .select(
                  '*, boutique_commande_items(*), '
                  'prestataire_profiles(id, nom_salon, nom_affiche)',
                )
                .eq('client_id', clientId)
                .order('created_at', ascending: false);
            rows = response as List<dynamic>;
          }
          return rows
              .map(
                (row) => BoutiqueCommande.fromJson(
                  Map<String, dynamic>.from(row as Map),
                ),
              )
              .toList();
        },
      );

  Future<List<BoutiqueCommande>> listForCurrentClient() =>
      SupabaseErrorHandler.run(
        operation: 'boutiqueCommande.listForCurrentClient',
        action: () async {
          await expireOwnStalePending();
          final userId = _client.auth.currentUser?.id;
          if (userId == null) return const <BoutiqueCommande>[];

          final clientRow = await _client
              .from('client_profiles')
              .select('id')
              .eq('user_id', userId)
              .maybeSingle();
          final clientId = clientRow?['id'] as String?;
          if (clientId == null) return const <BoutiqueCommande>[];
          return listForClient(clientId);
        },
      );

  Future<List<BoutiqueCommande>> listForPrestataire(String prestataireId) =>
      SupabaseErrorHandler.run(
        operation: 'boutiqueCommande.listForPrestataire',
        action: () async {
          List<dynamic> rows;
          try {
            final response = await _client
                .from('boutique_commandes')
                .select(
                  '*, boutique_commande_items(*), client_profiles(user_id)',
                )
                .eq('prestataire_id', prestataireId)
                .order('created_at', ascending: false);
            rows = response as List<dynamic>;
          } catch (_) {
            // Fallback si le join client_profiles est indisponible (RLS / schéma).
            final response = await _client
                .from('boutique_commandes')
                .select('*, boutique_commande_items(*)')
                .eq('prestataire_id', prestataireId)
                .order('created_at', ascending: false);
            rows = response as List<dynamic>;
          }
          final commandes = <BoutiqueCommande>[];
          final userIds = <String>[];
          final userIdByIndex = <int, String>{};

          for (var i = 0; i < rows.length; i++) {
            final map = Map<String, dynamic>.from(rows[i] as Map);
            commandes.add(BoutiqueCommande.fromJson(map));
            final userId = BoutiqueCommande.clientUserIdFromJson(map)?.trim();
            if (userId != null && userId.isNotEmpty) {
              userIds.add(userId);
              userIdByIndex[i] = userId;
            }
          }

          final profileService = _profileService;
          if (profileService == null || userIds.isEmpty) {
            return commandes;
          }

          final profiles = await profileService.getByUserIds(
            userIds.toSet().toList(),
          );
          return List.generate(commandes.length, (i) {
            final userId = userIdByIndex[i];
            if (userId == null) return commandes[i];
            final profile = profiles[userId];
            if (profile == null) return commandes[i];
            final prenom = profile.prenom?.trim() ?? '';
            final nom = profile.nom?.trim() ?? '';
            final parts = <String>[
              if (prenom.isNotEmpty) prenom,
              if (nom.isNotEmpty) nom,
            ];
            if (parts.isEmpty) return commandes[i];
            return commandes[i].copyWith(clientDisplayName: parts.join(' '));
          });
        },
      );

  Future<int> countOpenForPrestataire(String prestataireId) =>
      SupabaseErrorHandler.run(
        operation: 'boutiqueCommande.countOpenForPrestataire',
        action: () async {
          final response = await _client
              .from('boutique_commandes')
              .select('id')
              .eq('prestataire_id', prestataireId)
              .inFilter('statut', [
            'pay_on_site',
            'paid',
            'preparing',
            'ready',
            'pending_payment',
          ]);
          return (response as List<dynamic>).length;
        },
      );

  Future<void> updateStatut({
    required String prestataireId,
    required String commandeId,
    required BoutiqueCommandeStatut statut,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'boutiqueCommande.updateStatut',
        action: () async {
          final values = <String, dynamic>{
            'statut': statut.dbValue,
          };
          if (statut == BoutiqueCommandeStatut.completed) {
            values['payment_status'] = 'paid';
            values['paid_at'] = DateTime.now().toUtc().toIso8601String();
          }

          await _client
              .from('boutique_commandes')
              .update(values)
              .eq('prestataire_id', prestataireId)
              .eq('id', commandeId);
        },
      );

  Future<void> advanceStatut({
    required String prestataireId,
    required BoutiqueCommande commande,
  }) async {
    final next = commande.statut.nextForPrestataire;
    if (next == null) {
      throw const AppFailure('Cette commande ne peut plus évoluer.');
    }
    await updateStatut(
      prestataireId: prestataireId,
      commandeId: commande.id,
      statut: next,
    );
  }

  Future<void> cancel({
    required String prestataireId,
    required String commandeId,
  }) =>
      updateStatut(
        prestataireId: prestataireId,
        commandeId: commandeId,
        statut: BoutiqueCommandeStatut.canceled,
      );

  /// Client : confirme la réception (ready → completed).
  Future<BoutiqueCommande> confirmReceiptAsClient(String commandeId) =>
      SupabaseErrorHandler.run(
        operation: 'boutiqueCommande.confirmReceiptAsClient',
        action: () async {
          final raw = await _client.rpc(
            'client_confirm_boutique_receipt',
            params: {'p_commande_id': commandeId},
          );
          if (raw is! Map) {
            throw const AppFailure('Réponse confirmation invalide.');
          }
          return BoutiqueCommande.fromJson(Map<String, dynamic>.from(raw));
        },
      );

  /// Client : publie un avis après réception confirmée.
  Future<void> createAvisBoutique({
    required String commandeId,
    required int note,
    String? commentaire,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'boutiqueCommande.createAvisBoutique',
        action: () async {
          if (note < 1 || note > 5) {
            throw const AppFailure('La note doit être entre 1 et 5.');
          }
          await _client.rpc(
            'create_avis_boutique',
            params: {
              'p_payload': {
                'commande_id': commandeId,
                'note': note,
                if (commentaire != null && commentaire.trim().isNotEmpty)
                  'commentaire': commentaire.trim(),
              },
            },
          );
        },
      );
}
