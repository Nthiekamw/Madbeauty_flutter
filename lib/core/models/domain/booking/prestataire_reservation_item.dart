import 'package:madbeauty/core/logic/booking/reservation_payment_display.dart';

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

  /// Prénom + nom affichables (fallback sur [clientName]).
  String get clientDisplayName {
    final parts = <String>[
      if (clientPrenom?.trim().isNotEmpty == true) clientPrenom!.trim(),
      if (clientNom?.trim().isNotEmpty == true) clientNom!.trim(),
    ];
    if (parts.isNotEmpty) return parts.join(' ');
    return clientName;
  }
  final String? notesClient;
  final String? notesPrestataire;
  final int? amountCents;
  final String? paymentStatus;
  final String? paymentMode;
  final int? servicePriceCents;
  final int? platformFeeCents;
  final int? prestataireAmountCents;
  final int durationMinutes;

  ReservationPaymentDisplay get paymentDisplay =>
      ReservationPaymentDisplay.fromFields(
        paymentMode: paymentMode,
        servicePriceCents: servicePriceCents,
        platformFeeCents: platformFeeCents,
        prestataireAmountCents: prestataireAmountCents,
        amountCents: amountCents,
        paymentStatus: paymentStatus,
      );
}
