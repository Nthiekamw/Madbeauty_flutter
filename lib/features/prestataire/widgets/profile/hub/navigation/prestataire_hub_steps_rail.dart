import 'package:flutter/material.dart';

import '../../../../../../shared/theme/app_fonts.dart';
import '../layout/prestataire_hub_layout_core.dart';
import '../layout/prestataire_hub_step_meta.dart';

/// Rail latéral (écrans larges).
class PrestataireHubStepsRail extends StatelessWidget {
  const PrestataireHubStepsRail({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.saving,
    required this.onTap,
  });

  final List<PrestataireHubStepMeta> steps;
  final int currentStep;
  final bool saving;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return PrestataireHubSurfaceCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.route_outlined, size: 20, color: primary),
              const SizedBox(width: 8),
              Text(
                'Parcours',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < steps.length; i++) ...[
            _HubRailTile(
              index: i + 1,
              title: steps[i].title,
              icon: steps[i].icon,
              active: i == currentStep,
              done: i < currentStep,
              enabled: onTap != null && !saving,
              onTap: () => onTap?.call(i),
            ),
            if (i < steps.length - 1) const SizedBox(height: 8),
          ],
          if (saving) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(minHeight: 3, color: primary),
          ],
        ],
      ),
    );
  }
}

class _HubRailTile extends StatelessWidget {
  const _HubRailTile({
    required this.index,
    required this.title,
    required this.icon,
    required this.active,
    required this.done,
    required this.enabled,
    required this.onTap,
  });

  final int index;
  final String title;
  final IconData icon;
  final bool active;
  final bool done;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final bg = active
        ? primary.withValues(alpha: 0.12)
        : Colors.transparent;
    return Material(
      color: bg,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: active
            ? BorderSide(color: primary.withValues(alpha: 0.35))
            : BorderSide.none,
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: done
                      ? primary.withValues(alpha: 0.2)
                      : active
                          ? primary
                          : theme.colorScheme.surfaceContainerHighest,
                ),
                child: Icon(
                  done ? Icons.check_rounded : icon,
                  size: done ? 16 : 15,
                  color: done || active
                      ? theme.colorScheme.onPrimary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                    color: active ? primary : theme.colorScheme.onSurface,
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
