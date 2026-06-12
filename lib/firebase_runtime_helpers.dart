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

/// Initialise Firebase une seule fois (notifications push FCM).
///
/// Ne lance pas : les erreurs sont loguées et ignorées (l'app reste utilisable
/// sans push). N'utilise **pas** firebase_auth — Google Sign-In passe par Supabase.
Future<bool> ensureFirebaseInitialized() async {
  if (!isFirebaseConfiguredForPush()) return false;
  if (Firebase.apps.isNotEmpty) return true;
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );
    return true;
  } catch (e, st) {
    if (kDebugMode) {
      debugPrint('ensureFirebaseInitialized: échec (push désactivé) – $e\n$st');
    }
    return false;
  }
}
