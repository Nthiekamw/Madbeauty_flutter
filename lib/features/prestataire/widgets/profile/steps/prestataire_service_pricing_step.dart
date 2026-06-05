import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/widgets/app/app_text_field.dart';
import '../../../models/prestataire_service_field_set.dart';
import '../hub/prestataire_hub_layout.dart';

/// Tarifs et durées pour chaque prestation générée depuis le catalogue.
class PrestataireServicePricingStep extends StatelessWidget {
  const PrestataireServicePricingStep({
    super.key,
    required this.services,
    required this.errorText,
    required this.onChanged,
    this.hideTitle = false,
    this.useHubStyle = false,
    this.emptyHint,
  });

  final List<PrestataireServiceFieldSet> services;
  final String? errorText;
  final VoidCallback onChanged;
  final bool hideTitle;
  final bool useHubStyle;
  final String? emptyHint;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (services.isEmpty) {
      return _PricingEmptyState(
        message: emptyHint ?? DiscPrestaForm.pricingEmptyHint,
        useHubStyle: useHubStyle,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (!hideTitle) ...[
          Text(
            DiscPrestaForm.pricingTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DiscPrestaForm.pricingHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 14),
        ] else if (!useHubStyle) ...[
          Text(
            DiscPrestaForm.pricingHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (useHubStyle)
          Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              children: [
                Icon(
                  Icons.euro_rounded,
                  size: 18,
                  color: theme.colorScheme.primary,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    '${services.length} ${services.length > 1 ? 'prestations' : 'prestation'}',
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
        for (var i = 0; i < services.length; i++) ...[
          _PricingCard(
            service: services[i],
            index: i + 1,
            onChanged: onChanged,
            useHubStyle: useHubStyle,
          ),
          if (i < services.length - 1)
            SizedBox(height: useHubStyle ? 8 : 10),
        ],
        if (errorText != null) ...[
          const SizedBox(height: 10),
          Text(
            errorText!,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.error,
            ),
          ),
        ],
      ],
    );
  }
}

class _PricingEmptyState extends StatelessWidget {
  const _PricingEmptyState({
    required this.message,
    required this.useHubStyle,
  });

  final String message;
  final bool useHubStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    final content = Column(
      children: [
        Icon(
          Icons.payments_outlined,
          size: 40,
          color: primary.withValues(alpha: 0.75),
        ),
        const SizedBox(height: 12),
        Text(
          message,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
      ],
    );

    if (!useHubStyle) {
      return content;
    }

    return PrestataireHubSurfaceCard(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 28),
      child: content,
    );
  }
}

class _PricingCard extends StatelessWidget {
  const _PricingCard({
    required this.service,
    required this.index,
    required this.onChanged,
    required this.useHubStyle,
  });

  final PrestataireServiceFieldSet service;
  final int index;
  final VoidCallback onChanged;
  final bool useHubStyle;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final name = service.nomController.text.trim();

    final body = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            if (useHubStyle) ...[
              Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  '$index',
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                name.isEmpty ? DiscPrestaForm.svcName : name,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: useHubStyle ? AppFonts.display : null,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: AppTextField(
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
            ),
            const SizedBox(width: 12),
            Expanded(
              child: AppTextField(
                controller: service.dureeController,
                label: DiscPrestaForm.svcDuration,
                errorText: service.dureeError,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                onChanged: (_) {
                  service.dureeError = null;
                  onChanged();
                },
              ),
            ),
          ],
        ),
      ],
    );

    if (!useHubStyle) {
      return Card(margin: EdgeInsets.zero, child: Padding(
        padding: const EdgeInsets.all(12),
        child: body,
      ));
    }

    return PrestataireHubSurfaceCard(
      padding: const EdgeInsets.all(14),
      child: body,
    );
  }
}
