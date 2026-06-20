import 'package:flutter/material.dart';

import '../../../../models/prestataire_service_catalog_selection.dart';
import '../../../../models/prestataire_service_field_set.dart';
import 'prestataire_service_pricing_step.dart';
import 'prestataire_services_guided_wizard.dart';

/// Étape onboarding : parcours guidé prestation → spécialité → tarifs.
class PrestataireOnboardingServicesPanel extends StatelessWidget {
  const PrestataireOnboardingServicesPanel({
    super.key,
    required this.catalogSelection,
    required this.services,
    required this.catalogError,
    this.pricingError,
    required this.onCatalogChanged,
    required this.onPricingChanged,
    this.editMode = false,
  });

  final PrestataireServiceCatalogSelection catalogSelection;
  final List<PrestataireServiceFieldSet> services;
  final String? catalogError;
  final String? pricingError;
  final VoidCallback onCatalogChanged;
  final VoidCallback onPricingChanged;
  final bool editMode;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (editMode && services.isNotEmpty) ...[
          PrestataireServicePricingStep(
            services: services,
            errorText: pricingError,
            onChanged: onPricingChanged,
            useHubStyle: true,
          ),
          const SizedBox(height: 16),
        ],
        PrestataireServicesGuidedWizard(
          catalogSelection: catalogSelection,
          services: services,
          catalogError: catalogError,
          pricingError: editMode ? null : pricingError,
          onCatalogChanged: onCatalogChanged,
          onPricingChanged: onPricingChanged,
          externalPricing: editMode,
        ),
      ],
    );
  }
}
