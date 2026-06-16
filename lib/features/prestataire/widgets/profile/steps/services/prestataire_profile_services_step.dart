import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/models/domain/catalog/service_category.dart';
import '../../../../../../shared/widgets/app/app_text_field.dart';
import '../../../../models/prestataire_service_field_set.dart';
import 'prestataire_service_duration_field.dart';

class PrestataireProfileServicesStep extends StatelessWidget {
  const PrestataireProfileServicesStep({
    super.key,
    required this.categories,
    required this.services,
    required this.errorText,
    required this.suggestionNomController,
    required this.suggestionDescController,
    required this.onAdd,
    required this.onRemove,
    required this.onChanged,
  });

  final List<ServiceCategory> categories;
  final List<PrestataireServiceFieldSet> services;
  final String? errorText;
  final TextEditingController suggestionNomController;
  final TextEditingController suggestionDescController;
  final VoidCallback onAdd;
  final ValueChanged<int> onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (var i = 0; i < services.length; i++) ...[
          _ServiceCard(
            index: i,
            categories: categories,
            service: services[i],
            onRemove: () => onRemove(i),
            onChanged: onChanged,
          ),
          const SizedBox(height: 12),
        ],
        if (errorText != null) ...[
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
          const SizedBox(height: 12),
        ],
        OutlinedButton.icon(
          onPressed: onAdd,
          icon: const Icon(Icons.add),
          label: const Text(DiscPrestaForm.svcAdd),
        ),
        const SizedBox(height: 20),
        Text(
          DiscPrestaForm.suggestionTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 10),
        AppTextField(
          controller: suggestionNomController,
          label: DiscPrestaForm.suggestionNom,
          onChanged: (_) => onChanged(),
        ),
        const SizedBox(height: 12),
        AppTextField(
          controller: suggestionDescController,
          label: DiscPrestaForm.suggestionDesc,
          maxLines: 2,
          onChanged: (_) => onChanged(),
        ),
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.index,
    required this.categories,
    required this.service,
    required this.onRemove,
    required this.onChanged,
  });

  final int index;
  final List<ServiceCategory> categories;
  final PrestataireServiceFieldSet service;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final categoryLabel = categories
        .where((c) => c.id == service.categorieId)
        .map((c) => c.nom)
        .firstOrNull;

    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    '${DiscPrestaForm.stepServices} ${index + 1}',
                    style: theme.textTheme.titleSmall,
                  ),
                ),
                IconButton(
                  tooltip: DiscPrestaForm.svcDelete,
                  onPressed: onRemove,
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            const SizedBox(height: 8),
            AppTextField(
              controller: service.nomController,
              label: DiscPrestaForm.svcName,
              errorText: service.nomError,
              textInputAction: TextInputAction.next,
              onChanged: (_) {
                service.nomError = null;
                onChanged();
              },
            ),
            const SizedBox(height: 12),
            AppTextField(
              controller: service.descriptionController,
              label: DiscPrestaForm.svcDescription,
              maxLines: 2,
              onChanged: (_) => onChanged(),
            ),
            const SizedBox(height: 12),
            DropdownButtonFormField<String>(
              value: service.categorieId,
              decoration: InputDecoration(
                labelText: DiscPrestaForm.svcCategory,
                errorText: service.categorieError,
                border: const OutlineInputBorder(),
              ),
              hint: const Text(DiscPrestaForm.svcCategoryPick),
              items: [
                for (final cat in categories)
                  DropdownMenuItem(value: cat.id, child: Text(cat.nom)),
              ],
              onChanged: (value) {
                service.categorieId = value;
                service.categorieError = null;
                onChanged();
              },
            ),
            if (categoryLabel != null) ...[const SizedBox(height: 4)],
            const SizedBox(height: 12),
            AppTextField(
              controller: service.prixController,
              label: DiscPrestaForm.svcPrice,
              errorText: service.prixError,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
              ],
              onChanged: (_) {
                service.prixError = null;
                onChanged();
              },
            ),
            const SizedBox(height: 12),
            PrestataireServiceDurationField(
              controller: service.dureeController,
              errorText: service.dureeError,
              onChanged: () {
                service.dureeError = null;
                onChanged();
              },
            ),
          ],
        ),
      ),
    );
  }
}
