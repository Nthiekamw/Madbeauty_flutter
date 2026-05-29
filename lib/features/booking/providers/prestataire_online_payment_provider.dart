import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../services/supabase/supabase_service.dart';
import '../logic/booking_payment_flow.dart';

/// Le prestataire peut-il encaisser via Stripe Connect ?
final prestataireAcceptsOnlinePaymentProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, prestataireId) async {
  if (!BookingPaymentFlow.isPaymentAvailable || !AppConfig.hasSupabase) {
    return false;
  }

  final row = await SupabaseService.client
      .from('prestataire_profiles')
      .select('stripe_connect_charges_enabled')
      .eq('id', prestataireId)
      .maybeSingle();

  return row?['stripe_connect_charges_enabled'] as bool? ?? false;
});

/// Paiement Stripe obligatoire pour ce prestataire ?
bool bookingRequiresOnlinePayment(bool prestataireAcceptsOnline) =>
    BookingPaymentFlow.isPaymentAvailable && prestataireAcceptsOnline;
