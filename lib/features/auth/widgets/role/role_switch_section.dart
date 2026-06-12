import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_area.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/user_role.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../services/supabase/profile/client_profile_providers.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../../../../shared/widgets/discovery/content/discovery_shimmer.dart';
import '../../../prestataire/navigation/prestataire_navigation.dart';
import '../../../prestataire/providers/profile/current_prestataire_provider.dart';
import '../../navigation/client_navigation.dart';
import '../../providers/my_roles_provider.dart';
import 'become_prestataire_cta_card.dart';
import 'role_space_card.dart';

/// Bascule client â†” prestataire avec cartes visuelles.
class RoleSwitchSection extends ConsumerWidget {
  const RoleSwitchSection({
    super.key,
    this.sectionTitle,
    this.padding = const EdgeInsets.symmetric(horizontal: 0),
    this.showHeader = true,
    this.compact = false,
    this.forceTwoColumns = false,
  });

  final String? sectionTitle;
  final EdgeInsetsGeometry padding;
  final bool showHeader;
  final bool compact;
  final bool forceTwoColumns;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rolesAsync = ref.watch(myRolesProvider);
    final prestaProfileAsync = ref.watch(currentPrestataireProvider);
    final clientProfileAsync = ref.watch(currentClientProfileProvider);
    final activeRole = _activeRoleFromContext(context);

    return Padding(
      padding: padding,
      child: rolesAsync.when(
        data: (roles) {
          final hasClientByRole = roles.contains(UserRole.client);
          final hasPrestaByRole = roles.contains(UserRole.prestataire);
          final hasPrestaByProfile = switch (prestaProfileAsync) {
            AsyncData(:final value) => value != null,
            _ => false,
          };
          final hasPresta =
              hasPrestaByRole || hasPrestaByProfile || activeRole == 'prestataire';

          final hasClientByProfile = switch (clientProfileAsync) {
            AsyncData(:final value) => value != null,
            _ => false,
          };
          final hasClient = hasClientByRole || hasClientByProfile;

          /// Même logique que le profil prestataire : évite une zone vide si
          /// `user_roles` n'a pas encore (ou pas) la ligne « client ».
          final awaitingClientProfile = !hasClientByRole &&
              !hasPresta &&
              clientProfileAsync.isLoading;
          if (awaitingClientProfile) {
            return const DiscoveryInlineSkeleton(
              height: 88,
              padding: EdgeInsets.all(24),
            );
          }

          if (!hasClient && !hasPresta) {
            return const SizedBox.shrink();
          }

          final title = sectionTitle ?? DiscProfile.roleSpaceTitle;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (showHeader) ...[
                Text(
                  title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                    fontSize: compact ? 13 : null,
                  ),
                ),
                SizedBox(height: compact ? 8 : 6),
              ],
              if (hasClient && hasPresta) ...[
                if (!compact)
                  Text(
                    DiscProfile.roleSpaceDualHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                if (!compact) const SizedBox(height: 10),
                _RoleSpaceCards(
                  compact: compact,
                  stackVertically: !forceTwoColumns &&
                      DiscoveryResponsive.of(context).stackRoleSpaceCards,
                  activeRole: activeRole,
                  onClientTap: activeRole == 'client'
                      ? null
                      : () => ClientNavigation.switchToClientSpace(
                          context,
                          ref,
                        ),
                  onPrestaTap: activeRole == 'prestataire'
                      ? null
                      : () => PrestataireNavigation.switchToPrestataireSpace(
                          context,
                          ref,
                        ),
                ),
              ] else if (hasClient && !hasPresta) ...[
                BecomePrestataireCtaCard(
                  onTap: () => context.pushBecomePrestataire(),
                ),
              ],
            ],
          );
        },
        loading: () => const DiscoveryInlineSkeleton(
          height: 88,
          padding: EdgeInsets.all(24),
        ),
        error: (e, _) => DiscoverySectionError(
          message: CoreStrings.networkErrorBody,
          onRetry: () {
            ref.invalidate(myRolesProvider);
            ref.invalidate(currentClientProfileProvider);
            ref.invalidate(currentPrestataireProvider);
          },
        ),
      ),
    );
  }

  /// Espace affiché (route), pas seulement le cache – évite un switch inversé.
  static String _activeRoleFromContext(BuildContext context) {
    final path = GoRouterState.of(context).uri.path;
    return switch (appAreaFromPath(path)) {
      AppArea.prestataire => 'prestataire',
      AppArea.client => 'client',
    };
  }
}

class _RoleSpaceCards extends StatelessWidget {
  const _RoleSpaceCards({
    required this.compact,
    required this.stackVertically,
    required this.activeRole,
    required this.onClientTap,
    required this.onPrestaTap,
  });

  final bool compact;
  final bool stackVertically;
  final String activeRole;
  final VoidCallback? onClientTap;
  final VoidCallback? onPrestaTap;

  @override
  Widget build(BuildContext context) {
    final clientCard = RoleSpaceCard(
      compact: compact,
      icon: Icons.person_rounded,
      title: DiscProfile.roleClientTitle,
      subtitle: DiscProfile.roleClientSub,
      isActive: activeRole == 'client',
      onTap: onClientTap,
    );
    final prestaCard = RoleSpaceCard(
      compact: compact,
      icon: Icons.storefront_rounded,
      title: DiscProfile.rolePrestaTitle,
      subtitle: DiscProfile.rolePrestaSub,
      isActive: activeRole == 'prestataire',
      onTap: onPrestaTap,
    );

    if (stackVertically) {
      return Column(
        children: [
          clientCard,
          SizedBox(height: compact ? 8 : 10),
          prestaCard,
        ],
      );
    }

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Expanded(child: clientCard),
          SizedBox(width: compact ? 8 : 10),
          Expanded(child: prestaCard),
        ],
      ),
    );
  }
}

