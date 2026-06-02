import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../logic/prestataire_profile_completeness.dart';
import '../../logic/prestataire_profile_completion_progress.dart';
import '../../models/prestataire_profile_edit_section.dart';
import '../../providers/disponibilite_provider.dart';
import '../../providers/prestataire_profile_form_provider.dart';

/// Carte « complétez votre profil » (style maquette) avec progression et puces.
class PrestataireProfileCompletionCard extends ConsumerWidget {
  const PrestataireProfileCompletionCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final profileAsync = ref.watch(prestataireProfileFormProvider);
    final hasHoraires = ref.watch(prestataireHorairesProvider).maybeWhen(
          data: (h) => h.isNotEmpty,
          orElse: () => false,
        );

    return profileAsync.when(
      loading: () => const SizedBox.shrink(),
      error: (_, __) => const SizedBox.shrink(),
      data: (data) {
        if (data.isProfileFullyEnriched(hasHoraires: hasHoraires)) {
          return const SizedBox.shrink();
        }

        final percent = prestataireProfileCompletionPercent(
          data,
          hasHoraires: hasHoraires,
        );
        final chips = prestataireCompletionChipActions(
          data: data,
          hasHoraires: hasHoraires,
          onChecklist: (item) => _openChecklist(context, item),
          onEnhancement: (item) => _openEnhancement(context, item),
          onPayments: () {
            context.goPrestataireProfile();
          },
        );

        final accent = theme.colorScheme.error;
        final chipBg = accent.withValues(alpha: 0.08);

        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
          child: Material(
            elevation: 0,
            color: theme.colorScheme.surface,
            borderRadius: BorderRadius.circular(20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.12),
                ),
                boxShadow: [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.06),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: chipBg,
                      borderRadius: const BorderRadius.vertical(
                        top: Radius.circular(20),
                      ),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: accent.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                          ),
                          child: Icon(
                            Icons.error_outline_rounded,
                            color: accent,
                            size: 22,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                DiscPrestaWorkspace.completionTitle,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontFamily: AppFonts.display,
                                  fontWeight: FontWeight.w800,
                                  height: 1.25,
                                ),
                              ),
                              const SizedBox(height: 6),
                              Text(
                                DiscPrestaWorkspace.completionBody,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.35,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          onPressed: () => context.pushPrestataireProfileComplete(),
                          icon: const Icon(Icons.chevron_right_rounded),
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Row(
                          children: [
                            Text(
                              DiscPrestaWorkspace.completionProgress,
                              style: theme.textTheme.labelMedium?.copyWith(
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const Spacer(),
                            Text(
                              '$percent %',
                              style: theme.textTheme.labelLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                                color: theme.colorScheme.primary,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: percent / 100,
                            minHeight: 8,
                            backgroundColor: theme.colorScheme
                                .surfaceContainerHighest
                                .withValues(alpha: 0.8),
                            color: theme.colorScheme.primary,
                          ),
                        ),
                        if (chips.isNotEmpty) ...[
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              for (final chip in chips)
                                ActionChip(
                                  label: Text(chip.label),
                                  labelStyle: theme.textTheme.labelMedium
                                      ?.copyWith(
                                    color: accent,
                                    fontWeight: FontWeight.w600,
                                  ),
                                  backgroundColor: chipBg,
                                  side: BorderSide(
                                    color: accent.withValues(alpha: 0.35),
                                  ),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 4,
                                    vertical: 0,
                                  ),
                                  onPressed: chip.onTap,
                                ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _openChecklist(
    BuildContext context,
    PrestaCompletionChecklistItem item,
  ) {
    final section = switch (item) {
      PrestaCompletionChecklistItem.basics =>
        PrestataireProfileEditSection.vitrine,
      PrestaCompletionChecklistItem.services =>
        PrestataireProfileEditSection.services,
      PrestaCompletionChecklistItem.gallery =>
        PrestataireProfileEditSection.gallery,
    };
    context.pushPrestataireProfileEditSection(section);
  }

  void _openEnhancement(
    BuildContext context,
    PrestaProfileEnhancementItem item,
  ) {
    switch (item) {
      case PrestaProfileEnhancementItem.clientExperience:
        context.pushPrestataireProfileEditSection(
          PrestataireProfileEditSection.clientExperience,
        );
      case PrestaProfileEnhancementItem.gallery:
        context.pushPrestataireProfileEditSection(
          PrestataireProfileEditSection.gallery,
        );
      case PrestaProfileEnhancementItem.horaires:
        context.pushPrestataireHoraires();
    }
  }
}
