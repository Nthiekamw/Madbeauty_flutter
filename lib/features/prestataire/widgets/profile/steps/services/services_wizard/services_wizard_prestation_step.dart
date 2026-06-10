import 'package:flutter/material.dart';

import '../../../../../../../core/constants/app_strings.dart';
import '../../../../../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../../../../../shared/theme/app_colors.dart';
import '../../../../../../../shared/theme/app_fonts.dart';
import '../service_wizard_shine.dart';

/// Étape 1 : choix de la prestation principale.
class ServicesWizardPrestationStep extends StatelessWidget {
  const ServicesWizardPrestationStep({
    super.key,
    required this.onPick,
    required this.isMainConfigured,
    this.activeMain,
    this.errorText,
  });

  final ValueChanged<PrestaMainService> onPick;
  final bool Function(PrestaMainService main) isMainConfigured;
  final PrestaMainService? activeMain;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DiscPrestaForm.servicesWizardPickPrestationHint,
          style: theme.textTheme.titleSmall?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        const ServicesWizardCatalogMainCategoriesRow(),
        const SizedBox(height: 14),
        for (final main in PrestaMainService.values) ...[
          ServicesWizardPrestationRow(
            main: main,
            configured: isMainConfigured(main),
            active: activeMain == main,
            onTap: () => onPick(main),
          ),
          if (main != PrestaMainService.values.last) const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// Ligne horizontale : Coiffure · Manucure · Maquillage · Pédicure.
class ServicesWizardCatalogMainCategoriesRow extends StatelessWidget {
  const ServicesWizardCatalogMainCategoriesRow({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final labels = PrestaMainService.values
        .map(PrestataireServiceCatalog.label)
        .toList(growable: false);
    final style = theme.textTheme.labelLarge?.copyWith(
      fontFamily: AppFonts.body,
      fontWeight: FontWeight.w700,
      color: theme.colorScheme.onSurfaceVariant,
      height: 1,
    );
    final dotStyle = style?.copyWith(
      fontWeight: FontWeight.w500,
      color: theme.colorScheme.outline,
    );

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.55),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.16),
        ),
      ),
      child: SizedBox(
        height: 40,
        child: ListView.separated(
          scrollDirection: Axis.horizontal,
          padding: const EdgeInsets.symmetric(horizontal: 12),
          itemCount: labels.length,
          separatorBuilder: (_, __) => Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Center(child: Text('·', style: dotStyle)),
          ),
          itemBuilder: (context, index) => Center(
            child: Text(
              labels[index],
              maxLines: 1,
              softWrap: false,
              style: style,
            ),
          ),
        ),
      ),
    );
  }
}

class ServicesWizardPrestationRow extends StatelessWidget {
  const ServicesWizardPrestationRow({
    super.key,
    required this.main,
    required this.onTap,
    this.configured = false,
    this.active = false,
  });

  final PrestaMainService main;
  final VoidCallback onTap;
  final bool configured;
  final bool active;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return ServiceWizardShineFrame(
      shine: configured,
      borderRadius: 14,
      child: Material(
        color: active
            ? primary.withValues(alpha: 0.06)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(14),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(14),
          child: Ink(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: configured
                    ? theme.colorScheme.outline.withValues(alpha: 0.14)
                    : active
                        ? primary
                        : theme.colorScheme.outline.withValues(alpha: 0.18),
                width: configured || active ? 1.5 : 1,
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: primary.withValues(alpha: configured ? 0.2 : 0.12),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Icon(
                      configured
                          ? Icons.check_rounded
                          : PrestataireServiceCatalog.icon(main),
                      color: configured ? AppColors.brandGold : primary,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      PrestataireServiceCatalog.label(main),
                      maxLines: 1,
                      softWrap: false,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        height: 1.1,
                        color: configured ? primary : null,
                      ),
                    ),
                  ),
                  if (configured)
                    Padding(
                      padding: const EdgeInsets.only(left: 6),
                      child: Icon(
                        Icons.auto_awesome_rounded,
                        size: 18,
                        color: AppColors.brandGold,
                      ),
                    )
                  else
                    Icon(
                      Icons.chevron_right_rounded,
                      color: theme.colorScheme.onSurfaceVariant,
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
