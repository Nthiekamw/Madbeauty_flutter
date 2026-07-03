import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/supabase_error_handler.dart';
import '../../../../core/geo/discovery_reference.dart';
import '../../../../core/geo/geo_utils.dart';
import '../../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../../core/models/domain/catalog/service_category.dart';
import '../../../../core/models/domain/user/prestataire_profile.dart';
import '../../profile/profile_service.dart';
import 'prestataire_filters.dart';

class PrestataireService {
  PrestataireService(this._client, {required ProfileService profileService})
    : _profileService = profileService;

  final SupabaseClient _client;
  final ProfileService _profileService;

  String get _catalogTrialCutoffIso =>
      DateTime.now().toUtc().toIso8601String();

  /// Filtres SQL alignés sur [prestataire_is_catalog_visible] (abonnement / essai).
  PostgrestFilterBuilder<PostgrestList> _applyCatalogVisibilityQuery(
    PostgrestFilterBuilder<PostgrestList> query,
  ) {
    return query
        .eq('is_hidden', false)
        .or(
          'subscription_status.eq.active,'
          'subscription_status.eq.trialing,'
          'catalog_trial_ends_at.gt.$_catalogTrialCutoffIso',
        );
  }

  /// Vérifie ban + visibilité via RPC security definer (RLS bloque is_banned côté client).
  Future<List<PrestataireProfile>> _keepCatalogVisibleProfiles(
    List<PrestataireProfile> profiles,
  ) async {
    if (profiles.isEmpty) return const [];
    try {
      final response = await _client.rpc(
        'filter_catalog_visible_prestataire_ids',
        params: {'p_ids': profiles.map((p) => p.id).toList()},
      );
      final visibleIds = <String>{};
      if (response is List) {
        for (final raw in response) {
          final id = raw?.toString();
          if (id != null && id.isNotEmpty) visibleIds.add(id);
        }
      }
      if (visibleIds.isEmpty) return const [];
      return profiles.where((p) => visibleIds.contains(p.id)).toList();
    } catch (_) {
      return profiles;
    }
  }

  Future<List<PrestataireCatalogEntry>> getAll({
    PrestataireFilters filters = const PrestataireFilters(),
  }) => SupabaseErrorHandler.run(
    operation: 'prestataire.getAll',
    action: () async {
      final to = filters.offset + filters.limit - 1;
      final profilesRes = await _applyCatalogVisibilityQuery(
        _client.from('prestataire_profiles').select(),
      ).order('created_at', ascending: false).range(filters.offset, to);

      var profiles = (profilesRes as List<dynamic>)
          .map((e) => PrestataireProfile.fromJson(e as Map<String, dynamic>))
          .toList();
      profiles = await _keepCatalogVisibleProfiles(profiles);
      if (profiles.isEmpty) return [];

      final specialtyData = await getSpecialtyDataForPrestataires(
        profiles.map((p) => p.id).toList(),
      );
      final userProfiles = await _profileService.getByUserIds(
        profiles.map((p) => p.userId).toList(),
      );

      profiles = _applyFilters(
        profiles: profiles,
        filters: filters,
        specialtyNamesByPrestataire: specialtyData.namesByPrestataire,
        categoryIdsByPrestataire: specialtyData.categoryIdsByPrestataire,
      );

      return profiles.map((p) {
        final userProfile = userProfiles[p.userId];
        return PrestataireCatalogEntry(
          profile: p,
          avatarUrl: userProfile?.avatarUrl,
          userNom: userProfile?.nom,
          userPrenom: userProfile?.prenom,
          specialtyNames: List<String>.from(
            specialtyData.namesByPrestataire[p.id] ?? const [],
          ),
          specialtyCategoryIds: List<String>.from(
            specialtyData.categoryIdsByPrestataire[p.id] ?? const <String>{},
          ),
        );
      }).toList();
    },
  );

  /// Entrées catalogue pour une liste d'ids (ex. favoris), en conservant [prestataireIds].
  Future<List<PrestataireCatalogEntry>> getCatalogEntriesByIds(
    List<String> prestataireIds,
  ) =>
      SupabaseErrorHandler.run(
        operation: 'prestataire.getCatalogEntriesByIds',
        action: () async {
          if (prestataireIds.isEmpty) return [];

          final profilesRes = await _applyCatalogVisibilityQuery(
            _client.from('prestataire_profiles').select(),
          ).inFilter('id', prestataireIds);

          final profilesById = <String, PrestataireProfile>{};
          for (final raw in profilesRes as List<dynamic>) {
            final p = PrestataireProfile.fromJson(
              Map<String, dynamic>.from(raw as Map),
            );
            profilesById[p.id] = p;
          }

          final ordered = <PrestataireProfile>[
            for (final id in prestataireIds)
              if (profilesById.containsKey(id)) profilesById[id]!,
          ];
          final visibleOrdered = await _keepCatalogVisibleProfiles(ordered);
          if (visibleOrdered.isEmpty) return [];

          final specialtyData = await getSpecialtyDataForPrestataires(
            visibleOrdered.map((p) => p.id).toList(),
          );
          final reviewCounts = await _reviewCountsForPrestataires(
            visibleOrdered.map((p) => p.id).toList(),
          );
          final userProfiles = await _profileService.getByUserIds(
            visibleOrdered.map((p) => p.userId).toList(),
          );

          return visibleOrdered.map((p) {
            final userProfile = userProfiles[p.userId];
            return PrestataireCatalogEntry(
              profile: p,
              avatarUrl: userProfile?.avatarUrl,
              userNom: userProfile?.nom,
              userPrenom: userProfile?.prenom,
              specialtyNames: List<String>.from(
                specialtyData.namesByPrestataire[p.id] ?? const [],
              ),
              specialtyCategoryIds: List<String>.from(
                specialtyData.categoryIdsByPrestataire[p.id] ?? const <String>{},
              ),
              reviewCount: reviewCounts[p.id],
            );
          }).toList();
        },
      );

  Future<PrestataireProfile?> getById(String id) => SupabaseErrorHandler.run(
    operation: 'prestataire.getById',
    action: () async {
      final response = await _client
          .from('prestataire_profiles')
          .select()
          .eq('id', id)
          .maybeSingle();
      if (response == null) return null;
      final profile = PrestataireProfile.fromJson(Map<String, dynamic>.from(response));
      final visible = await _keepCatalogVisibleProfiles([profile]);
      return visible.isEmpty ? null : visible.first;
    },
  );

  /// Crée une ligne `prestataire_profiles` si absente (rôle + upsert minimal).
  Future<String> ensureProfileForUser(String userId) =>
      SupabaseErrorHandler.run(
        operation: 'prestataire.ensureProfileForUser',
        action: () async {
          final existing = await getByUserId(userId);
          if (existing != null) return existing.id;

          return upsert(
            PrestataireUpsertData(
              userId: userId,
              nomSalon: '',
              bio: '',
              ville: '',
            ),
          );
        },
      );

  Future<PrestataireProfile?> getByUserId(String userId) =>
      SupabaseErrorHandler.run(
        operation: 'prestataire.getByUserId',
        action: () async {
          final response = await _client
              .from('prestataire_profiles')
              .select()
              .eq('user_id', userId)
              .maybeSingle();
          if (response == null) return null;
          return PrestataireProfile.fromJson(
            Map<String, dynamic>.from(response),
          );
        },
      );

  Future<String> upsert(PrestataireUpsertData prestataire) =>
      SupabaseErrorHandler.run(
        operation: 'prestataire.upsert',
        action: () async {
          final response = await _client
              .from('prestataire_profiles')
              .upsert({
                'user_id': prestataire.userId,
                'nom_salon': prestataire.nomSalon.trim(),
                'bio': prestataire.bio.trim(),
                'ville': prestataire.ville.trim(),
                if (prestataire.adresse != null &&
                    prestataire.adresse!.trim().isNotEmpty)
                  'adresse': prestataire.adresse!.trim(),
                if (prestataire.codePostal != null &&
                    prestataire.codePostal!.trim().isNotEmpty)
                  'code_postal': prestataire.codePostal!.trim(),
                if (prestataire.pays != null &&
                    prestataire.pays!.trim().isNotEmpty)
                  'pays': prestataire.pays!.trim().toUpperCase(),
                if (prestataire.nomAffiche != null &&
                    prestataire.nomAffiche!.trim().isNotEmpty)
                  'nom_affiche': prestataire.nomAffiche!.trim(),
                if (prestataire.lieuTravail != null)
                  'lieu_travail': prestataire.lieuTravail!.value,
                if (prestataire.anneesExperience != null &&
                    prestataire.anneesExperience!.trim().isNotEmpty)
                  'annees_experience': prestataire.anneesExperience!.trim(),
                if (prestataire.experienceProfessionnelle != null &&
                    prestataire.experienceProfessionnelle!.trim().isNotEmpty)
                  'experience_professionnelle':
                      prestataire.experienceProfessionnelle!.trim(),
                if (prestataire.description != null &&
                    prestataire.description!.trim().isNotEmpty)
                  'description': prestataire.description!.trim(),
                'confort_client': prestataire.confortClient,
                'conditions_service': prestataire.conditionsService,
                if (prestataire.latitude != null)
                  'latitude': prestataire.latitude,
                if (prestataire.longitude != null)
                  'longitude': prestataire.longitude,
              }, onConflict: 'user_id')
              .select('id')
              .single();

          return Map<String, dynamic>.from(response as Map)['id'] as String;
        },
      );

  Future<List<PrestataireProfile>> getNearby(
    double lat,
    double lng,
    double rayonKm, {
    int limit = 16,
    int fetchCap = 48,
  }) => SupabaseErrorHandler.run(
    operation: 'prestataire.getNearby',
    action: () async {
      final response = await _applyCatalogVisibilityQuery(
        _client.from('prestataire_profiles').select(),
      ).order('created_at', ascending: false).limit(fetchCap);

      final rows = response as List<dynamic>;
      final allProfiles = rows
          .map((e) => PrestataireProfile.fromJson(e as Map<String, dynamic>))
          .toList();
      final all = await _keepCatalogVisibleProfiles(allProfiles);

      double distanceKm(PrestataireProfile p) {
        final la = p.latitude;
        final lo = p.longitude;
        if (la == null || lo == null) return double.infinity;
        return haversineDistanceKm(lat1: lat, lon1: lng, lat2: la, lon2: lo);
      }

      final withGeo = all.where((p) {
        final d = distanceKm(p);
        return !d.isInfinite && d <= rayonKm;
      }).toList()..sort((a, b) => distanceKm(a).compareTo(distanceKm(b)));

      final out = <PrestataireProfile>[];
      final seen = <String>{};

      void addUnique(PrestataireProfile p) {
        if (out.length >= limit) return;
        if (seen.add(p.id)) out.add(p);
      }

      for (final p in withGeo) {
        addUnique(p);
      }
      for (final p in all) {
        addUnique(p);
      }

      return out;
    },
  );

  Future<List<PrestataireProfile>> getBestRated({
    int limit = 16,
  }) => SupabaseErrorHandler.run(
    operation: 'prestataire.getBestRated',
    action: () async {
      final response = await _applyCatalogVisibilityQuery(
        _client.from('prestataire_profiles').select(),
      )
          .not('note_moyenne', 'is', null)
          .order('note_moyenne', ascending: false)
          .limit(limit);

      final profiles = (response as List<dynamic>)
          .map((e) => PrestataireProfile.fromJson(e as Map<String, dynamic>))
          .where((p) => p.noteMoyenne != null)
          .toList();
      return _keepCatalogVisibleProfiles(profiles);
    },
  );

  Future<List<ServiceCategory>> getServiceCategories() =>
      SupabaseErrorHandler.run(
        operation: 'prestataire.getServiceCategories',
        action: () async {
          final response = await _client
              .from('categories_service')
              .select('id, nom, icone')
              .order('nom');

          return (response as List<dynamic>)
              .map((row) {
                final m = Map<String, dynamic>.from(row as Map);
                return ServiceCategory(
                  id: m['id'] as String,
                  nom: (m['nom'] as String?)?.trim() ?? '',
                  icone: m['icone'] as String?,
                );
              })
              .where((c) => c.nom.isNotEmpty)
              .toList();
        },
      );

  Future<List<String>> getSpecialtyNames(String prestataireId) async {
    final data = await getSpecialtyDataForPrestataires([prestataireId]);
    return List<String>.from(
      data.namesByPrestataire[prestataireId] ?? const [],
    );
  }

  Future<void> replaceSpecialties({
    required String prestataireId,
    required Set<String> categoryIds,
  }) => SupabaseErrorHandler.run(
    operation: 'prestataire.replaceSpecialties',
    action: () async {
      await _client
          .from('prestataire_specialites')
          .delete()
          .eq('prestataire_id', prestataireId);
      if (categoryIds.isEmpty) return;

      await _client
          .from('prestataire_specialites')
          .insert(
            categoryIds
                .map(
                  (id) => {'prestataire_id': prestataireId, 'categorie_id': id},
                )
                .toList(),
          );
    },
  );

  Future<PrestataireSpecialtyData> getSpecialtyDataForPrestataires(
    List<String> prestataireIds,
  ) async {
    if (prestataireIds.isEmpty) return const PrestataireSpecialtyData();

    return SupabaseErrorHandler.run(
      operation: 'prestataire.getSpecialtyDataForPrestataires',
      action: () async {
        final response = await _client
            .from('prestataire_specialites')
            .select('prestataire_id, categorie_id, categories_service(nom)')
            .inFilter('prestataire_id', prestataireIds);

        final namesByPrestataire = <String, List<String>>{};
        final categoryIdsByPrestataire = <String, Set<String>>{};
        for (final row in response as List<dynamic>) {
          final m = Map<String, dynamic>.from(row as Map);
          final pid = m['prestataire_id'] as String;
          final cid = m['categorie_id'] as String?;
          if (cid != null) {
            categoryIdsByPrestataire.putIfAbsent(pid, () => {}).add(cid);
          }
          final nested = m['categories_service'];
          final nom = nested is Map<String, dynamic>
              ? nested['nom'] as String?
              : null;
          if (nom != null && nom.trim().isNotEmpty) {
            namesByPrestataire.putIfAbsent(pid, () => []).add(nom.trim());
          }
        }

        return PrestataireSpecialtyData(
          namesByPrestataire: namesByPrestataire,
          categoryIdsByPrestataire: categoryIdsByPrestataire,
        );
      },
    );
  }

  Future<List<PrestataireProfile>> getNearbyFromReference({
    double rayonKm = double.infinity,
    int limit = 16,
    int fetchCap = 48,
  }) {
    return getNearby(
      kDiscoveryReferenceLatitude,
      kDiscoveryReferenceLongitude,
      rayonKm,
      limit: limit,
      fetchCap: fetchCap,
    );
  }

  List<PrestataireProfile> _applyFilters({
    required List<PrestataireProfile> profiles,
    required PrestataireFilters filters,
    required Map<String, List<String>> specialtyNamesByPrestataire,
    required Map<String, Set<String>> categoryIdsByPrestataire,
  }) {
    final q = filters.query?.trim().toLowerCase();
    final categoryId = filters.categoryId?.trim();
    return profiles.where((p) {
      if (categoryId != null &&
          categoryId.isNotEmpty &&
          !(categoryIdsByPrestataire[p.id]?.contains(categoryId) ?? false)) {
        return false;
      }
      if (q == null || q.isEmpty) return true;
      bool has(String? s) => (s ?? '').toLowerCase().contains(q);
      return has(p.nomSalon) ||
          has(p.ville) ||
          has(p.bio) ||
          (specialtyNamesByPrestataire[p.id] ?? const []).any(
            (s) => s.toLowerCase().contains(q),
          );
    }).toList();
  }

  Future<Map<String, int>> _reviewCountsForPrestataires(
    List<String> prestataireIds,
  ) async {
    if (prestataireIds.isEmpty) return {};
    final response = await _client
        .from('avis')
        .select('prestataire_id')
        .inFilter('prestataire_id', prestataireIds);
    final counts = <String, int>{};
    for (final raw in response as List<dynamic>) {
      final row = Map<String, dynamic>.from(raw as Map);
      final id = row['prestataire_id'] as String?;
      if (id == null || id.isEmpty) continue;
      counts[id] = (counts[id] ?? 0) + 1;
    }
    return counts;
  }
}

class PrestataireSpecialtyData {
  const PrestataireSpecialtyData({
    this.namesByPrestataire = const {},
    this.categoryIdsByPrestataire = const {},
  });

  final Map<String, List<String>> namesByPrestataire;
  final Map<String, Set<String>> categoryIdsByPrestataire;
}

