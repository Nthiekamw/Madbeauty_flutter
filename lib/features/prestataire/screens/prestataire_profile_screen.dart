import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/discovery_menu_tile.dart';
import '../../../shared/widgets/discovery_surface_card.dart';
import '../../../shared/widgets/prototype/prototype_tab_body.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../auth/widgets/role_switch_section.dart';
import '../../profile/providers/app_version_provider.dart';
import '../logic/prestataire_profile_completeness.dart';
import '../providers/prestataire_profile_form_provider.dart';
import '../models/prestataire_profile_edit_section.dart';
import '../widgets/prestataire_client_experience_section.dart';
import '../widgets/prestataire_completeness_badge.dart';
import '../widgets/prestataire_profile_load_error.dart';
import '../widgets/prestataire_profile_manage_menu.dart';
import '../widgets/prestataire_profile_stats_strip.dart';
import '../widgets/prestataire_section_header.dart';
import '../../../shared/widgets/app_avatar.dart';

/// Onglet Profil de l’espace prestataire (compte + raccourcis pro).
class PrestataireProfileScreen extends ConsumerWidget {
  const PrestataireProfileScreen({super.key});

  Future<void> _confirmSignOut(BuildContext context, WidgetRef ref) async {
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
    final email = ref.watch(authNotifierProvider).value?.email?.trim() ?? '';

    return PrototypeTabBody(
      child: profileAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => PrestataireProfileLoadError(
          onRetry: () => ref.invalidate(prestataireProfileFormProvider),
        ),
        data: (data) {
          final salon = data.nomSalon.trim();
          final ville = data.ville.trim();
          final title = salon.isNotEmpty ? salon : DiscPrestaProfile.title;
          final complete = data.isProfessionallyComplete;
          final subtitle = [
            if (ville.isNotEmpty) ville,
            complete ? DiscPrestaDash.welcome : DiscPrestaDash.profileMissing,
          ].join(' · ');

          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 20, 16, 32),
            children: [
              DiscoverySurfaceCard(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    AppAvatar(
                      imageUrl: data.avatarUrl,
                      displayName: title,
                      radius: 40,
                    ),
                    const SizedBox(height: 12),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                    const SizedBox(height: 12),
                    PrestataireCompletenessBadge(complete: complete),
                  ],
                ),
              ),
              if (!complete) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DiscoverySurfaceCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PrestataireSectionHeader(
                          icon: Icons.auto_awesome_rounded,
                          title: DiscPrestaProfile.incompleteTitle,
                          subtitle: DiscPrestaProfile.incompleteBody,
                          iconColor: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(height: 16),
                        FilledButton.icon(
                          onPressed: () =>
                              context.pushPrestataireProfileComplete(),
                          icon: const Icon(Icons.arrow_forward_rounded),
                          label: const Text(DiscPrestaProfile.incompleteCta),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (complete) ...[
                PrestataireProfileStatsStrip(
                  servicesCount: data.services.length,
                  specialtiesCount: data.selectedCategoryIds.length,
                  photosCount: data.realisationPhotos.length,
                ),
                if (data.bio.trim().isNotEmpty) ...[
                  const SizedBox(height: 16),
                  DiscoverySurfaceCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PrestataireSectionHeader(
                          icon: Icons.format_quote_rounded,
                          title: DiscPrestaProfile.sectionBio,
                          iconColor: theme.colorScheme.primary,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          data.bio.trim(),
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
              const SizedBox(height: 16),
              if (data.confortClient.isNotEmpty ||
                  data.conditionsService.isNotEmpty)
                PrestataireClientExperienceSection(
                  comfortIds: data.confortClient,
                  conditionIds: data.conditionsService,
                )
              else
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DiscoverySurfaceCard(
                    padding: const EdgeInsets.all(18),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        PrestataireSectionHeader(
                          icon: Icons.favorite_outline_rounded,
                          title: DiscPrestaComfort.sectionComfortTitle,
                          subtitle: DiscPrestaComfort.emptyComfort,
                          iconColor: theme.colorScheme.tertiary,
                        ),
                        const SizedBox(height: 14),
                        OutlinedButton.icon(
                          onPressed: () => context.pushPrestataireProfileEditSection(
                            PrestataireProfileEditSection.clientExperience,
                          ),
                          icon: const Icon(Icons.edit_outlined),
                          label: const Text(DiscPrestaComfort.menuTitle),
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              const PrestataireProfileManageMenu(),
              if (data.prestataireId != null) ...[
                const SizedBox(height: 16),
                DiscoverySurfaceCard(
                  child: DiscoveryMenuTile(
                    icon: Icons.visibility_rounded,
                    title: DiscPrestaProfile.publicFiche,
                    subtitle: DiscPrestaProfile.publicFicheHint,
                    onTap: () =>
                        context.pushPrestataireDetail(data.prestataireId!),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              DiscoverySurfaceCard(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PrestataireSectionHeader(
                      icon: Icons.swap_horiz_rounded,
                      title: DiscNav.profileSpace,
                      subtitle: DiscPrestaProfile.sectionSpaceHint,
                      iconColor: theme.colorScheme.secondary,
                    ),
                    const SizedBox(height: 4),
                    const RoleSwitchSection(padding: EdgeInsets.zero),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              DiscoverySurfaceCard(
                padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    PrestataireSectionHeader(
                      icon: Icons.manage_accounts_rounded,
                      title: DiscPrestaProfile.sectionAccount,
                      subtitle: DiscPrestaProfile.sectionAccountHint,
                    ),
                    if (email.isNotEmpty) ...[
                      const SizedBox(height: 8),
                      Divider(
                        height: 1,
                        color: theme.colorScheme.outline.withValues(
                          alpha: 0.12,
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 4,
                          vertical: 12,
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.mail_outline_rounded,
                              size: 22,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Text(
                                email,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  fontFamily: AppFonts.body,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                    Divider(
                      height: 1,
                      color: theme.colorScheme.outline.withValues(alpha: 0.12),
                    ),
                    DiscoveryMenuTile(
                      icon: Icons.logout_rounded,
                      title: ShellStrings.accountActionSignOut,
                      onTap: () => _confirmSignOut(context, ref),
                      destructive: true,
                      showChevron: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 24),
              versionAsync.when(
                data: (version) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    '${ShellStrings.profileVersionLabel} $version',
                    textAlign: TextAlign.center,
                    style: theme.textTheme.bodySmall?.copyWith(
                      fontFamily: AppFonts.body,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                loading: () => const SizedBox(height: 24),
                error: (_, __) => const SizedBox(height: 24),
              ),
            ],
          );
        },
      ),
    );
  }
}
