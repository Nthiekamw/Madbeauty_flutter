import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/domain/payment/client_payment_method.dart';
import 'stripe_client_payment_providers.dart';

final clientPaymentMethodsProvider =
    FutureProvider.autoDispose<List<ClientPaymentMethod>>((ref) async {
  final service = ref.watch(stripeClientPaymentServiceProvider);
  if (service == null) return const [];
  return service.listPaymentMethods();
});
