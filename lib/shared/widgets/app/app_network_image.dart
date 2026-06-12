import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';

import '../discovery/content/discovery_shimmer.dart';

/// Image réseau avec cache disque/mémoire, placeholder shimmer et fallback.
class AppNetworkImage extends StatelessWidget {
  const AppNetworkImage({
    super.key,
    required this.url,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.borderRadius,
    this.placeholder,
    this.error,
    this.filterQuality = FilterQuality.medium,
  });

  final String url;
  final BoxFit fit;
  final double? width;
  final double? height;
  final BorderRadius? borderRadius;
  final Widget? placeholder;
  final Widget? error;
  final FilterQuality filterQuality;

  bool get _hasUrl => url.trim().isNotEmpty;

  int? _memCacheSize(BuildContext context, double? logicalSize) {
    if (logicalSize == null || !logicalSize.isFinite || logicalSize <= 0) {
      return null;
    }
    final ratio = MediaQuery.devicePixelRatioOf(context);
    return (logicalSize * ratio).round();
  }

  double? get _finiteWidth =>
      width != null && width!.isFinite && width! > 0 ? width : null;

  double? get _finiteHeight =>
      height != null && height!.isFinite && height! > 0 ? height : null;

  /// Une seule dimension de cache pour ne pas déformer le décodage.
  ({int? width, int? height}) _memCacheDimensions(BuildContext context) {
    final cacheW = _memCacheSize(context, _finiteWidth);
    final cacheH = _memCacheSize(context, _finiteHeight);
    if (cacheW == null && cacheH == null) {
      return (width: null, height: null);
    }
    if (cacheW == null) return (width: null, height: cacheH);
    if (cacheH == null) return (width: cacheW, height: null);
    if (cacheW >= cacheH) {
      return (width: cacheW, height: null);
    }
    return (width: null, height: cacheH);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final memCache = _memCacheDimensions(context);
    final child = !_hasUrl
        ? _errorWidget(theme)
        : CachedNetworkImage(
            imageUrl: url,
            fit: fit,
            width: _finiteWidth,
            height: _finiteHeight,
            memCacheWidth: memCache.width,
            memCacheHeight: memCache.height,
            filterQuality: filterQuality,
            placeholder: (_, __) => _placeholderWidget(context, theme),
            errorWidget: (_, __, ___) => _errorWidget(theme),
          );

    if (borderRadius == null) return child;

    return ClipRRect(
      borderRadius: borderRadius!,
      child: child,
    );
  }

  Widget _placeholderWidget(BuildContext context, ThemeData theme) {
    if (placeholder != null) return placeholder!;
    final track = DiscoveryShimmer.colors(theme).track;
    return DiscoveryShimmer.wrap(
      context: context,
      child: ColoredBox(
        color: theme.colorScheme.surfaceContainerHighest,
        child: Center(
          child: Container(
            width: _finiteWidth != null ? _finiteWidth! * 0.4 : 48,
            height: _finiteHeight != null ? _finiteHeight! * 0.4 : 48,
            constraints: const BoxConstraints(maxWidth: 64, maxHeight: 64),
            decoration: BoxDecoration(
              color: track,
              borderRadius: BorderRadius.circular(8),
            ),
          ),
        ),
      ),
    );
  }

  Widget _errorWidget(ThemeData theme) {
    return error ??
        ColoredBox(
          color: theme.colorScheme.surfaceContainerHighest,
          child: Center(
            child: Icon(
              Icons.broken_image_outlined,
              color: theme.colorScheme.onSurfaceVariant,
              size: 28,
            ),
          ),
        );
  }
}
