import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../models/prestataire_service_catalog_selection.dart';
import '../../../models/prestataire_service_field_set.dart';
import '../hub/prestataire_hub_layout.dart';
import 'prestataire_service_catalog_step.dart';
import 'prestataire_service_pricing_step.dart';

/// Catalogue (4 services + spécialités) puis tarifs – étape onboarding prestataire.
class PrestataireOnboardingServicesPanel extends StatelessWidget {
  const PrestataireOnboardingServicesPanel({
    super.key,
    required this.catalogSelection,
    required this.services,
    required this.catalogError,
    this.pricingError,
    required this.onCatalogChanged,
    required this.onPricingChanged,
    this.guidedMode = false,
  });

  final PrestataireServiceCatalogSelection catalogSelection;
  final List<PrestataireServiceFieldSet> services;
  final String? catalogError;
  final String? pricingError;
  final VoidCallback onCatalogChanged;
  final VoidCallback onPricingChanged;
  final bool guidedMode;

  @override
  Widget build(BuildContext context) {
    if (!guidedMode) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          PrestataireServiceCatalogStep(
            selection: catalogSelection,
            errorText: catalogError,
            onChanged: onCatalogChanged,
          ),
          const SizedBox(height: 24),
          PrestataireServicePricingStep(
            services: services,
            errorText: pricingError,
            onChanged: onPricingChanged,
          ),
        ],
      );
    }

    final specialtyCount = catalogSelection.specialtyCount;
    final configured = services.where((s) {
      final prix =
          double.tryParse(s.prixController.text.replaceAll(',', '.')) ?? 0;
      final duree = int.tryParse(s.dureeController.text.trim()) ?? 0;
      return s.nomController.text.trim().isNotEmpty &&
          s.categorieId != null &&
          prix >= 1 &&
          duree > 0;
    }).length;
    final progressTarget = specialtyCount > 0 ? specialtyCount : 1;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        PrestataireHubMetricBanner(
          icon: Icons.content_cut_rounded,
          label: DiscPrestaForm.hubServicesProgressLabel,
          value: specialtyCount == 0
              ? '0'
              : '$configured / $specialtyCount',
          progress: specialtyCount == 0
              ? 0
              : (configured / progressTarget).clamp(0.0, 1.0),
        ),
        const SizedBox(height: PrestataireHubLayout.sectionGap),
        PrestataireHubFormSection(
          index: 1,
          title: DiscPrestaForm.hubSectionCatalog,
          subtitle: DiscPrestaForm.hubSectionCatalogHint,
          icon: Icons.grid_view_rounded,
          child: PrestataireServiceCatalogStep(
            selection: catalogSelection,
            errorText: catalogError,
            onChanged: onCatalogChanged,
            hideIntro: true,
            useHubStyle: true,
          ),
        ),
        const SizedBox(height: PrestataireHubLayout.sectionGap),
        PrestataireHubFormSection(
          index: 2,
          title: DiscPrestaForm.hubSectionPricing,
          subtitle: services.isEmpty
              ? DiscPrestaForm.pricingEmptySpecialtyHint
              : DiscPrestaForm.hubSectionPricingHint,
          icon: Icons.payments_outlined,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: PrestataireServicePricingStep(
              key: ValueKey<int>(services.length),
              services: services,
              errorText: pricingError,
              onChanged: onPricingChanged,
              hideTitle: true,
              useHubStyle: true,
              emptyHint: catalogSelection.selectedMains.isNotEmpty &&
                      specialtyCount == 0
                  ? DiscPrestaForm.pricingEmptySpecialtyHint
                  : DiscPrestaForm.pricingEmptyHint,
            ),
          ),
        ),
      ],
    );
  }
}
