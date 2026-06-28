import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import 'discovery_responsive.dart';
import 'shell_nav_destination.dart';
import 'web_shell_content_frame.dart';
import '../widgets/layout/web_site_header.dart';

/// Shell adaptatif : barre du bas (mobile) ou rail latéral (web desktop).
class AdaptiveShellScaffold extends StatelessWidget {
  const AdaptiveShellScaffold({
    super.key,
    required this.body,
    required this.selectedIndex,
    required this.onDestinationSelected,
    required this.destinations,
    required this.bottomNavigationBar,
    this.pageTitle,
    this.railSpaceLabel = 'Espace client',
  });

  final Widget body;
  final int selectedIndex;
  final ValueChanged<int> onDestinationSelected;
  final List<ShellNavDestination> destinations;
  final Widget bottomNavigationBar;
  final String? pageTitle;
  final String railSpaceLabel;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);

    if (!layout.useSidebarNavigation) {
      return Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: body,
        bottomNavigationBar: bottomNavigationBar,
      );
    }

    final theme = Theme.of(context);
    final extended = layout.width >= DiscoveryResponsive.desktopBreakpoint;
    final railWidth = extended ? 248.0 : 80.0;

    return Scaffold(
      backgroundColor: theme.colorScheme.surfaceContainerLowest,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: railWidth,
            child: Material(
              elevation: theme.brightness == Brightness.light ? 1 : 0,
              shadowColor: AppColors.brandBrown.withValues(alpha: 0.08),
              color: theme.colorScheme.surface,
              child: NavigationRail(
                extended: extended,
                minExtendedWidth: 220,
                minWidth: 72,
                groupAlignment: -0.92,
                useIndicator: true,
                indicatorColor: theme.colorScheme.primary.withValues(alpha: 0.14),
                indicatorShape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                selectedIconTheme: IconThemeData(
                  color: theme.colorScheme.primary,
                  size: 24,
                ),
                unselectedIconTheme: IconThemeData(
                  color: theme.colorScheme.onSurfaceVariant,
                  size: 22,
                ),
                selectedLabelTextStyle: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
                unselectedLabelTextStyle: theme.textTheme.labelMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
                selectedIndex: selectedIndex,
                onDestinationSelected: onDestinationSelected,
                labelType: extended
                    ? NavigationRailLabelType.none
                    : NavigationRailLabelType.selected,
                leading: extended
                    ? Padding(
                        padding: const EdgeInsets.fromLTRB(16, 20, 16, 12),
                        child: _WebRailBrand(
                          theme: theme,
                          spaceLabel: railSpaceLabel,
                        ),
                      )
                    : const SizedBox(height: 12),
                trailing: extended
                    ? Padding(
                        padding: const EdgeInsets.only(bottom: 16),
                        child: Text(
                          '© MadBeauty',
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.65),
                          ),
                        ),
                      )
                    : null,
                destinations: [
                  for (final item in destinations)
                    NavigationRailDestination(
                      icon: _navIcon(
                        item.outlinedIcon,
                        item.filledIcon,
                        selected: false,
                        badgeCount: item.badgeCount,
                      ),
                      selectedIcon: _navIcon(
                        item.outlinedIcon,
                        item.filledIcon,
                        selected: true,
                        badgeCount: item.badgeCount,
                      ),
                      label: Text(item.label),
                    ),
                ],
              ),
            ),
          ),
          VerticalDivider(
            width: 1,
            thickness: 1,
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                if (!extended)
                  WebSiteHeader(pageTitle: pageTitle),
                Expanded(
                  child: WebShellContentFrame(
                    applyHorizontalPadding: false,
                    child: body,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WebRailBrand extends StatelessWidget {
  const _WebRailBrand({
    required this.theme,
    required this.spaceLabel,
  });

  final ThemeData theme;
  final String spaceLabel;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: Image.asset(
            'assets/images/logo.png',
            width: 48,
            height: 48,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'MadBeauty',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
              Text(
                spaceLabel,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

Widget _navIcon(
  IconData outlined,
  IconData filled, {
  required bool selected,
  int badgeCount = 0,
}) {
  final icon = Icon(selected ? filled : outlined);
  if (badgeCount <= 0) return icon;
  final label = badgeCount > 99 ? '99+' : '$badgeCount';
  return Badge(
    label: Text(label, style: const TextStyle(fontSize: 10)),
    child: icon,
  );
}
