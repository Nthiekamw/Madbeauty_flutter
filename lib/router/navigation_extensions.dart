import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';

extension AppNavigationX on BuildContext {
  void goSplash() => goNamed(AppRouteNames.splash);
  void goHome() => goNamed(AppRouteNames.home);
  void goListing({String? query}) {
    final q = query?.trim();
    if (q != null && q.isNotEmpty) {
      goNamed(AppRouteNames.listing, queryParameters: {'q': q});
    } else {
      goNamed(AppRouteNames.listing);
    }
  }

  void pushListing({String? query}) {
    final q = query?.trim();
    if (q != null && q.isNotEmpty) {
      pushNamed(AppRouteNames.listing, queryParameters: {'q': q});
    } else {
      pushNamed(AppRouteNames.listing);
    }
  }

  void goLogin() => goNamed(AppRouteNames.login);
  void goRegister() => goNamed(AppRouteNames.register);
  void goRoleChoice() => goNamed(AppRouteNames.role);
  void goPrestataire() => goNamed(AppRouteNames.prestataire);

  void pushLogin() => pushNamed(AppRouteNames.login);
  void pushRegister() => pushNamed(AppRouteNames.register);
  void pushForgotPassword() => pushNamed(AppRouteNames.forgotPassword);
  void pushPrestataireDetail(String id) => pushNamed(
        AppRouteNames.prestataireDetail,
        pathParameters: {'id': id},
      );
  void pushPrestataire() => pushNamed(AppRouteNames.prestataire);
}
