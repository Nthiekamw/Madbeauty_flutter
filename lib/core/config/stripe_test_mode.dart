/// Carte de test Stripe (mode `pk_test_…`).
abstract final class StripeTestCard {
  StripeTestCard._();

  static const numberDisplay = '4242 4242 4242 4242';
  static const numberRaw = '4242424242424242';
  static const expiry = '12/34';
  static const cvc = '123';
}
