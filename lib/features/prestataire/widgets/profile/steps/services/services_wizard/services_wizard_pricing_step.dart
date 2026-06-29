import 'package:flutter/material.dart';

import '../../../../../../../core/constants/app_strings.dart';
import '../../../../../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../../../../../shared/theme/app_fonts.dart';
import '../../../../../models/prestataire_service_field_set.dart';
import '../prestataire_service_pricing_step.dart';
import '../service_wizard_shine.dart';

/// Étape 3 : tarifs pour la spécialité active.
class ServicesWizardPricingStep extends StatelessWidget {
  const ServicesWizardPricingStep({
    super.key,
    required this.main,
    required this.specialtyLabel,
    required this.service,
    this.pricingError,
    required this.onPricingChanged,
    required this.onAnotherSpecialty,
    required this.onAnotherPrestation,
  });

  final PrestaMainService? main;
  final String? specialtyLabel;
  final PrestataireServiceFieldSet? service;
  final String? pricingError;
  final VoidCallback onPricingChanged;
  final VoidCallback onAnotherSpecialty;
  final VoidCallback onAnotherPrestation;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final serviceConfigured =
        service != null && isServiceWizardConfigured(service!);

    Widget buildHeader({required bool configured}) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (main != null) ...[
            Text(
              DiscPrestaForm.servicesWizardActivePrestation(
                PrestataireServiceCatalog.label(main!),
              ),
              style: theme.textTheme.labelLarge?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 2),
          ],
          if (specialtyLabel != null)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 2),
              child: Text(
                DiscPrestaForm.servicesWizardActiveSpecialty(specialtyLabel!),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  color: configured ? primary : null,
                ),
              ),
            ),
          const SizedBox(height: 4),
          Text(
            DiscPrestaForm.servicesWizardPricingHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (service != null)
          ListenableBuilder(
            listenable: Listenable.merge([
              service!.prixController,
              service!.dureeController,
            ]),
            builder: (context, _) => buildHeader(
              configured: isServiceWizardConfigured(service!),
            ),
          )
        else
          buildHeader(configured: serviceConfigured),
        const SizedBox(height: 14),
        if (service != null)
          PrestataireServicePricingStep(
            services: [service!],
            errorText: pricingError,
            onChanged: onPricingChanged,
            hideTitle: true,
            useHubStyle: true,
            hideServiceCount: true,
          )
        else
          Text(
            DiscPrestaForm.pricingEmptyHint,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        const SizedBox(height: 16),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            OutlinedButton.icon(
              onPressed: onAnotherSpecialty,
              icon: const Icon(Icons.tune_rounded, size: 18),
              label: Text(DiscPrestaForm.servicesWizardAnotherSpecialty),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: BorderSide(color: primary.withValues(alpha: 0.4)),
              ),
            ),
            OutlinedButton.icon(
              onPressed: onAnotherPrestation,
              icon: const Icon(Icons.grid_view_rounded, size: 18),
              label: Text(DiscPrestaForm.servicesWizardAnotherPrestation),
              style: OutlinedButton.styleFrom(
                foregroundColor: primary,
                side: BorderSide(color: primary.withValues(alpha: 0.4)),
              ),
            ),
          ],
        ),
      ],
    );
  }
}
