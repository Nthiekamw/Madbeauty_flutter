import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../../models/prestataire_service_catalog_selection.dart';
import '../../../../models/prestataire_service_field_set.dart';
import '../../hub/prestataire_hub_layout.dart';
import 'service_wizard_shine.dart';
import 'services_wizard/services_wizard_chrome.dart';
import 'services_wizard/services_wizard_prestation_step.dart';
import 'services_wizard/services_wizard_pricing_step.dart';
import 'services_wizard/services_wizard_specialty_step.dart';
import 'services_wizard/services_wizard_step.dart';

/// Parcours guidé : prestation → spécialité → tarifs (avec retour arrière).
class PrestataireServicesGuidedWizard extends StatefulWidget {
  const PrestataireServicesGuidedWizard({
    super.key,
    required this.catalogSelection,
    required this.services,
    required this.catalogError,
    this.pricingError,
    required this.onCatalogChanged,
    required this.onPricingChanged,
    this.externalPricing = false,
  });

  final PrestataireServiceCatalogSelection catalogSelection;
  final List<PrestataireServiceFieldSet> services;
  final String? catalogError;
  final String? pricingError;
  final VoidCallback onCatalogChanged;
  final VoidCallback onPricingChanged;
  final bool externalPricing;

  @override
  State<PrestataireServicesGuidedWizard> createState() =>
      _PrestataireServicesGuidedWizardState();
}

class _PrestataireServicesGuidedWizardState
    extends State<PrestataireServicesGuidedWizard> {
  ServicesWizardStep _step = ServicesWizardStep.prestation;
  PrestaMainService? _activeMain;
  String? _activeSpecialtyId;
  String? _activeCustomSpecialty;
  final _customSpecialtyController = TextEditingController();

  @override
  void dispose() {
    _customSpecialtyController.dispose();
    super.dispose();
  }

  void _openPrestation(PrestaMainService main) {
    setState(() {
      _activeMain = main;
      _activeSpecialtyId = null;
      _activeCustomSpecialty = null;
      _step = ServicesWizardStep.specialty;
    });
  }

  void _onPricingChanged() {
    widget.onPricingChanged();
  }

  void _openSpecialty({String? specialtyId, String? customLabel}) {
    final main = _activeMain;
    if (main == null) return;
    if (specialtyId == null &&
        (customLabel == null || customLabel.trim().isEmpty)) {
      return;
    }

    widget.catalogSelection.selectedMains.add(main);
    if (specialtyId != null) {
      widget.catalogSelection.specialtyIdsByMain
          .putIfAbsent(main, () => {})
          .add(specialtyId);
    } else if (customLabel != null) {
      final label = customLabel.trim();
      final list = widget.catalogSelection.customSpecialtiesByMain
          .putIfAbsent(main, () => []);
      if (!list.any((e) => e.toLowerCase() == label.toLowerCase())) {
        list.add(label);
      }
    }
    widget.onCatalogChanged();

    setState(() {
      if (specialtyId != null) {
        _activeSpecialtyId = specialtyId;
        _activeCustomSpecialty = null;
      } else if (customLabel != null) {
        _activeCustomSpecialty = customLabel.trim();
        _activeSpecialtyId = null;
        _customSpecialtyController.clear();
      }
      _step = widget.externalPricing
          ? ServicesWizardStep.specialty
          : ServicesWizardStep.pricing;
    });
  }

  void _deselectCatalogSpecialty(String specialtyId) {
    final main = _activeMain;
    if (main == null) return;

    setState(() {
      widget.catalogSelection.removeCatalogSpecialty(main, specialtyId);
      if (_activeSpecialtyId == specialtyId) {
        _activeSpecialtyId = null;
        if (_step == ServicesWizardStep.pricing) {
          _step = ServicesWizardStep.specialty;
        }
      }
    });
    widget.onCatalogChanged();
  }

  void _deselectCustomSpecialty(String label) {
    final main = _activeMain;
    if (main == null) return;

    setState(() {
      widget.catalogSelection.removeCustomSpecialty(main, label);
      if (_activeCustomSpecialty?.toLowerCase() == label.toLowerCase()) {
        _activeCustomSpecialty = null;
        if (_step == ServicesWizardStep.pricing) {
          _step = ServicesWizardStep.specialty;
        }
      }
    });
    widget.onCatalogChanged();
  }

  String? _activeSpecialtyLabel() {
    if (_activeCustomSpecialty != null) return _activeCustomSpecialty;
    if (_activeSpecialtyId == null) return null;
    return PrestataireServiceCatalog.specialtyById(_activeSpecialtyId!)?.label;
  }

  PrestataireServiceFieldSet? _activeServiceField() {
    final label = _activeSpecialtyLabel()?.trim().toLowerCase();
    if (label == null || label.isEmpty) return null;
    for (final service in widget.services) {
      if (service.nomController.text.trim().toLowerCase() == label) {
        return service;
      }
    }
    return null;
  }

  PrestataireServiceFieldSet? _serviceForLabel(String label) {
    final key = label.trim().toLowerCase();
    for (final service in widget.services) {
      if (service.nomController.text.trim().toLowerCase() == key) {
        return service;
      }
    }
    return null;
  }

  bool _isSpecialtyConfigured(String label) {
    final service = _serviceForLabel(label);
    return service != null && isServiceWizardConfigured(service);
  }

  bool _mainHasConfigured(PrestaMainService main) {
    for (final spec in PrestataireServiceCatalog.specialties(main)) {
      if (_isSpecialtyConfigured(spec.label)) return true;
    }
    for (final custom
        in widget.catalogSelection.customSpecialtiesByMain[main] ?? const []) {
      if (_isSpecialtyConfigured(custom)) return true;
    }
    return false;
  }

  List<PrestataireServiceFieldSet> _configuredServices() =>
      widget.services.where(isServiceWizardConfigured).toList(growable: false);

  void _leavePricingStep(VoidCallback navigate) {
    widget.onPricingChanged();
    setState(navigate);
  }

  void _back() {
    setState(() {
      switch (_step) {
        case ServicesWizardStep.pricing:
          _step = ServicesWizardStep.specialty;
        case ServicesWizardStep.specialty:
          _step = ServicesWizardStep.prestation;
          _activeMain = null;
          _activeSpecialtyId = null;
          _activeCustomSpecialty = null;
        case ServicesWizardStep.prestation:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final specialtyCount = widget.catalogSelection.specialtyCount;
    final pricingListenable =
        prestataireServicesPricingListenable(widget.services);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const ServicesWizardAssistantHeader(),
        const SizedBox(height: PrestataireHubLayout.sectionGap),
        ListenableBuilder(
          listenable: pricingListenable,
          builder: (context, _) {
            final configured =
                widget.services.where(isServiceWizardConfigured).length;
            final progressTarget = specialtyCount > 0 ? specialtyCount : 1;
            final allConfigured =
                specialtyCount > 0 && configured == specialtyCount;

            return ServiceWizardShineFrame(
              shine: allConfigured,
              borderRadius: 14,
              child: PrestataireHubMetricBanner(
                icon: Icons.content_cut_rounded,
                label: DiscPrestaForm.hubServicesProgressLabel,
                value:
                    specialtyCount == 0 ? '0' : '$configured / $specialtyCount',
                progress: specialtyCount == 0
                    ? 0
                    : (configured / progressTarget).clamp(0.0, 1.0),
              ),
            );
          },
        ),
        ListenableBuilder(
          listenable: pricingListenable,
          builder: (context, _) {
            final configuredList = _configuredServices();
            if (configuredList.isEmpty) return const SizedBox.shrink();
            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: PrestataireHubLayout.sectionGap),
                ServicesWizardConfiguredStrip(services: configuredList),
              ],
            );
          },
        ),
        const SizedBox(height: PrestataireHubLayout.sectionGap),
        ServicesWizardStepIndicator(current: _step),
        const SizedBox(height: PrestataireHubLayout.sectionGap),
        if (_step != ServicesWizardStep.prestation)
          Align(
            alignment: Alignment.centerLeft,
            child: TextButton.icon(
              onPressed: _back,
              icon: const Icon(Icons.arrow_back_rounded, size: 18),
              label: Text(DiscPrestaForm.back),
            ),
          ),
        PrestataireHubSurfaceCard(
          padding: const EdgeInsets.all(14),
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 220),
            child: switch (_step) {
              ServicesWizardStep.prestation => ListenableBuilder(
                  key: const ValueKey('prestation'),
                  listenable: pricingListenable,
                  builder: (context, _) => ServicesWizardPrestationStep(
                    activeMain: _activeMain,
                    onPick: _openPrestation,
                    isMainConfigured: _mainHasConfigured,
                    errorText: widget.catalogError,
                  ),
                ),
              ServicesWizardStep.specialty => ListenableBuilder(
                  key: const ValueKey('specialty'),
                  listenable: pricingListenable,
                  builder: (context, _) => ServicesWizardSpecialtyStep(
                    main: _activeMain!,
                    selection: widget.catalogSelection,
                    customController: _customSpecialtyController,
                    isSpecialtyConfigured: _isSpecialtyConfigured,
                    onPickSpecialty: (id) => _openSpecialty(specialtyId: id),
                    onDeselectSpecialty: _deselectCatalogSpecialty,
                    onAddCustom: () => _openSpecialty(
                      customLabel: _customSpecialtyController.text,
                    ),
                    onPickCustom: (label) =>
                        _openSpecialty(customLabel: label),
                    onDeselectCustom: _deselectCustomSpecialty,
                    errorText: widget.catalogError,
                  ),
                ),
              ServicesWizardStep.pricing => ServicesWizardPricingStep(
                  key: const ValueKey('pricing'),
                  main: _activeMain,
                  specialtyLabel: _activeSpecialtyLabel(),
                  service: _activeServiceField(),
                  pricingError: widget.pricingError,
                  onPricingChanged: _onPricingChanged,
                  onAnotherSpecialty: () => _leavePricingStep(() {
                    _step = ServicesWizardStep.specialty;
                    _activeSpecialtyId = null;
                    _activeCustomSpecialty = null;
                  }),
                  onAnotherPrestation: () => _leavePricingStep(() {
                    _step = ServicesWizardStep.prestation;
                    _activeMain = null;
                    _activeSpecialtyId = null;
                    _activeCustomSpecialty = null;
                  }),
                ),
            },
          ),
        ),
        if (widget.catalogError != null &&
            _step == ServicesWizardStep.prestation) ...[
          const SizedBox(height: 8),
          Text(
            widget.catalogError!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}
