import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../logic/reservation_payment_display.dart';

/// Bandeau paiement (client ou prestataire).
class ReservationPaymentSummaryCard extends StatelessWidget {
  const ReservationPaymentSummaryCard({
    super.key,
    required this.display,
    required this.lines,
    this.compact = false,
  });

  final ReservationPaymentDisplay display;
  final List<ReservationPaymentLine> lines;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    if (!display.shouldShow || lines.isEmpty) {
      return const SizedBox.shrink();
    }

    final theme = Theme.of(context);
    final accent = const Color(0xFF10B981);

    return Container(
      width: double.infinity,
      padding: EdgeInsets.all(compact ? 10 : 12),
      decoration: BoxDecoration(
        color: accent.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: accent.withValues(alpha: 0.22)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.payments_rounded,
                size: compact ? 16 : 18,
                color: accent,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  display.hasStructuredMode
                      ? display.modeLabel
                      : DiscResPay.sectionTitle,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w700,
                    color: accent,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: compact ? 6 : 8),
          for (var i = 0; i < lines.length; i++) ...[
            if (i > 0) const SizedBox(height: 4),
            _LineRow(line: lines[i], theme: theme, accent: accent),
          ],
        ],
      ),
    );
  }
}

class _LineRow extends StatelessWidget {
  const _LineRow({
    required this.line,
    required this.theme,
    required this.accent,
  });

  final ReservationPaymentLine line;
  final ThemeData theme;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: Text(
            line.label,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: AppFonts.body,
              fontWeight: line.emphasize ? FontWeight.w700 : FontWeight.w500,
              color: line.emphasize
                  ? theme.colorScheme.onSurface
                  : theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
        Text(
          line.formattedAmount,
          style: theme.textTheme.bodySmall?.copyWith(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w800,
            color: line.emphasize ? accent : theme.colorScheme.onSurface,
          ),
        ),
      ],
    );
  }
}
