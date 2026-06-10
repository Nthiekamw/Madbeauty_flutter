import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../providers/listing_view_preferences_provider.dart';
import '../filters/listing_filters_panel.dart';
import '../content/listing_layout_toggle.dart';

/// En-tête résultats : titre, compteur, bascules liste/carte et format cartes.
class ListingResultsHeader extends ConsumerWidget {
  const ListingResultsHeader({
    super.key,
    required this.count,
    required this.title,
    this.onSecondaryAction,
    this.secondaryActionLabel,
  });

  final int count;
  final String title;
  final VoidCallback? onSecondaryAction;
  final String? secondaryActionLabel;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final hPad = DiscoveryResponsive.of(context).horizontalPadding;
    final primary = theme.colorScheme.primary;
    final prefs = ref.watch(listingViewPreferencesProvider);

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, 14, hPad, 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                    height: 1.2,
                    fontSize: 15,
                  ),
                ),
              ),
              if (secondaryActionLabel != null && onSecondaryAction != null)
                TextButton(
                  onPressed: onSecondaryAction,
                  style: TextButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    minimumSize: Size.zero,
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    visualDensity: VisualDensity.compact,
                  ),
                  child: Text(
                    secondaryActionLabel!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: primary,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Flexible(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 5,
                  ),
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: primary.withValues(alpha: 0.22),
                    ),
                  ),
                  child: Text(
                    DiscList.resultsCount(count),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontFamily: AppFonts.body,
                      fontWeight: FontWeight.w700,
                      color: primary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              ListingLayoutToggle(
                layout: prefs.catalogLayout,
                onChanged: (layout) {
                  ref
                      .read(listingViewPreferencesProvider.notifier)
                      .setCatalogLayout(layout);
                  ref.read(listingExpandedCardIdProvider.notifier).clear();
                },
              ),
              const SizedBox(width: 6),
              _ViewModeToggle(
                viewMode: prefs.viewMode,
                onChanged: (mode) => ref
                    .read(listingViewPreferencesProvider.notifier)
                    .setViewMode(mode),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ViewModeToggle extends StatelessWidget {
  const _ViewModeToggle({
    required this.viewMode,
    required this.onChanged,
  });

  final ListingViewMode viewMode;
  final ValueChanged<ListingViewMode> onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.5 : 0.85,
        ),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _ToggleIcon(
            tooltip: DiscList.modeList,
            icon: Icons.view_list_rounded,
            selected: viewMode == ListingViewMode.list,
            onTap: () => onChanged(ListingViewMode.list),
            accent: primary,
          ),
          _ToggleIcon(
            tooltip: DiscList.modeMap,
            icon: Icons.map_rounded,
            selected: viewMode == ListingViewMode.map,
            onTap: () => onChanged(ListingViewMode.map),
            accent: primary,
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
    required this.onTap,
    required this.accent,
  });

  final String tooltip;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: selected ? accent.withValues(alpha: 0.14) : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(10),
          child: Padding(
            padding: const EdgeInsets.all(8),
            child: Icon(
              icon,
              size: 20,
              color: selected ? accent : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ),
    );
  }
}
