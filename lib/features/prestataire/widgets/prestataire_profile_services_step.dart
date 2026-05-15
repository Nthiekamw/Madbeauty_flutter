import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_text_field.dart';
import '../models/prestataire_service_field_set.dart';

class PrestataireProfileServicesStep extends StatelessWidget {
  const PrestataireProfileServicesStep({
    super.key,
    required this.services,
    required this.errorText,
    required this.onAdd,
    required this.onRemove,
    required this.onChanged,
  });

  final List<PrestataireServiceFieldSet> services;
  final String? errorText;
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
      ],
    );
  }
}

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.index,
    required this.service,
    required this.onRemove,
    required this.onChanged,
  });

  final int index;
  final PrestataireServiceFieldSet service;
  final VoidCallback onRemove;
  final VoidCallback onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
                  tooltip:
                      DiscPrestaForm.svcDelete,
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
            Row(
              children: [
                Expanded(
                  child: AppTextField(
                    controller: service.prixController,
                    label: DiscPrestaForm.svcPrice,
                    errorText: service.prixError,
                    keyboardType:
                        const TextInputType.numberWithOptions(decimal: true),
                    inputFormatters: [
                      FilteringTextInputFormatter.allow(RegExp(r'[0-9,.]')),
                    ],
                    textInputAction: TextInputAction.next,
                    onChanged: (_) {
                      service.prixError = null;
                      onChanged();
                    },
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: AppTextField(
                    controller: service.dureeController,
                    label:
                        DiscPrestaForm.svcDuration,
                    errorText: service.dureeError,
                    keyboardType: TextInputType.number,
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                    ],
                    textInputAction: TextInputAction.done,
                    onChanged: (_) {
                      service.dureeError = null;
                      onChanged();
                    },
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
