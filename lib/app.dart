import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_strings.dart';
import 'features/auth/navigation/auth_recovery_navigation.dart';
import 'router/app_router.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/router_theme_scope.dart';

class MadBeautyApp extends ConsumerWidget {
  const MadBeautyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    listenPasswordRecoveryNavigation(ref);
    final router = ref.watch(goRouterProvider);
    return RouterThemeScope(
      router: router,
      builder: (context, area) {
        return MaterialApp.router(
          title: CoreStrings.appName,
          debugShowCheckedModeBanner: false,
          themeMode: ThemeMode.system,
          theme: AppTheme.light(area),
          darkTheme: AppTheme.dark(area),
          locale: const Locale('fr', 'FR'),
          supportedLocales: const [Locale('fr', 'FR')],
          localizationsDelegates: GlobalMaterialLocalizations.delegates,
          routerConfig: router,
        );
      },
    );
  }
}
