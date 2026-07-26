import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/widgets/discovery/content/discovery_detail_skeleton.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../profile/logic/account_deletion_flow.dart';
import '../../profile/providers/app_version_provider.dart';
import '../../profile/widgets/layout/profile_footer_actions.dart';
import '../../profile/widgets/sections/profile_role_space_section.dart';
import '../../support/navigation/user_support_navigation.dart';
import '../logic/prestataire_profile_completeness.dart';
import '../providers/profile/prestataire_profile_form_provider.dart';
import '../widgets/profile/overview/layout/prestataire_profile_insets.dart';
import '../widgets/profile/overview/layout/prestataire_profile_load_error.dart';
import '../widgets/profile/overview/menu/prestataire_profile_hub_grid.dart';
import '../widgets/profile/overview/sections/prestataire_profile_section.dart';
import '../widgets/profile/overview/stats/prestataire_profile_stats_strip.dart';
import '../widgets/workspace/prestataire_brand_scaffold.dart';
import '../widgets/workspace/prestataire_profile_completion_card.dart';
import '../widgets/workspace/prestataire_profile_summary_card.dart';
import '../widgets/workspace/prestataire_workspace_shell.dart';

/// Onglet Profil presta — cockpit court (hub A).
///
/// Ordre : identité → alerte complétion → stats → raccourcis → espace → compte.
class PrestataireProfileScreen extends ConsumerWidget {
  const PrestataireProfileScreen({super.key});

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(prestataireProfileFormProvider);
    await ref.read(prestataireProfileFormProvider.future);
  }

  Future<void> _signOut(BuildContext context, WidgetRef ref) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(ShellStrings.accountSignOutConfirmTitle),
        content: const Text(ShellStrings.accountSignOutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(CoreStrings.actionCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(ShellStrings.accountActionSignOut),
          ),
        ],
      ),
    );
    if (go != true || !context.mounted) return;
    await ref.read(authNotifierProvider.notifier).signOut();
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(prestataireProfileFormProvider);
    final versionAsync = ref.watch(appVersionProvider);

    return PrestataireBrandScaffold(
      body: profileAsync.when(
        loading: () => const PrestataireWorkspaceShell(
          title: ShellStrings.navPrestataireProfile,
          subtitle: DiscPrestaWorkspace.profileHeaderSubtitle,
          child: DiscoveryDetailSkeleton(),
        ),
        error: (_, __) => PrestataireProfileLoadError(
          onRetry: () => ref.invalidate(prestataireProfileFormProvider),
        ),
        data: (data) {
          final salon = data.nomSalon.trim();
          final title = salon.isNotEmpty ? salon : DiscPrestaProfile.title;
          final complete = data.isProfessionallyComplete;
          final profession = data.description.trim().isNotEmpty
              ? data.description.trim().split('\n').first
              : DiscPrestaProfile.pageSubtitle;

          return PrestataireWorkspaceShell(
            title: ShellStrings.navPrestataireProfile,
            subtitle: DiscPrestaWorkspace.profileHeaderSubtitle,
            onRefresh: () => _refresh(ref),
            headerSubtitle: DiscPrestaWorkspace.profileHeaderSubtitle,
            child: RefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: EdgeInsets.only(
                  bottom: PrestataireProfileInsets.listBottom(context),
                ),
                children: [
                  // 1. Identité salon
                  PrestataireProfileSummaryCard(
                    title: title,
                    subtitle: profession,
                    avatarUrl: data.avatarUrl,
                    trailingBadge: prestataireFreePlanBadge(context),
                    onTap: () => context.pushPrestataireProfileSalon(),
                  ),
                  // 2. Progression profil (si incomplet)
                  const PrestataireProfileCompletionCard(),
                  // 3. Stats activité
                  if (complete)
                    PrestataireProfileStatsStrip(
                      servicesCount: data.services.length,
                      specialtiesCount: data.selectedCategoryIds.length,
                      photosCount: data.realisationPhotos.length,
                    ),
                  // 4. Navigation métier
                  PrestataireProfileSection(
                    title: DiscPrestaProfile.hubSectionTitle,
                    icon: Icons.apps_rounded,
                    children: const [
                      PrestataireProfileHubGrid(),
                    ],
                  ),
                  // 5. Basculer d’espace
                  PrestataireProfileSection(
                    title: DiscProfile.roleSpaceTitle,
                    icon: Icons.swap_horiz_rounded,
                    children: const [
                      ProfileRoleSpaceSection(showHeader: false),
                    ],
                  ),
                  // 6. Support / session
                  PrestataireProfileSection(
                    title: DiscProfile.sectionAccount,
                    icon: Icons.manage_accounts_outlined,
                    children: [
                      ProfileFooterActions(
                        onSupportUser: () =>
                            openUserSupportChat(context, ref),
                        onSignOut: () => _signOut(context, ref),
                        onDeleteAccount: () => runAccountDeletionRequestFlow(
                          context: context,
                          ref: ref,
                        ),
                      ),
                    ],
                  ),
                  versionAsync.when(
                    data: (version) => Padding(
                      padding: PrestataireProfileInsets.page(context)
                          .copyWith(top: 12),
                      child: Text(
                        '${ShellStrings.profileVersionLabel} $version',
                        textAlign: TextAlign.center,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                    loading: () => const SizedBox(height: 24),
                    error: (_, __) => const SizedBox(height: 24),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
