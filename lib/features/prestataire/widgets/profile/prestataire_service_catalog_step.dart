import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../models/prestataire_service_catalog_selection.dart';

/// Étape onboarding : 4 services prédéfinis + spécialités + ajouts libres.
class PrestataireServiceCatalogStep extends StatefulWidget {
  const PrestataireServiceCatalogStep({
    super.key,
    required this.selection,
    required this.errorText,
    required this.onChanged,
  });

  final PrestataireServiceCatalogSelection selection;
  final String? errorText;
  final VoidCallback onChanged;

  @override
  State<PrestataireServiceCatalogStep> createState() =>
      _PrestataireServiceCatalogStepState();
}

class _PrestataireServiceCatalogStepState
    extends State<PrestataireServiceCatalogStep> {
  final _customControllers = <PrestaMainService, TextEditingController>{};

  @override
  void dispose() {
    for (final c in _customControllers.values) {
      c.dispose();
    }
    super.dispose();
  }

  TextEditingController _controllerFor(PrestaMainService main) {
    return _customControllers.putIfAbsent(
      main,
      TextEditingController.new,
    );
  }

  void _toggleMain(PrestaMainService main, bool selected) {
    setState(() {
      if (selected) {
        widget.selection.selectedMains.add(main);
      } else {
        widget.selection.selectedMains.remove(main);
        widget.selection.specialtyIdsByMain.remove(main);
        widget.selection.customSpecialtiesByMain.remove(main);
      }
    });
    widget.onChanged();
  }

  void _toggleSpecialty(PrestaMainService main, String specialtyId) {
    setState(() {
      final set =
          widget.selection.specialtyIdsByMain.putIfAbsent(main, () => {});
      if (set.contains(specialtyId)) {
        set.remove(specialtyId);
      } else {
        set.add(specialtyId);
      }
    });
    widget.onChanged();
  }

  void _addCustom(PrestaMainService main) {
    final controller = _controllerFor(main);
    final label = controller.text.trim();
    if (label.isEmpty) return;
    setState(() {
      final list =
          widget.selection.customSpecialtiesByMain.putIfAbsent(main, () => []);
      if (!list.any((e) => e.toLowerCase() == label.toLowerCase())) {
        list.add(label);
      }
      controller.clear();
    });
    widget.onChanged();
  }

  void _removeCustom(PrestaMainService main, String label) {
    setState(() {
      widget.selection.customSpecialtiesByMain[main]?.remove(label);
    });
    widget.onChanged();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selection = widget.selection;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DiscPrestaForm.catalogIntro,
          style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
        ),
        const SizedBox(height: 16),
        Text(
          DiscPrestaForm.catalogMainTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          children: [
            for (final main in PrestaMainService.values)
              _MainServiceCard(
                main: main,
                selected: selection.selectedMains.contains(main),
                onSelected: (v) => _toggleMain(main, v),
              ),
          ],
        ),
        if (widget.errorText != null) ...[
          const SizedBox(height: 10),
          Text(
            widget.errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
        for (final main in PrestaMainService.values)
          if (selection.selectedMains.contains(main)) ...[
            const SizedBox(height: 20),
            _SpecialtiesSection(
              main: main,
              selectedSpecialtyIds:
                  selection.specialtyIdsByMain[main] ?? const {},
              customLabels: selection.customSpecialtiesByMain[main] ?? const [],
              customController: _controllerFor(main),
              onToggleSpecialty: (id) => _toggleSpecialty(main, id),
              onAddCustom: () => _addCustom(main),
              onRemoveCustom: (label) => _removeCustom(main, label),
            ),
          ],
      ],
    );
  }
}

class _MainServiceCard extends StatelessWidget {
  const _MainServiceCard({
    required this.main,
    required this.selected,
    required this.onSelected,
  });

  final PrestaMainService main;
  final bool selected;
  final ValueChanged<bool> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;

    return Material(
      color: selected
          ? cs.primaryContainer.withValues(alpha: 0.55)
          : cs.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onSelected(!selected),
        child: Container(
          width: 156,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? cs.primary
                  : cs.outline.withValues(alpha: 0.25),
              width: selected ? 1.6 : 1,
            ),
          ),
          child: Row(
            children: [
              Icon(
                PrestataireServiceCatalog.icon(main),
                color: selected ? cs.primary : cs.onSurfaceVariant,
                size: 22,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  PrestataireServiceCatalog.label(main),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                    color: selected ? cs.onPrimaryContainer : cs.onSurface,
                  ),
                ),
              ),
              if (selected)
                Icon(Icons.check_circle_rounded, color: cs.primary, size: 20),
            ],
          ),
        ),
      ),
    );
  }
}

class _SpecialtiesSection extends StatelessWidget {
  const _SpecialtiesSection({
    required this.main,
    required this.selectedSpecialtyIds,
    required this.customLabels,
    required this.customController,
    required this.onToggleSpecialty,
    required this.onAddCustom,
    required this.onRemoveCustom,
  });

  final PrestaMainService main;
  final Set<String> selectedSpecialtyIds;
  final List<String> customLabels;
  final TextEditingController customController;
  final ValueChanged<String> onToggleSpecialty;
  final VoidCallback onAddCustom;
  final ValueChanged<String> onRemoveCustom;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final specialties = PrestataireServiceCatalog.specialties(main);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DiscPrestaForm.catalogSpecialtiesTitle(
            PrestataireServiceCatalog.label(main),
          ),
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          DiscPrestaForm.catalogSpecialtiesHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: [
            for (final spec in specialties)
              FilterChip(
                label: Text(spec.label),
                selected: selectedSpecialtyIds.contains(spec.id),
                onSelected: (_) => onToggleSpecialty(spec.id),
              ),
            for (final custom in customLabels)
              InputChip(
                label: Text(custom),
                onDeleted: () => onRemoveCustom(custom),
              ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: customController,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  labelText: DiscPrestaForm.catalogCustomHint,
                  border: const OutlineInputBorder(),
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
      ],
    );
  }
}
