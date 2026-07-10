// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

const _stripePaymentQueryKeys = {
  'payment_intent',
  'payment_intent_client_secret',
  'redirect_status',
};

/// Retire `?code=` / `#access_token=` de la barre d’adresse après OAuth.
void stripOAuthParamsFromBrowserUrl(Uri uri) {
  final clean = Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: uri.path.isEmpty ? '/' : uri.path,
    fragment: uri.fragment.isEmpty ? null : uri.fragment,
  );
  html.window.history.replaceState(null, '', clean.toString());
}

/// Retire les paramètres de retour Stripe Payment Element (3DS).
void stripStripePaymentParamsFromBrowserUrl(Uri uri) {
  if (!_stripePaymentQueryKeys
      .any((key) => uri.queryParameters.containsKey(key))) {
    return;
  }
  final cleanParams = Map<String, String>.from(uri.queryParameters)
    ..removeWhere((key, _) => _stripePaymentQueryKeys.contains(key));
  final clean = uri.replace(queryParameters: cleanParams.isEmpty ? null : cleanParams);
  html.window.history.replaceState(null, '', clean.toString());
}
