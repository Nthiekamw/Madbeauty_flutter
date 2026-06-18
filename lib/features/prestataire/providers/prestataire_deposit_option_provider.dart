import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/stripe/prestataire_deposit_service.dart';
import '../../../services/supabase/supabase_service.dart';
import 'profile/current_prestataire_provider.dart';

final prestataireDepositServiceProvider =
    Provider<PrestataireDepositService?>((ref) {
  return PrestataireDepositService.fromEnv();
});

/// Option acompte du prestataire connecté (profil pro).
final currentPrestataireDepositOptionProvider =
    FutureProvider.autoDispose<bool>((ref) async {
  final presta = await ref.watch(currentPrestataireProvider.future);
  if (presta == null) return false;

  final row = await SupabaseService.client
      .from('prestataire_profiles')
      .select('deposit_option_enabled')
      .eq('id', presta.id)
      .maybeSingle();

  return row?['deposit_option_enabled'] as bool? ?? false;
});
