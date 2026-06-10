import 'package:flutter/material.dart';

import '../../../../../../../core/constants/app_strings.dart';
import '../../../../../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../../../../../shared/theme/app_colors.dart';
import '../../../../../../../shared/theme/app_fonts.dart';
import '../../../../../models/prestataire_service_catalog_selection.dart';
import '../service_wizard_shine.dart';

/// Étape 2 : spécialités catalogue + personnalisées.
class ServicesWizardSpecialtyStep extends StatelessWidget {
  const ServicesWizardSpecialtyStep({
    super.key,
    required this.main,
    required this.selection,
    required this.customController,
    required this.onPickSpecialty,
    required this.onDeselectSpecialty,
    required this.onAddCustom,
    required this.onPickCustom,
    required this.onDeselectCustom,
    required this.isSpecialtyConfigured,
    this.errorText,
  });

  final PrestaMainService main;
  final PrestataireServiceCatalogSelection selection;
  final TextEditingController customController;
  final ValueChanged<String> onPickSpecialty;
  final ValueChanged<String> onDeselectSpecialty;
  final VoidCallback onAddCustom;
  final ValueChanged<String> onPickCustom;
  final ValueChanged<String> onDeselectCustom;
  final bool Function(String label) isSpecialtyConfigured;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final specialties = PrestataireServiceCatalog.specialties(main);
    final selectedIds = selection.specialtyIdsByMain[main] ?? const {};
    final customLabels = selection.customSpecialtiesByMain[main] ?? const [];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DiscPrestaForm.servicesWizardActivePrestation(
            PrestataireServiceCatalog.label(main),
          ),
          style: theme.textTheme.titleSmall?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          DiscPrestaForm.servicesWizardPickSpecialtyHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 14),
        for (final spec in specialties) ...[
          ServicesWizardSpecialtyRow(
            icon: PrestataireServiceCatalog.icon(main),
            label: spec.label,
            selected: selectedIds.contains(spec.id),
            configured: isSpecialtyConfigured(spec.label),
            onTap: () => onPickSpecialty(spec.id),
            trailing: selectedIds.contains(spec.id)
                ? IconButton(
                    icon: const Icon(Icons.close_rounded, size: 18),
                    tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
                    onPressed: () => onDeselectSpecialty(spec.id),
                  )
                : null,
          ),
          const SizedBox(height: 8),
        ],
        for (final custom in customLabels) ...[
          ServicesWizardSpecialtyRow(
            icon: Icons.add_circle_outline_rounded,
            label: custom,
            selected: true,
            configured: isSpecialtyConfigured(custom),
            onTap: () => onPickCustom(custom),
            trailing: IconButton(
              icon: const Icon(Icons.close_rounded, size: 18),
              tooltip: MaterialLocalizations.of(context).deleteButtonTooltip,
              onPressed: () => onDeselectCustom(custom),
            ),
          ),
          const SizedBox(height: 8),
        ],
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: customController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: DiscPrestaForm.catalogCustomHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  isDense: true,
                ),
                onSubmitted: (_) => onAddCustom(),
              ),
            ),
            const SizedBox(width: 8),
            IconButton.filled(
              tooltip: DiscPrestaForm.catalogCustomAdd,
              onPressed: onAddCustom,
              icon: const Icon(Icons.add_rounded),
            ),
          ],
        ),
        if (errorText != null) ...[
          const SizedBox(height: 10),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        if (selectedIds.isEmpty && customLabels.isEmpty) ...[
          const SizedBox(height: 8),
          Text(
            DiscPrestaForm.catalogSpecialtiesHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: primary.withValues(alpha: 0.85),
            ),
          ),
        ],
      ],
    );
  }
}

class ServicesWizardSpecialtyRow extends StatelessWidget {
  const ServicesWizardSpecialtyRow({
    super.key,
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
    this.configured = false,
    this.trailing,
  });

  final IconData icon;
  final String label;
  final bool selected;
  final bool configured;
  final VoidCallback onTap;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return ServiceWizardShineFrame(
      shine: configured,
      borderRadius: 12,
      child: Material(
        color: selected
            ? primary.withValues(alpha: 0.08)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.4),
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(12),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: configured
                    ? theme.colorScheme.outline.withValues(alpha: 0.14)
                    : selected
                        ? primary
                        : theme.colorScheme.outline.withValues(alpha: 0.2),
                width: configured || selected ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              child: Row(
                children: [
                  Icon(
                    configured ? Icons.check_circle_rounded : icon,
                    size: 18,
                    color: configured
                        ? AppColors.brandGold
                        : selected
                            ? primary
                            : theme.colorScheme.onSurfaceVariant,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      label,
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: configured ? primary : null,
                      ),
                    ),
                  ),
                  trailing ??
                      Icon(
                        configured
                            ? Icons.auto_awesome_rounded
                            : selected
                                ? Icons.check_circle_rounded
                                : Icons.chevron_right_rounded,
                        size: 20,
                        color: configured
                            ? AppColors.brandGold
                            : selected
                                ? primary
                                : theme.colorScheme.onSurfaceVariant,
                      ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
