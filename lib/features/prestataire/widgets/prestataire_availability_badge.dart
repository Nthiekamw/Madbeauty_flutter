import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../providers/prestataire_open_slots_provider.dart';

/// Pastille « Dispo » / « Non dispo » selon les créneaux réservables.
class PrestataireAvailabilityBadge extends ConsumerWidget {
  const PrestataireAvailabilityBadge({
    super.key,
    required this.prestataireId,
    this.compact = false,
  });

  final String prestataireId;
  final bool compact;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(prestataireHasOpenSlotsProvider(prestataireId));

    return async.when(
      data: (available) => _AvailabilityChip(
        available: available,
        compact: compact,
      ),
      loading: () => const SizedBox.shrink(),
      error: (_, __) => _AvailabilityChip(
        available: false,
        compact: compact,
      ),
    );
  }
}

class _AvailabilityChip extends StatelessWidget {
  const _AvailabilityChip({
    required this.available,
    required this.compact,
  });

  final bool available;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bg = available
        ? const Color(0xFF1B5E20)
        : theme.colorScheme.onSurface.withValues(alpha: 0.72);
    final fg = Colors.white;
    final label = available ? DiscHome.badgeDispo : DiscHome.badgeNonDispo;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(compact ? 10 : 12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.symmetric(
          horizontal: compact ? 7 : 9,
          vertical: compact ? 4 : 5,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: compact ? 6 : 7,
              height: compact ? 6 : 7,
              decoration: BoxDecoration(
                color: available ? const Color(0xFF69F0AE) : const Color(0xFFB0BEC5),
                shape: BoxShape.circle,
              ),
            ),
            SizedBox(width: compact ? 5 : 6),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w700,
                color: fg,
                fontSize: compact ? 10 : 11,
                letterSpacing: 0.2,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
