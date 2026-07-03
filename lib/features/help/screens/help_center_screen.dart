import 'package:flutter/material.dart';

import '../../../core/config/legal_urls_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/layout/profile_flow_scaffold.dart';
import '../../../shared/utils/app_url_launcher.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/discovery_menu_tile.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;
    final padding = useWeb
        ? const EdgeInsets.fromLTRB(20, 16, 20, 32)
        : const EdgeInsets.fromLTRB(20, 8, 20, 32);

    return ProfileFlowScaffold(
      title: DiscHelp.screenTitle,
      icon: Icons.help_outline_rounded,
      body: ListView(
        padding: padding,
        children: [
          _Section(
            title: DiscHelp.sectionBooking,
            children: [
              _Tile(
                title: DiscHelp.bookingFlowTitle,
                body: DiscHelp.bookingFlowBody,
              ),
              _Tile(
                title: DiscHelp.cancelPolicyTitle,
                body: DiscHelp.cancelPolicyBody,
              ),
              _Tile(
                title: DiscHelp.waitlistTitle,
                body: DiscHelp.waitlistBody,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: DiscHelp.sectionChat,
            children: [
              _Tile(
                title: DiscHelp.chatPolicyTitle,
                body: DiscHelp.chatPolicyBody,
              ),
              _Tile(
                title: DiscHelp.reportTitle,
                body: DiscHelp.reportBody,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: DiscHelp.sectionReferral,
            children: [
              _Tile(
                title: DiscHelp.referralTitle,
                body: DiscHelp.referralBody,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: DiscHelp.sectionPayment,
            children: [
              _Tile(
                title: DiscHelp.paymentTitle,
                body: DiscHelp.paymentBody,
              ),
            ],
          ),
          const SizedBox(height: 16),
          _Section(
            title: DiscHelp.sectionLegal,
            children: [
              DiscoverySurfaceCard(
                child: DiscoveryMenuTile(
                  icon: Icons.privacy_tip_outlined,
                  title: DiscHelp.privacyPolicyTitle,
                  subtitle: DiscHelp.privacyPolicyHint,
                  onTap: () => _openPrivacyPolicy(context),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Text(
            DiscHelp.contactSupport,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _openPrivacyPolicy(BuildContext context) async {
    final opened = await AppUrlLauncher.openInApp(
      context,
      LegalUrlsConfig.privacyPolicyUrl,
    );
    if (!opened && context.mounted) {
      AppSnackBar.show(
        context,
        message: DiscHelp.openPrivacyPolicyErr,
        kind: AppSnackKind.error,
      );
    }
  }
}

class _Section extends StatelessWidget {
  const _Section({required this.title, required this.children});

  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          title,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w800,
              ),
        ),
        const SizedBox(height: 10),
        ...children,
      ],
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.title, required this.body});

  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: DiscoverySurfaceCard(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              body,
              style: theme.textTheme.bodyMedium?.copyWith(
                height: 1.45,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

