import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Paiement en ligne désactivé (Stripe retiré).
final prestataireDepositAvailableProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, prestataireId) async {
  return false;
});

/// @deprecated Utiliser [prestataireDepositAvailableProvider].
final prestataireAcceptsOnlinePaymentProvider = prestataireDepositAvailableProvider;
