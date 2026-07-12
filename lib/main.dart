import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_web_plugins/url_strategy.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'core/config/stripe_platform_policy.dart';
import 'firebase_runtime_helpers.dart';
import 'core/providers/offline_sync_hooks.dart';
import 'features/offline/providers/offline_booking_sync_invalidation.dart';
import 'services/auth/google_auth_service.dart';
import 'services/notifications/booking_local_reminders.dart';
import 'services/notifications/prestataire_catalog_visibility_reminders.dart';
import 'services/notifications/fcm_background_handler.dart';
import 'services/storage/local_cache_service.dart';
import 'services/stripe/stripe_web_bootstrap.dart';
import 'services/supabase/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _bootstrapMadBeauty();
}

Future<void> _bootstrapMadBeauty() async {
  if (kIsWeb) {
    try {
      usePathUrlStrategy();
    } on Object catch (e, st) {
      _logBootWarning('usePathUrlStrategy ignoré', e, st);
    }
  }

  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(fcmBackgroundMessagingHandler);
  }

  try {
    await LocalCacheService.initialize();
  } on Object catch (e, st) {
    _logBootError('LocalCacheService', e, st);
    if (!kIsWeb) rethrow;
  }

  await _safeInit('dateFormatting.fr', () => initializeDateFormatting('fr_FR'));
  await _safeInit('dateFormatting.en', () => initializeDateFormatting('en_US'));

  if (!kIsWeb) {
    await BookingLocalReminders.instance.initialize();
    await PrestataireCatalogVisibilityReminders.instance.initialize();
  }

  if (AppConfig.hasSupabase) {
    await _safeInit(
      'SupabaseService',
      () => SupabaseService.initialize().timeout(
        const Duration(seconds: 20),
        onTimeout: () {
          throw TimeoutException('Supabase.initialize > 20s');
        },
      ),
    );
  }

  if (!kIsWeb) {
    await _safeInit('GoogleAuthService.warmUp', () async {
      try {
        await GoogleAuthService.warmUp();
      } on Object catch (e, st) {
        _logBootWarning('GoogleAuthService.warmUp ignoré', e, st);
      }
    });
  }

  await _safeInit('Firebase', () => ensureFirebaseInitialized());

  if (kDebugMode) {
    debugPrint(
      'MadBeauty config: supabase=${AppConfig.hasSupabase} '
      'stripe=${StripePlatformPolicy.isEnabled} '
      'volatileCache=${LocalCacheService.volatileMemoryFallback}',
    );
  }

  runApp(
    ProviderScope(
      overrides: [
        offlineSyncAfterFlushProvider.overrideWithValue(
          invalidateBookingCachesAfterOfflineSync,
        ),
      ],
      child: const MadBeautyApp(),
    ),
  );

  if (kIsWeb && StripePlatformPolicy.isEnabled) {
    unawaited(
      StripeWebBootstrap.ensureInitialized().timeout(
        const Duration(seconds: 12),
        onTimeout: () {
          _logBootWarning('StripeWebBootstrap timeout', null, null);
          return false;
        },
      ),
    );
  }
}

Future<void> _safeInit(
  String label,
  Future<void> Function() action,
) async {
  try {
    await action();
  } on Object catch (e, st) {
    _logBootError(label, e, st);
    if (!kIsWeb) rethrow;
  }
}

void _logBootWarning(String label, Object? error, StackTrace? stack) {
  if (!kDebugMode) return;
  debugPrint('MadBeauty boot warning [$label]: $error');
  if (stack != null) debugPrint('$stack');
}

void _logBootError(String label, Object error, StackTrace stack) {
  if (kDebugMode) {
    debugPrint('MadBeauty boot error [$label]: $error\n$stack');
  }
}
