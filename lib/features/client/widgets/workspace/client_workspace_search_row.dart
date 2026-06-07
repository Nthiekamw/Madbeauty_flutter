import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/theme/app_colors.dart';

/// Barre de recherche + bouton filtres (écran Recherche).
class ClientWorkspaceSearchRow extends StatelessWidget {
  const ClientWorkspaceSearchRow({
    super.key,
    required this.controller,
    required this.onChanged,
    this.onClear,
    this.onFilterTap,
    this.onSubmitted,
    this.filtersActive = false,
    this.compact = false,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback? onClear;
  final VoidCallback? onFilterTap;
  final ValueChanged<String>? onSubmitted;
  final bool filtersActive;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final hPad = DiscoveryResponsive.of(context).horizontalPadding;
    final fieldHeight = compact ? 44.0 : 50.0;
    final fontSize = compact ? 13.0 : null;

    return Padding(
      padding: EdgeInsets.fromLTRB(hPad, compact ? 2 : 4, hPad, compact ? 4 : 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: theme.brightness == Brightness.light
                    ? [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.07),
                          blurRadius: 12,
                          offset: const Offset(0, 3),
                        ),
                      ]
                    : null,
              ),
              child: TextField(
                controller: controller,
                onChanged: onChanged,
                onSubmitted: onSubmitted,
                textInputAction: TextInputAction.search,
                style: fontSize != null
                    ? theme.textTheme.bodyMedium?.copyWith(fontSize: fontSize)
                    : null,
                decoration: InputDecoration(
                  hintText: DiscClientWorkspace.searchHint,
                  hintStyle: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant
                        .withValues(alpha: 0.65),
                    fontSize: fontSize,
                  ),
                  prefixIcon: Icon(
                    compact ? Icons.search_rounded : Icons.storefront_outlined,
                    size: compact ? 20 : 24,
                    color: primary.withValues(alpha: 0.75),
                  ),
                  suffixIcon: controller.text.isEmpty
                      ? null
                      : IconButton(
                          onPressed: onClear,
                          icon: Icon(
                            Icons.close_rounded,
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                  filled: true,
                  fillColor: AppColors.cardSurfaceFor(theme.brightness),
                  contentPadding: EdgeInsets.symmetric(
                    vertical: compact ? 10 : 13,
                  ),
                  isDense: compact,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.12),
                    ),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.12),
                    ),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(16),
                    borderSide: BorderSide(color: primary, width: 1.5),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Material(
            color: primary,
            elevation: theme.brightness == Brightness.light ? 2 : 0,
            shadowColor: primary.withValues(alpha: 0.35),
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              onTap: onFilterTap,
              borderRadius: BorderRadius.circular(16),
              child: Tooltip(
                message: DiscClientWorkspace.filterTooltip,
                child: SizedBox(
                  width: fieldHeight,
                  height: fieldHeight,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      Icon(
                        Icons.tune_rounded,
                        color: theme.colorScheme.onPrimary,
                      ),
                      if (filtersActive)
                        Positioned(
                          top: 11,
                          right: 11,
                          child: Container(
                            width: 9,
                            height: 9,
                            decoration: BoxDecoration(
                              color: theme.colorScheme.tertiary,
                              shape: BoxShape.circle,
                              border: Border.all(
                                color: theme.colorScheme.onPrimary,
                                width: 1.5,
                              ),
                            ),
                          ),
                        ),
                    ],
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
