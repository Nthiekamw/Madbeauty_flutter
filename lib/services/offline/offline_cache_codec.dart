import '../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../core/models/domain/catalog/service_category.dart';
import '../../core/models/domain/user/prestataire_profile.dart';
import '../../core/models/domain/user/user_profile.dart';
import '../../features/booking/models/client_reservation_summary.dart';
import '../../features/prestataire/models/prestataire_dashboard_data.dart';
import '../../features/prestataire/models/prestataire_reservation_item.dart';

/// Sérialisation JSON pour le cache hors ligne.
abstract final class OfflineCacheCodec {
  OfflineCacheCodec._();

  static List<PrestataireProfile> decodePrestataireList(Object? raw) {
    if (raw is! List) return const [];
    return raw
        .whereType<Map>()
        .map((e) => PrestataireProfile.fromJson(Map<String, dynamic>.from(e)))
        .toList();
  }

  static List<Map<String, dynamic>> encodePrestataireList(
    List<PrestataireProfile> list,
  ) =>
      list.map((e) => e.toJson()).toList();

  static UserProfile? decodeUserProfile(Object? raw) {
    if (raw is! Map) return null;
    return UserProfile.fromJson(Map<String, dynamic>.from(raw));
  }

  static List<ClientReservationSummary> decodeClientReservations(Object? raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((m) {
      final map = Map<String, dynamic>.from(m);
      return ClientReservationSummary(
        id: map['id'] as String? ?? '',
        dateHeure: DateTime.parse(map['dateHeure'] as String),
        statut: map['statut'] as String? ?? '',
        serviceName: map['serviceName'] as String?,
        prestataireId: map['prestataireId'] as String?,
        prestataireName: map['prestataireName'] as String?,
        prestataireAvatarUrl: map['prestataireAvatarUrl'] as String?,
      );
    }).toList();
  }

  static List<Map<String, dynamic>> encodeClientReservations(
    List<ClientReservationSummary> list,
  ) =>
      list
          .map(
            (e) => {
              'id': e.id,
              'dateHeure': e.dateHeure.toIso8601String(),
              'statut': e.statut,
              'serviceName': e.serviceName,
              'prestataireId': e.prestataireId,
              'prestataireName': e.prestataireName,
              'prestataireAvatarUrl': e.prestataireAvatarUrl,
            },
          )
          .toList();

  static PrestataireDashboardData decodeDashboard(Object? raw) {
    if (raw is! Map) {
      return const PrestataireDashboardData(
        pending: [],
        todayConfirmed: [],
        weekConfirmed: [],
      );
    }
    final map = Map<String, dynamic>.from(raw);
    return PrestataireDashboardData(
      pending: _decodeReservationItems(map['pending']),
      todayConfirmed: _decodeReservationItems(map['todayConfirmed']),
      weekConfirmed: _decodeReservationItems(map['weekConfirmed']),
    );
  }

  static Map<String, dynamic> encodeDashboard(PrestataireDashboardData data) =>
      {
        'pending': _encodeReservationItems(data.pending),
        'todayConfirmed': _encodeReservationItems(data.todayConfirmed),
        'weekConfirmed': _encodeReservationItems(data.weekConfirmed),
      };

  static List<PrestataireReservationItem> _decodeReservationItems(Object? raw) {
    if (raw is! List) return const [];
    return raw.whereType<Map>().map((m) {
      final map = Map<String, dynamic>.from(m);
      return PrestataireReservationItem(
        id: map['id'] as String? ?? '',
        dateHeure: DateTime.parse(map['dateHeure'] as String),
        statut: map['statut'] as String? ?? '',
        serviceName: map['serviceName'] as String? ?? '',
        clientName: map['clientName'] as String? ?? '',
        clientId: map['clientId'] as String?,
        notesClient: map['notesClient'] as String?,
        notesPrestataire: map['notesPrestataire'] as String?,
      );
    }).toList();
  }

  static List<PrestataireReservationItem> decodeAgendaItems(Object? raw) =>
      _decodeReservationItems(raw);

  static List<Map<String, dynamic>> encodeAgendaItems(
    List<PrestataireReservationItem> list,
  ) =>
      _encodeReservationItems(list);

  static List<Map<String, dynamic>> _encodeReservationItems(
    List<PrestataireReservationItem> list,
  ) =>
      list
          .map(
            (e) => {
              'id': e.id,
              'dateHeure': e.dateHeure.toIso8601String(),
              'statut': e.statut,
              'serviceName': e.serviceName,
              'clientName': e.clientName,
              'clientId': e.clientId,
              'notesClient': e.notesClient,
              'notesPrestataire': e.notesPrestataire,
            },
          )
          .toList();

  static Map<String, dynamic> encodeCatalogSnapshot({
    required List<ServiceCategory> categories,
    required List<PrestataireCatalogEntry> entries,
  }) =>
      {
        'categories': categories
            .map((c) => {'id': c.id, 'nom': c.nom, 'icone': c.icone})
            .toList(),
        'entries': entries.map(_encodeCatalogEntry).toList(),
      };

  static ({List<ServiceCategory> categories, List<PrestataireCatalogEntry> entries})
  decodeCatalogSnapshot(Object? raw) {
    if (raw is! Map) {
      return (categories: const [], entries: const []);
    }
    final map = Map<String, dynamic>.from(raw);
    final categories = (map['categories'] as List? ?? const [])
        .whereType<Map>()
        .map((c) {
          final m = Map<String, dynamic>.from(c);
          return ServiceCategory(
            id: m['id'] as String? ?? '',
            nom: m['nom'] as String? ?? '',
            icone: m['icone'] as String?,
          );
        })
        .toList();
    final entries = (map['entries'] as List? ?? const [])
        .whereType<Map>()
        .map((e) => _decodeCatalogEntry(Map<String, dynamic>.from(e)))
        .toList();
    return (categories: categories, entries: entries);
  }

  static Map<String, dynamic> _encodeCatalogEntry(PrestataireCatalogEntry e) =>
      {
        'profile': e.profile.toJson(),
        'avatarUrl': e.avatarUrl,
        'userNom': e.userNom,
        'userPrenom': e.userPrenom,
        'specialtyNames': e.specialtyNames,
        'specialtyCategoryIds': e.specialtyCategoryIds,
      };

  static PrestataireCatalogEntry _decodeCatalogEntry(Map<String, dynamic> map) {
    return PrestataireCatalogEntry(
      profile: PrestataireProfile.fromJson(
        Map<String, dynamic>.from(map['profile'] as Map),
      ),
      avatarUrl: map['avatarUrl'] as String?,
      userNom: map['userNom'] as String?,
      userPrenom: map['userPrenom'] as String?,
      specialtyNames: (map['specialtyNames'] as List? ?? const [])
          .map((e) => '$e')
          .toList(),
      specialtyCategoryIds: (map['specialtyCategoryIds'] as List? ?? const [])
          .map((e) => '$e')
          .toList(),
    );
  }
}
