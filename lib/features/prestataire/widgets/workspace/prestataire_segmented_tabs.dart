import 'package:flutter/material.dart';

import '../../../../shared/theme/app_fonts.dart';

/// Onglets segmentés (style maquette : pilule active marron).
class PrestataireSegmentedTabs<T> extends StatelessWidget {
  const PrestataireSegmentedTabs({
    super.key,
    required this.tabs,
    required this.selected,
    required this.onSelected,
    required this.labelBuilder,
  });

  final List<T> tabs;
  final T selected;
  final ValueChanged<T> onSelected;
  final String Function(T tab) labelBuilder;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.5 : 0.65,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        children: [
          for (final tab in tabs)
            Expanded(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 2),
                child: Material(
                  color: tab == selected ? primary : Colors.transparent,
                  borderRadius: BorderRadius.circular(10),
                  child: InkWell(
                    onTap: () => onSelected(tab),
                    borderRadius: BorderRadius.circular(10),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 10),
                      child: Text(
                        labelBuilder(tab),
                        textAlign: TextAlign.center,
                        style: theme.textTheme.labelLarge?.copyWith(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w700,
                          color: tab == selected
                              ? onPrimary
                              : theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
