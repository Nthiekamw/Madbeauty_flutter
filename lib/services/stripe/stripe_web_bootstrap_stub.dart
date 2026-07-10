/// No-op hors web (évite de compiler flutter_stripe_web sur mobile).
abstract final class StripeWebBootstrap {
  StripeWebBootstrap._();

  static Future<bool> ensureInitialized() => Future.value(false);
}
