import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

/// True sur Android/iOS hors Web, avec un [DefaultFirebaseOptions] non placeholder.
///
/// Séparé de `firebase_options.dart` pour ne pas perdre ces garde-fous lors d’un
/// `flutterfire configure` (le fichier régénéré n’expose pas cette logique).
bool isFirebaseConfiguredForPush() {
  if (kIsWeb) return false;
  switch (defaultTargetPlatform) {
    case TargetPlatform.android:
    case TargetPlatform.iOS:
      break;
    default:
      return false;
  }
  try {
    final o = DefaultFirebaseOptions.currentPlatform;
    if (o.projectId.isEmpty || o.apiKey.isEmpty) return false;
    const placeholders = {'madbeauty-placeholder'};
    if (placeholders.contains(o.projectId)) return false;
    if (o.apiKey.startsWith('REPLACE')) return false;
    return true;
  } catch (_) {
    return false;
  }
}
