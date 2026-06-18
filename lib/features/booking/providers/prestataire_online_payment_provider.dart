import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../services/supabase/supabase_service.dart';
import '../logic/booking_payment_flow.dart';

/// État acompte d’un prestataire (option + Connect).
class PrestataireDepositAvailability {
  const PrestataireDepositAvailability({
    required this.optionEnabled,
    required this.connectReady,
  });

  final bool optionEnabled;
  final bool connectReady;

  bool get isAvailable => optionEnabled && connectReady;
}

/// Le prestataire a activé l’option acompte et peut encaisser via Stripe Connect.
final prestataireDepositAvailabilityProvider =
    FutureProvider.autoDispose.family<PrestataireDepositAvailability, String>(
        (ref, prestataireId) async {
  if (!BookingPaymentFlow.isPaymentAvailable || !AppConfig.hasSupabase) {
    return const PrestataireDepositAvailability(
      optionEnabled: false,
      connectReady: false,
    );
  }

  final row = await SupabaseService.client
      .from('prestataire_profiles')
      .select('deposit_option_enabled, stripe_connect_charges_enabled')
      .eq('id', prestataireId)
      .maybeSingle();

  return PrestataireDepositAvailability(
    optionEnabled: row?['deposit_option_enabled'] as bool? ?? false,
    connectReady: row?['stripe_connect_charges_enabled'] as bool? ?? false,
  );
});

/// Raccourci : acompte disponible pour la réservation client.
final prestataireDepositAvailableProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, prestataireId) async {
  final state = await ref.watch(
    prestataireDepositAvailabilityProvider(prestataireId).future,
  );
  return state.isAvailable;
});

/// @deprecated Utiliser [prestataireDepositAvailableProvider].
final prestataireAcceptsOnlinePaymentProvider = prestataireDepositAvailableProvider;
