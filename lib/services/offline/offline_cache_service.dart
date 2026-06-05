import 'dart:convert';

import '../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../core/models/domain/catalog/service_category.dart';
import '../../core/models/domain/user/prestataire_profile.dart';
import '../../core/models/domain/user/user_profile.dart';
import '../../features/booking/models/client_reservation_summary.dart';
import '../../features/prestataire/models/prestataire_dashboard_data.dart';
import '../../features/prestataire/models/prestataire_reservation_item.dart';
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

  Future<void> saveUserProfile(UserProfile profile) =>
      _write(OfflineCacheKeys.userProfile, profile.toJson());

  UserProfile? readUserProfile() =>
      OfflineCacheCodec.decodeUserProfile(_read(OfflineCacheKeys.userProfile));

  Future<void> saveClientReservations(List<ClientReservationSummary> list) =>
      _write(
        OfflineCacheKeys.clientReservations,
        OfflineCacheCodec.encodeClientReservations(list),
      );

  List<ClientReservationSummary> readClientReservations() =>
      OfflineCacheCodec.decodeClientReservations(
        _read(OfflineCacheKeys.clientReservations),
      );

  Future<void> savePrestataireDashboard(PrestataireDashboardData data) =>
      _write(
        OfflineCacheKeys.prestataireDashboard,
        OfflineCacheCodec.encodeDashboard(data),
      );

  PrestataireDashboardData readPrestataireDashboard() =>
      OfflineCacheCodec.decodeDashboard(_read(OfflineCacheKeys.prestataireDashboard));

  Future<void> savePrestataireAgenda(List<PrestataireReservationItem> list) =>
      _write(
        OfflineCacheKeys.prestataireAgenda,
        OfflineCacheCodec.encodeAgendaItems(list),
      );

  List<PrestataireReservationItem> readPrestataireAgenda() =>
      OfflineCacheCodec.decodeAgendaItems(_read(OfflineCacheKeys.prestataireAgenda));
}

