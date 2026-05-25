import 'package:flutter/material.dart';

import '../../theme/prototype_layout.dart';
import '../../theme/prototype_palette.dart';

class PrototypeNavDestination {
  const PrototypeNavDestination({
    required this.icon,
    required this.selectedIcon,
    required this.label,
    this.badgeCount = 0,
  });

  final IconData icon;
  final IconData selectedIcon;
  final String label;
  final int badgeCount;
}

/// Barre de navigation basse style Madbeauty_flutter (fond clair, pill or).
class PrototypeLightBottomNav extends StatelessWidget {
  const PrototypeLightBottomNav({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onTap,
  });

  final int selectedIndex;
  final List<PrototypeNavDestination> destinations;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final layout = PrototypeLayout(context);
    final rem = layout.rem;

    return Container(
      height: MediaQuery.sizeOf(context).height * 0.082,
      decoration: BoxDecoration(
        color: PrototypePalette.cardWhite,
        border: const Border(top: BorderSide(color: PrototypePalette.goldLight)),
        boxShadow: PrototypePalette.navTopShadow,
      ),
      child: Row(
        children: [
          for (var i = 0; i < destinations.length; i++)
            _LightNavBtn(
              destination: destinations[i],
              index: i,
              selected: i == selectedIndex,
              rem: rem,
              onTap: () => onTap(i),
            ),
        ],
      ),
    );
  }
}

class _LightNavBtn extends StatelessWidget {
  const _LightNavBtn({
    required this.destination,
    required this.index,
    required this.selected,
    required this.rem,
    required this.onTap,
  });

  final PrototypeNavDestination destination;
  final int index;
  final bool selected;
  final double rem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final iconWidget = Icon(
      selected ? destination.selectedIcon : destination.icon,
      size: rem * 6,
      color: selected ? PrototypePalette.gold : PrototypePalette.textGrey,
    );

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              padding: EdgeInsets.symmetric(
                horizontal: rem * 3.5,
                vertical: rem * 1.2,
              ),
              decoration: BoxDecoration(
                color: selected
                    ? PrototypePalette.goldLight
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(rem * 4),
              ),
              child: destination.badgeCount > 0
                  ? Badge(
                      label: Text(
                        destination.badgeCount > 99
                            ? '99+'
                            : '${destination.badgeCount}',
                      ),
                      child: iconWidget,
                    )
                  : iconWidget,
            ),
            SizedBox(height: rem * 0.8),
            Text(
              destination.label,
              style: TextStyle(
                fontSize: rem * 2.6,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: selected
                    ? PrototypePalette.gold
                    : PrototypePalette.textGrey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Barre de navigation prestataire (fond brun foncé, icônes or).
class PrototypeDarkBottomNav extends StatelessWidget {
  const PrototypeDarkBottomNav({
    super.key,
    required this.selectedIndex,
    required this.destinations,
    required this.onTap,
  });

  final int selectedIndex;
  final List<PrototypeNavDestination> destinations;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final rem = PrototypeLayout(context).rem;

    return ColoredBox(
      color: PrototypePalette.navDark,
      child: SafeArea(
        top: false,
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: rem * 1.5),
          child: Row(
            children: [
              for (var i = 0; i < destinations.length; i++)
                _DarkNavBtn(
                  destination: destinations[i],
                  selected: i == selectedIndex,
                  rem: rem,
                  onTap: () => onTap(i),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _DarkNavBtn extends StatelessWidget {
  const _DarkNavBtn({
    required this.destination,
    required this.selected,
    required this.rem,
    required this.onTap,
  });

  final PrototypeNavDestination destination;
  final bool selected;
  final double rem;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = selected
        ? PrototypePalette.gold
        : Colors.white.withValues(alpha: 0.45);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              selected ? destination.selectedIcon : destination.icon,
              size: rem * 6,
              color: color,
            ),
            SizedBox(height: rem * 0.8),
            Text(
              destination.label,
              style: TextStyle(
                fontSize: rem * 2.4,
                fontWeight: selected ? FontWeight.w700 : FontWeight.w400,
                color: color,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
