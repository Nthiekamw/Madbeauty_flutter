import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../navigation/prestataire_hub_wizard_navigation.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../logic/prestataire_profile_completeness.dart';
import '../../../models/prestataire_profile_edit_section.dart';
import '../../../providers/agenda/disponibilite_provider.dart';
import '../../../providers/profile/prestataire_profile_form_provider.dart';
import '../../profile/overview/layout/prestataire_profile_insets.dart';

/// Carte compacte « complétez votre profil » (progression + raccourcis).
class PrestataireProfileCompletionCard extends ConsumerWidget {
  const PrestataireProfileCompletionCard({super.key});

  static const _topPadding = 12.0;

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
        final chips = prestataireProfileProgressChipActions(
          data: data,
          hasHoraires: hasHoraires,
          onChecklist: (item) => _openChecklist(context, item),
          onEnhancement: (item) => _openEnhancement(context, item),
          onPayments: () => context.goPrestataireProfile(),
        );

        const accent = AppColors.errorLight;

        void openWizard() {
          PrestataireHubWizardNavigation.openWizard(
            context,
            initialStep: PrestataireHubWizardNavigation.hubStepFromProfileData(
              data,
              hasHoraires: hasHoraires,
            ),
          );
        }

        return Padding(
          padding: PrestataireProfileInsets.page(context).copyWith(
            top: _topPadding,
            bottom: 4,
          ),
          child: Material(
            color: theme.colorScheme.surface,
            elevation: 0,
            borderRadius: BorderRadius.circular(16),
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: openWizard,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      accent.withValues(alpha: 0.12),
                      accent.withValues(alpha: 0.04),
                    ],
                  ),
                  border: Border.all(
                    color: accent.withValues(alpha: 0.45),
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: accent.withValues(alpha: 0.08),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.person_outline_rounded,
                            size: 20,
                            color: accent,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              DiscPrestaWorkspace.completionTitle,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontFamily: AppFonts.display,
                                fontWeight: FontWeight.w800,
                                height: 1.2,
                                fontSize: 14,
                                color: accent,
                              ),
                            ),
                          ),
                          Text(
                            '$percent %',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w800,
                              color: accent,
                            ),
                          ),
                          IconButton(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            constraints: const BoxConstraints(
                              minWidth: 32,
                              minHeight: 32,
                            ),
                            onPressed: openWizard,
                            icon: Icon(
                              Icons.chevron_right_rounded,
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: percent / 100,
                          minHeight: 5,
                          backgroundColor: theme.colorScheme
                              .surfaceContainerHighest
                              .withValues(alpha: 0.9),
                          color: accent,
                        ),
                      ),
                      if (chips.isNotEmpty) ...[
                        const SizedBox(height: 8),
                        SizedBox(
                          height: 30,
                          child: ListView.separated(
                            scrollDirection: Axis.horizontal,
                            itemCount: chips.length,
                            separatorBuilder: (_, __) =>
                                const SizedBox(width: 6),
                            itemBuilder: (context, index) {
                              final chip = chips[index];
                              return ActionChip(
                                visualDensity: VisualDensity.compact,
                                materialTapTargetSize:
                                    MaterialTapTargetSize.shrinkWrap,
                                label: Text(chip.label),
                                labelStyle:
                                    theme.textTheme.labelSmall?.copyWith(
                                  color: accent,
                                  fontWeight: FontWeight.w600,
                                  fontSize: 11,
                                ),
                                backgroundColor:
                                    theme.colorScheme.surface,
                                side: BorderSide(
                                  color: accent.withValues(alpha: 0.3),
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 2,
                                ),
                                onPressed: chip.onTap,
                              );
                            },
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
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
    switch (item) {
      case PrestaCompletionChecklistItem.basics:
        PrestataireHubWizardNavigation.openWizard(context, initialStep: 0);
      case PrestaCompletionChecklistItem.services:
        PrestataireHubWizardNavigation.openWizard(context, initialStep: 2);
      case PrestaCompletionChecklistItem.gallery:
        PrestataireHubWizardNavigation.openWizard(context, initialStep: 4);
    }
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
