import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/geo/discovery_reference.dart';
import '../../core/geo/geo_utils.dart';
import '../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../core/models/domain/catalog/service_category.dart';
import '../../core/models/domain/user/prestataire_profile.dart';

/// Lecture du catalogue prestataires (PostgREST + RLS `authenticated`).
class PrestataireCatalogRepository {
  PrestataireCatalogRepository(this._client);

  final SupabaseClient _client;

  /// Prestataires « proches » : d’abord ceux géolocalisés, triés par distance
  /// depuis [kDiscoveryReferenceLatitude] / [kDiscoveryReferenceLongitude], puis
  /// complétés par les autres profils récents si besoin.
  Future<List<PrestataireProfile>> fetchNearbyPrestataires({
    int limit = 16,
    int fetchCap = 48,
  }) async {
    final response = await _client
        .from('prestataire_profiles')
        .select()
        .order('created_at', ascending: false)
        .limit(fetchCap);

    final rows = response as List<dynamic>;
    final all = rows
        .map((e) => PrestataireProfile.fromJson(e as Map<String, dynamic>))
        .toList();

    double distanceKm(PrestataireProfile p) {
      final la = p.latitude;
      final lo = p.longitude;
      if (la == null || lo == null) return double.infinity;
      return haversineDistanceKm(
        lat1: kDiscoveryReferenceLatitude,
        lon1: kDiscoveryReferenceLongitude,
        lat2: la,
        lon2: lo,
      );
    }

    final withGeo =
        all.where((p) => p.latitude != null && p.longitude != null).toList()
          ..sort((a, b) => distanceKm(a).compareTo(distanceKm(b)));

    final seen = <String>{};
    final out = <PrestataireProfile>[];

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
  }

  /// Prestataires triés par [PrestataireProfile.noteMoyenne] décroissante ;
  /// les notes nulles sont en dernier, puis tri par [PrestataireProfile.createdAt].
  Future<List<PrestataireProfile>> fetchBestRatedPrestataires({
    int limit = 16,
    int fetchCap = 48,
  }) async {
    final response = await _client
        .from('prestataire_profiles')
        .select()
        .limit(fetchCap);

    final rows = response as List<dynamic>;
    final all = rows
        .map((e) => PrestataireProfile.fromJson(e as Map<String, dynamic>))
        .toList();

    int compareByNoteThenDate(PrestataireProfile a, PrestataireProfile b) {
      final na = a.noteMoyenne;
      final nb = b.noteMoyenne;
      if (na != null && nb != null && na != nb) {
        return nb.compareTo(na);
      }
      if (na != null && nb == null) return -1;
      if (na == null && nb != null) return 1;
      return b.createdAt.compareTo(a.createdAt);
    }

    all.sort(compareByNoteThenDate);
    return all.take(limit).toList();
  }

  /// Catégories de services (chips filtre) — ordre alphabétique sur [ServiceCategory.nom].
  Future<List<ServiceCategory>> fetchServiceCategories() async {
    final response = await _client
        .from('categories_service')
        .select('id, nom, icone')
        .order('nom');

    return (response as List<dynamic>).map((row) {
      final m = Map<String, dynamic>.from(row as Map);
      return ServiceCategory(
        id: m['id'] as String,
        nom: (m['nom'] as String?)?.trim() ?? '',
        icone: m['icone'] as String?,
      );
    }).where((c) => c.nom.isNotEmpty).toList();
  }

  /// Une fiche prestataire par identifiant [id] (`prestataire_profiles.id`).
  Future<PrestataireProfile?> fetchPrestataireById(String id) async {
    final response = await _client
        .from('prestataire_profiles')
        .select()
        .eq('id', id)
        .maybeSingle();
    if (response == null) return null;
    return PrestataireProfile.fromJson(Map<String, dynamic>.from(response));
  }

  /// Catalogue exploration : profils + avatars (`user_profiles`) + spécialités.
  ///
  /// Pagination PostgREST : [offset] 0-based, [limit] lignes (défaut 10).
  Future<List<PrestataireCatalogEntry>> fetchCatalogEntries({
    int limit = 10,
    int offset = 0,
  }) async {
    final to = offset + limit - 1;
    final profilesRes = await _client
        .from('prestataire_profiles')
        .select()
        .order('created_at', ascending: false)
        .range(offset, to);

    final profiles = (profilesRes as List<dynamic>)
        .map((e) => PrestataireProfile.fromJson(e as Map<String, dynamic>))
        .toList();
    if (profiles.isEmpty) return [];

    final userIds = profiles.map((p) => p.userId).toList();
    final prestataireIds = profiles.map((p) => p.id).toList();

    final usersRes = await _client
        .from('user_profiles')
        .select('user_id, avatar_url, nom, prenom')
        .inFilter('user_id', userIds);

    final userById = <String, Map<String, dynamic>>{};
    for (final row in usersRes as List<dynamic>) {
      final m = Map<String, dynamic>.from(row as Map);
      userById[m['user_id'] as String] = m;
    }

    final specRes = await _client
        .from('prestataire_specialites')
        .select('prestataire_id, categorie_id, categories_service(nom)')
        .inFilter('prestataire_id', prestataireIds);

    final specsByPrest = <String, List<String>>{};
    final specIdsByPrest = <String, Set<String>>{};
    for (final row in specRes as List<dynamic>) {
      final m = Map<String, dynamic>.from(row as Map);
      final pid = m['prestataire_id'] as String;
      final cid = m['categorie_id'] as String?;
      if (cid != null) {
        specIdsByPrest.putIfAbsent(pid, () => {}).add(cid);
      }
      final nested = m['categories_service'];
      final nom = nested is Map<String, dynamic>
          ? nested['nom'] as String?
          : null;
      if (nom != null && nom.trim().isNotEmpty) {
        specsByPrest.putIfAbsent(pid, () => []).add(nom.trim());
      }
    }

    return profiles
        .map((p) {
          final u = userById[p.userId];
          final rawUrl = u?['avatar_url'] as String?;
          return PrestataireCatalogEntry(
            profile: p,
            avatarUrl: (rawUrl != null && rawUrl.trim().isNotEmpty)
                ? rawUrl.trim()
                : null,
            userNom: u?['nom'] as String?,
            userPrenom: u?['prenom'] as String?,
            specialtyNames: List<String>.from(specsByPrest[p.id] ?? const []),
            specialtyCategoryIds:
                List<String>.from(specIdsByPrest[p.id] ?? const <String>{}),
          );
        })
        .toList();
  }
}
