import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../features/auth/providers/auth_notifier.dart';
import '../../../../../features/favorites/providers/client_favorite_prestataire_ids_provider.dart';
import '../../../../../features/likes/providers/client_prestataire_likes_provider.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/widgets/app/app_snack_bar.dart';
import 'sections/prestataire_detail_section_layout.dart';
import 'sections/prestataire_detail_surface.dart';

/// Like (public) vs favori (privé) — carte style accueil.
class PrestataireClientEngagementRow extends ConsumerWidget {
  const PrestataireClientEngagementRow({
    super.key,
    required this.prestataireId,
  });

  final String prestataireId;

  static const _likeColor = Color(0xFF2563EB);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final pad = DiscoveryResponsive.of(context).horizontalPadding;
    final isLiked = ref.watch(isPrestataireLikedProvider(prestataireId));
    final isFavorite = ref.watch(isPrestataireFavoriteProvider(prestataireId));

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
                    onTap: () => _toggleLike(context, ref, isLiked),
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
                    onTap: () => _toggleFavorite(context, ref, isFavorite),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _toggleLike(
    BuildContext context,
    WidgetRef ref,
    bool wasLiked,
  ) async {
    final user = switch (ref.read(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (user == null) {
      AppSnackBar.show(context, message: DiscLike.loginRequired);
      return;
    }

    try {
      await ref
          .read(clientLikedPrestataireIdsProvider.notifier)
          .toggle(prestataireId);
      if (!context.mounted) return;
      AppSnackBar.show(
        context,
        message: wasLiked ? DiscLike.removedFeedback : DiscLike.addedFeedback,
      );
    } catch (_) {
      if (!context.mounted) return;
      AppSnackBar.show(context, message: DiscLike.toggleError);
    }
  }

  Future<void> _toggleFavorite(
    BuildContext context,
    WidgetRef ref,
    bool wasFavorite,
  ) async {
    final user = switch (ref.read(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    if (user == null) {
      AppSnackBar.show(context, message: DiscFavori.loginRequired);
      context.pushLogin();
      return;
    }

    try {
      await ref
          .read(clientFavoritePrestataireIdsProvider.notifier)
          .toggle(prestataireId);
      if (!context.mounted) return;
      AppSnackBar.show(
        context,
        message: wasFavorite
            ? DiscFavori.removedFeedback
            : DiscFavori.addedFeedback,
      );
    } catch (_) {
      if (!context.mounted) return;
      AppSnackBar.show(context, message: DiscFavori.toggleError);
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
  });

  final IconData icon;
  final String label;
  final String hint;
  final bool active;
  final Color activeColor;
  final VoidCallback onTap;

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
          onTap: onTap,
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
                      color: active ? activeColor : theme.colorScheme.onSurface,
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
