import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Autorise le redirect à quitter `/login` après le dialogue de bienvenue.
final loginRedirectAfterWelcomeProvider =
    NotifierProvider<LoginRedirectAfterWelcomeNotifier, bool>(
  LoginRedirectAfterWelcomeNotifier.new,
);

class LoginRedirectAfterWelcomeNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void arm() => state = true;

  void disarm() => state = false;
}

/// Destination unique pour quitter `/splash` une fois le bootstrap terminé.
final splashRedirectTargetProvider =
    NotifierProvider<SplashRedirectTargetNotifier, String?>(
  SplashRedirectTargetNotifier.new,
);

class SplashRedirectTargetNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void setTarget(String path) => state = path;

  void clear() => state = null;
}
