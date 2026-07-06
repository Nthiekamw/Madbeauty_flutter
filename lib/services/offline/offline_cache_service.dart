import 'dart:convert';

import '../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../core/models/domain/catalog/service_category.dart';
import '../../core/models/domain/user/prestataire_profile.dart';
import '../../core/models/domain/user/user_profile.dart';
import '../../core/models/domain/booking/client_reservation_summary.dart';
import '../../core/models/domain/booking/prestataire_reservation_item.dart';
import '../../core/models/domain/prestataire/prestataire_dashboard_data.dart';
import '../storage/local_cache_service.dart';
import 'offline_cache_codec.dart';

/// Clés SharedPreferences pour les données consultables hors ligne.
abstract final class OfflineCacheKeys {
  OfflineCacheKeys._();

  static const nearbyPrestataires = 'offline.nearby_prestataires';
  static const topRatedPrestataires = 'offline.top_rated_prestataires';
  static const listingCatalog = 'offline.listing_catalog';
  static const userProfile = 'offline.user_profile';
  static const clientReservations = 'offline.client_reservations';
  static const prestataireDashboard = 'offline.prestataire_dashboard';
  static const prestataireAgenda = 'offline.prestataire_agenda';

  static String forUser(String baseKey, String userId) => '$baseKey.$userId';
}

class OfflineCacheService {
  OfflineCacheService._();

  static OfflineCacheService get instance => OfflineCacheService._();

  Future<void> _write(String key, Object value) async {
    await LocalCacheService.instance.setString(key, jsonEncode(value));
  }

  Object? _read(String key) {
    final raw = LocalCacheService.instance.getString(key);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw);
    } catch (_) {
      return null;
    }
  }

  Future<void> saveNearbyPrestataires(List<PrestataireProfile> list) =>
      _write(
        OfflineCacheKeys.nearbyPrestataires,
        OfflineCacheCodec.encodePrestataireList(list),
      );

  List<PrestataireProfile> readNearbyPrestataires() =>
      OfflineCacheCodec.decodePrestataireList(_read(OfflineCacheKeys.nearbyPrestataires));

  Future<void> saveTopRatedPrestataires(List<PrestataireProfile> list) =>
      _write(
        OfflineCacheKeys.topRatedPrestataires,
        OfflineCacheCodec.encodePrestataireList(list),
      );

  List<PrestataireProfile> readTopRatedPrestataires() =>
      OfflineCacheCodec.decodePrestataireList(
        _read(OfflineCacheKeys.topRatedPrestataires),
      );

  Future<void> saveListingCatalog({
    required List<ServiceCategory> categories,
    required List<PrestataireCatalogEntry> entries,
  }) =>
      _write(
        OfflineCacheKeys.listingCatalog,
        OfflineCacheCodec.encodeCatalogSnapshot(
          categories: categories,
          entries: entries,
        ),
      );

  ({List<ServiceCategory> categories, List<PrestataireCatalogEntry> entries})
  readListingCatalog() =>
      OfflineCacheCodec.decodeCatalogSnapshot(_read(OfflineCacheKeys.listingCatalog));

  Future<void> saveUserProfile(String userId, UserProfile profile) =>
      _write(
        OfflineCacheKeys.forUser(OfflineCacheKeys.userProfile, userId),
        profile.toJson(),
      );

  UserProfile? readUserProfile(String userId) =>
      OfflineCacheCodec.decodeUserProfile(
        _read(OfflineCacheKeys.forUser(OfflineCacheKeys.userProfile, userId)),
      );

  Future<void> saveClientReservations(
    String userId,
    List<ClientReservationSummary> list,
  ) =>
      _write(
        OfflineCacheKeys.forUser(OfflineCacheKeys.clientReservations, userId),
        OfflineCacheCodec.encodeClientReservations(list),
      );

  List<ClientReservationSummary> readClientReservations(String userId) =>
      OfflineCacheCodec.decodeClientReservations(
        _read(
          OfflineCacheKeys.forUser(OfflineCacheKeys.clientReservations, userId),
        ),
      );

  Future<void> savePrestataireDashboard(
    String userId,
    PrestataireDashboardData data,
  ) =>
      _write(
        OfflineCacheKeys.forUser(OfflineCacheKeys.prestataireDashboard, userId),
        OfflineCacheCodec.encodeDashboard(data),
      );

  PrestataireDashboardData readPrestataireDashboard(String userId) =>
      OfflineCacheCodec.decodeDashboard(
        _read(
          OfflineCacheKeys.forUser(OfflineCacheKeys.prestataireDashboard, userId),
        ),
      );

  Future<void> savePrestataireAgenda(
    String userId,
    List<PrestataireReservationItem> list,
  ) =>
      _write(
        OfflineCacheKeys.forUser(OfflineCacheKeys.prestataireAgenda, userId),
        OfflineCacheCodec.encodeAgendaItems(list),
      );

  List<PrestataireReservationItem> readPrestataireAgenda(String userId) =>
      OfflineCacheCodec.decodeAgendaItems(
        _read(OfflineCacheKeys.forUser(OfflineCacheKeys.prestataireAgenda, userId)),
      );

  /// Anciennes clés globales (pré-scope utilisateur) — à purger à la déconnexion.
  Future<void> clearLegacyUserScopedKeys() async {
    final legacy = [
      OfflineCacheKeys.userProfile,
      OfflineCacheKeys.clientReservations,
      OfflineCacheKeys.prestataireDashboard,
      OfflineCacheKeys.prestataireAgenda,
    ];
    for (final key in legacy) {
      await LocalCacheService.instance.remove(key);
    }
  }

  /// Données privées d'un compte (dashboard, agenda, réservations, profil).
  Future<void> clearUserScopedCache(String userId) async {
    final keys = [
      OfflineCacheKeys.forUser(OfflineCacheKeys.userProfile, userId),
      OfflineCacheKeys.forUser(OfflineCacheKeys.clientReservations, userId),
      OfflineCacheKeys.forUser(OfflineCacheKeys.prestataireDashboard, userId),
      OfflineCacheKeys.forUser(OfflineCacheKeys.prestataireAgenda, userId),
    ];
    for (final key in keys) {
      await LocalCacheService.instance.remove(key);
    }
  }
}

