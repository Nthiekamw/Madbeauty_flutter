import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_colors.dart';
import '../models/listing_catalog_layout.dart';

/// Bascule grille (2 col.) / étendu (pleine largeur).
class ListingLayoutToggle extends StatelessWidget {
  const ListingLayoutToggle({
    super.key,
    required this.layout,
    required this.onChanged,
    this.onPrimaryBackground = false,
  });

  final ListingCatalogLayout layout;
  final ValueChanged<ListingCatalogLayout> onChanged;
  final bool onPrimaryBackground;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fg = onPrimaryBackground
        ? theme.colorScheme.onPrimaryContainer
        : theme.colorScheme.onSurface;
    final selectedBg = onPrimaryBackground
        ? theme.colorScheme.surface.withValues(alpha: 0.92)
        : theme.colorScheme.primaryContainer.withValues(alpha: 0.55);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: onPrimaryBackground
            ? AppColors.shadowSelected08
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleIcon(
            tooltip: DiscList.layoutExpandedHint,
            icon: Icons.view_agenda_outlined,
            selected: layout == ListingCatalogLayout.expanded,
            foreground: fg,
            selectedBackground: selectedBg,
            onTap: () => onChanged(ListingCatalogLayout.expanded),
          ),
          _ToggleIcon(
            tooltip: DiscList.layoutGridHint,
            icon: Icons.grid_view_rounded,
            selected: layout == ListingCatalogLayout.grid,
            foreground: fg,
            selectedBackground: selectedBg,
            onTap: () => onChanged(ListingCatalogLayout.grid),
          ),
        ],
      ),
    );
  }
}

class _ToggleIcon extends StatelessWidget {
  const _ToggleIcon({
    required this.tooltip,
    required this.icon,
    required this.selected,
    required this.foreground,
    required this.selectedBackground,
    required this.onTap,
  });

  final String tooltip;
  final IconData icon;
  final bool selected;
  final Color foreground;
  final Color selectedBackground;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: Material(
        color: selected ? selectedBackground : AppColors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 20,
              color: selected
                  ? Theme.of(context).colorScheme.primary
                  : foreground.withValues(alpha: 0.75),
            ),
          ),
        ),
      ),
    );
  }
}

