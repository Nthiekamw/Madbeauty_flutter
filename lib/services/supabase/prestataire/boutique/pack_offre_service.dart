import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/supabase_error_handler.dart';
import '../../../../core/models/domain/catalog/pack_item.dart';
import '../../../../core/models/domain/catalog/pack_item_type.dart';
import '../../../../core/models/domain/catalog/pack_offre.dart';
import '../../../../core/models/domain/catalog/pack_offre_detail.dart';
import '../../../../core/models/domain/catalog/produit_boutique.dart';
import '../../../../core/models/domain/catalog/service_beaute.dart';
import '../../storage/storage_service.dart';

/// Pack enrichi pour le feed accueil (salon, prix catalogue, résumé items).
class PackOffreHomeEntry {
  const PackOffreHomeEntry({
    required this.pack,
    required this.prestataireDisplayName,
    this.ville,
    this.prixCatalogue,
    this.itemsSummary,
    this.hasBookableServices = false,
  });

  final PackOffre pack;
  final String prestataireDisplayName;
  final String? ville;
  final double? prixCatalogue;

  /// Ex. « Coiffure + Maquillage » pour le sous-titre carte.
  final String? itemsSummary;

  /// Au moins un service réservable dans le pack.
  final bool hasBookableServices;

  double? get discountPercent {
    final catalogue = prixCatalogue;
    if (catalogue == null) return null;
    return pack.discountPercent(catalogue);
  }
}

class PackItemDraft {
  const PackItemDraft.service({
    required this.refId,
    this.quantite = 1,
    this.sortOrder = 0,
  }) : type = PackItemType.service;

  const PackItemDraft.produit({
    required this.refId,
    this.quantite = 1,
    this.sortOrder = 0,
  }) : type = PackItemType.produit;

  final PackItemType type;
  final String refId;
  final int quantite;
  final int sortOrder;
}

class PackOffreUpsertData {
  const PackOffreUpsertData({
    this.id,
    required this.prestataireId,
    required this.titre,
    required this.prixPack,
    required this.items,
    this.description,
    this.imageUrl,
    this.isOffreDuJour = false,
    this.isActif = false,
    this.startsAt,
    this.endsAt,
  });

  final String? id;
  final String prestataireId;
  final String titre;
  final String? description;
  final String? imageUrl;
  final double prixPack;
  final bool isOffreDuJour;
  final bool isActif;
  final DateTime? startsAt;
  final DateTime? endsAt;
  final List<PackItemDraft> items;
}

class PackOffreService {
  PackOffreService(this._client, {StorageService? storageService})
      : _storageService = storageService;

  final SupabaseClient _client;
  final StorageService? _storageService;

  Future<String> uploadImage({
    required String prestataireId,
    required StorageUploadFile file,
  }) {
    final storage = _storageService;
    if (storage == null) {
      throw StateError('StorageService requis pour uploader une image pack.');
    }
    return storage.uploadRealisation(
      prestataireId: prestataireId,
      file: file,
    );
  }

  Future<List<PackOffre>> listByPrestataire(
    String prestataireId, {
    bool actifsOnly = true,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'packOffre.listByPrestataire',
        action: () async {
          var query = _client
              .from('packs_offre')
              .select()
              .eq('prestataire_id', prestataireId);
          if (actifsOnly) {
            query = query.eq('is_actif', true);
          }
          final response = await query.order('created_at', ascending: false);
          return (response as List<dynamic>)
              .map((row) => PackOffre.fromJson(row as Map<String, dynamic>))
              .toList();
        },
      );

  Future<List<PackItem>> listItems(String packId) => SupabaseErrorHandler.run(
        operation: 'packOffre.listItems',
        action: () async {
          final response = await _client
              .from('pack_items')
              .select()
              .eq('pack_id', packId)
              .order('sort_order');
          return (response as List<dynamic>)
              .map((row) => PackItem.fromJson(row as Map<String, dynamic>))
              .toList();
        },
      );

  Future<List<PackOffreDetail>> listDetailsByPrestataire(
    String prestataireId, {
    bool actifsOnly = true,
    Map<String, ServiceBeaute> servicesById = const {},
    Map<String, ProduitBoutique> produitsById = const {},
  }) async {
    final packs = await listByPrestataire(
      prestataireId,
      actifsOnly: actifsOnly,
    );
    if (packs.isEmpty) return const [];

    final details = <PackOffreDetail>[];
    for (final pack in packs) {
      final items = await listItems(pack.id);
      details.add(
        PackOffreDetail(
          pack: pack,
          items: items,
          prixCatalogue: computePackPrixCatalogue(
            items: items,
            servicesById: servicesById,
            produitsById: produitsById,
          ),
        ),
      );
    }
    return details;
  }

  Future<PackOffre> upsert(PackOffreUpsertData data) =>
      SupabaseErrorHandler.run(
        operation: 'packOffre.upsert',
        action: () async {
          if (data.items.length < 2) {
            throw const AppFailure(
              'Un pack doit contenir au moins 2 éléments '
              '(services et/ou produits).',
            );
          }

          final values = <String, dynamic>{
            'prestataire_id': data.prestataireId,
            'titre': data.titre.trim(),
            'prix_pack': data.prixPack,
            'is_offre_du_jour': data.isOffreDuJour,
            // Toujours créer / mettre à jour en brouillon d’abord, puis activer.
            'is_actif': false,
            'description': data.description?.trim().isNotEmpty == true
                ? data.description!.trim()
                : null,
            'image_url': data.imageUrl?.trim().isNotEmpty == true
                ? data.imageUrl!.trim()
                : null,
            'starts_at': data.startsAt?.toUtc().toIso8601String(),
            'ends_at': data.endsAt?.toUtc().toIso8601String(),
          };

          late final PackOffre pack;
          final id = data.id;
          if (id == null) {
            final inserted = await _client
                .from('packs_offre')
                .insert(values)
                .select()
                .single();
            pack = PackOffre.fromJson(inserted);
          } else {
            final updated = await _client
                .from('packs_offre')
                .update(values)
                .eq('prestataire_id', data.prestataireId)
                .eq('id', id)
                .select()
                .single();
            pack = PackOffre.fromJson(updated);
            await _client.from('pack_items').delete().eq('pack_id', pack.id);
          }

          final rows = <Map<String, dynamic>>[];
          for (var i = 0; i < data.items.length; i++) {
            final item = data.items[i];
            rows.add({
              'pack_id': pack.id,
              'item_type': item.type.dbValue,
              'service_id':
                  item.type == PackItemType.service ? item.refId : null,
              'produit_id':
                  item.type == PackItemType.produit ? item.refId : null,
              'quantite': item.quantite,
              'sort_order': item.sortOrder != 0 ? item.sortOrder : i,
            });
          }
          await _client.from('pack_items').insert(rows);

          if (data.isActif) {
            final activated = await _client
                .from('packs_offre')
                .update({'is_actif': true})
                .eq('id', pack.id)
                .eq('prestataire_id', data.prestataireId)
                .select()
                .single();
            return PackOffre.fromJson(activated);
          }

          return pack;
        },
      );

  Future<void> setActif({
    required String prestataireId,
    required String id,
    required bool isActif,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'packOffre.setActif',
        action: () async {
          await _client
              .from('packs_offre')
              .update({'is_actif': isActif})
              .eq('prestataire_id', prestataireId)
              .eq('id', id);
        },
      );

  Future<void> deactivate({
    required String prestataireId,
    required String id,
  }) =>
      setActif(prestataireId: prestataireId, id: id, isActif: false);

  Future<void> delete({
    required String prestataireId,
    required String id,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'packOffre.delete',
        action: () async {
          await _client
              .from('packs_offre')
              .delete()
              .eq('prestataire_id', prestataireId)
              .eq('id', id);
        },
      );

  Future<int> countActifs(String prestataireId) => SupabaseErrorHandler.run(
        operation: 'packOffre.countActifs',
        action: () async {
          final response = await _client
              .from('packs_offre')
              .select('id')
              .eq('prestataire_id', prestataireId)
              .eq('is_actif', true);
          return (response as List<dynamic>).length;
        },
      );

  /// Packs actifs pour le feed accueil (offres du jour d’abord).
  Future<List<PackOffreHomeEntry>> listFeaturedForHome({int limit = 12}) =>
      SupabaseErrorHandler.run(
        operation: 'packOffre.listFeaturedForHome',
        action: () async {
          final response = await _client
              .from('packs_offre')
              .select(
                '*, prestataire_profiles!inner(id, nom_salon, nom_affiche, ville)',
              )
              .eq('is_actif', true)
              .order('is_offre_du_jour', ascending: false)
              .order('created_at', ascending: false)
              .limit(limit);

          final base = <({PackOffre pack, String name, String? ville})>[];
          for (final raw in response as List<dynamic>) {
            final row = Map<String, dynamic>.from(raw as Map);
            final profileRaw = row.remove('prestataire_profiles');
            final pack = PackOffre.fromJson(row);
            var displayName = 'Salon';
            String? ville;
            if (profileRaw is Map) {
              final profile = Map<String, dynamic>.from(profileRaw);
              final nomAffiche =
                  (profile['nom_affiche'] as String?)?.trim() ?? '';
              final nomSalon = (profile['nom_salon'] as String?)?.trim() ?? '';
              displayName = nomAffiche.isNotEmpty
                  ? nomAffiche
                  : (nomSalon.isNotEmpty ? nomSalon : displayName);
              ville = (profile['ville'] as String?)?.trim();
            }
            base.add((
              pack: pack,
              name: displayName,
              ville: (ville == null || ville.isEmpty) ? null : ville,
            ));
          }
          if (base.isEmpty) return const <PackOffreHomeEntry>[];

          final packIds = base.map((e) => e.pack.id).toList(growable: false);
          final itemsByPack = await _itemsByPackIds(packIds);
          final serviceIds = <String>{};
          final produitIds = <String>{};
          for (final items in itemsByPack.values) {
            for (final item in items) {
              final sid = item.serviceId;
              final pid = item.produitId;
              if (sid != null && sid.isNotEmpty) serviceIds.add(sid);
              if (pid != null && pid.isNotEmpty) produitIds.add(pid);
            }
          }

          final servicesById = await _servicesByIds(serviceIds.toList());
          final produitsById = await _produitsByIds(produitIds.toList());

          final entries = <PackOffreHomeEntry>[];
          for (final row in base) {
            final items = itemsByPack[row.pack.id] ?? const <PackItem>[];
            entries.add(
              PackOffreHomeEntry(
                pack: row.pack,
                prestataireDisplayName: row.name,
                ville: row.ville,
                prixCatalogue: computePackPrixCatalogue(
                  items: items,
                  servicesById: servicesById,
                  produitsById: produitsById,
                ),
                itemsSummary: _itemsSummary(
                  items: items,
                  servicesById: servicesById,
                  produitsById: produitsById,
                ),
                hasBookableServices: items.any(
                  (i) => i.itemType == PackItemType.service,
                ),
              ),
            );
          }
          return entries;
        },
      );

  Future<Map<String, List<PackItem>>> _itemsByPackIds(List<String> packIds) async {
    if (packIds.isEmpty) return const {};
    final response = await _client
        .from('pack_items')
        .select()
        .inFilter('pack_id', packIds)
        .order('sort_order');
    final map = <String, List<PackItem>>{};
    for (final raw in response as List<dynamic>) {
      final item = PackItem.fromJson(Map<String, dynamic>.from(raw as Map));
      map.putIfAbsent(item.packId, () => <PackItem>[]).add(item);
    }
    return map;
  }

  Future<Map<String, ServiceBeaute>> _servicesByIds(List<String> ids) async {
    if (ids.isEmpty) return const {};
    final response =
        await _client.from('services_beaute').select().inFilter('id', ids);
    return {
      for (final raw in response as List<dynamic>)
        (raw as Map)['id'] as String: ServiceBeaute.fromJson(
          Map<String, dynamic>.from(raw),
        ),
    };
  }

  Future<Map<String, ProduitBoutique>> _produitsByIds(List<String> ids) async {
    if (ids.isEmpty) return const {};
    final response =
        await _client.from('produits_boutique').select().inFilter('id', ids);
    return {
      for (final raw in response as List<dynamic>)
        (raw as Map)['id'] as String: ProduitBoutique.fromJson(
          Map<String, dynamic>.from(raw),
        ),
    };
  }

  static String? _itemsSummary({
    required List<PackItem> items,
    required Map<String, ServiceBeaute> servicesById,
    required Map<String, ProduitBoutique> produitsById,
  }) {
    final names = <String>[];
    for (final item in items) {
      switch (item.itemType) {
        case PackItemType.service:
          final s =
              item.serviceId == null ? null : servicesById[item.serviceId];
          final nom = s?.nom.trim() ?? '';
          if (nom.isNotEmpty) names.add(nom);
        case PackItemType.produit:
          final p =
              item.produitId == null ? null : produitsById[item.produitId];
          final nom = p?.nom.trim() ?? '';
          if (nom.isNotEmpty) names.add(nom);
      }
    }
    if (names.isEmpty) return null;
    if (names.length <= 3) return names.join(' + ');
    return '${names.take(2).join(' + ')} +${names.length - 2}';
  }
}
