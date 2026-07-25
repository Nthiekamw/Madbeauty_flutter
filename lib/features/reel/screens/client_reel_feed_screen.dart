import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/models/domain/catalog/realisation_media_type.dart';
import '../../../core/models/domain/reel/reel_feed_item.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/app/app_network_image.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/prestataire/network_video_preview.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../providers/reel_feed_provider.dart';

/// Fil vertical type Reel (photos + vidéos).
class ClientReelFeedScreen extends ConsumerStatefulWidget {
  const ClientReelFeedScreen({super.key});

  @override
  ConsumerState<ClientReelFeedScreen> createState() =>
      _ClientReelFeedScreenState();
}

class _ClientReelFeedScreenState extends ConsumerState<ClientReelFeedScreen> {
  final _pageController = PageController();
  int _currentIndex = 0;

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reelFeedControllerProvider);
    final maxW = DiscoveryResponsive.of(context).contentMaxWidth;

    return ColoredBox(
      color: AppColors.black,
      child: SafeArea(
        top: true,
        bottom: false,
        child: Center(
          child: ConstrainedBox(
            constraints: BoxConstraints(maxWidth: maxW.clamp(320, 560)),
            child: _buildBody(state),
          ),
        ),
      ),
    );
  }

  Widget _buildBody(ReelFeedState state) {
    if (state.isLoading && state.items.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(color: AppColors.white),
      );
    }
    if (state.error != null && state.items.isEmpty) {
      final err = state.error;
      final body = err is AppFailure ? err.message : DiscReel.feedLoadError;
      return DiscoveryEmptyState(
        icon: Icons.wifi_off_rounded,
        title: DiscReel.feedLoadError,
        body: body,
        actionLabel: DiscReel.retry,
        onAction: () => ref.read(reelFeedControllerProvider.notifier).refresh(),
      );
    }
    if (state.items.isEmpty) {
      return DiscoveryEmptyState(
        icon: Icons.movie_filter_outlined,
        title: DiscReel.feedEmptyTitle,
        body: DiscReel.feedEmptyBody,
        actionLabel: DiscReel.retry,
        onAction: () => ref.read(reelFeedControllerProvider.notifier).refresh(),
      );
    }

    return RefreshIndicator(
      color: AppColors.white,
      backgroundColor: AppColors.scrimDark54,
      onRefresh: () => ref.read(reelFeedControllerProvider.notifier).refresh(),
      child: PageView.builder(
        controller: _pageController,
        scrollDirection: Axis.vertical,
        itemCount: state.items.length,
        onPageChanged: (index) {
          setState(() => _currentIndex = index);
          final item = state.items[index];
          ref.read(reelFeedControllerProvider.notifier).recordView(item.id);
          if (index >= state.items.length - 3) {
            ref.read(reelFeedControllerProvider.notifier).loadMore();
          }
        },
        itemBuilder: (context, index) {
          final item = state.items[index];
          return _ReelPage(
            item: item,
            active: index == _currentIndex,
            onLike: () => _onLike(item.id),
            onOpenSalon: () =>
                context.pushPrestataireDetail(item.prestataireId),
            onBook: () =>
                context.pushBooking(prestataireId: item.prestataireId),
          );
        },
      ),
    );
  }

  Future<void> _onLike(String reelId) async {
    final isGuest = ref.read(guestModeProvider);
    if (isGuest) {
      AppSnackBar.show(context, message: DiscReel.likeLoginRequired);
      return;
    }
    try {
      await ref.read(reelFeedControllerProvider.notifier).toggleLike(reelId);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, DiscReel.likeError);
    }
  }
}

class _ReelPage extends StatelessWidget {
  const _ReelPage({
    required this.item,
    required this.active,
    required this.onLike,
    required this.onOpenSalon,
    required this.onBook,
  });

  final ReelFeedItem item;
  final bool active;
  final VoidCallback onLike;
  final VoidCallback onOpenSalon;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final isVideo = item.mediaType == RealisationMediaType.video;
    final caption = item.caption?.trim();
    final avatar = item.avatarUrl?.trim();

    return Stack(
      fit: StackFit.expand,
      children: [
        if (isVideo)
          NetworkVideoPreview(
            url: item.mediaUrl,
            autoPlay: active,
            muted: false,
            loop: true,
            fit: BoxFit.cover,
          )
        else
          AppNetworkImage(
            url: item.mediaUrl,
            fit: BoxFit.cover,
          ),
        const DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                Color(0x66000000),
                Color(0x00000000),
                Color(0x99000000),
              ],
              stops: [0, 0.35, 1],
            ),
          ),
        ),
        Positioned(
          left: 16,
          right: 72,
          bottom: 24,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              InkWell(
                onTap: onOpenSalon,
                child: Row(
                  children: [
                    CircleAvatar(
                      radius: 18,
                      backgroundColor: AppColors.scrimDark54,
                      backgroundImage:
                          avatar != null && avatar.isNotEmpty
                              ? NetworkImage(avatar)
                              : null,
                      child: avatar == null || avatar.isEmpty
                          ? const Icon(
                              Icons.storefront,
                              color: AppColors.white,
                              size: 18,
                            )
                          : null,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.salonName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style:
                            Theme.of(context).textTheme.titleMedium?.copyWith(
                                  color: AppColors.white,
                                  fontWeight: FontWeight.w700,
                                ),
                      ),
                    ),
                  ],
                ),
              ),
              if (caption != null && caption.isNotEmpty) ...[
                const SizedBox(height: 10),
                Text(
                  caption,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.white,
                      ),
                ),
              ],
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  FilledButton(
                    onPressed: onBook,
                    child: const Text(DiscReel.bookCta),
                  ),
                  OutlinedButton(
                    onPressed: onOpenSalon,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: const BorderSide(color: AppColors.white),
                    ),
                    child: const Text(DiscReel.seeSalon),
                  ),
                ],
              ),
            ],
          ),
        ),
        Positioned(
          right: 12,
          bottom: 36,
          child: Column(
            children: [
              IconButton(
                onPressed: onLike,
                icon: Icon(
                  item.likedByMe
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: item.likedByMe ? Colors.pinkAccent : AppColors.white,
                  size: 32,
                ),
                tooltip: item.likedByMe
                    ? DiscReel.unlikeTooltip
                    : DiscReel.likeTooltip,
              ),
              Text(
                '${item.likesCount}',
                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                      color: AppColors.white,
                      fontWeight: FontWeight.w600,
                    ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
