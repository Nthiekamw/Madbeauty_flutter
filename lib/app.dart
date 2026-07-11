import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_localizations/flutter_localizations.dart';

import 'core/constants/app_strings.dart';
import 'core/providers/app_appearance_provider.dart';
import 'features/auth/navigation/auth_recovery_navigation.dart';
import 'router/app_router.dart';
import 'router/deep_link_listener.dart';
import 'features/messaging/widgets/presence/user_presence_coordinator.dart';
import 'features/notifications/widgets/live_updates_coordinator.dart';
import 'features/notifications/widgets/booking_push_coordinator.dart';
import 'features/notifications/widgets/prestataire_booking_notification_coordinator.dart';
import 'features/notifications/widgets/prestataire_visibility_notification_coordinator.dart';
import 'features/pwa/widgets/pwa_install_banner.dart';
import 'shared/theme/app_theme.dart';
import 'shared/theme/router_theme_scope.dart';
import 'shared/widgets/layout/web_readability_scope.dart';

class MadBeautyApp extends ConsumerWidget {
  const MadBeautyApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    listenPasswordRecoveryNavigation(ref);
    final router = ref.watch(goRouterProvider);
    final appearance = ref.watch(appAppearanceProvider);
    return DeepLinkListener(
      child: UserPresenceCoordinator(
        child: LiveUpdatesCoordinator(
          child: BookingPushCoordinator(
            child: PrestataireBookingNotificationCoordinator(
              child: PrestataireVisibilityNotificationCoordinator(
                child: RouterThemeScope(
                router: router,
                builder: (context, area) {
                  return MaterialApp.router(
                    title: CoreStrings.appName,
                    debugShowCheckedModeBanner: false,
                    themeMode: appearance.themeMode,
                    theme: AppTheme.light(area),
                    darkTheme: AppTheme.dark(area),
                    locale: appearance.locale,
                    supportedLocales: const [
                      Locale('fr', 'FR'),
                      Locale('en', 'US'),
                    ],
                    localizationsDelegates:
                        GlobalMaterialLocalizations.delegates,
                    routerConfig: router,
                    builder: (context, child) => WebReadabilityScope(
                      child: Column(
                        children: [
                          const PwaInstallBanner(),
                          Expanded(
                            child: child ?? const SizedBox.shrink(),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

