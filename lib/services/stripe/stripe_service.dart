import '../../core/config/app_config.dart';

/// Configuration Stripe côté client (clé publique uniquement).
class StripeService {
  StripeService._();

  static String get publishableKey => AppConfig.stripePublishableKey;

  static bool get isConfigured => publishableKey.trim().isNotEmpty;
}

