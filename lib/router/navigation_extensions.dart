import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';

extension AppNavigationX on BuildContext {
  void goSplash() => goNamed(AppRouteNames.splash);
  void goHome() => goNamed(AppRouteNames.home);
  void goLogin() => goNamed(AppRouteNames.login);
  void goRegister() => goNamed(AppRouteNames.register);
  void goRoleChoice() => goNamed(AppRouteNames.role);
  void goPrestataire() => goNamed(AppRouteNames.prestataire);

  void pushLogin() => pushNamed(AppRouteNames.login);
  void pushRegister() => pushNamed(AppRouteNames.register);
  void pushForgotPassword() => pushNamed(AppRouteNames.forgotPassword);
  void pushPrestataire() => pushNamed(AppRouteNames.prestataire);
}
