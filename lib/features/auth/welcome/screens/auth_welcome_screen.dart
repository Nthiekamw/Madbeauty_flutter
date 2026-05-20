import 'package:flutter/material.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:go_router/go_router.dart';



import '../../../../core/constants/app_strings.dart';

import '../../../../router/app_router.dart';

import '../../../../shared/theme/app_fonts.dart';

import '../../../../shared/widgets/brand_background.dart';

import '../../guest/guest_mode_provider.dart';

import '../../widgets/auth_marketing_logo.dart';



/// Hub avant connexion : Inscription / Connexion / mode invité.

class AuthWelcomeScreen extends ConsumerWidget {

  const AuthWelcomeScreen({super.key});



  @override

  Widget build(BuildContext context, WidgetRef ref) {

    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;



    return Scaffold(

      body: Stack(

        fit: StackFit.expand,

        children: [

          BrandBackground(isDark: isDark),

          SafeArea(

            child: Padding(

              padding: const EdgeInsets.symmetric(horizontal: 24),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.stretch,

                children: [

                  const SizedBox(height: 24),

                  const AuthMarketingLogo(width: 260),

                  const Spacer(flex: 2),

                  Text(

                    AuthStrings.welcomeTitle,

                    textAlign: TextAlign.center,

                    style: theme.textTheme.headlineLarge?.copyWith(

                      fontFamily: AppFonts.display,

                      fontWeight: FontWeight.w700,

                      letterSpacing: -0.5,

                      height: 1.1,

                    ),

                  ),

                  const SizedBox(height: 12),

                  Text(

                    AuthStrings.welcomeSubtitle,

                    textAlign: TextAlign.center,

                    style: theme.textTheme.bodyLarge?.copyWith(

                      fontFamily: AppFonts.body,

                      color: onSurfaceVariant,

                      height: 1.4,

                    ),

                  ),

                  const SizedBox(height: 28),

                  const _WelcomeFeatureRow(

                    icon: Icons.person_outline,

                    label: AuthStrings.welcomeFeatureDualRole,

                  ),

                  SizedBox(height: 10),

                  const _WelcomeFeatureRow(

                    icon: Icons.lock_outline,

                    label: AuthStrings.welcomeFeatureSecure,

                  ),

                  const Spacer(flex: 3),

                  FilledButton(

                    onPressed: () {
                      ref.read(guestModeProvider.notifier).disable();
                      context.push(AppRoutes.register);
                    },

                    style: FilledButton.styleFrom(

                      minimumSize: const Size.fromHeight(52),

                      shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(16),

                      ),

                    ),

                    child: Text(

                      AuthStrings.welcomeRegister,

                      style: const TextStyle(

                        fontFamily: AppFonts.body,

                        fontWeight: FontWeight.w600,

                        fontSize: 16,

                      ),

                    ),

                  ),

                  const SizedBox(height: 12),

                  OutlinedButton(

                    onPressed: () {
                      ref.read(guestModeProvider.notifier).disable();
                      context.push(AppRoutes.login);
                    },

                    style: OutlinedButton.styleFrom(

                      minimumSize: const Size.fromHeight(52),

                      shape: RoundedRectangleBorder(

                        borderRadius: BorderRadius.circular(16),

                      ),

                      side: BorderSide(

                        color: theme.colorScheme.primary,

                        width: 1.5,

                      ),

                    ),

                    child: Text(

                      AuthStrings.welcomeLogin,

                      style: TextStyle(

                        fontFamily: AppFonts.body,

                        fontWeight: FontWeight.w600,

                        fontSize: 16,

                        color: theme.colorScheme.primary,

                      ),

                    ),

                  ),

                  const SizedBox(height: 12),

                  TextButton(

                    onPressed: () {

                      ref.read(guestModeProvider.notifier).enable();

                      context.go(AppRoutes.clientHome);

                    },

                    child: Text(

                      AuthStrings.welcomeContinueGuest,

                      style: TextStyle(

                        fontFamily: AppFonts.body,

                        fontWeight: FontWeight.w600,

                        fontSize: 15,

                        color: theme.colorScheme.primary,

                      ),

                    ),

                  ),

                  const SizedBox(height: 8),

                  Text(

                    AuthStrings.welcomeGuestHint,

                    textAlign: TextAlign.center,

                    style: theme.textTheme.bodySmall?.copyWith(

                      fontFamily: AppFonts.body,

                      color: onSurfaceVariant,

                      height: 1.35,

                    ),

                  ),

                  const SizedBox(height: 24),

                ],

              ),

            ),

          ),

        ],

      ),

    );

  }

}



class _WelcomeFeatureRow extends StatelessWidget {

  const _WelcomeFeatureRow({required this.icon, required this.label});



  final IconData icon;

  final String label;



  @override

  Widget build(BuildContext context) {

    final theme = Theme.of(context);



    return Container(

      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),

      decoration: BoxDecoration(

        color: theme.colorScheme.surfaceContainerHighest.withValues(

          alpha: theme.brightness == Brightness.dark ? 0.5 : 0.85,

        ),

        borderRadius: BorderRadius.circular(14),

        border: Border.all(

          color: theme.colorScheme.outline.withValues(alpha: 0.2),

        ),

      ),

      child: Row(

        children: [

          Icon(icon, size: 22, color: theme.colorScheme.primary),

          const SizedBox(width: 12),

          Expanded(

            child: Text(

              label,

              style: theme.textTheme.bodyMedium?.copyWith(

                fontFamily: AppFonts.body,

                fontWeight: FontWeight.w500,

              ),

            ),

          ),

        ],

      ),

    );

  }

}


