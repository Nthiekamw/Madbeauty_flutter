import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery/discovery_menu_tile.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../profile/providers/app_version_provider.dart';
import '../../profile/widgets/profile_account_section.dart';
import '../../profile/widgets/profile_footer_actions.dart';
import '../../profile/widgets/profile_preferences_section.dart';
import '../../profile/widgets/profile_role_space_section.dart';
import '../logic/prestataire_profile_completeness.dart';
import '../providers/prestataire_profile_form_provider.dart';
import '../widgets/profile/prestataire_profile_load_error.dart';
import '../widgets/profile/prestataire_profile_manage_menu.dart';
import '../widgets/profile/prestataire_profile_messages_tile.dart';
import '../widgets/profile/prestataire_profile_stats_strip.dart';
import '../widgets/profile/prestataire_stripe_connect_tile.dart';
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
    final hPad = DiscoveryResponsive.of(context).horizontalPadding;

    return DiscoveryBrandScaffold(
      body: profileAsync.when(
        loading: () => const PrestataireWorkspaceShell(
          child: Center(child: CircularProgressIndicator()),
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
            onRefresh: () => _refresh(ref),
            child: RefreshIndicator(
              onRefresh: () => _refresh(ref),
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.only(bottom: 32),
                children: [
                  const PrestataireProfileCompletionCard(),
                  PrestataireProfileSummaryCard(
                    title: title,
                    subtitle: profession,
                    avatarUrl: data.avatarUrl,
                    trailingBadge: prestataireFreePlanBadge(context),
                    onTap: () => context.pushPrestataireProfileEdit(),
                  ),
                  if (!complete) ...[
                    const SizedBox(height: 12),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: FilledButton.icon(
                        onPressed: () =>
                            context.pushPrestataireProfileComplete(),
                        icon: const Icon(Icons.arrow_forward_rounded),
                        label: const Text(DiscPrestaProfile.incompleteCta),
                      ),
                    ),
                  ],
                  if (complete) ...[
                    const SizedBox(height: 8),
                    PrestataireProfileStatsStrip(
                      servicesCount: data.services.length,
                      specialtiesCount: data.selectedCategoryIds.length,
                      photosCount: data.realisationPhotos.length,
                    ),
                  ],
                  const SizedBox(height: 16),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Text(
                      DiscPrestaWorkspace.profileMenuTitle,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: PrestataireProfileMessagesTile(),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: PrestataireStripeConnectTile(),
                  ),
                  const SizedBox(height: 10),
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 20),
                    child: PrestataireProfileManageMenu(showHeader: false),
                  ),
                  if (data.prestataireId != null) ...[
                    const SizedBox(height: 10),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 20),
                      child: DiscoverySurfaceCard(
                        child: DiscoveryMenuTile(
                          icon: Icons.visibility_rounded,
                          title: DiscPrestaProfile.publicFiche,
                          subtitle: DiscPrestaProfile.publicFicheHint,
                          onTap: () => context.pushPrestataireDetail(
                            data.prestataireId!,
                          ),
                        ),
                      ),
                    ),
                  ],
                  const SizedBox(height: 16),
                  const ProfilePreferencesSection(),
                  const SizedBox(height: 10),
                  const ProfileRoleSpaceSection(),
                  const SizedBox(height: 10),
                  const ProfileAccountSection(),
                  const SizedBox(height: 16),
                  ProfileFooterActions(
                    onSignOut: () => _signOut(context, ref),
                    onDeleteAccount: () => _confirmDeleteAccount(context, ref),
                  ),
                  const SizedBox(height: 16),
                  versionAsync.when(
                    data: (version) => Padding(
                      padding: EdgeInsets.symmetric(horizontal: hPad),
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
