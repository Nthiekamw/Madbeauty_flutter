import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../logic/prestataire_clients_grouping.dart';
import '../../shared/prestataire_client_identity_row.dart';

/// Carte client (style accueil).
class PrestataireClientRowCard extends StatelessWidget {
  const PrestataireClientRowCard({
    super.key,
    required this.summary,
    required this.onTap,
  });

  final PrestataireClientSummary summary;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    return Material(
      color: AppColors.cardSurfaceFor(theme.brightness),
      elevation: 0,
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(
                alpha: isDark ? 0.28 : 0.1,
              ),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(14, 12, 12, 12),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Expanded(
                  child: PrestataireClientIdentityRow(
                    clientName: summary.clientDisplayName,
                    clientPrenom: summary.clientPrenom,
                    clientNom: summary.clientNom,
                    serviceName: summary.lastServiceName,
                    clientAvatarUrl: summary.clientAvatarUrl,
                    avatarRadius: 22,
                    nameStyle: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.2,
                      height: 1.1,
                    ),
                  ),
                ),
                if (summary.isLoyal) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.secondary.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      DiscPrestaWorkspace.loyalBadge,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontWeight: FontWeight.w700,
                        fontSize: 10,
                        color: theme.colorScheme.secondary,
                      ),
                    ),
                  ),
                ],
                const SizedBox(width: 8),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.event_available_outlined,
                          size: 14,
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '${summary.bookingCount}',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontFamily: AppFonts.display,
                            fontWeight: FontWeight.w800,
                            color: primary,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 2),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 20,
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.45),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
