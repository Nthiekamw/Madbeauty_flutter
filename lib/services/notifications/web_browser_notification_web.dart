// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:js_util' as js_util;

/// Affiche une notification système navigateur (premier plan).
///
/// Préfère `ServiceWorkerRegistration.showNotification` : plus fiable que
/// `new Notification()` sur Chrome Android quand l’onglet MadBeauty est ouvert
/// (cas typique des tests depuis l’admin).
Future<bool> showWebBrowserNotification({
  required String title,
  required String body,
  String? payload,
}) async {
  if (!html.Notification.supported) return false;
  if (html.Notification.permission != 'granted') return false;

  final trimmedBody = body.trim();
  if (trimmedBody.isEmpty) return false;
  final trimmedTitle = title.trim().isEmpty ? 'MadBeauty' : title.trim();

  final options = <String, Object>{
    'body': trimmedBody,
    'icon': '/icons/Icon-notification-192.png',
    'badge': '/icons/Icon-badge-72.png',
    'tag': 'madbeauty-foreground',
    'renotify': true,
  };
  if (payload != null && payload.isNotEmpty) {
    options['data'] = <String, String>{'payload': payload};
  }

  try {
    final container = html.window.navigator.serviceWorker;
    if (container != null) {
      final registration = await container.ready;
      await js_util.promiseToFuture(
        js_util.callMethod(
          registration,
          'showNotification',
          [trimmedTitle, js_util.jsify(options)],
        ),
      );
      return true;
    }
  } catch (_) {
    /* fallback Notification API */
  }

  try {
    html.Notification(
      trimmedTitle,
      body: trimmedBody,
      icon: '/icons/Icon-notification-192.png',
    );
    return true;
  } catch (_) {
    return false;
  }
}
