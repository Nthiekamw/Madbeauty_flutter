import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/booking/client_reservation_summary.dart';
import '../../../core/models/domain/booking/prestataire_reservation_item.dart';
import '../../../core/models/domain/booking/reservation.dart';
import '../../../core/models/domain/serialization/supabase_domain_codec.dart';
import '../../../core/models/domain/prestataire/prestataire_analytics_reservation.dart';
import '../profile/profile_service.dart';

abstract final class BookingMappers {
  BookingMappers._();

  static DateTime startOfMinuteLocal(DateTime dateHeure) {
    final l = dateHeure.toLocal();
    return DateTime(l.year, l.month, l.day, l.hour, l.minute);
  }

  static String normalizeStatut(Object? raw) {
    if (raw is! String) return '';
    return raw.trim().toLowerCase().replaceAll('é', 'e');
  }

  static List<Reservation> decodeReservationRows(Object response) {
    return (response as List<dynamic>)
        .map(
          (raw) => SupabaseDomainCodec.reservation(
            Map<String, dynamic>.from(raw as Map),
          ),
        )
        .toList();
  }

  static ClientReservationSummary clientReservationSummaryFromRow(
    Map<String, dynamic> map,
    Object? service,
    Object? prestataire,
  ) {
    final paidRaw = map['paid_at'] as String?;
    final duree = service is Map
        ? (service['duree_minutes'] as num?)?.toInt() ?? 60
        : 60;
    return ClientReservationSummary(
      id: map['id'] as String,
      dateHeure: DateTime.parse(map['date_heure'] as String).toLocal(),
      statut: map['statut'] as String,
      serviceName: service is Map ? service['nom'] as String? : null,
      prestataireId: map['prestataire_id'] as String?,
      prestataireName:
          prestataire is Map ? prestataire['nom_salon'] as String? : null,
      serviceId: map['service_id'] as String?,
      notesPrestataire: map['notes_prestataire'] as String?,
      durationMinutes: duree,
      amountCents: (map['amount_cents'] as num?)?.toInt(),
      currency: map['currency'] as String?,
      paidAt: paidRaw != null ? DateTime.tryParse(paidRaw)?.toLocal() : null,
      paymentStatus: map['payment_status'] as String?,
      paymentMode: map['payment_mode'] as String?,
      servicePriceCents: (map['service_price_cents'] as num?)?.toInt(),
      platformFeeCents: (map['platform_fee_cents'] as num?)?.toInt(),
      prestataireAmountCents:
          (map['prestataire_amount_cents'] as num?)?.toInt(),
    );
  }

  static PrestataireReservationItem prestataireReservationItemFromRow(
    Map<String, dynamic> map,
    Object? serviceRow,
    String clientName, {
    String? clientPrenom,
    String? clientNom,
    String? clientAvatarUrl,
  }) {
    final duree = serviceRow is Map
        ? (serviceRow['duree_minutes'] as num?)?.toInt() ?? 60
        : 60;
    final serviceName =
        serviceRow is Map ? (serviceRow['nom'] as String?)?.trim() ?? '' : '';
    return PrestataireReservationItem(
      id: map['id'] as String,
      dateHeure: DateTime.parse(map['date_heure'] as String).toLocal(),
      statut: map['statut'] as String,
      serviceName: serviceName.isEmpty
          ? DiscPrestaDash.unknownService
          : serviceName,
      clientName: clientName.isEmpty ? DiscPrestaDash.unknownClient : clientName,
      clientPrenom: clientPrenom,
      clientNom: clientNom,
      clientId: map['client_id'] as String?,
      clientAvatarUrl: clientAvatarUrl,
      notesClient: map['notes_client'] as String?,
      notesPrestataire: map['notes_prestataire'] as String?,
      amountCents: (map['amount_cents'] as num?)?.toInt(),
      paymentStatus: map['payment_status'] as String?,
      paymentMode: map['payment_mode'] as String?,
      servicePriceCents: (map['service_price_cents'] as num?)?.toInt(),
      platformFeeCents: (map['platform_fee_cents'] as num?)?.toInt(),
      prestataireAmountCents:
          (map['prestataire_amount_cents'] as num?)?.toInt(),
      durationMinutes: duree,
    );
  }

  static PrestataireAnalyticsReservation analyticsReservationFromRow(
    Map<String, dynamic> map,
  ) {
    final service = map['services_beaute'];
    final prix = service is Map
        ? (service['prix'] as num?)?.toDouble() ?? 0
        : 0.0;
    return PrestataireAnalyticsReservation(
      dateHeure: DateTime.parse(map['date_heure'] as String).toLocal(),
      statut: map['statut'] as String? ?? '',
      amountCents: (map['amount_cents'] as num?)?.toInt(),
      paymentStatus: map['payment_status'] as String?,
      servicePriceEur: prix,
    );
  }

  static Future<List<ClientReservationSummary>> enrichClientSummariesWithAvatars(
    List<dynamic> rawRows,
    List<ClientReservationSummary> summaries,
    ProfileService? profileService,
  ) async {
    if (profileService == null || summaries.isEmpty) return summaries;

    final userIds = <String>[];
    for (final raw in rawRows) {
      final map = Map<String, dynamic>.from(raw as Map);
      final prestataire = map['prestataire_profiles'];
      final userId =
          prestataire is Map ? prestataire['user_id'] as String? : null;
      if (userId != null && userId.isNotEmpty) userIds.add(userId);
    }

    final unique = userIds.toSet().toList();
    if (unique.isEmpty) return summaries;

    final profileMap = await profileService.getByUserIds(unique);
    return List.generate(summaries.length, (i) {
      final summary = summaries[i];
      final row = Map<String, dynamic>.from(rawRows[i] as Map);
      final prestataire = row['prestataire_profiles'];
      final uid = prestataire is Map
          ? prestataire['user_id'] as String?
          : null;
      final avatarUrl = uid != null ? profileMap[uid]?.avatarUrl : null;
      return ClientReservationSummary(
        id: summary.id,
        dateHeure: summary.dateHeure,
        statut: summary.statut,
        serviceName: summary.serviceName,
        prestataireId: summary.prestataireId,
        prestataireName: summary.prestataireName,
        prestataireAvatarUrl: avatarUrl?.trim().isNotEmpty == true
            ? avatarUrl!.trim()
            : null,
        amountCents: summary.amountCents,
        currency: summary.currency,
        paidAt: summary.paidAt,
        paymentStatus: summary.paymentStatus,
        paymentMode: summary.paymentMode,
        servicePriceCents: summary.servicePriceCents,
        platformFeeCents: summary.platformFeeCents,
        prestataireAmountCents: summary.prestataireAmountCents,
        serviceId: summary.serviceId,
        notesPrestataire: summary.notesPrestataire,
        durationMinutes: summary.durationMinutes,
      );
    });
  }

  static Future<ClientReservationSummary> enrichClientDetailWithAvatar(
    ClientReservationSummary summary,
    String? prestataireUserId,
    ProfileService? profileService,
  ) async {
    final profileSvc = profileService;
    if (profileSvc == null ||
        prestataireUserId == null ||
        prestataireUserId.isEmpty) {
      return summary;
    }

    final profileMap = await profileSvc.getByUserIds([prestataireUserId]);
    final avatar = profileMap[prestataireUserId]?.avatarUrl;
    if (avatar?.trim().isNotEmpty != true) return summary;

    return ClientReservationSummary(
      id: summary.id,
      dateHeure: summary.dateHeure,
      statut: summary.statut,
      serviceName: summary.serviceName,
      prestataireId: summary.prestataireId,
      prestataireName: summary.prestataireName,
      prestataireAvatarUrl: avatar!.trim(),
      amountCents: summary.amountCents,
      currency: summary.currency,
      paidAt: summary.paidAt,
      paymentStatus: summary.paymentStatus,
      paymentMode: summary.paymentMode,
      servicePriceCents: summary.servicePriceCents,
      platformFeeCents: summary.platformFeeCents,
      prestataireAmountCents: summary.prestataireAmountCents,
      serviceId: summary.serviceId,
      notesPrestataire: summary.notesPrestataire,
      durationMinutes: summary.durationMinutes,
    );
  }

  static Future<List<PrestataireReservationItem>>
      enrichPrestataireItemsWithProfiles(
    List<dynamic> rawRows,
    List<PrestataireReservationItem> items,
    ProfileService? profileService,
  ) async {
    if (profileService == null || items.isEmpty) {
      return items
          .map(
            (e) => PrestataireReservationItem(
              id: e.id,
              dateHeure: e.dateHeure,
              statut: e.statut,
              serviceName: e.serviceName.isEmpty
                  ? DiscPrestaDash.unknownService
                  : e.serviceName,
              clientName: DiscPrestaDash.unknownClient,
              clientId: e.clientId,
              clientAvatarUrl: e.clientAvatarUrl,
              notesClient: e.notesClient,
              notesPrestataire: e.notesPrestataire,
              amountCents: e.amountCents,
              paymentStatus: e.paymentStatus,
              paymentMode: e.paymentMode,
              servicePriceCents: e.servicePriceCents,
              platformFeeCents: e.platformFeeCents,
              prestataireAmountCents: e.prestataireAmountCents,
              durationMinutes: e.durationMinutes,
            ),
          )
          .toList();
    }

    final userIds = <String>[];
    for (final raw in rawRows) {
      final map = Map<String, dynamic>.from(raw as Map);
      final client = map['client_profiles'];
      final userId = client is Map ? client['user_id'] as String? : null;
      if (userId != null && userId.isNotEmpty) userIds.add(userId);
    }

    if (userIds.isEmpty) {
      return items
          .map(
            (e) => PrestataireReservationItem(
              id: e.id,
              dateHeure: e.dateHeure,
              statut: e.statut,
              serviceName: e.serviceName,
              clientName: DiscPrestaDash.unknownClient,
              clientId: e.clientId,
              notesClient: e.notesClient,
              notesPrestataire: e.notesPrestataire,
              amountCents: e.amountCents,
              paymentStatus: e.paymentStatus,
              paymentMode: e.paymentMode,
              servicePriceCents: e.servicePriceCents,
              platformFeeCents: e.platformFeeCents,
              prestataireAmountCents: e.prestataireAmountCents,
              durationMinutes: e.durationMinutes,
            ),
          )
          .toList();
    }

    final profileMap = await profileService.getByUserIds(userIds.toSet().toList());
    return List.generate(items.length, (i) {
      final map = Map<String, dynamic>.from(rawRows[i] as Map);
      final service = map['services_beaute'];
      final client = map['client_profiles'];
      final userId = client is Map ? client['user_id'] as String? : null;
      final profile = userId != null ? profileMap[userId] : null;
      final prenom = profile?.prenom?.trim();
      final nom = profile?.nom?.trim();
      final parts = [
        prenom,
        nom,
      ].where((p) => p != null && p.isNotEmpty).cast<String>();
      final clientName = parts.isEmpty
          ? DiscPrestaDash.unknownClient
          : parts.join(' ');
      final avatar = profile?.avatarUrl?.trim();
      return prestataireReservationItemFromRow(
        map,
        service,
        clientName,
        clientPrenom: prenom,
        clientNom: nom,
        clientAvatarUrl: avatar != null && avatar.isNotEmpty ? avatar : null,
      );
    });
  }
}
