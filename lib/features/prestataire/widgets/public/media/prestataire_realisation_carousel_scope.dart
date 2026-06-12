import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../../../shared/widgets/discovery/content/discovery_shimmer.dart';
import '../../../../../shared/widgets/gallery/fullscreen_realisation_gallery.dart';
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
    this.playVideos = false,
    this.imagesOnly = true,
  });

  final String prestataireId;
  final double height;
  final double? width;
  final BorderRadius borderRadius;
  final String? fallbackDisplayName;
  final String? fallbackAvatarUrl;
  final bool playVideos;
  /// `true` sur les cartes (accueil, catalogue, favoris) : masque les vidéos.
  final bool imagesOnly;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(realisationPhotosProvider(prestataireId));
    final theme = Theme.of(context);

    return async.when(
      data: (photos) {
        final visible =
            imagesOnly ? photos.realisationImagesOnly : photos;
        if (visible.isEmpty) {
          return PrestataireRealisationCarousel(
            items: const [],
            height: height,
            width: width,
            borderRadius: borderRadius,
            fallbackDisplayName: fallbackDisplayName,
            fallbackAvatarUrl: fallbackAvatarUrl,
          );
        }

        return PrestataireRealisationCarousel(
          items: visible.map(RealisationCarouselItem.fromPhoto).toList(),
          height: height,
          width: width,
          borderRadius: borderRadius,
          fallbackDisplayName: fallbackDisplayName,
          fallbackAvatarUrl: fallbackAvatarUrl,
          playVideos: playVideos && !imagesOnly,
          onItemTap: (index) => FullscreenRealisationGallery.open(
            context,
            items: visible,
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
        items: const [],
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
        child: DiscoveryShimmer.wrap(
          context: context,
          child: ColoredBox(color: color),
        ),
      ),
    );
  }
}

