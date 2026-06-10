import 'package:flutter/material.dart';

import '../../../../../../shared/theme/app_fonts.dart';
import '../../../../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../shared/prestataire_section_header.dart';

class PrestataireDashboardSection extends StatelessWidget {
  const PrestataireDashboardSection({
    super.key,
    required this.icon,
    required this.title,
    required this.child,
    this.subtitle,
    this.badgeCount,
    this.emptyTitle,
    this.emptyMessage,
    this.isEmpty = false,
    this.iconColor,
  });

  final IconData icon;
  final String title;
  final String? subtitle;
  final Widget child;
  final int? badgeCount;
  final String? emptyTitle;
  final String? emptyMessage;
  final bool isEmpty;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrestataireSectionHeader(
            icon: icon,
            title: title,
            subtitle: subtitle,
            badgeCount: badgeCount,
            iconColor: iconColor,
          ),
          const SizedBox(height: 14),
          if (isEmpty && emptyTitle != null && emptyMessage != null)
            DiscoveryEmptyState(
              icon: icon,
              title: emptyTitle!,
              body: emptyMessage!,
              iconColor: (iconColor ?? theme.colorScheme.primary)
                  .withValues(alpha: 0.8),
            )
          else
            child,
        ],
      ),
    );
  }
}

class PrestataireDashboardEmptyHint extends StatelessWidget {
  const PrestataireDashboardEmptyHint({super.key, required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.35 : 0.55,
        ),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.inbox_outlined,
            size: 22,
            color: theme.colorScheme.onSurfaceVariant,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontFamily: AppFonts.body,
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

