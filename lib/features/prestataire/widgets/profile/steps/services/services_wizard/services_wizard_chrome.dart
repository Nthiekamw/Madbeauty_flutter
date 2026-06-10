import 'package:flutter/material.dart';

import '../../../../../../../core/constants/app_strings.dart';
import '../../../../../../../shared/theme/app_colors.dart';
import '../../../../../../../shared/theme/app_fonts.dart';
import '../../../../../models/prestataire_service_field_set.dart';
import '../service_wizard_shine.dart';
import 'services_wizard_step.dart';

/// Bandeau horizontal des prestations déjà configurées.
class ServicesWizardConfiguredStrip extends StatelessWidget {
  const ServicesWizardConfiguredStrip({super.key, required this.services});

  final List<PrestataireServiceFieldSet> services;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(Icons.auto_awesome_rounded, size: 16, color: AppColors.brandGold),
            const SizedBox(width: 6),
            Text(
              DiscPrestaForm.servicesWizardConfiguredBadge,
              style: theme.textTheme.labelLarge?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w800,
                color: primary,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        SizedBox(
          height: 44,
          child: ListView.separated(
            scrollDirection: Axis.horizontal,
            itemCount: services.length,
            separatorBuilder: (_, __) => const SizedBox(width: 8),
            itemBuilder: (context, index) {
              final service = services[index];
              final name = service.nomController.text.trim();
              final prix =
                  service.prixController.text.trim().replaceAll('.', ',');
              return ServiceWizardShineFrame(
                shine: true,
                borderRadius: 22,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.surfaceContainerHighest
                        .withValues(alpha: 0.55),
                    borderRadius: BorderRadius.circular(22),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.check_circle_rounded,
                          size: 16, color: AppColors.brandGold),
                      const SizedBox(width: 6),
                      Text(
                        name,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      if (prix.isNotEmpty) ...[
                        Text(
                          ' · $prix €',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            color: primary,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

/// En-tête assistant du wizard services.
class ServicesWizardAssistantHeader extends StatelessWidget {
  const ServicesWizardAssistantHeader({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.auto_awesome_rounded, color: primary, size: 22),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  DiscPrestaForm.servicesWizardAssistantTitle,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DiscPrestaForm.servicesWizardAssistantSubtitle,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
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

/// Indicateur 1 → 2 → 3 du wizard.
class ServicesWizardStepIndicator extends StatelessWidget {
  const ServicesWizardStepIndicator({super.key, required this.current});

  final ServicesWizardStep current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    Widget step(int index, String label, ServicesWizardStep step) {
      final active = current == step;
      final done = current.index > step.index;
      final color = active || done ? primary : theme.colorScheme.outline;

      return Expanded(
        child: Column(
          children: [
            Row(
              children: [
                if (index > 0)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: done || active
                          ? primary.withValues(alpha: 0.35)
                          : theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
                Container(
                  width: 26,
                  height: 26,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: active || done
                        ? primary.withValues(alpha: 0.14)
                        : theme.colorScheme.surfaceContainerHighest,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: color.withValues(alpha: active ? 1 : 0.35),
                      width: active ? 1.5 : 1,
                    ),
                  ),
                  child: Text(
                    '$index',
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: active || done
                          ? primary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
                if (index < 3)
                  Expanded(
                    child: Container(
                      height: 2,
                      color: done
                          ? primary.withValues(alpha: 0.35)
                          : theme.colorScheme.outline.withValues(alpha: 0.2),
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 6),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                label,
                maxLines: 1,
                textAlign: TextAlign.center,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                  color: active
                      ? primary
                      : theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Row(
      children: [
        step(1, DiscPrestaForm.servicesWizardStepPrestation,
            ServicesWizardStep.prestation),
        step(2, DiscPrestaForm.servicesWizardStepSpecialty,
            ServicesWizardStep.specialty),
        step(3, DiscPrestaForm.servicesWizardStepPricing,
            ServicesWizardStep.pricing),
      ],
    );
  }
}
