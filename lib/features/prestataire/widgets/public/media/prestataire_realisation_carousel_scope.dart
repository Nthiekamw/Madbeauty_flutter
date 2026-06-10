import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../shared/widgets/gallery/fullscreen_photo_gallery.dart';
import '../../../../../shared/widgets/prestataire/prestataire_realisation_carousel.dart';
import '../../../providers/profile/prestataire_photos_provider.dart';

/// Charge les réalisations puis affiche le carrousel (ou repli avatar).
class PrestataireRealisationCarouselScope extends ConsumerWidget {
  const PrestataireRealisationCarouselScope({
    super.key,
    required this.prestataireId,
    this.height = 120,
    this.width,
    this.borderRadius = BorderRadius.zero,
    this.fallbackDisplayName,
    this.fallbackAvatarUrl,
  });

  final String prestataireId;
  final double height;
  final double? width;
  final BorderRadius borderRadius;
  final String? fallbackDisplayName;
  final String? fallbackAvatarUrl;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(realisationPhotosProvider(prestataireId));
    final theme = Theme.of(context);

    return async.when(
      data: (photos) {
        if (photos.isEmpty) {
          return PrestataireRealisationCarousel(
            photoUrls: const [],
            height: height,
            width: width,
            borderRadius: borderRadius,
            fallbackDisplayName: fallbackDisplayName,
            fallbackAvatarUrl: fallbackAvatarUrl,
          );
        }

        return PrestataireRealisationCarousel(
          photoUrls: photos.map((p) => p.url).toList(),
          height: height,
          width: width,
          borderRadius: borderRadius,
          fallbackDisplayName: fallbackDisplayName,
          fallbackAvatarUrl: fallbackAvatarUrl,
          onPhotoTap: (index) => FullscreenPhotoGallery.open(
            context,
            urls: photos.map((p) => p.url).toList(),
            captions: photos.map((p) => p.caption).toList(),
            initialIndex: index,
          ),
        );
      },
      loading: () => _LoadingFrame(
        height: height,
        width: width,
        borderRadius: borderRadius,
        color: theme.colorScheme.surfaceContainerHighest,
      ),
      error: (_, __) => PrestataireRealisationCarousel(
        photoUrls: const [],
        height: height,
        width: width,
        borderRadius: borderRadius,
        fallbackDisplayName: fallbackDisplayName,
        fallbackAvatarUrl: fallbackAvatarUrl,
      ),
    );
  }
}

class _LoadingFrame extends StatelessWidget {
  const _LoadingFrame({
    required this.height,
    required this.width,
    required this.borderRadius,
    required this.color,
  });

  final double height;
  final double? width;
  final BorderRadius borderRadius;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: borderRadius,
      child: SizedBox(
        width: width,
        height: height,
        child: ColoredBox(
          color: color,
          child: const Center(
            child: SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          ),
        ),
      ),
    );
  }
}

