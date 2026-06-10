import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../features/auth/providers/auth_notifier.dart';
import '../../../../../features/favorites/providers/client_favorite_prestataire_ids_provider.dart';
import '../../../../../features/likes/providers/client_prestataire_likes_provider.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/theme/discovery_styles.dart';
import '../../../../../shared/widgets/app/app_snack_bar.dart';

/// Like (public) vs favori (privé) — actions explicites sur la fiche prestataire.
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
    final isLiked = ref.watch(isPrestataireLikedProvider(prestataireId));
    final isFavorite = ref.watch(isPrestataireFavoriteProvider(prestataireId));

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            DiscPrestaDetail.engagementSectionTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            DiscPrestaDetail.engagementSectionSubtitle,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 12),
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
              const SizedBox(width: 10),
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
    final borderColor = active
        ? activeColor.withValues(alpha: 0.55)
        : theme.colorScheme.outline.withValues(alpha: 0.2);
    final background = active
        ? activeColor.withValues(alpha: 0.1)
        : theme.colorScheme.surfaceContainerLowest;

    return Material(
      color: background,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: DiscoveryStyles.cardBorderRadius,
        side: BorderSide(color: borderColor),
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: DiscoveryStyles.cardBorderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 12),
          child: Column(
            children: [
              Icon(
                icon,
                size: 22,
                color: active ? activeColor : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: active ? activeColor : theme.colorScheme.onSurface,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                hint,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.25,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
