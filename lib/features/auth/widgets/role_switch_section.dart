import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/user_role.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/discovery_menu_tile.dart';
import '../../prestataire/navigation/prestataire_navigation.dart';
import '../navigation/client_navigation.dart';
import '../providers/my_roles_provider.dart';

/// Bascule client ↔ prestataire (profil client, dashboard pro, etc.).
class RoleSwitchSection extends ConsumerWidget {
  const RoleSwitchSection({
    super.key,
    this.sectionTitle,
    this.padding = const EdgeInsets.symmetric(horizontal: 0),
  });

  final String? sectionTitle;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final rolesAsync = ref.watch(myRolesProvider);
    final cachedRole = LocalCacheService.instance.selectedRole;

    return Padding(
      padding: padding,
      child: rolesAsync.when(
        data: (roles) {
          final hasClient = roles.contains(UserRole.client);
          final hasPresta = roles.contains(UserRole.prestataire);

          if (!hasClient && !hasPresta) {
            return const SizedBox.shrink();
          }

          final children = <Widget>[];

          if (sectionTitle != null && sectionTitle!.isNotEmpty) {
            children.add(
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                child: Text(
                  sectionTitle!,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
            );
          }

          if (hasClient && hasPresta) {
            children.add(
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
                child: Text(
                  AuthStrings.profileDualRoleHint,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              ),
            );
            children.add(
              _RoleSwitchTile(
                icon: Icons.person_outline,
                title: AuthStrings.profileSwitchToClient,
                isCurrent: cachedRole == 'client',
                onTap: cachedRole == 'client'
                    ? null
                    : () => ClientNavigation.switchToClientSpace(context, ref),
              ),
            );
            children.add(
              _RoleSwitchTile(
                icon: Icons.storefront_outlined,
                title: AuthStrings.profileSwitchToPresta,
                isCurrent: cachedRole == 'prestataire',
                onTap: cachedRole == 'prestataire'
                    ? null
                    : () =>
                        PrestataireNavigation.switchToPrestataireSpace(
                          context,
                          ref,
                        ),
              ),
            );
          } else if (hasClient && !hasPresta) {
            children.add(
              _RoleSwitchTile(
                icon: Icons.storefront_outlined,
                title: AuthStrings.profileBecomePresta,
                subtitle: 'Ajoute ton activité et passe en espace pro',
                showChevron: true,
                onTap: () => context.goBecomePrestataire(),
              ),
            );
          }

          if (children.isEmpty) {
            return const SizedBox.shrink();
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: children,
          );
        },
        loading: () => const Padding(
          padding: EdgeInsets.all(24),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            e.toString(),
            style: TextStyle(color: theme.colorScheme.error),
          ),
        ),
      ),
    );
  }
}

class _RoleSwitchTile extends StatelessWidget {
  const _RoleSwitchTile({
    required this.icon,
    required this.title,
    this.subtitle,
    this.isCurrent = false,
    this.showChevron = false,
    this.onTap,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final bool isCurrent;
  final bool showChevron;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return DiscoveryMenuTile(
      icon: icon,
      title: title,
      subtitle: isCurrent ? 'Actuel' : subtitle,
      onTap: onTap,
      showChevron: showChevron || (!isCurrent && onTap != null),
    );
  }
}
