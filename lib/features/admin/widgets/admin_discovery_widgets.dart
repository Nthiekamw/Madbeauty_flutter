import 'package:flutter/material.dart';

import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/widgets/discovery/content/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';

/// Carte liste admin (accent latéral + surface discovery).
class AdminDiscoveryCard extends StatelessWidget {
  const AdminDiscoveryCard({
    super.key,
    required this.child,
    this.accentColor,
  });

  final Widget child;
  final Color? accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = accentColor ?? AppColors.adminAccentMid;
    final radius = DiscoveryStyles.cardBorderRadius;

    return DiscoverySurfaceCard(
      includeHorizontalMargin: false,
      padding: EdgeInsets.zero,
      child: ClipRRect(
        borderRadius: radius,
        child: IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                width: 4,
                color: accent,
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                  child: DefaultTextStyle(
                    style: theme.textTheme.bodyMedium!,
                    child: child,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Pastille de statut admin.
class AdminStatusChip extends StatelessWidget {
  const AdminStatusChip({
    super.key,
    required this.label,
    required this.tone,
  });

  final String label;
  final AdminStatusTone tone;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final (bg, fg) = switch (tone) {
      AdminStatusTone.pending => (
          AppColors.adminBg12,
          AppColors.adminAccentDark,
        ),
      AdminStatusTone.progress => (
          AppColors.adminAccent.withValues(alpha: 0.18),
          AppColors.adminAccentDark,
        ),
      AdminStatusTone.success => (
          scheme.tertiaryContainer,
          scheme.onTertiaryContainer,
        ),
      AdminStatusTone.neutral => (
          scheme.surfaceContainerHighest,
          scheme.onSurfaceVariant,
        ),
      AdminStatusTone.warning => (
          scheme.errorContainer.withValues(alpha: 0.65),
          scheme.onErrorContainer,
        ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: fg.withValues(alpha: 0.22),
        ),
      ),
      child: Text(
        label,
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: fg,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.1,
            ),
      ),
    );
  }
}

enum AdminStatusTone { pending, progress, success, neutral, warning }

AdminStatusTone adminBugStatusTone(String status) => switch (status) {
      'pending' => AdminStatusTone.pending,
      'in_progress' => AdminStatusTone.progress,
      'resolved' => AdminStatusTone.success,
      'closed' => AdminStatusTone.neutral,
      _ => AdminStatusTone.neutral,
    };

/// Étiquette catégorie / type (compacte).
class AdminMetaChip extends StatelessWidget {
  const AdminMetaChip({
    super.key,
    required this.label,
    this.icon,
  });

  final String label;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.adminBg12,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.adminBorder30.withValues(alpha: 0.6)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 14, color: AppColors.adminAccentMid),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: theme.textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w700,
              color: AppColors.adminAccentDark,
            ),
          ),
        ],
      ),
    );
  }
}

/// Ligne d’info (icône + libellé + valeur).
class AdminInfoRow extends StatelessWidget {
  const AdminInfoRow({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.dense = false,
  });

  final IconData icon;
  final String label;
  final String value;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Padding(
      padding: EdgeInsets.only(top: dense ? 4 : 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            icon,
            size: 18,
            color: AppColors.adminAccentMid,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  value,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    height: 1.35,
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

/// Titre de bloc dans une carte admin.
class AdminCardSectionTitle extends StatelessWidget {
  const AdminCardSectionTitle({super.key, required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6, top: 4),
      child: Text(
        title,
        style: Theme.of(context).textTheme.labelLarge?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
              color: AppColors.adminAccentDark,
            ),
      ),
    );
  }
}

/// Encadré note / message dans une fiche.
class AdminNotePanel extends StatelessWidget {
  const AdminNotePanel({
    super.key,
    required this.title,
    required this.body,
    this.highlighted = false,
  });

  final String title;
  final String body;
  final bool highlighted;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      width: double.infinity,
      margin: const EdgeInsets.only(top: 10),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: highlighted
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.35)
            : AppColors.adminBg12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: highlighted
              ? theme.colorScheme.primary.withValues(alpha: 0.25)
              : AppColors.adminBorder30.withValues(alpha: 0.5),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: theme.textTheme.labelMedium?.copyWith(
              fontWeight: FontWeight.w800,
              color: highlighted
                  ? theme.colorScheme.primary
                  : AppColors.adminAccentDark,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            body,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.4),
          ),
        ],
      ),
    );
  }
}

/// Filtre segmenté avec style admin.
class AdminFilterSegment<T extends Object> extends StatelessWidget {
  const AdminFilterSegment({
    super.key,
    required this.segments,
    required this.selected,
    required this.onSelectionChanged,
  });

  final List<ButtonSegment<T>> segments;
  final Set<T> selected;
  final ValueChanged<Set<T>> onSelectionChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: DiscoveryStyles.cardBorderRadius,
        border: Border.all(color: AppColors.adminBorder30.withValues(alpha: 0.55)),
        color: theme.colorScheme.surface,
      ),
      child: Padding(
        padding: const EdgeInsets.all(4),
        child: SegmentedButton<T>(
          segments: segments,
          selected: selected,
          onSelectionChanged: onSelectionChanged,
          style: ButtonStyle(
            visualDensity: VisualDensity.compact,
            textStyle: WidgetStatePropertyAll(
              theme.textTheme.labelLarge?.copyWith(fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}

/// Liste vide admin harmonisée.
class AdminListEmptyState extends StatelessWidget {
  const AdminListEmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: DiscoveryEmptyState(
          icon: icon,
          title: title,
          body: body,
          iconColor: AppColors.adminAccentMid,
        ),
      ),
    );
  }
}

/// Rangée d’actions (boutons) dans une carte.
class AdminActionRow extends StatelessWidget {
  const AdminActionRow({
    super.key,
    required this.children,
  });

  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 12),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: children,
      ),
    );
  }
}
