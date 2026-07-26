import 'package:madbeauty/core/logic/booking/reservation_payment_display.dart';

import 'reservation_pack_line.dart';

/// Réservation enrichie pour le tableau de bord / agenda prestataire.
class PrestataireReservationItem {
  const PrestataireReservationItem({
    required this.id,
    required this.dateHeure,
    required this.statut,
    required this.serviceName,
    required this.clientName,
    this.clientPrenom,
    this.clientNom,
    this.clientId,
    this.clientAvatarUrl,
    this.notesClient,
    this.notesPrestataire,
    this.amountCents,
    this.paymentStatus,
    this.paymentMode,
    this.servicePriceCents,
    this.platformFeeCents,
    this.prestataireAmountCents,
    this.durationMinutes = 60,
    this.packId,
    this.packTitle,
    this.packItems = const [],
  });

  final String id;
  final DateTime dateHeure;
  final String statut;
  final String serviceName;
  final String clientName;
  final String? clientPrenom;
  final String? clientNom;
  final String? clientId;
  final String? clientAvatarUrl;
  final String? notesClient;
  final String? notesPrestataire;
  final int? amountCents;
  final String? paymentStatus;
  final String? paymentMode;
  final int? servicePriceCents;
  final int? platformFeeCents;
  final int? prestataireAmountCents;
  final int durationMinutes;
  final String? packId;
  final String? packTitle;
  final List<ReservationPackLine> packItems;

  bool get isPack =>
      packId != null && packId!.trim().isNotEmpty;

  /// Titre affiché (pack prioritaire, sinon service).
  String get offerTitle {
    final pack = packTitle?.trim();
    if (pack != null && pack.isNotEmpty) return pack;
    return serviceName;
  }

  /// Prénom + nom affichables (fallback sur [clientName]).
  String get clientDisplayName {
    final parts = <String>[
      if (clientPrenom?.trim().isNotEmpty == true) clientPrenom!.trim(),
      if (clientNom?.trim().isNotEmpty == true) clientNom!.trim(),
    ];
    if (parts.isNotEmpty) return parts.join(' ');
    return clientName;
  }

  ReservationPaymentDisplay get paymentDisplay =>
      ReservationPaymentDisplay.fromFields(
        paymentMode: paymentMode,
        servicePriceCents: servicePriceCents,
        platformFeeCents: platformFeeCents,
        prestataireAmountCents: prestataireAmountCents,
        amountCents: amountCents,
        paymentStatus: paymentStatus,
      );

  PrestataireReservationItem copyWith({
    String? id,
    DateTime? dateHeure,
    String? statut,
    String? serviceName,
    String? clientName,
    String? clientPrenom,
    String? clientNom,
    String? clientId,
    String? clientAvatarUrl,
    String? notesClient,
    String? notesPrestataire,
    int? amountCents,
    String? paymentStatus,
    String? paymentMode,
    int? servicePriceCents,
    int? platformFeeCents,
    int? prestataireAmountCents,
    int? durationMinutes,
    String? packId,
    String? packTitle,
    List<ReservationPackLine>? packItems,
  }) {
    return PrestataireReservationItem(
      id: id ?? this.id,
      dateHeure: dateHeure ?? this.dateHeure,
      statut: statut ?? this.statut,
      serviceName: serviceName ?? this.serviceName,
      clientName: clientName ?? this.clientName,
      clientPrenom: clientPrenom ?? this.clientPrenom,
      clientNom: clientNom ?? this.clientNom,
      clientId: clientId ?? this.clientId,
      clientAvatarUrl: clientAvatarUrl ?? this.clientAvatarUrl,
      notesClient: notesClient ?? this.notesClient,
      notesPrestataire: notesPrestataire ?? this.notesPrestataire,
      amountCents: amountCents ?? this.amountCents,
      paymentStatus: paymentStatus ?? this.paymentStatus,
      paymentMode: paymentMode ?? this.paymentMode,
      servicePriceCents: servicePriceCents ?? this.servicePriceCents,
      platformFeeCents: platformFeeCents ?? this.platformFeeCents,
      prestataireAmountCents:
          prestataireAmountCents ?? this.prestataireAmountCents,
      durationMinutes: durationMinutes ?? this.durationMinutes,
      packId: packId ?? this.packId,
      packTitle: packTitle ?? this.packTitle,
      packItems: packItems ?? this.packItems,
    );
  }
}
