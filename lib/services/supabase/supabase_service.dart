import 'dart:async';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../auth/auth_session_sanitizer.dart';

class SupabaseService {
  SupabaseService._();

  static StreamSubscription<AuthState>? _authStartupGuard;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      authOptions: const FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        detectSessionInUri: true,
      ),
    );

    _authStartupGuard?.cancel();
    _authStartupGuard =
        AuthSessionSanitizer.installStartupGuard(client.auth);
  }

  static SupabaseClient get client => Supabase.instance.client;
}
