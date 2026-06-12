import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/models/domain/payment/client_payment_method.dart';
import 'stripe_subscription_providers.dart';

final prestataireBillingPaymentMethodsProvider =
    FutureProvider.autoDispose<List<ClientPaymentMethod>>((ref) async {
  final service = ref.watch(stripePrestaSubscriptionServiceProvider);
  if (service == null) return const [];
  return service.listPaymentMethods();
});
