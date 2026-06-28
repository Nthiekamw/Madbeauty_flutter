// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

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
