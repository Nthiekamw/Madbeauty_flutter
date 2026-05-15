import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/config/app_config.dart';
import 'services/storage/local_cache_service.dart';
import 'services/supabase/supabase_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await LocalCacheService.initialize();
  await initializeDateFormatting('fr_FR');

  if (AppConfig.hasSupabase) {
    await SupabaseService.initialize();
  }

  runApp(const ProviderScope(child: MadBeautyApp()));
}
