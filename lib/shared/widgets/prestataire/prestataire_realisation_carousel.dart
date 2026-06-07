import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../app/app_avatar.dart';

/// Carrousel auto-défilant pour les photos de réalisations d'un prestataire.
class PrestataireRealisationCarousel extends StatefulWidget {
  const PrestataireRealisationCarousel({
    super.key,
    required this.photoUrls,
    this.height = 120,
    this.width,
    this.borderRadius = BorderRadius.zero,
    this.fallbackDisplayName,
    this.fallbackAvatarUrl,
    this.autoAdvanceInterval = const Duration(seconds: 3),
  });

  final List<String> photoUrls;
  final double height;
  final double? width;
  final BorderRadius borderRadius;
  final String? fallbackDisplayName;
  final String? fallbackAvatarUrl;
  final Duration autoAdvanceInterval;

  @override
  State<PrestataireRealisationCarousel> createState() =>
      _PrestataireRealisationCarouselState();
}

class _PrestataireRealisationCarouselState
    extends State<PrestataireRealisationCarousel> {
  PageController? _pageController;
  Timer? _autoTimer;
  int _pageIndex = 0;

  List<String> get _urls => _normalizeUrls(widget.photoUrls);

  static List<String> _normalizeUrls(List<String> raw) =>
      raw.map((u) => u.trim()).where((u) => u.isNotEmpty).toList();

  @override
  void initState() {
    super.initState();
    _initController();
    _scheduleAutoAdvance();
  }

  @override
  void didUpdateWidget(covariant PrestataireRealisationCarousel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (listEquals(_normalizeUrls(oldWidget.photoUrls), _urls)) return;

    _stopAutoAdvance();
    _pageIndex = 0;
    _disposeController();
    _initController();
    _scheduleAutoAdvance();
  }

  void _initController() {
    if (_urls.length > 1) {
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
    if (_urls.length <= 1) return;

    _autoTimer = Timer.periodic(widget.autoAdvanceInterval, (_) {
      if (!mounted) return;

      final urls = _urls;
      final controller = _pageController;
      if (urls.length <= 1 || controller == null || !controller.hasClients) {
        return;
      }

      final next = (_pageIndex + 1) % urls.length;
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

    if (_urls.isEmpty) {
      return _FallbackMedia(
        size: size,
        borderRadius: widget.borderRadius,
        displayName: widget.fallbackDisplayName,
        avatarUrl: widget.fallbackAvatarUrl,
      );
    }

    if (_urls.length == 1) {
      return _PhotoFrame(
        url: _urls.first,
        size: size,
        borderRadius: widget.borderRadius,
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
              itemCount: _urls.length,
              itemBuilder: (context, index) {
                return _PhotoFrame(
                  url: _urls[index],
                  size: size,
                  borderRadius: BorderRadius.zero,
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
                  children: List.generate(_urls.length, (i) {
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

class _PhotoFrame extends StatelessWidget {
  const _PhotoFrame({
    required this.url,
    required this.size,
    required this.borderRadius,
  });

  final String url;
  final Size size;
  final BorderRadius borderRadius;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: size.width > 0 ? size.width : null,
        height: size.height,
        child: Image.network(
          url,
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => ColoredBox(
            color: theme.colorScheme.surfaceContainerHighest,
            child: Icon(
              Icons.broken_image_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          loadingBuilder: (context, child, progress) {
            if (progress == null) return child;
            return ColoredBox(
              color: theme.colorScheme.surfaceContainerHighest,
              child: Center(
                child: SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: theme.colorScheme.primary,
                  ),
                ),
              ),
            );
          },
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
  });

  final Size size;
  final BorderRadius borderRadius;
  final String? displayName;
  final String? avatarUrl;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final url = avatarUrl?.trim();

    if (url != null && url.isNotEmpty) {
      return _PhotoFrame(
        url: url,
        size: size,
        borderRadius: borderRadius,
      );
    }

    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: size.width > 0 ? size.width : null,
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
              radius: 32,
            ),
          ),
        ),
      ),
    );
  }
}
