import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

/// Ouvre une URL dans le navigateur intégré (Custom Tabs / Safari in-app).
abstract final class AppUrlLauncher {
  AppUrlLauncher._();

  /// `true` si le navigateur in-app s'est ouvert, `false` sinon.
  static Future<bool> openInApp(
    BuildContext context,
    String url,
  ) async {
    final trimmed = url.trim();
    if (trimmed.isEmpty) return false;

    final uri = Uri.parse(trimmed);
    const modes = [
      LaunchMode.inAppBrowserView,
      LaunchMode.platformDefault,
      LaunchMode.externalApplication,
    ];
    for (final mode in modes) {
      try {
        if (await launchUrl(uri, mode: mode)) return true;
      } catch (_) {}
    }
    return false;
  }
}
