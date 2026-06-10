import 'package:flutter/material.dart';

import '../../../../core/models/domain/catalog/service_beaute.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/utils/currency_format.dart';
import '../../logic/booking_formatters.dart';

class SelectedServiceHeader extends StatelessWidget {
  const SelectedServiceHeader({super.key, required this.service});

  final ServiceBeaute service;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final tertiary = theme.colorScheme.tertiary;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(20),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.6, 1.0],
          colors: [
            primary.withValues(alpha: isDark ? 0.45 : 0.7),
            theme.colorScheme.primaryContainer.withValues(
              alpha: isDark ? 0.6 : 0.88,
            ),
            tertiary.withValues(alpha: isDark ? 0.25 : 0.35),
          ],
        ),
        border: Border.all(
          color: primary.withValues(alpha: isDark ? 0.3 : 0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: 0.12),
            blurRadius: 16,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Row(
          children: [
            Container(
              width: 52,
              height: 52,
              decoration: BoxDecoration(
                color: AppColors.onPrimarySurface20,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: AppColors.onPrimarySurface30,
                ),
              ),
              child: const Icon(Icons.content_cut_rounded,
                  size: 24, color: AppColors.white),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Service sélectionné',
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.onPrimaryMuted75,
                      letterSpacing: 0.3,
                    ),
                  ),
                  const SizedBox(height: 3),
                  Text(
                    service.nom,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                      fontSize: 17,
                      color: AppColors.white,
                      height: 1.15,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    formatBookingServiceMeta(
                      durationMinutes: service.dureeMinutes,
                      price: service.prix,
                    ),
                    style: TextStyle(
                      fontFamily: AppFonts.body,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                      color: AppColors.onPrimaryMuted80,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: AppColors.onPrimarySurface20,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: AppColors.onPrimarySurface30,
                ),
              ),
              child: Text(
                CurrencyFormat.eur(service.prix),
                style: const TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w900,
                  fontSize: 18,
                  color: AppColors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

