import '../../core/config/app_config.dart';

/// Configuration Stripe côté client (clé publique uniquement).
class StripeService {
  StripeService._();

  static String get publishableKey => AppConfig.stripePublishableKey;

  static bool get isConfigured => publishableKey.trim().isNotEmpty;

  /// `true` si la clé publique est une clé Stripe test (`pk_test_…`).
  static bool get isTestMode {
    final key = publishableKey.trim();
    return key.startsWith('pk_test_');
  }
}

