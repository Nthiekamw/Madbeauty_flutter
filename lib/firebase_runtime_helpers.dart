import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import 'firebase_options.dart';

/// True sur Android/iOS hors Web, avec un [DefaultFirebaseOptions] non placeholder.
///
/// Séparé de `firebase_options.dart` pour ne pas perdre ces garde-fous lors d'un
/// `flutterfire configure` (le fichier régénéré n'expose pas cette logique).
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

/// Initialise Firebase une seule fois (auth téléphone, FCM, etc.).
Future<void> ensureFirebaseInitialized() async {
  if (!isFirebaseConfiguredForPush()) return;
  if (Firebase.apps.isEmpty) {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
  }
  await _configureFirebasePhoneAuthIfNeeded();
}

bool _firebasePhoneAuthConfigured = false;

/// Évite Play Integrity en dev (erreur 17028) : flux reCAPTCHA web à la place.
Future<void> _configureFirebasePhoneAuthIfNeeded() async {
  if (_firebasePhoneAuthConfigured || kIsWeb) return;
  if (defaultTargetPlatform != TargetPlatform.android) return;
  _firebasePhoneAuthConfigured = true;
  if (kDebugMode) {
    await fb.FirebaseAuth.instance.setSettings(forceRecaptchaFlow: true);
    debugPrint(
      '[FirebaseAuth] forceRecaptchaFlow=true (debug Android, évite Play Integrity)',
    );
  }
}

