import '../core/config/app_config.dart';

/// Paiements Stripe (clé publique + flux à implémenter côté app / Edge Functions).
class StripeService {
  StripeService._();

  static String get publishableKey => AppConfig.stripePublishableKey;

  static bool get isConfigured => publishableKey.isNotEmpty;
}
