import 'package:flutter/material.dart';

import '../../../../models/prestataire_service_catalog_selection.dart';
import '../../../../models/prestataire_service_field_set.dart';
import 'prestataire_services_guided_wizard.dart';

/// @deprecated Utiliser [PrestataireServicesGuidedWizard] directement.
/// Conservé pour compatibilité : redirige vers le parcours guidé.
class PrestataireServiceCatalogStep extends StatelessWidget {
  const PrestataireServiceCatalogStep({
    super.key,
    required this.selection,
    required this.errorText,
    required this.onChanged,
    this.hideIntro = false,
    this.useHubStyle = false,
    this.services = const [],
    this.pricingError,
    this.onPricingChanged,
  });

  final PrestataireServiceCatalogSelection selection;
  final String? errorText;
  final VoidCallback onChanged;
  final bool hideIntro;
  final bool useHubStyle;
  final List<PrestataireServiceFieldSet> services;
  final String? pricingError;
  final VoidCallback? onPricingChanged;

  @override
  Widget build(BuildContext context) {
    return PrestataireServicesGuidedWizard(
      catalogSelection: selection,
      services: services,
      catalogError: errorText,
      pricingError: pricingError,
      onCatalogChanged: onChanged,
      onPricingChanged: onPricingChanged ?? onChanged,
    );
  }
}
