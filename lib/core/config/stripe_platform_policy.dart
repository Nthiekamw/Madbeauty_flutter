import 'package:flutter/foundation.dart';

import '../../services/stripe/stripe_service.dart';

/// Stripe activé uniquement sur Flutter Web pour l’instant (stores sans IAP).
abstract final class StripePlatformPolicy {
  StripePlatformPolicy._();

  static bool get isEnabled => kIsWeb && StripeService.isConfigured;
}
