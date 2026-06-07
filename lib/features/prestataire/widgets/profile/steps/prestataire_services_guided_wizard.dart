import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../models/prestataire_service_catalog_selection.dart';
import '../../../models/prestataire_service_field_set.dart';
import '../hub/prestataire_hub_layout.dart';
import 'prestataire_service_pricing_step.dart';
import 'service_wizard_shine.dart';

enum _ServicesWizardStep { prestation, specialty, pricing }

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
  });

  final PrestataireServiceCatalogSelection catalogSelection;
  final List<PrestataireServiceFieldSet> services;
  final String? catalogError;
  final String? pricingError;
  final VoidCallback onCatalogChanged;
  final VoidCallback onPricingChanged;

  @override
  State<PrestataireServicesGuidedWizard> createState() =>
      _PrestataireServicesGuidedWizardState();
}

class _PrestataireServicesGuidedWizardState
    extends State<PrestataireServicesGuidedWizard> {
  _ServicesWizardStep _step = _ServicesWizardStep.prestation;
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
      _step = _ServicesWizardStep.specialty;
      widget.catalogSelection.selectedMains.add(main);
    });
    widget.onCatalogChanged();
  }

  void _openSpecialty({String? specialtyId, String? customLabel}) {
    final main = _activeMain;
    if (main == null) return;
    if (specialtyId == null &&
        (customLabel == null || customLabel.trim().isEmpty)) {
      return;
    }

    setState(() {
      if (specialtyId != null) {
        widget.catalogSelection.specialtyIdsByMain
            .putIfAbsent(main, () => {})
            .add(specialtyId);
        _activeSpecialtyId = specialtyId;
        _activeCustomSpecialty = null;
      } else if (customLabel != null) {
        final label = customLabel.trim();
        final list = widget.catalogSelection.customSpecialtiesByMain
            .putIfAbsent(main, () => []);
        if (!list.any((e) => e.toLowerCase() == label.toLowerCase())) {
          list.add(label);
        }
        _activeCustomSpecialty = label;
        _activeSpecialtyId = null;
        _customSpecialtyController.clear();
      }
      _step = _ServicesWizardStep.pricing;
    });
    widget.onCatalogChanged();
  }

  void _deselectCatalogSpecialty(String specialtyId) {
    final main = _activeMain;
    if (main == null) return;

    setState(() {
      widget.catalogSelection.removeCatalogSpecialty(main, specialtyId);
      if (_activeSpecialtyId == specialtyId) {
        _activeSpecialtyId = null;
        if (_step == _ServicesWizardStep.pricing) {
          _step = _ServicesWizardStep.specialty;
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
        if (_step == _ServicesWizardStep.pricing) {
          _step = _ServicesWizardStep.specialty;
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

  void _back() {
    setState(() {
      switch (_step) {
        case _ServicesWizardStep.pricing:
          _step = _ServicesWizardStep.specialty;
        case _ServicesWizardStep.specialty:
          _step = _ServicesWizardStep.prestation;
          _activeMain = null;
          _activeSpecialtyId = null;
          _activeCustomSpecialty = null;
        case _ServicesWizardStep.prestation:
          break;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final specialtyCount = widget.catalogSelection.specialtyCount;
    final configured = widget.services.where(isServiceWizardConfigured).length;
    final progressTarget = specialtyCount > 0 ? specialtyCount : 1;

    final configuredList = _configuredServices();
    final allConfigured =
        specialtyCount > 0 && configured == specialtyCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _ServicesAssistantHeader(),
        const SizedBox(height: PrestataireHubLayout.sectionGap),
        ServiceWizardShineFrame(
          shine: allConfigured,
          borderRadius: 14,
          child: PrestataireHubMetricBanner(
            icon: Icons.content_cut_rounded,
            label: DiscPrestaForm.hubServicesProgressLabel,
            value: specialtyCount == 0 ? '0' : '$configured / $specialtyCount',
            progress: specialtyCount == 0
                ? 0
                : (configured / progressTarget).clamp(0.0, 1.0),
          ),
        ),
        if (configuredList.isNotEmpty) ...[
          const SizedBox(height: PrestataireHubLayout.sectionGap),
          _ConfiguredServicesStrip(services: configuredList),
        ],
        const SizedBox(height: PrestataireHubLayout.sectionGap),
        _WizardStepIndicator(current: _step),
        const SizedBox(height: PrestataireHubLayout.sectionGap),
        if (_step != _ServicesWizardStep.prestation)
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
              _ServicesWizardStep.prestation => _PrestationStep(
                  key: const ValueKey('prestation'),
                  activeMain: _activeMain,
                  onPick: _openPrestation,
                  isMainConfigured: _mainHasConfigured,
                  errorText: widget.catalogError,
                ),
              _ServicesWizardStep.specialty => _SpecialtyStep(
                  key: const ValueKey('specialty'),
                  main: _activeMain!,
                  selection: widget.catalogSelection,
                  customController: _customSpecialtyController,
                  isSpecialtyConfigured: _isSpecialtyConfigured,
                  onPickSpecialty: (id) => _openSpecialty(specialtyId: id),
                  onDeselectSpecialty: _deselectCatalogSpecialty,
                  onAddCustom: () => _openSpecialty(
                    customLabel: _customSpecialtyController.text,
                  ),
                  onPickCustom: (label) => _openSpecialty(customLabel: label),
                  onDeselectCustom: _deselectCustomSpecialty,
                  onCatalogChanged: widget.onCatalogChanged,
                  errorText: widget.catalogError,
                ),
              _ServicesWizardStep.pricing => _PricingStep(
                  key: const ValueKey('pricing'),
                  main: _activeMain,
                  specialtyLabel: _activeSpecialtyLabel(),
                  service: _activeServiceField(),
                  pricingError: widget.pricingError,
                  onPricingChanged: widget.onPricingChanged,
                  onAnotherSpecialty: () => setState(() {
                    _step = _ServicesWizardStep.specialty;
                    _activeSpecialtyId = null;
                    _activeCustomSpecialty = null;
                  }),
                  onAnotherPrestation: () => setState(() {
                    _step = _ServicesWizardStep.prestation;
                    _activeMain = null;
                    _activeSpecialtyId = null;
                    _activeCustomSpecialty = null;
                  }),
                ),
            },
          ),
        ),
        if (widget.catalogError != null &&
            _step == _ServicesWizardStep.prestation) ...[
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

class _ConfiguredServicesStrip extends StatelessWidget {
  const _ConfiguredServicesStrip({required this.services});

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

class _ServicesAssistantHeader extends StatelessWidget {
  const _ServicesAssistantHeader();

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

class _WizardStepIndicator extends StatelessWidget {
  const _WizardStepIndicator({required this.current});

  final _ServicesWizardStep current;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    Widget step(int index, String label, _ServicesWizardStep step) {
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
            _ServicesWizardStep.prestation),
        step(2, DiscPrestaForm.servicesWizardStepSpecialty,
            _ServicesWizardStep.specialty),
        step(3, DiscPrestaForm.servicesWizardStepPricing,
            _ServicesWizardStep.pricing),
      ],
    );
  }
}

class _PrestationStep extends StatelessWidget {
  const _PrestationStep({
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
        const _CatalogMainCategoriesRow(),
        const SizedBox(height: 14),
        for (final main in PrestaMainService.values) ...[
          _PrestationRow(
            main: main,
            configured: isMainConfigured(main),
            active: activeMain == main,
            onTap: () => onPick(main),
          ),
          if (main != PrestaMainService.values.last)
            const SizedBox(height: 8),
        ],
      ],
    );
  }
}

/// Ligne horizontale : Coiffure · Manucure · Maquillage · Pédicure (jamais coupée).
class _CatalogMainCategoriesRow extends StatelessWidget {
  const _CatalogMainCategoriesRow();

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
            child: Center(
              child: Text('·', style: dotStyle),
            ),
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

class _PrestationRow extends StatelessWidget {
  const _PrestationRow({
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

class _SpecialtyStep extends StatelessWidget {
  const _SpecialtyStep({
    super.key,
    required this.main,
    required this.selection,
    required this.customController,
    required this.onPickSpecialty,
    required this.onDeselectSpecialty,
    required this.onAddCustom,
    required this.onPickCustom,
    required this.onDeselectCustom,
    required this.onCatalogChanged,
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
  final VoidCallback onCatalogChanged;
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
          _SpecialtyRow(
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
          _SpecialtyRow(
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

class _SpecialtyRow extends StatelessWidget {
  const _SpecialtyRow({
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

class _PricingStep extends StatelessWidget {
  const _PricingStep({
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
                color: serviceConfigured ? primary : null,
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
