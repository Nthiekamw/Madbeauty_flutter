import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/realisation_media_type.dart';
import '../../../core/models/domain/reel/reel_feed_item.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/layout/profile_flow_scaffold.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/prestataire/realisation_media_cover.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/guest/widgets/guest_account_prompt.dart';
import '../../auth/providers/auth_notifier.dart';
import '../providers/reel_feed_provider.dart';

/// Reels enregistrés (favoris) — profil client.
class ClientReelFavoritesScreen extends ConsumerWidget {
  const ClientReelFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = switch (ref.watch(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final isGuest = ref.watch(isGuestBrowsingProvider);
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;
    final padding = useWeb
        ? const EdgeInsets.fromLTRB(20, 12, 20, 28)
        : const EdgeInsets.fromLTRB(16, 8, 16, 28);
    final cols = useWeb ? 3 : 2;

    if (user == null || isGuest) {
      return ProfileFlowScaffold(
        title: DiscReel.savedTitle,
        icon: Icons.bookmark_border_rounded,
        wrapPanel: false,
        body: GuestAccountPrompt(
          icon: Icons.bookmark_border_rounded,
          title: DiscReel.savedTitle,
          message: DiscReel.favoriteLoginRequired,
        ),
      );
    }

    final async = ref.watch(clientReelFavoritesProvider);

    return ProfileFlowScaffold(
      title: DiscReel.savedTitle,
      icon: Icons.bookmark_border_rounded,
      body: async.when(
        loading: () => const DiscoveryListSkeleton(rowCount: 6),
        error: (_, __) => Center(
          child: DiscoveryEmptyState(
            icon: Icons.cloud_off_outlined,
            title: DiscReel.savedLoadError,
            body: DiscReel.retry,
            iconColor: theme.colorScheme.error,
            actionLabel: DiscReel.retry,
            onAction: () => ref.invalidate(clientReelFavoritesProvider),
          ),
        ),
        data: (items) {
          if (items.isEmpty) {
            return Center(
              child: DiscoveryEmptyState(
                icon: Icons.bookmark_border_rounded,
                title: DiscReel.savedEmptyTitle,
                body: DiscReel.savedEmptyBody,
                iconColor: theme.colorScheme.primary,
                actionLabel: DiscReel.navLabel,
                onAction: () => context.goClientReel(),
              ),
            );
          }
          return RefreshIndicator(
            onRefresh: () async {
              ref.invalidate(clientReelFavoritesProvider);
              await ref.read(clientReelFavoritesProvider.future);
            },
            child: GridView.builder(
              padding: padding,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
                childAspectRatio: 3 / 4,
              ),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                return _SavedReelTile(
                  item: item,
                  onTap: () => context.goClientReel(reelId: item.id),
                );
              },
            ),
          );
        },
      ),
    );
  }
}

class _SavedReelTile extends StatelessWidget {
  const _SavedReelTile({
    required this.item,
    required this.onTap,
  });

  final ReelFeedItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: theme.colorScheme.outline.withValues(alpha: 0.12),
            ),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Stack(
              fit: StackFit.expand,
              children: [
                RealisationMediaCover(
                  mediaType: item.mediaType,
                  imageUrl: item.mediaUrl,
                  playVideoPreview: false,
                  showPlayBadge: item.mediaType == RealisationMediaType.video,
                ),
                const DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0x00000000),
                        Color(0x99000000),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: Text(
                    item.salonName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: theme.textTheme.labelMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                if (item.hasMultipleMedia)
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Icon(
                      Icons.collections_outlined,
                      size: 16,
                      color: AppColors.white.withValues(alpha: 0.95),
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
