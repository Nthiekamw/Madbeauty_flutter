import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../core/models/domain/user/lieu_travail.dart';
import '../../../../../../core/models/domain/user/prestataire_profile.dart';
import '../../../../../../shared/theme/app_fonts.dart';
import '../../../../logic/lieu_travail_display.dart';
import '../../../../logic/professional_experience_entries.dart';

class PrestataireDetailAboutBlock extends StatelessWidget {
  const PrestataireDetailAboutBlock({super.key, required this.profile});

  final PrestataireProfile profile;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final description = profile.description?.trim() ?? '';
    final bio = profile.bio?.trim() ?? '';
    final years = profile.anneesExperience?.trim() ?? '';
    final exp = profile.experienceProfessionnelle?.trim() ?? '';
    final experiences = ProfessionalExperienceCodec.decode(exp, years);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (description.isNotEmpty) ...[
          Text(
            description,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
          ),
          if (bio.isNotEmpty) const SizedBox(height: 14),
        ],
        if (bio.isNotEmpty) ...[
          if (description.isNotEmpty)
            Text(
              DiscPrestaDetail.bioTitle,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          if (description.isNotEmpty) const SizedBox(height: 6),
          Text(
            bio,
            style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
          ),
        ],
        if (experiences.isNotEmpty) ...[
          const SizedBox(height: 16),
          Divider(
            color: theme.colorScheme.outline.withValues(alpha: 0.12),
          ),
          const SizedBox(height: 14),
          Text(
            DiscPrestaDetail.experienceYearsLabel,
            style: theme.textTheme.labelMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          for (final entry in experiences) ...[
            Container(
              width: double.infinity,
              margin: const EdgeInsets.only(bottom: 8),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHighest
                    .withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: theme.colorScheme.outline.withValues(alpha: 0.12),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    entry.role,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  if (entry.years.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      entry.years,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: theme.colorScheme.onSurfaceVariant,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ],
        ],
        if (profile.lieuTravail != null) ...[
          const SizedBox(height: 16),
          _WorkLocationChip(lieu: profile.lieuTravail!),
        ],
      ],
    );
  }
}

class _WorkLocationChip extends StatelessWidget {
  const _WorkLocationChip({required this.lieu});

  final LieuTravail lieu;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Icon(LieuTravailDisplay.icon(lieu), color: primary, size: 22),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              LieuTravailDisplay.label(lieu),
              style: theme.textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
