import 'package:flutter/material.dart';

import '../../../../models/prestataire_service_catalog_selection.dart';
import '../../../../models/prestataire_service_field_set.dart';
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
  });

  final PrestataireServiceCatalogSelection catalogSelection;
  final List<PrestataireServiceFieldSet> services;
  final String? catalogError;
  final String? pricingError;
  final VoidCallback onCatalogChanged;
  final VoidCallback onPricingChanged;

  @override
  Widget build(BuildContext context) {
    return PrestataireServicesGuidedWizard(
      catalogSelection: catalogSelection,
      services: services,
      catalogError: catalogError,
      pricingError: pricingError,
      onCatalogChanged: onCatalogChanged,
      onPricingChanged: onPricingChanged,
    );
  }
}
