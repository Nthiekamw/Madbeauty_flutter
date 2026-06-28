import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../router/app_router.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/layout/auth_brand_background.dart';
import '../../guest/guest_mode_provider.dart';
import '../../providers/pending_ban_notice_provider.dart';
import '../../widgets/auth_marketing_logo.dart';
import '../../widgets/feedback/account_banned_dialog.dart';

/// Hub avant connexion : Inscription / Connexion / mode invité.
class AuthWelcomeScreen extends ConsumerStatefulWidget {
  const AuthWelcomeScreen({super.key});

  @override
  ConsumerState<AuthWelcomeScreen> createState() => _AuthWelcomeScreenState();
}

class _AuthWelcomeScreenState extends ConsumerState<AuthWelcomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _showPendingBanNotice());
  }

  Future<void> _showPendingBanNotice() async {
    if (!mounted) return;
    final notice = ref.read(pendingBanNoticeProvider.notifier).take();
    if (notice == null || !mounted) return;
    final action =
        await AccountBannedDialog.show(context, reason: notice.reason);
    if (!mounted) return;
    if (action == AccountBannedDialogAction.contactSupport) {
      ref.read(guestModeProvider.notifier).disable();
      context.push(AppRoutes.login);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;
    final layout = DiscoveryResponsive.of(context);
    final useWebLayout = layout.useWebAuthFormLayout;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!useWebLayout) ...[
          const SizedBox(height: 24),
          const AuthMarketingLogo(width: 260),
          const Spacer(flex: 2),
        ],
        Text(
          AuthStrings.welcomeTitle,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineLarge?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.5,
            height: 1.1,
            fontSize: useWebLayout ? 32 : null,
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
        const SizedBox(height: 10),
        const _WelcomeFeatureRow(
          icon: Icons.lock_outline,
          label: AuthStrings.welcomeFeatureSecure,
        ),
        if (!useWebLayout) const Spacer(flex: 3),
        if (useWebLayout) const SizedBox(height: 32),
        FilledButton(
          onPressed: () {
            ref.read(guestModeProvider.notifier).disable();
            context.push(AppRoutes.register);
          },
          child: Text(AuthStrings.welcomeRegister),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: () {
            ref.read(guestModeProvider.notifier).disable();
            context.push(AppRoutes.login);
          },
          child: Text(AuthStrings.welcomeLogin),
        ),
        const SizedBox(height: 12),
        TextButton(
          onPressed: () {
            ref.read(guestModeProvider.notifier).enable();
            context.goNamed(AppRouteNames.clientHome);
          },
          child: Text(AuthStrings.welcomeContinueGuest),
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
    );

    return Scaffold(
      backgroundColor: theme.scaffoldBackgroundColor,
      body: Stack(
        fit: StackFit.expand,
        children: [
          const AuthBrandBackground(),
          SafeArea(
            child: useWebLayout
                ? Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: layout.horizontalPadding,
                        vertical: 24,
                      ),
                      child: ConstrainedBox(
                        constraints: BoxConstraints(
                          maxWidth: layout.authFormMaxWidthFor(
                            MediaQuery.sizeOf(context).width,
                          ),
                        ),
                        child: DecoratedBox(
                          decoration: BoxDecoration(
                            color: theme.colorScheme.surface.withValues(
                              alpha: 0.94,
                            ),
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(
                              color: theme.colorScheme.outline
                                  .withValues(alpha: 0.15),
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(28, 32, 28, 28),
                            child: content,
                          ),
                        ),
                      ),
                    ),
                  )
                : Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24),
                    child: content,
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
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.85),
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
