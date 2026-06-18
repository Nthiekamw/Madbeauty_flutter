import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../support/navigation/user_support_navigation.dart';
import '../widgets/workspace/prestataire_brand_scaffold.dart';
import '../../../shared/widgets/discovery/content/discovery_detail_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_menu_tile.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../profile/providers/app_version_provider.dart';
import '../../profile/widgets/account/profile_account_section.dart';
import '../../profile/widgets/layout/profile_footer_actions.dart';
import '../../profile/widgets/sections/profile_appearance_section.dart';
import '../../profile/widgets/sections/profile_preferences_section.dart';
import '../../profile/widgets/sections/profile_role_space_section.dart';
import '../logic/prestataire_profile_completeness.dart';
import '../navigation/prestataire_hub_wizard_navigation.dart';
import '../providers/agenda/disponibilite_provider.dart';
import '../providers/profile/prestataire_profile_form_provider.dart';
import '../widgets/profile/overview/menu/prestataire_profile_account_menu.dart';
import '../widgets/profile/overview/layout/prestataire_profile_insets.dart';
import '../widgets/profile/overview/layout/prestataire_profile_load_error.dart';
import '../widgets/profile/overview/menu/prestataire_profile_manage_menu.dart';
import '../widgets/profile/overview/sections/prestataire_profile_section.dart';
import '../widgets/profile/overview/stats/prestataire_profile_stats_strip.dart';
import '../widgets/prestataire_verification_request_card.dart';
import '../widgets/workspace/prestataire_profile_completion_card.dart';
import '../widgets/workspace/prestataire_profile_summary_card.dart';
import '../widgets/workspace/prestataire_workspace_shell.dart';

/// Onglet Profil de l’espace prestataire (compte + raccourcis pro).
class PrestataireProfileScreen extends ConsumerWidget {
  const PrestataireProfileScreen({super.key});

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

  Future<void> _confirmDeleteAccount(BuildContext context, WidgetRef ref) async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(DiscProfile.deleteAccountTitle),
        content: const Text(DiscProfile.deleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(CoreStrings.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(DiscProfile.deleteAccountConfirm),
          ),
        ],
      ),
    );
    if (go != true || !context.mounted) return;

    try {
      await LocalCacheService.instance.setProfilePushNotificationsEnabled(
        false,
      );
      await LocalCacheService.instance.setProfileGeolocationEnabled(false);
      await ref.read(authNotifierProvider.notifier).signOut();
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: DiscProfile.deleteAccountDone,
          kind: AppSnackKind.success,
        );
      }
    } catch (_) {
      if (context.mounted) {
        AppSnackBar.show(
          context,
          message: DiscProfile.deleteAccountErr,
          kind: AppSnackKind.error,
        );
      }
    }
  }

  Future<void> _refresh(WidgetRef ref) async {
    ref.invalidate(prestataireProfileFormProvider);
    await ref.read(prestataireProfileFormProvider.future);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(prestataireProfileFormProvider);
    final versionAsync = ref.watch(appVersionProvider);

    return PrestataireBrandScaffold(
      body: profileAsync.when(
        loading: () => const PrestataireWorkspaceShell(
          child: DiscoveryDetailSkeleton(),
        ),
        error: (_, __) => PrestataireProfileLoadError(
          onRetry: () => ref.invalidate(prestataireProfileFormProvider),
        ),
        data: (data) {
          final salon = data.nomSalon.trim();
          final title = salon.isNotEmpty ? salon : DiscPrestaProfile.title;
          final complete = data.isProfessionallyComplete;
          final hasHoraires = ref.watch(prestataireHorairesProvider).maybeWhen(
                data: (h) => h.isNotEmpty,
                orElse: () => false,
              );
          final profession = data.description.trim().isNotEmpty
              ? data.description.trim().split('\n').first
              : DiscPrestaProfile.pageSubtitle;

          return PrestataireWorkspaceShell(
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
                  const PrestataireProfileCompletionCard(),
                  PrestataireProfileSummaryCard(
                    title: title,
                    subtitle: profession,
                    avatarUrl: data.avatarUrl,
                    trailingBadge: prestataireFreePlanBadge(context),
                    onTap: () => context.pushPrestataireProfileEdit(),
                  ),
                  Padding(
                    padding: PrestataireProfileInsets.page(context).copyWith(
                      top: PrestataireProfileInsets.sectionTop,
                    ),
                    child: const ProfileRoleSpaceSection(),
                  ),
                  if (!complete)
                    Padding(
                      padding: PrestataireProfileInsets.page(context)
                          .copyWith(top: 12),
                      child: FilledButton.icon(
                        onPressed: () =>
                            PrestataireHubWizardNavigation.openWizard(
                          context,
                          initialStep: PrestataireHubWizardNavigation
                              .hubStepFromProfileData(
                            data,
                            hasHoraires: hasHoraires,
                          ),
                        ),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text(DiscPrestaProfile.incompleteCta),
                      ),
                    ),
                  if (complete) ...[
                    Padding(
                      padding: PrestataireProfileInsets.page(context)
                          .copyWith(top: 12),
                      child: const PrestataireVerificationRequestCard(),
                    ),
                    PrestataireProfileStatsStrip(
                      servicesCount: data.services.length,
                      specialtiesCount: data.selectedCategoryIds.length,
                      photosCount: data.realisationPhotos.length,
                    ),
                  ],
                  PrestataireProfileSection(
                    title: DiscPrestaProfile.sectionActivity,
                    icon: Icons.dashboard_customize_outlined,
                    children: [
                      const PrestataireProfileManageMenu(showHeader: true),
                      if (data.prestataireId != null)
                        DiscoverySurfaceCard(
                          child: DiscoveryMenuTile(
                            icon: Icons.visibility_rounded,
                            title: DiscPrestaProfile.publicFiche,
                            subtitle: DiscPrestaProfile.publicFicheHint,
                            onTap: () => context.pushPrestataireDetail(
                              data.prestataireId!,
                            ),
                          ),
                        ),
                    ],
                  ),
                  Padding(
                    padding: PrestataireProfileInsets.page(context).copyWith(
                      top: PrestataireProfileInsets.sectionTop,
                    ),
                    child: const ProfileAppearanceSection(),
                  ),
                  Padding(
                    padding: PrestataireProfileInsets.page(context).copyWith(
                      top: PrestataireProfileInsets.sectionTop,
                    ),
                    child: const ProfilePreferencesSection(),
                  ),
                  Padding(
                    padding: PrestataireProfileInsets.page(context).copyWith(
                      top: PrestataireProfileInsets.sectionTop,
                    ),
                    child: const ProfileAccountSection(
                      menuPrefix: PrestataireProfileAccountMenu(),
                      showClientPaymentMethods: false,
                      showClientReviews: false,
                    ),
                  ),
                  Padding(
                    padding: PrestataireProfileInsets.page(context)
                        .copyWith(top: PrestataireProfileInsets.sectionTop),
                    child: ProfileFooterActions(
                      onSupportUser: () => openUserSupportChat(context, ref),
                      onSignOut: () => _signOut(context, ref),
                      onDeleteAccount: () =>
                          _confirmDeleteAccount(context, ref),
                    ),
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
