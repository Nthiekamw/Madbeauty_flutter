import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/supabase_error_handler.dart';
import '../../../../core/models/domain/booking/reservation.dart';
import '../../../../core/models/domain/serialization/supabase_domain_codec.dart';

/// Création réservation pack via RPC `create_pack_booking`.
class PackBookingService {
  PackBookingService(this._client);

  final SupabaseClient _client;

  Future<Reservation> createPackBooking({
    required String packId,
    required DateTime dateHeure,
    required String paymentMode,
    String? notesClient,
    String? stripePaymentIntentId,
    int? amountCents,
    int? servicePriceCents,
    int? platformFeeCents,
    int? prestataireAmountCents,
    int? originalServicePriceCents,
    int? referralDiscountPercent,
    String? paymentStatus,
    String? clientId,
  }) {
    return SupabaseErrorHandler.run(
      operation: 'packBooking.create',
      action: () async {
        final local = dateHeure.toLocal();
        final minuteLocal = DateTime(
          local.year,
          local.month,
          local.day,
          local.hour,
          local.minute,
        );
        final payload = <String, dynamic>{
          'pack_id': packId,
          'date_heure': minuteLocal.toUtc().toIso8601String(),
          'payment_mode': paymentMode,
          if (notesClient != null && notesClient.trim().isNotEmpty)
            'notes_client': notesClient.trim(),
          if (stripePaymentIntentId != null)
            'stripe_payment_intent_id': stripePaymentIntentId,
          if (amountCents != null) 'amount_cents': amountCents,
          if (servicePriceCents != null)
            'service_price_cents': servicePriceCents,
          if (platformFeeCents != null) 'platform_fee_cents': platformFeeCents,
          if (prestataireAmountCents != null)
            'prestataire_amount_cents': prestataireAmountCents,
          if (originalServicePriceCents != null)
            'original_service_price_cents': originalServicePriceCents,
          if (referralDiscountPercent != null && referralDiscountPercent > 0)
            'referral_discount_percent': referralDiscountPercent,
          if (paymentStatus != null) 'payment_status': paymentStatus,
          if (clientId != null) 'client_id': clientId,
        };

        final raw = await _client.rpc('create_pack_booking', params: {
          'p_payload': payload,
        });
        final map = Map<String, dynamic>.from(raw as Map);
        final reservationId = map['reservation_id'] as String?;
        if (reservationId == null || reservationId.isEmpty) {
          throw StateError('create_pack_booking: reservation_id manquant');
        }

        final row = await _client
            .from('reservations')
            .select()
            .eq('id', reservationId)
            .single();
        return SupabaseDomainCodec.reservation(
          Map<String, dynamic>.from(row),
        );
      },
    );
  }
}
