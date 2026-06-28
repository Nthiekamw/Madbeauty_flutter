import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/app_config.dart';
import '../auth/auth_session_sanitizer.dart';
import 'supabase_http_client.dart';

class SupabaseService {
  SupabaseService._();

  static StreamSubscription<AuthState>? _authStartupGuard;

  static Future<void> initialize() async {
    await Supabase.initialize(
      url: AppConfig.supabaseUrl,
      anonKey: AppConfig.supabaseAnonKey,
      httpClient: SupabaseTimeoutHttpClient(),
      realtimeClientOptions: RealtimeClientOptions(
        timeout: AppConfig.supabaseRealtimeTimeout,
      ),
      authOptions: FlutterAuthClientOptions(
        authFlowType: AuthFlowType.pkce,
        // Web : session OAuth dans l’URL (?code=). Mobile : [DeepLinkListener].
        detectSessionInUri: kIsWeb,
      ),
    );

    _authStartupGuard?.cancel();
    _authStartupGuard =
        AuthSessionSanitizer.installStartupGuard(client.auth);
  }

  static SupabaseClient get client => Supabase.instance.client;
}

