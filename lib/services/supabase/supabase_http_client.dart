import 'package:http/http.dart' as http;

import '../../core/config/app_config.dart';

/// Client HTTP Supabase avec délai maximal par requête (REST, Auth, Storage…).
class SupabaseTimeoutHttpClient extends http.BaseClient {
  SupabaseTimeoutHttpClient({
    http.Client? inner,
    Duration? timeout,
  })  : _inner = inner ?? http.Client(),
        _timeout = timeout ?? AppConfig.supabaseHttpTimeout;

  final http.Client _inner;
  final Duration _timeout;

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) {
    return _inner.send(request).timeout(_timeout);
  }

  @override
  void close() => _inner.close();
}
