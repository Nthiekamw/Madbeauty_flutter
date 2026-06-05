import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/constants/prestataire/prestataire_service_catalog.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../models/prestataire_service_catalog_selection.dart';
import '../hub/prestataire_hub_layout.dart';

/// Étape onboarding : 4 services prédéfinis + spécialités + ajouts libres.
class PrestataireServiceCatalogStep extends StatefulWidget {
  const PrestataireServiceCatalogStep({
    super.key,
    required this.selection,
    required this.errorText,
    required this.onChanged,
    this.hideIntro = false,
    this.useHubStyle = false,
  });

  final PrestataireServiceCatalogSelection selection;
  final String? errorText;
  final VoidCallback onChanged;
  final bool hideIntro;
  final bool useHubStyle;

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
    return _customControllers.putIfAbsent(main, TextEditingController.new);
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
      final set = widget.selection.specialtyIdsByMain.putIfAbsent(
        main,
        () => {},
      );
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
      final list = widget.selection.customSpecialtiesByMain.putIfAbsent(
        main,
        () => [],
      );
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
    final hub = widget.useHubStyle;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!widget.hideIntro) ...[
          Text(
            DiscPrestaForm.catalogIntro,
            style: theme.textTheme.bodyMedium?.copyWith(height: 1.45),
          ),
          const SizedBox(height: 16),
        ],
        if (!hub)
          Text(
            widget.hideIntro
                ? DiscPrestaForm.catalogMainTitle
                : DiscPrestaForm.catalogMainTitle,
            style: widget.hideIntro
                ? theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                    color: theme.colorScheme.onSurfaceVariant,
                  )
                : theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                  ),
          ),
        if (!hub) const SizedBox(height: 10),
        if (hub)
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.35,
            children: [
              for (final main in PrestaMainService.values)
                _MainServiceCard(
                  main: main,
                  selected: selection.selectedMains.contains(main),
                  onSelected: (v) => _toggleMain(main, v),
                  useHubStyle: true,
                ),
            ],
          )
        else
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: [
              for (final main in PrestaMainService.values)
                _MainServiceCard(
                  main: main,
                  selected: selection.selectedMains.contains(main),
                  onSelected: (v) => _toggleMain(main, v),
                  useHubStyle: false,
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
            SizedBox(height: hub ? 12 : 20),
            _SpecialtiesSection(
              main: main,
              selectedSpecialtyIds:
                  selection.specialtyIdsByMain[main] ?? const {},
              customLabels: selection.customSpecialtiesByMain[main] ?? const [],
              customController: _controllerFor(main),
              onToggleSpecialty: (id) => _toggleSpecialty(main, id),
              onAddCustom: () => _addCustom(main),
              onRemoveCustom: (label) => _removeCustom(main, label),
              useHubStyle: hub,
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
    required this.useHubStyle,
  });

  final PrestaMainService main;
  final bool selected;
  final ValueChanged<bool> onSelected;
  final bool useHubStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cs = theme.colorScheme;
    final primary = cs.primary;

    final child = Material(
      color: selected
          ? primary.withValues(alpha: 0.08)
          : cs.surfaceContainerHighest.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () => onSelected(!selected),
        child: Container(
          width: useHubStyle ? double.infinity : 156,
          padding: EdgeInsets.symmetric(
            horizontal: useHubStyle ? 12 : 14,
            vertical: useHubStyle ? 12 : 14,
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: selected
                  ? primary
                  : cs.outline.withValues(alpha: 0.22),
              width: selected ? 1.8 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: selected
                      ? primary.withValues(alpha: 0.14)
                      : cs.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  PrestataireServiceCatalog.icon(main),
                  color: selected ? primary : cs.onSurfaceVariant,
                  size: 20,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  PrestataireServiceCatalog.label(main),
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: useHubStyle ? AppFonts.display : null,
                    fontWeight: FontWeight.w700,
                    fontSize: useHubStyle ? 14 : null,
                    color: selected ? cs.onSurface : cs.onSurface,
                  ),
                ),
              ),
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 180),
                child: selected
                    ? Icon(
                        Icons.check_circle_rounded,
                        key: const ValueKey('on'),
                        color: primary,
                        size: 22,
                      )
                    : Icon(
                        Icons.circle_outlined,
                        key: const ValueKey('off'),
                        color: cs.outline.withValues(alpha: 0.45),
                        size: 22,
                      ),
              ),
            ],
          ),
        ),
      ),
    );

    return child;
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
    required this.useHubStyle,
  });

  final PrestaMainService main;
  final Set<String> selectedSpecialtyIds;
  final List<String> customLabels;
  final TextEditingController customController;
  final ValueChanged<String> onToggleSpecialty;
  final VoidCallback onAddCustom;
  final ValueChanged<String> onRemoveCustom;
  final bool useHubStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final specialties = PrestataireServiceCatalog.specialties(main);
    final primary = theme.colorScheme.primary;
    final selectedCount =
        selectedSpecialtyIds.length + customLabels.length;

    final content = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              PrestataireServiceCatalog.icon(main),
              size: 18,
              color: primary,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                DiscPrestaForm.catalogSpecialtiesTitle(
                  PrestataireServiceCatalog.label(main),
                ),
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: useHubStyle ? AppFonts.display : null,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            if (selectedCount > 0)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '$selectedCount',
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          DiscPrestaForm.catalogSpecialtiesHint,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        const SizedBox(height: 12),
        if (useHubStyle)
          _SpecialtiesTwoColumnGrid(
            specialties: specialties,
            customLabels: customLabels,
            selectedSpecialtyIds: selectedSpecialtyIds,
            primary: primary,
            theme: theme,
            onToggleSpecialty: onToggleSpecialty,
            onRemoveCustom: onRemoveCustom,
          )
        else
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              for (final spec in specialties)
                FilterChip(
                  label: Text(spec.label),
                  selected: selectedSpecialtyIds.contains(spec.id),
                  showCheckmark: true,
                  onSelected: (_) => onToggleSpecialty(spec.id),
                  selectedColor: primary.withValues(alpha: 0.18),
                  checkmarkColor: primary,
                  side: BorderSide(
                    color: selectedSpecialtyIds.contains(spec.id)
                        ? primary.withValues(alpha: 0.5)
                        : theme.colorScheme.outline.withValues(alpha: 0.3),
                  ),
                ),
              for (final custom in customLabels)
                InputChip(
                  label: Text(custom),
                  deleteIconColor: primary,
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
      ],
    );

    if (!useHubStyle) return content;

    return PrestataireHubSurfaceCard(
      padding: const EdgeInsets.all(14),
      child: content,
    );
  }
}

/// Grille 2 colonnes pour les spécialités (mode hub).
class _SpecialtiesTwoColumnGrid extends StatelessWidget {
  const _SpecialtiesTwoColumnGrid({
    required this.specialties,
    required this.customLabels,
    required this.selectedSpecialtyIds,
    required this.primary,
    required this.theme,
    required this.onToggleSpecialty,
    required this.onRemoveCustom,
  });

  final List<PrestaCatalogSpecialty> specialties;
  final List<String> customLabels;
  final Set<String> selectedSpecialtyIds;
  final Color primary;
  final ThemeData theme;
  final ValueChanged<String> onToggleSpecialty;
  final ValueChanged<String> onRemoveCustom;

  @override
  Widget build(BuildContext context) {
    final itemCount = specialties.length + customLabels.length;
    if (itemCount == 0) return const SizedBox.shrink();

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
        mainAxisExtent: 44,
      ),
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index < specialties.length) {
          final spec = specialties[index];
          final selected = selectedSpecialtyIds.contains(spec.id);
          return SizedBox(
            width: double.infinity,
            child: FilterChip(
              label: Text(
                spec.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              selected: selected,
              showCheckmark: true,
              onSelected: (_) => onToggleSpecialty(spec.id),
              selectedColor: primary.withValues(alpha: 0.18),
              checkmarkColor: primary,
              side: BorderSide(
                color: selected
                    ? primary.withValues(alpha: 0.5)
                    : theme.colorScheme.outline.withValues(alpha: 0.3),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 4),
            ),
          );
        }
        final custom = customLabels[index - specialties.length];
        return SizedBox(
          width: double.infinity,
          child: InputChip(
            label: Text(
              custom,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            deleteIconColor: primary,
            onDeleted: () => onRemoveCustom(custom),
            padding: const EdgeInsets.symmetric(horizontal: 4),
          ),
        );
      },
    );
  }
}
