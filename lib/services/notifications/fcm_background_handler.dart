import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

import '../../firebase_options.dart';
import '../../firebase_runtime_helpers.dart';

/// Handler isolé pour les notifications FCM en arrière-plan (obligatoire : top-level).
@pragma('vm:entry-point')
Future<void> fcmBackgroundMessagingHandler(RemoteMessage message) async {
  if (!isFirebaseConfiguredForPush()) return;

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Les messages avec champ `notification` sont affichés par le système sur Android /
  // peuvent être gérés automatiquement sur iOS. On conserve l’initialisation Firebase
  // pour les traitements nécessitant le SDK (hooks data-only, futures extensions).
}
