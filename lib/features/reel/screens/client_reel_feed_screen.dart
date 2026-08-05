import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/models/domain/catalog/realisation_media_type.dart';
import '../../../core/models/domain/reel/reel_feed_item.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/widgets/app/app_avatar.dart';
import '../../../shared/widgets/app/app_network_image.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/prestataire/network_video_preview.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../logic/reel_share.dart';
import '../providers/reel_feed_provider.dart';
import '../widgets/reel_comments_sheet.dart';
import '../../../shared/utils/native_share.dart';

/// Fil vertical type Reel (photos + vidéos), style TikTok.
class ClientReelFeedScreen extends ConsumerStatefulWidget {
  const ClientReelFeedScreen({super.key, this.focusReelId});

  /// Deep link / partage : place ce Reel en tête du feed.
  final String? focusReelId;

  @override
  ConsumerState<ClientReelFeedScreen> createState() =>
      _ClientReelFeedScreenState();
}

class _ClientReelFeedScreenState extends ConsumerState<ClientReelFeedScreen> {
  final _pageController = PageController();
  int _currentIndex = 0;
  String? _focusedReelId;

  @override
  void initState() {
    super.initState();
    final focus = widget.focusReelId?.trim();
    if (focus != null && focus.isNotEmpty) {
      _focusedReelId = focus;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ref.read(reelFeedControllerProvider.notifier).focusReel(focus);
      });
    }
  }

  @override
  void didUpdateWidget(covariant ClientReelFeedScreen oldWidget) {
    super.didUpdateWidget(oldWidget);
    final focus = widget.focusReelId?.trim();
    if (focus != null &&
        focus.isNotEmpty &&
        focus != _focusedReelId) {
      _focusedReelId = focus;
      ref.read(reelFeedControllerProvider.notifier).focusReel(focus);
      if (_pageController.hasClients) {
        _pageController.jumpToPage(0);
      }
      setState(() => _currentIndex = 0);
    }
  }

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
            onFavorite: () => _onFavorite(item),
            onShare: (shareContext) => _onShare(shareContext, item),
            onComment: () => showReelCommentsSheet(context, reelId: item.id),
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
    final isGuest = ref.read(isGuestBrowsingProvider);
    if (isGuest) {
      AppSnackBar.show(context, message: DiscReel.likeLoginRequired);
      return;
    }
    try {
      await ref.read(reelFeedControllerProvider.notifier).toggleLike(reelId);
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, _mapReelActionError(e, like: true));
    }
  }

  Future<void> _onFavorite(ReelFeedItem item) async {
    final isGuest = ref.read(isGuestBrowsingProvider);
    if (isGuest) {
      AppSnackBar.show(context, message: DiscReel.favoriteLoginRequired);
      return;
    }
    try {
      final saved = await ref
          .read(reelFeedControllerProvider.notifier)
          .toggleFavorite(item.id);
      ref.invalidate(clientReelFavoritesProvider);
      if (!mounted) return;
      AppSnackBar.success(
        context,
        saved ? DiscReel.favoriteAdded : DiscReel.favoriteRemoved,
      );
    } catch (e) {
      if (!mounted) return;
      AppSnackBar.error(context, _mapReelActionError(e, like: false));
    }
  }

  String _mapReelActionError(Object error, {required bool like}) {
    final raw = error.toString().toLowerCase();
    if (raw.contains('profil client') ||
        raw.contains('ensure_client_profile')) {
      return like ? DiscReel.likeNeedClient : DiscReel.favoriteNeedClient;
    }
    return like ? DiscReel.likeError : DiscReel.favoriteError;
  }

  Future<void> _onShare(BuildContext shareContext, ReelFeedItem item) async {
    final outcome = await shareReelPost(shareContext, item);
    if (!mounted) return;
    switch (outcome) {
      case NativeShareOutcome.shared:
      case NativeShareOutcome.dismissed:
        break;
      case NativeShareOutcome.copiedFallback:
        AppSnackBar.success(context, DiscReel.shareCopiedFallback);
        break;
      case NativeShareOutcome.failed:
        AppSnackBar.error(context, DiscReel.shareError);
        break;
    }
  }
}

class _ReelPage extends StatefulWidget {
  const _ReelPage({
    required this.item,
    required this.active,
    required this.onLike,
    required this.onFavorite,
    required this.onShare,
    required this.onComment,
    required this.onOpenSalon,
    required this.onBook,
  });

  final ReelFeedItem item;
  final bool active;
  final VoidCallback onLike;
  final VoidCallback onFavorite;
  final void Function(BuildContext shareContext) onShare;
  final VoidCallback onComment;
  final VoidCallback onOpenSalon;
  final VoidCallback onBook;

  @override
  State<_ReelPage> createState() => _ReelPageState();
}

class _ReelPageState extends State<_ReelPage> {
  late final PageController _mediaController;
  int _mediaIndex = 0;

  @override
  void initState() {
    super.initState();
    _mediaController = PageController();
  }

  @override
  void dispose() {
    _mediaController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final item = widget.item;
    final media = item.media;
    final caption = item.caption?.trim();
    final avatar = item.avatarUrl?.trim();
    final multi = media.length > 1;

    return Stack(
      fit: StackFit.expand,
      children: [
        if (media.isEmpty)
          const ColoredBox(color: AppColors.black)
        else if (!multi)
          _ReelMediaSlide(
            media: media.first,
            active: widget.active,
          )
        else
          PageView.builder(
            controller: _mediaController,
            itemCount: media.length,
            onPageChanged: (i) => setState(() => _mediaIndex = i),
            physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
            itemBuilder: (context, index) {
              return _ReelMediaSlide(
                media: media[index],
                active: widget.active && index == _mediaIndex,
              );
            },
          ),
        // Ne doit pas bloquer le swipe horizontal du carrousel.
        const IgnorePointer(
          child: DecoratedBox(
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
        ),
        if (multi)
          Positioned(
            left: 16,
            right: 72,
            bottom: 132,
            child: IgnorePointer(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  for (var i = 0; i < media.length; i++) ...[
                    if (i > 0) const SizedBox(width: 5),
                    AnimatedContainer(
                      duration: const Duration(milliseconds: 180),
                      width: i == _mediaIndex ? 7 : 5,
                      height: i == _mediaIndex ? 7 : 5,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: i == _mediaIndex
                            ? AppColors.white
                            : AppColors.white.withValues(alpha: 0.45),
                      ),
                    ),
                  ],
                ],
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
                onTap: widget.onOpenSalon,
                child: Row(
                  children: [
                    AppAvatar(
                      displayName: item.salonName,
                      imageUrl: avatar,
                      radius: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        item.salonName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.titleMedium?.copyWith(
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
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: AppColors.white,
                  ),
                ),
              ],
              const SizedBox(height: 10),
              Wrap(
                spacing: 6,
                runSpacing: 6,
                children: [
                  FilledButton(
                    onPressed: widget.onBook,
                    style: FilledButton.styleFrom(
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    child: const Text(DiscReel.bookCta),
                  ),
                  OutlinedButton(
                    onPressed: widget.onOpenSalon,
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppColors.white,
                      side: const BorderSide(color: AppColors.white, width: 1),
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      minimumSize: const Size(0, 32),
                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      textStyle: theme.textTheme.labelMedium?.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
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
                onPressed: widget.onLike,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                padding: EdgeInsets.zero,
                icon: Icon(
                  item.likedByMe
                      ? Icons.favorite_rounded
                      : Icons.favorite_border_rounded,
                  color: item.likedByMe
                      ? AppColors.notificationDot
                      : AppColors.white,
                  size: 28,
                ),
                tooltip: item.likedByMe
                    ? DiscReel.unlikeTooltip
                    : DiscReel.likeTooltip,
              ),
              Text(
                '${item.likesCount}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              IconButton(
                onPressed: widget.onComment,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.chat_bubble_outline_rounded,
                  color: AppColors.white,
                  size: 26,
                ),
                tooltip: DiscReel.commentTooltip,
              ),
              Text(
                '${item.commentsCount}',
                style: theme.textTheme.labelMedium?.copyWith(
                  color: AppColors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 10),
              IconButton(
                onPressed: widget.onFavorite,
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                padding: EdgeInsets.zero,
                icon: Icon(
                  item.savedByMe
                      ? Icons.bookmark_rounded
                      : Icons.bookmark_border_rounded,
                  color: AppColors.white,
                  size: 28,
                ),
                tooltip: item.savedByMe
                    ? DiscReel.unfavoriteTooltip
                    : DiscReel.favoriteTooltip,
              ),
              const SizedBox(height: 10),
              IconButton(
                onPressed: () => widget.onShare(context),
                visualDensity: VisualDensity.compact,
                constraints: const BoxConstraints(minWidth: 44, minHeight: 44),
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.share_rounded,
                  color: AppColors.white,
                  size: 26,
                ),
                tooltip: DiscReel.shareTooltip,
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _ReelMediaSlide extends StatelessWidget {
  const _ReelMediaSlide({
    required this.media,
    required this.active,
  });

  final ReelMediaItem media;
  final bool active;

  @override
  Widget build(BuildContext context) {
    if (media.mediaType == RealisationMediaType.video) {
      return NetworkVideoPreview(
        url: media.mediaUrl,
        autoPlay: active,
        muted: false,
        loop: true,
        fit: BoxFit.cover,
        tapToTogglePlay: true,
        placeholderIconSize: 48,
      );
    }
    return AppNetworkImage(
      url: media.mediaUrl,
      fit: BoxFit.cover,
    );
  }
}


