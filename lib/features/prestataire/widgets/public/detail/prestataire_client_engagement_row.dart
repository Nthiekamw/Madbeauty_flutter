import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../features/favorites/providers/client_favorite_prestataire_ids_provider.dart';
import '../../../../../features/likes/logic/toggle_prestataire_like.dart';
import '../../../../../features/likes/providers/client_prestataire_likes_provider.dart';
import '../../../../../features/auth/providers/auth_notifier.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/widgets/app/app_snack_bar.dart';
import 'sections/prestataire_detail_section_layout.dart';
import 'sections/prestataire_detail_surface.dart';

/// Like (public) vs favori (privé) — carte style accueil.
class PrestataireClientEngagementRow extends ConsumerStatefulWidget {
  const PrestataireClientEngagementRow({
    super.key,
    required this.prestataireId,
  });

  final String prestataireId;

  @override
  ConsumerState<PrestataireClientEngagementRow> createState() =>
      _PrestataireClientEngagementRowState();
}

class _PrestataireClientEngagementRowState
    extends ConsumerState<PrestataireClientEngagementRow> {
  static const _likeColor = Color(0xFF2563EB);

  bool _likeBusy = false;
  bool _favoriteBusy = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final pad = DiscoveryResponsive.of(context).horizontalPadding;
    final isLiked = ref.watch(isPrestataireLikedProvider(widget.prestataireId));
    final isFavorite =
        ref.watch(isPrestataireFavoriteProvider(widget.prestataireId));

    return Padding(
      padding: EdgeInsets.fromLTRB(pad, 18, pad, 0),
      child: PrestataireDetailSurface.cardMaterial(
        theme: theme,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            PrestataireDetailSectionHeader(
              icon: Icons.favorite_outline_rounded,
              title: DiscPrestaDetail.engagementSectionTitle,
            ),
            const SizedBox(height: 10),
            Row(
              children: [
                Expanded(
                  child: _EngagementChip(
                    icon: isLiked
                        ? Icons.thumb_up_rounded
                        : Icons.thumb_up_outlined,
                    label: DiscLike.engagementLabel,
                    hint: DiscLike.engagementHint,
                    active: isLiked,
                    activeColor: _likeColor,
                    enabled: !_likeBusy,
                    onTap: _toggleLike,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _EngagementChip(
                    icon: isFavorite
                        ? Icons.bookmark_rounded
                        : Icons.bookmark_border_rounded,
                    label: DiscFavori.engagementLabel,
                    hint: DiscFavori.engagementHint,
                    active: isFavorite,
                    activeColor: AppColors.favorite,
                    enabled: !_favoriteBusy,
                    onTap: _toggleFavorite,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleLike() async {
    if (_likeBusy) return;
    setState(() => _likeBusy = true);
    try {
      await togglePrestataireLike(
        context: context,
        ref: ref,
        prestataireId: widget.prestataireId,
      );
    } finally {
      if (mounted) setState(() => _likeBusy = false);
    }
  }

  Future<void> _toggleFavorite() async {
    if (_favoriteBusy) return;

    final user = switch (ref.read(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (user == null) {
      AppSnackBar.show(context, message: DiscFavori.loginRequired);
      context.pushLogin();
      return;
    }

    final wasFavorite =
        ref.read(isPrestataireFavoriteProvider(widget.prestataireId));

    setState(() => _favoriteBusy = true);
    try {
      await ref
          .read(clientFavoritePrestataireIdsProvider.notifier)
          .toggle(widget.prestataireId);
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: wasFavorite
            ? DiscFavori.removedFeedback
            : DiscFavori.addedFeedback,
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, message: DiscFavori.toggleError);
    } finally {
      if (mounted) setState(() => _favoriteBusy = false);
    }
  }
}

class _EngagementChip extends StatelessWidget {
  const _EngagementChip({
    required this.icon,
    required this.label,
    required this.hint,
    required this.active,
    required this.activeColor,
    required this.onTap,
    this.enabled = true,
  });

  final IconData icon;
  final String label;
  final String hint;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final fill = active
        ? activeColor.withValues(alpha: 0.12)
        : (isDark
            ? AppColors.darkSurfaceContainerHigh
            : AppColors.filterChipInactive);

    return Tooltip(
      message: hint,
      child: Material(
        color: fill,
        borderRadius: BorderRadius.circular(24),
        child: InkWell(
          onTap: enabled ? onTap : null,
          borderRadius: BorderRadius.circular(24),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(
                  icon,
                  size: 16,
                  color: active
                      ? activeColor
                      : theme.colorScheme.onSurfaceVariant,
                ),
                const SizedBox(width: 6),
                Flexible(
                  child: Text(
                    label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelSmall?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w700,
                      fontSize: 11,
                      color:
                          active ? activeColor : theme.colorScheme.onSurface,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
