import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
/// Niveau d’obligation affiché sur une étape du hub profil.
enum HubStepRequirement { required, recommended, optional }

/// Marges et composants visuels partagés par le hub profil (7 étapes).
abstract final class PrestataireHubLayout {
  PrestataireHubLayout._();

  static const sectionGap = 12.0;
  static const blockGap = 16.0;
  static const actionGap = 10.0;
  static BorderRadius cardRadius = BorderRadius.circular(16);

  /// Padding unique de tout l’écran hub (scroll + rail latéral).
  static EdgeInsets pagePadding(BuildContext context) {
    final h = DiscoveryResponsive.of(context).horizontalPadding;
    return EdgeInsets.fromLTRB(h, 12, h, 28);
  }
}

/// Carte pleine largeur sans marge horizontale supplémentaire.
class PrestataireHubSurfaceCard extends StatelessWidget {
  const PrestataireHubSurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final surface = theme.colorScheme.surface.withValues(
      alpha: isDark ? 0.92 : 0.98,
    );

    return Material(
      color: surface,
      elevation: 0,
      surfaceTintColor: AppColors.transparent,
      clipBehavior: Clip.antiAlias,
      shape: RoundedRectangleBorder(
        borderRadius: PrestataireHubLayout.cardRadius,
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(padding: padding, child: child),
    );
  }
}

/// En-tête d’étape : numéro, titre, objectif, badge.
class PrestataireHubStepHeader extends StatelessWidget {
  const PrestataireHubStepHeader({
    super.key,
    required this.stepIndex,
    required this.stepTotal,
    required this.icon,
    required this.title,
    required this.goal,
    this.requirement,
  });

  final int stepIndex;
  final int stepTotal;
  final IconData icon;
  final String title;
  final String goal;
  final HubStepRequirement? requirement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return PrestataireHubSurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary.withValues(alpha: 0.18),
                  primary.withValues(alpha: 0.06),
                ],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: primary.withValues(alpha: 0.22)),
            ),
            child: Icon(icon, size: 26, color: primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.3,
                          height: 1.15,
                          color: theme.colorScheme.onSurface,
                        ),
                      ),
                    ),
                    if (requirement != null) ...[
                      const SizedBox(width: 8),
                      _HubRequirementChip(requirement: requirement!),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  goal,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.45,
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

class _HubRequirementChip extends StatelessWidget {
  const _HubRequirementChip({required this.requirement});

  final HubStepRequirement requirement;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final (label, bg, fg) = switch (requirement) {
      HubStepRequirement.required => (
        DiscPrestaForm.hubBadgeRequired,
        theme.colorScheme.primary.withValues(alpha: 0.14),
        theme.colorScheme.primary,
      ),
      HubStepRequirement.recommended => (
        DiscPrestaForm.hubBadgeRecommended,
        theme.colorScheme.secondaryContainer.withValues(alpha: 0.7),
        theme.colorScheme.onSecondaryContainer,
      ),
      HubStepRequirement.optional => (
        DiscPrestaForm.hubBadgeOptional,
        theme.colorScheme.surfaceContainerHighest,
        theme.colorScheme.onSurfaceVariant,
      ),
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        label,
        style: theme.textTheme.labelSmall?.copyWith(
          fontWeight: FontWeight.w700,
          color: fg,
        ),
      ),
    );
  }
}

/// Sous-bloc à l’intérieur d’une étape (identité, tarifs, etc.).
class PrestataireHubFormSection extends StatelessWidget {
  const PrestataireHubFormSection({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
    this.icon,
    this.index,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget child;
  final int? index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return PrestataireHubSurfaceCard(
      padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (index != null)
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '$index',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: primary,
                    ),
                  ),
                ),
              if (index != null) const SizedBox(width: 10),
              if (icon != null) ...[
                Icon(icon, size: 20, color: primary),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 2),
                      Text(
                        subtitle!,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          child,
        ],
      ),
    );
  }
}

/// Conseil contextuel en bas de chaque étape du hub.
class PrestataireHubStepTip extends StatelessWidget {
  const PrestataireHubStepTip({super.key, required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: primary.withValues(alpha: 0.18)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.tips_and_updates_outlined, size: 20, color: primary),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

/// Indicateur de progression (photos, services, jours ouverts…).
class PrestataireHubMetricBanner extends StatelessWidget {
  const PrestataireHubMetricBanner({
    super.key,
    required this.icon,
    required this.label,
    required this.value,
    this.progress,
  });

  final IconData icon;
  final String label;
  final String value;
  final double? progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 10, 12, 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(icon, size: 18, color: primary),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              Text(
                value,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  color: primary,
                ),
              ),
            ],
          ),
          if (progress != null) ...[
            const SizedBox(height: 8),
            ClipRRect(
              borderRadius: BorderRadius.circular(4),
              child: LinearProgressIndicator(
                value: progress!.clamp(0, 1),
                minHeight: 5,
                backgroundColor:
                    theme.colorScheme.outline.withValues(alpha: 0.15),
                color: primary,
              ),
            ),
          ],
        ],
      ),
    );
  }
}

/// Légende sous la barre de progression (étape courante + nom).
class PrestataireHubWizardStepCaption extends StatelessWidget {
  const PrestataireHubWizardStepCaption({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.stepTitle,
  });

  final int currentStep;
  final int totalSteps;
  final String stepTitle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final onSurface = theme.colorScheme.onSurface;

    return Row(
      children: [
        Text(
          DiscPrestaForm.hubWizardProgressLabel(
            currentStep + 1,
            totalSteps,
          ),
          style: theme.textTheme.labelMedium?.copyWith(
            fontWeight: FontWeight.w700,
            color: onSurface.withValues(alpha: 0.72),
          ),
        ),
        const SizedBox(width: 8),
        Text(
          '·',
          style: theme.textTheme.labelMedium?.copyWith(
            color: onSurface.withValues(alpha: 0.35),
          ),
        ),
        const SizedBox(width: 8),
        Expanded(
          child: Text(
            stepTitle,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: theme.textTheme.labelLarge?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
              color: onSurface,
            ),
          ),
        ),
      ],
    );
  }
}

/// Barre de progression segmentée (7 étapes).
class PrestataireHubWizardProgress extends StatelessWidget {
  const PrestataireHubWizardProgress({
    super.key,
    required this.currentStep,
    required this.totalSteps,
    required this.saving,
  });

  final int currentStep;
  final int totalSteps;
  final bool saving;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Row(
      children: [
        for (var i = 0; i < totalSteps; i++) ...[
          Expanded(
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: i <= currentStep
                    ? primary
                    : theme.colorScheme.outline.withValues(alpha: 0.18),
              ),
            ),
          ),
          if (i < totalSteps - 1) const SizedBox(width: 4),
        ],
        if (saving) ...[
          const SizedBox(width: 10),
          SizedBox(
            width: 16,
            height: 16,
            child: CircularProgressIndicator(strokeWidth: 2, color: primary),
          ),
        ],
      ],
    );
  }
}

/// Navigation horizontale entre étapes (numérotée, scroll auto).
class PrestataireHubStepNavigator extends StatefulWidget {
  const PrestataireHubStepNavigator({
    super.key,
    required this.steps,
    required this.currentStep,
    required this.enabled,
    required this.onTap,
  });

  final List<PrestataireHubStepMeta> steps;
  final int currentStep;
  final bool enabled;
  final ValueChanged<int> onTap;

  @override
  State<PrestataireHubStepNavigator> createState() =>
      _PrestataireHubStepNavigatorState();
}

class _PrestataireHubStepNavigatorState extends State<PrestataireHubStepNavigator> {
  final _scrollController = ScrollController();
  static const _chipWidth = 118.0;
  static const _chipGap = 8.0;

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant PrestataireHubStepNavigator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentStep != widget.currentStep) {
      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToCurrent());
    }
  }

  void _scrollToCurrent() {
    if (!_scrollController.hasClients) return;
    final offset = (widget.currentStep * (_chipWidth + _chipGap))
        .clamp(0.0, _scrollController.position.maxScrollExtent);
    _scrollController.animateTo(
      offset,
      duration: const Duration(milliseconds: 280),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SingleChildScrollView(
      controller: _scrollController,
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < widget.steps.length; i++) ...[
            _HubStepChip(
              index: i + 1,
              title: widget.steps[i].title,
              icon: widget.steps[i].icon,
              selected: i == widget.currentStep,
              done: i < widget.currentStep,
              enabled: widget.enabled,
              onTap: () => widget.onTap(i),
              primary: primary,
              theme: theme,
            ),
            if (i < widget.steps.length - 1) const SizedBox(width: _chipGap),
          ],
        ],
      ),
    );
  }
}

class _HubStepChip extends StatelessWidget {
  const _HubStepChip({
    required this.index,
    required this.title,
    required this.icon,
    required this.selected,
    required this.done,
    required this.enabled,
    required this.onTap,
    required this.primary,
    required this.theme,
  });

  final int index;
  final String title;
  final IconData icon;
  final bool selected;
  final bool done;
  final bool enabled;
  final VoidCallback onTap;
  final Color primary;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final onPrimary = theme.colorScheme.onPrimary;
    final muted = theme.colorScheme.onSurfaceVariant;
    final fg = selected ? onPrimary : (done ? primary : muted);
    final bg = selected
        ? primary
        : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(12),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          width: _PrestataireHubStepNavigatorState._chipWidth,
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: bg,
            border: Border.all(
              color: selected
                  ? primary
                  : theme.colorScheme.outline.withValues(alpha: 0.14),
            ),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Container(
                    width: 22,
                    height: 22,
                    alignment: Alignment.center,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: selected
                          ? onPrimary.withValues(alpha: 0.2)
                          : primary.withValues(alpha: done ? 0.15 : 0.1),
                    ),
                    child: done && !selected
                        ? Icon(Icons.check_rounded, size: 14, color: primary)
                        : Text(
                            '$index',
                            style: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: fg,
                              height: 1,
                            ),
                          ),
                  ),
                  const SizedBox(width: 6),
                  Icon(icon, size: 15, color: fg),
                ],
              ),
              const SizedBox(height: 6),
              Text(
                title,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
                  color: fg,
                  height: 1.15,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

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

/// Métadonnées d’une étape (titre + icône).
class PrestataireHubStepMeta {
  const PrestataireHubStepMeta({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;
}

/// Boutons de navigation en bas d’étape.
class PrestataireHubStepActions extends StatelessWidget {
  const PrestataireHubStepActions({
    super.key,
    required this.primaryLabel,
    required this.onPrimary,
    required this.saving,
    this.onBack,
    this.onSkip,
    this.onCompleteLater,
    this.showSkip = false,
    this.showCompleteLater = false,
  });

  final String primaryLabel;
  final VoidCallback? onPrimary;
  final bool saving;
  final VoidCallback? onBack;
  final VoidCallback? onSkip;
  final VoidCallback? onCompleteLater;
  final bool showSkip;
  final bool showCompleteLater;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final layout = DiscoveryResponsive.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        FilledButton(
          onPressed: saving ? null : onPrimary,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: PrestataireHubLayout.cardRadius,
            ),
          ),
          child: Text(
            primaryLabel,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
        if (onBack != null || showSkip || showCompleteLater) ...[
          const SizedBox(height: PrestataireHubLayout.actionGap),
          if (layout.stackStepperActions)
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: _secondaryActions(theme),
            )
          else
            Wrap(
              alignment: WrapAlignment.center,
              spacing: 8,
              runSpacing: 8,
              children: _secondaryActions(theme),
            ),
        ],
      ],
    );
  }

  List<Widget> _secondaryActions(ThemeData theme) {
    return [
      if (onBack != null)
        TextButton(
          onPressed: saving ? null : onBack,
          child: const Text(DiscPrestaForm.back),
        ),
      if (showSkip && onSkip != null)
        OutlinedButton.icon(
          onPressed: saving ? null : onSkip,
          icon: const Icon(Icons.fast_forward_rounded, size: 16),
          label: const Text(DiscPrestaForm.skipStep),
        ),
      if (showCompleteLater && onCompleteLater != null)
        FilledButton.tonalIcon(
          onPressed: saving ? null : onCompleteLater,
          icon: const Icon(Icons.schedule_outlined, size: 16),
          label: const Text(DiscPrestaForm.completeLater),
        ),
    ];
  }
}
