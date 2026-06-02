import 'package:flutter/material.dart';

import '../../models/prestataire_service_catalog_selection.dart';
import '../../models/prestataire_service_field_set.dart';
import 'prestataire_service_catalog_step.dart';
import 'prestataire_service_pricing_step.dart';

/// Catalogue (4 services + spécialités) puis tarifs — étape onboarding prestataire.
class PrestataireOnboardingServicesPanel extends StatelessWidget {
  const PrestataireOnboardingServicesPanel({
    super.key,
    required this.catalogSelection,
    required this.services,
    required this.catalogError,
    this.pricingError,
    required this.onChanged,
  });

  final PrestataireServiceCatalogSelection catalogSelection;
  final List<PrestataireServiceFieldSet> services;
  final String? catalogError;
  final String? pricingError;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrestataireServiceCatalogStep(
          selection: catalogSelection,
          errorText: catalogError,
          onChanged: onChanged,
        ),
        const SizedBox(height: 24),
        PrestataireServicePricingStep(
          services: services,
          errorText: pricingError,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
