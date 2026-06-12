import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../providers/agenda/prestataire_open_slots_provider.dart';
import '../../../../shared/theme/app_colors.dart';

/// Pastille « Dispo » / « Non dispo » selon les créneaux réservables.
class PrestataireAvailabilityBadge extends ConsumerWidget {
  const PrestataireAvailabilityBadge({
    super.key,
    required this.prestataireId,
    this.compact = false,
    this.micro = false,
  });

  final String prestataireId;
  final bool compact;
  final bool micro;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(prestataireHasOpenSlotsProvider(prestataireId));

    return async.when(
      data: (available) => _AvailabilityChip(
        available: available,
        compact: compact,
        micro: micro,
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => _AvailabilityChip(
        available: false,
        compact: compact,
        micro: micro,
      ),
    );
  }
}

class _AvailabilityChip extends StatelessWidget {
  const _AvailabilityChip({
    required this.available,
    required this.compact,
    this.micro = false,
  });

  final bool available;
  final bool compact;
  final bool micro;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final small = compact || micro;
    final bg = available
        ? AppColors.availableBadgeDark.withValues(alpha: micro ? 0.68 : (compact ? 0.72 : 0.85))
        : theme.colorScheme.onSurface.withValues(alpha: micro ? 0.52 : (compact ? 0.58 : 0.72));
    final fg = AppColors.white;
    final label = available ? DiscHome.badgeDispo : DiscHome.badgeNonDispo;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(micro ? 8 : (compact ? 10 : 12)),
        boxShadow: [
          BoxShadow(
            color: AppColors.scrimDark18,
            blurRadius: micro ? 4 : 6,
            offset: Offset(0, micro ? 1 : 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: micro ? 5 : (compact ? 7 : 9),
          vertical: micro ? 2 : (compact ? 4 : 5),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: micro ? 4.5 : (compact ? 6 : 7),
              height: micro ? 4.5 : (compact ? 6 : 7),
              decoration: BoxDecoration(
                color: available
                    ? AppColors.availableDot.withValues(alpha: small ? 0.85 : 1)
                    : AppColors.unavailableDot,
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: micro ? 3 : (compact ? 5 : 6)),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w700,
                color: fg,
                fontSize: micro ? 7.5 : (compact ? 9 : 11),
                letterSpacing: micro ? 0 : 0.2,
                height: 1.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

