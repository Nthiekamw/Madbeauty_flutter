import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../shared/theme/app_colors.dart';
import '../../../../../../shared/theme/app_fonts.dart';

/// Rappel des règles MadBeauty pour les photos de réalisations (sans texte / promo).
class RealisationGalleryPolicyBanner extends StatelessWidget {
  const RealisationGalleryPolicyBanner({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const accent = AppColors.errorLight;
    final bodyStyle = theme.textTheme.bodySmall?.copyWith(
      fontFamily: AppFonts.body,
      color: accent,
      height: 1.45,
      fontSize: 12,
    );
    final boldStyle = bodyStyle?.copyWith(fontWeight: FontWeight.w800);

    return DecoratedBox(
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: accent.withValues(alpha: 0.45), width: 1.2),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: const BoxDecoration(
                color: accent,
                shape: BoxShape.circle,
              ),
              child: const Padding(
                padding: EdgeInsets.all(6),
                child: Icon(
                  Icons.error_outline_rounded,
                  size: 18,
                  color: AppColors.white,
                ),
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DiscPrestaForm.galleryPolicyTitle,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                      color: accent,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text.rich(
                    TextSpan(
                      style: bodyStyle,
                      children: [
                        const TextSpan(
                          text: DiscPrestaForm.galleryPolicyBodyPrefix,
                        ),
                        TextSpan(
                          text: DiscPrestaForm.galleryPolicyBodyBold,
                          style: boldStyle,
                        ),
                        const TextSpan(
                          text: DiscPrestaForm.galleryPolicyBodySuffix,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
