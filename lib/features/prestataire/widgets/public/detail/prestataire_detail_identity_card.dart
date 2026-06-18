import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/models/domain/user/prestataire_profile.dart';
import '../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/theme/discovery_styles.dart';
import '../../../../../services/supabase/likes/prestataire_like_providers.dart';
import '../../../providers/profile/prestataire_response_time_provider.dart';
import '../../../../reviews/providers/prestataire_note_moyenne_provider.dart';
import 'sections/prestataire_detail_surface.dart';

/// Carte stats et actions (identité affichée dans le hero).
class PrestataireDetailIdentityCard extends ConsumerWidget {
  const PrestataireDetailIdentityCard({
    super.key,
    required this.profile,
    required this.servicesCount,
    required this.isOwnProfile,
    required this.onBook,
    this.onMessage,
  });

  final PrestataireProfile profile;
  final int servicesCount;
  final bool isOwnProfile;
  final VoidCallback onBook;
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final pad = DiscoveryResponsive.of(context).horizontalPadding;

    final liveNote = switch (ref.watch(
      prestataireNoteMoyenneProvider(profile.id),
    )) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final rating = liveNote ?? profile.noteMoyenne;
    final respondsQuickly = ref
        .watch(prestataireRespondsQuicklyProvider(profile.id))
        .maybeWhen(data: (v) => v, orElse: () => false);
    final likesCount = ref
        .watch(prestataireLikesCountProvider(profile.id))
        .maybeWhen(data: (v) => v, orElse: () => 0);

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 4, pad, 0),
      child: PrestataireDetailSurface.cardMaterial(
        theme: theme,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatPill(
                    icon: Icons.star_rounded,
                    iconColor: AppColors.starRating,
                    label: rating != null
                        ? rating.toStringAsFixed(1)
                        : '—',
                    hint: DiscPrestaDetail.statRating,
                    centered: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatPill(
                    icon: Icons.content_cut_rounded,
                    iconColor: primary,
                    label: '$servicesCount',
                    hint: DiscPrestaDetail.statServices,
                    centered: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatPill(
                    icon: Icons.thumb_up_rounded,
                    iconColor: AppColors.brandBrownMid,
                    label: '$likesCount',
                    hint: DiscPrestaDetail.statLikes,
                    centered: true,
                  ),
                ),
                if (respondsQuickly) ...[
                  const SizedBox(width: 8),
                  Expanded(
                    child: _StatPill(
                      icon: Icons.bolt_rounded,
                      iconColor: AppColors.purpleAccent,
                      label: '<2h',
                      hint: DiscPrestaDetail.statResponse,
                      centered: true,
                    ),
                  ),
                ],
              ],
            ),
              if (!isOwnProfile) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: FilledButton.icon(
                        onPressed: onBook,
                        icon: const Icon(Icons.calendar_month_rounded, size: 17),
                        label: Text(
                          DiscPrestaDetail.actionBook,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontFamily: AppFonts.display,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        style: FilledButton.styleFrom(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 10,
                            vertical: 10,
                          ),
                          minimumSize: const Size(0, 42),
                          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          shape: RoundedRectangleBorder(
                            borderRadius: DiscoveryStyles.chipBorderRadius,
                          ),
                        ),
                      ),
                    ),
                    if (onMessage != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton.icon(
                          onPressed: onMessage,
                          icon: const Icon(
                            Icons.chat_bubble_outline_rounded,
                            size: 16,
                          ),
                          label: FittedBox(
                            fit: BoxFit.scaleDown,
                            child: Text(
                              DiscPrestaDetail.contact,
                              maxLines: 1,
                              softWrap: false,
                            ),
                          ),
                          style: OutlinedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 10,
                            ),
                            minimumSize: const Size(0, 42),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            shape: RoundedRectangleBorder(
                              borderRadius: DiscoveryStyles.chipBorderRadius,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ],
          ),
        ),
    );
  }
}

class _StatPill extends StatelessWidget {
  const _StatPill({
    required this.icon,
    required this.iconColor,
    required this.label,
    required this.hint,
    this.centered = false,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String hint;
  final bool centered;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fill = isDark
        ? AppColors.darkSurfaceContainerHigh
        : AppColors.filterChipInactive;

    return Tooltip(
      message: hint,
      child: Container(
        width: centered ? double.infinity : null,
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
        decoration: BoxDecoration(
          color: fill,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          mainAxisSize: centered ? MainAxisSize.max : MainAxisSize.min,
          mainAxisAlignment:
              centered ? MainAxisAlignment.center : MainAxisAlignment.start,
          children: [
            Icon(icon, size: 15, color: iconColor),
            const SizedBox(width: 5),
            Flexible(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: centered ? TextAlign.center : TextAlign.start,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w700,
                  fontSize: 11,
                  color: theme.colorScheme.onSurface,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
