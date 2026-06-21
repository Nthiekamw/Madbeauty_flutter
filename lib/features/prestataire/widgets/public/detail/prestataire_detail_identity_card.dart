import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/models/domain/user/prestataire_profile.dart';
import '../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/theme/discovery_styles.dart';
import '../../../../../features/likes/logic/toggle_prestataire_like.dart';
import '../../../../../features/likes/providers/client_prestataire_likes_provider.dart';
import '../../../../../services/supabase/likes/prestataire_like_providers.dart';
import '../../../providers/profile/prestataire_response_time_provider.dart';
import '../../../../reviews/providers/prestataire_note_moyenne_provider.dart';
import 'sections/prestataire_detail_surface.dart';

/// Carte stats et actions (identité affichée dans le hero).
class PrestataireDetailIdentityCard extends ConsumerStatefulWidget {
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
  ConsumerState<PrestataireDetailIdentityCard> createState() =>
      _PrestataireDetailIdentityCardState();
}

class _PrestataireDetailIdentityCardState
    extends ConsumerState<PrestataireDetailIdentityCard> {
  static const _likeColor = Color(0xFF2563EB);

  bool _likeBusy = false;

  Future<void> _toggleLike() async {
    if (_likeBusy || widget.isOwnProfile) return;
    setState(() => _likeBusy = true);
    try {
      await togglePrestataireLike(
        context: context,
        ref: ref,
        prestataireId: widget.profile.id,
      );
    } finally {
      if (mounted) setState(() => _likeBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final pad = DiscoveryResponsive.of(context).horizontalPadding;

    final liveNote = switch (ref.watch(
      prestataireNoteMoyenneProvider(widget.profile.id),
    )) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final rating = liveNote ?? widget.profile.noteMoyenne;
    final respondsQuickly = ref
        .watch(prestataireRespondsQuicklyProvider(widget.profile.id))
        .maybeWhen(data: (v) => v, orElse: () => false);
    final likesCount = ref
        .watch(prestataireLikesCountProvider(widget.profile.id))
        .maybeWhen(data: (v) => v, orElse: () => 0);
    final isLiked = ref.watch(isPrestataireLikedProvider(widget.profile.id));

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 0, pad, 0),
      child: Transform.translate(
        offset: const Offset(0, -6),
        child: PrestataireDetailSurface.cardMaterial(
          theme: theme,
          padding: const EdgeInsets.fromLTRB(14, 10, 14, 14),
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
                    label: '${widget.servicesCount}',
                    hint: DiscPrestaDetail.statServices,
                    centered: true,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatPill(
                    icon: isLiked
                        ? Icons.thumb_up_rounded
                        : Icons.thumb_up_outlined,
                    iconColor:
                        isLiked ? _likeColor : AppColors.brandBrownMid,
                    label: '$likesCount',
                    hint: isLiked
                        ? DiscLike.unlikeTooltip
                        : DiscLike.likeTooltip,
                    centered: true,
                    onTap: widget.isOwnProfile || _likeBusy ? null : _toggleLike,
                    active: isLiked,
                    activeColor: _likeColor,
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
              if (!widget.isOwnProfile) ...[
                const SizedBox(height: 14),
                Row(
                  children: [
                    Expanded(
                      flex: 3,
                      child: FilledButton.icon(
                        onPressed: widget.onBook,
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
                    if (widget.onMessage != null) ...[
                      const SizedBox(width: 8),
                      Expanded(
                        flex: 2,
                        child: OutlinedButton.icon(
                          onPressed: widget.onMessage,
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
    this.onTap,
    this.active = false,
    this.activeColor,
  });

  final IconData icon;
  final Color iconColor;
  final String label;
  final String hint;
  final bool centered;
  final VoidCallback? onTap;
  final bool active;
  final Color? activeColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fill = active && activeColor != null
        ? activeColor!.withValues(alpha: 0.12)
        : (isDark
            ? AppColors.darkSurfaceContainerHigh
            : AppColors.filterChipInactive);

    final child = Container(
      width: centered ? double.infinity : null,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      decoration: BoxDecoration(
        color: fill,
        borderRadius: DiscoveryStyles.chipBorderRadius,
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
    );

    return Tooltip(
      message: hint,
      child: onTap == null
          ? child
          : Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onTap,
                borderRadius: DiscoveryStyles.chipBorderRadius,
                child: child,
              ),
            ),
    );
  }
}
