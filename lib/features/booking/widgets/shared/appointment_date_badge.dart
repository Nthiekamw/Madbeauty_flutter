import 'package:flutter/material.dart';

import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../logic/booking_formatters.dart';

/// Badge compact jour + mois pour un rendez-vous.
class AppointmentDateBadge extends StatelessWidget {
  const AppointmentDateBadge({
    super.key,
    required this.date,
    this.size = 38,
  });

  final DateTime date;
  final double size;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final local = date.toLocal();
    final primary = theme.colorScheme.primary;

    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.clientAppointmentIconBgDark
            : AppColors.clientAppointmentIconBg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: primary.withValues(alpha: isDark ? 0.35 : 0.2),
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            formatBookingMonthShort(local),
            style: theme.textTheme.labelSmall?.copyWith(
              fontFamily: AppFonts.body,
              fontSize: 8.5,
              fontWeight: FontWeight.w800,
              letterSpacing: 0.4,
              height: 1,
              color: primary.withValues(alpha: 0.9),
            ),
          ),
          const SizedBox(height: 1),
          Text(
            '${local.day}',
            style: theme.textTheme.titleSmall?.copyWith(
              fontFamily: AppFonts.display,
              fontSize: 15,
              fontWeight: FontWeight.w900,
              height: 1,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ],
      ),
    );
  }
}
