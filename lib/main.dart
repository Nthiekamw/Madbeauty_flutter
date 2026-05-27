import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'services/notifications/fcm_background_handler.dart';
import 'services/storage/local_cache_service.dart';
import 'services/supabase/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if (!kIsWeb) {
    FirebaseMessaging.onBackgroundMessage(fcmBackgroundMessagingHandler);
  }
  await LocalCacheService.initialize();
  await initializeDateFormatting('fr_FR');

  if (AppConfig.hasSupabase) {
    await SupabaseService.initialize();
  }

  runApp(const ProviderScope(child: MadBeautyApp()));
}
