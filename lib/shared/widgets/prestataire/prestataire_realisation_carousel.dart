import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../core/models/domain/catalog/realisation_media_type.dart';
import '../../theme/app_colors.dart';
import '../app/app_avatar.dart';
import 'realisation_media_cover.dart';

/// Élément affichable dans [PrestataireRealisationCarousel].
class RealisationCarouselItem {
  const RealisationCarouselItem({
    required this.url,
    this.mediaType = RealisationMediaType.image,
  });

  factory RealisationCarouselItem.fromPhoto(PhotoRealisation photo) {
    return RealisationCarouselItem(
      url: photo.url,
      mediaType: photo.mediaType,
    );
  }

  final String url;
  final RealisationMediaType mediaType;

  bool get isVideo => mediaType.isVideo;
}

/// Carrousel auto-défilant pour photos et vidéos de réalisations.
class PrestataireRealisationCarousel extends StatefulWidget {
  const PrestataireRealisationCarousel({
    super.key,
    this.items = const [],
    @Deprecated('Use items instead') this.photoUrls = const [],
    this.height = 120,
    this.width,
    this.borderRadius = BorderRadius.zero,
    this.fallbackDisplayName,
    this.fallbackAvatarUrl,
    this.autoAdvanceInterval = const Duration(seconds: 3),
    this.playVideos = false,
    this.onItemTap,
    this.coverAlignment = Alignment.center,
  });

  final List<RealisationCarouselItem> items;
  final List<String> photoUrls;
  final double height;
  final double? width;
  final BorderRadius borderRadius;
  final String? fallbackDisplayName;
  final String? fallbackAvatarUrl;
  final Duration autoAdvanceInterval;
  final bool playVideos;
  final void Function(int index)? onItemTap;
  final Alignment coverAlignment;

  @override
  State<PrestataireRealisationCarousel> createState() =>
      _PrestataireRealisationCarouselState();
}

class _PrestataireRealisationCarouselState
    extends State<PrestataireRealisationCarousel> {
  PageController? _pageController;
  Timer? _autoTimer;
  int _pageIndex = 0;

  List<RealisationCarouselItem> get _items => _resolveItems();

  List<RealisationCarouselItem> _resolveItems() {
    if (widget.items.isNotEmpty) {
      return widget.items
          .where((item) => item.url.trim().isNotEmpty)
          .toList();
    }
    return widget.photoUrls
        .map((u) => u.trim())
        .where((u) => u.isNotEmpty)
        .map((url) => RealisationCarouselItem(url: url))
        .toList();
  }

  @override
  void initState() {
    super.initState();
    _initController();
    _scheduleAutoAdvance();
  }

  @override
  void didUpdateWidget(covariant PrestataireRealisationCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (listEquals(oldWidget.items, widget.items) &&
        listEquals(oldWidget.photoUrls, widget.photoUrls) &&
        oldWidget.playVideos == widget.playVideos) {
      return;
    }

    _stopAutoAdvance();
    _pageIndex = 0;
    _disposeController();
    _initController();
    _scheduleAutoAdvance();
  }

  void _initController() {
    if (_items.length > 1) {
      _pageController = PageController();
    }
  }

  void _stopAutoAdvance() {
    _autoTimer?.cancel();
    _autoTimer = null;
  }

  void _disposeController() {
    _pageController?.dispose();
    _pageController = null;
  }

  void _scheduleAutoAdvance() {
    _stopAutoAdvance();
    if (_items.length <= 1) return;

    _autoTimer = Timer.periodic(widget.autoAdvanceInterval, (_) {
      if (!mounted) return;

      final items = _items;
      final controller = _pageController;
      if (items.length <= 1 || controller == null || !controller.hasClients) {
        return;
      }

      final current = items[_pageIndex];
      if (widget.playVideos && current.isVideo) return;

      final next = (_pageIndex + 1) % items.length;
      controller.animateToPage(
        next,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
    });
  }

  @override
  void dispose() {
    _stopAutoAdvance();
    _disposeController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return _buildCarousel(context, theme, widget.width);
  }

  Widget _buildCarousel(
    BuildContext context,
    ThemeData theme,
    double? width,
  ) {
    final size = Size(width ?? 0, widget.height);
    final items = _items;

    if (items.isEmpty) {
      return _FallbackMedia(
        size: size,
        borderRadius: widget.borderRadius,
        displayName: widget.fallbackDisplayName,
        avatarUrl: widget.fallbackAvatarUrl,
        coverAlignment: widget.coverAlignment,
      );
    }

    if (items.length == 1) {
      return _MediaFrame(
        item: items.first,
        size: size,
        borderRadius: widget.borderRadius,
        playVideos: widget.playVideos,
        coverAlignment: widget.coverAlignment,
        onTap: widget.onItemTap != null ? () => widget.onItemTap!(0) : null,
      );
    }

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: SizedBox(
        width: width,
        height: widget.height,
        child: Stack(
          fit: StackFit.expand,
          children: [
            PageView.builder(
              controller: _pageController,
              onPageChanged: (i) => setState(() => _pageIndex = i),
              itemCount: items.length,
              itemBuilder: (context, index) {
                return _MediaFrame(
                  item: items[index],
                  size: size,
                  borderRadius: BorderRadius.zero,
                  playVideos: widget.playVideos && index == _pageIndex,
                  coverAlignment: widget.coverAlignment,
                  onTap: widget.onItemTap != null
                      ? () => widget.onItemTap!(index)
                      : null,
                );
              },
            ),
            Positioned(
              left: 8,
              right: 8,
              bottom: 8,
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(items.length, (i) {
                    final active = i == _pageIndex;
                    return AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.symmetric(horizontal: 2.5),
                      width: active ? 14 : 6,
                      height: 6,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(4),
                        color: active
                            ? theme.colorScheme.onPrimary
                            : theme.colorScheme.onPrimary.withValues(
                                alpha: 0.45,
                              ),
                      ),
                    );
                  }),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MediaFrame extends StatelessWidget {
  const _MediaFrame({
    required this.item,
    required this.size,
    required this.borderRadius,
    required this.playVideos,
    this.coverAlignment = Alignment.center,
    this.onTap,
  });

  final RealisationCarouselItem item;
  final Size size;
  final BorderRadius borderRadius;
  final bool playVideos;
  final Alignment coverAlignment;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final media = RealisationMediaCover(
      mediaType: item.mediaType,
      imageUrl: item.url,
      fit: BoxFit.cover,
      alignment: coverAlignment,
      playVideoPreview: playVideos && item.isVideo,
      showPlayBadge: item.isVideo && !playVideos,
      playIconSize: size.height < 120 ? 24 : 36,
    );

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: size.width > 0 ? size.width : double.infinity,
        height: size.height,
        child: onTap == null
            ? media
            : Material(
                color: AppColors.transparent,
                child: InkWell(onTap: onTap, child: media),
              ),
      ),
    );
  }
}

class _FallbackMedia extends StatelessWidget {
  const _FallbackMedia({
    required this.size,
    required this.borderRadius,
    this.displayName,
    this.avatarUrl,
    this.coverAlignment = Alignment.center,
  });

  final Size size;
  final BorderRadius borderRadius;
  final String? displayName;
  final String? avatarUrl;
  final Alignment coverAlignment;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = avatarUrl?.trim();

    if (url != null && url.isNotEmpty) {
      return _MediaFrame(
        item: RealisationCarouselItem(url: url),
        size: size,
        borderRadius: borderRadius,
        playVideos: false,
        coverAlignment: coverAlignment,
      );
    }

    final shortest = size.shortestSide > 0 ? size.shortestSide : 120.0;
    final avatarRadius = (shortest * 0.26).clamp(28.0, 56.0);

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: size.width > 0 ? size.width : double.infinity,
        height: size.height,
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
                theme.colorScheme.secondaryContainer.withValues(alpha: 0.4),
              ],
            ),
          ),
          child: Center(
            child: AppAvatar(
              displayName: displayName,
              radius: avatarRadius,
            ),
          ),
        ),
      ),
    );
  }
}
