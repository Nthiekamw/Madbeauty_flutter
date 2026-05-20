import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery_menu_tile.dart';
import '../../../shared/widgets/discovery_screen_header.dart';
import '../../../shared/widgets/discovery_surface_card.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../auth/widgets/role_switch_section.dart';
import '../../profile/providers/app_version_provider.dart';
import '../logic/prestataire_profile_completeness.dart';
import '../providers/prestataire_profile_form_provider.dart';
import '../widgets/prestataire_profile_load_error.dart';
import '../widgets/prestataire_profile_manage_menu.dart';
import '../widgets/prestataire_salon_hero.dart';

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

    return DiscoveryBrandScaffold(
      body: profileAsync.when(
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
            padding: const EdgeInsets.only(bottom: 32),
            children: [
              const DiscoveryScreenHeader(
                title: DiscPrestaProfile.title,
                subtitle: DiscPrestaProfile.pageSubtitle,
              ),
              PrestataireSalonHero(
                title: title,
                subtitle: subtitle,
                avatarUrl: data.avatarUrl,
                trailing: _CompletenessChip(complete: complete),
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
                        Text(
                          DiscPrestaProfile.incompleteTitle,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontFamily: AppFonts.display,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          DiscPrestaProfile.incompleteBody,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                            height: 1.4,
                          ),
                        ),
                        const SizedBox(height: 14),
                        FilledButton(
                          onPressed: () =>
                              context.pushPrestataireProfileComplete(),
                          child: const Text(DiscPrestaProfile.incompleteCta),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (complete && data.bio.trim().isNotEmpty) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Text(
                    data.bio.trim(),
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ),
              ],
              if (complete) ...[
                const SizedBox(height: 12),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _StatChip(
                        icon: Icons.design_services_outlined,
                        label: DiscPrestaProfile.servicesCount(
                          data.services.length,
                        ),
                      ),
                      _StatChip(
                        icon: Icons.category_outlined,
                        label: DiscPrestaProfile.specialtiesCount(
                          data.selectedCategoryIds.length,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              const PrestataireProfileManageMenu(),
              if (data.prestataireId != null) ...[
                const SizedBox(height: 16),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: DiscoverySurfaceCard(
                    child: DiscoveryMenuTile(
                      icon: Icons.visibility_rounded,
                      title: DiscPrestaProfile.publicFiche,
                      onTap: () =>
                          context.pushPrestataireDetail(data.prestataireId!),
                    ),
                  ),
                ),
              ],
              const SizedBox(height: 16),
              DiscoverySurfaceCard(
                child: const RoleSwitchSection(
                  sectionTitle: DiscNav.profileSpace,
                  padding: EdgeInsets.zero,
                ),
              ),
              if (email.isNotEmpty) ...[
                const SizedBox(height: 16),
                DiscoverySurfaceCard(
                  padding: const EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(
                        Icons.mail_outline_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DiscPrestaProfile.sectionAccount,
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontFamily: AppFonts.body,
                                fontWeight: FontWeight.w700,
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              email,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: AppFonts.body,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 16),
              DiscoverySurfaceCard(
                child: DiscoveryMenuTile(
                  icon: Icons.logout_rounded,
                  title: ShellStrings.accountActionSignOut,
                  onTap: () => _confirmSignOut(context, ref),
                  destructive: true,
                  showChevron: false,
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

class _CompletenessChip extends StatelessWidget {
  const _CompletenessChip({required this.complete});

  final bool complete;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: complete
            ? theme.colorScheme.primary.withValues(alpha: 0.14)
            : theme.colorScheme.errorContainer.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        complete ? DiscPrestaDash.welcome : DiscPrestaDash.profileMissing,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: complete
              ? theme.colorScheme.primary
              : theme.colorScheme.onErrorContainer,
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.5 : 0.85,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.16),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(
            label,
            style: theme.textTheme.labelLarge?.copyWith(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
