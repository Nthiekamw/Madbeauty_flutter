import 'package:flutter/foundation.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart';

import '../../core/config/stripe_platform_policy.dart';
import 'stripe_service.dart';

/// Initialise Stripe.js une fois avant tout Payment Element (web).
abstract final class StripeWebBootstrap {
  StripeWebBootstrap._();

  static Future<bool>? _initFuture;

  /// Idempotent : charge Stripe.js et crée l’instance [WebStripe].
  static Future<bool> ensureInitialized() {
    if (!kIsWeb || !StripePlatformPolicy.isEnabled) {
      return Future.value(false);
    }
    if (!StripeService.isConfigured) {
      return Future.value(false);
    }
    return _initFuture ??= _initialize();
  }

  static Future<bool> _initialize() async {
    try {
      final publishableKey = StripeService.publishableKey.trim();
      if (publishableKey.isEmpty) return false;

      Stripe.publishableKey = publishableKey;
      await WebStripe.instance.initialise(publishableKey: publishableKey);
      return true;
    } catch (e, st) {
      debugPrint('StripeWebBootstrap failed: $e\n$st');
      _initFuture = null;
      return false;
    }
  }
}
