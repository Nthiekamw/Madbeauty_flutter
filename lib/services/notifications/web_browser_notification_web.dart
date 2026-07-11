// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;

Future<bool> showWebBrowserNotification({
  required String title,
  required String body,
  String? payload,
}) async {
  if (!html.Notification.supported) return false;
  if (html.Notification.permission != 'granted') return false;

  final trimmedBody = body.trim();
  if (trimmedBody.isEmpty) return false;

  try {
    html.Notification(
      title.trim().isEmpty ? 'MadBeauty' : title.trim(),
      body: trimmedBody,
      icon: 'icons/Icon-notification-192.png',
    );
    return true;
  } catch (_) {
    return false;
  }
}
