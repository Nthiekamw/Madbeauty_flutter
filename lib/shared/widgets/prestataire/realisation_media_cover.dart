import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../core/models/domain/catalog/realisation_media_type.dart';
import '../../theme/app_colors.dart';
import '../app/app_network_image.dart';
import 'network_video_preview.dart';

/// Vignette image ou vidéo pour grilles / bandeaux de réalisations.
class RealisationMediaCover extends StatelessWidget {
  const RealisationMediaCover({
    super.key,
    required this.mediaType,
    this.imageUrl,
    this.memoryBytes,
    this.localVideoPath,
    this.fit = BoxFit.cover,
    this.playVideoPreview = false,
    this.showPlayBadge = true,
    this.playIconSize = 28,
  });

  final RealisationMediaType mediaType;
  final String? imageUrl;
  final Uint8List? memoryBytes;
  final String? localVideoPath;
  final BoxFit fit;
  final bool playVideoPreview;
  final bool showPlayBadge;
  final double playIconSize;

  bool get _isVideo => mediaType.isVideo;

  @override
  Widget build(BuildContext context) {
    if (_isVideo) {
      return Stack(
        fit: StackFit.expand,
        children: [
          if (playVideoPreview)
            NetworkVideoPreview(
              url: imageUrl,
              localPath: localVideoPath,
              autoPlay: true,
              muted: true,
              loop: true,
              fit: fit,
            )
          else
            ColoredBox(
              color: Colors.black.withValues(alpha: 0.78),
              child: imageUrl != null
                  ? AppNetworkImage(url: imageUrl!, fit: fit)
                  : const SizedBox.shrink(),
            ),
          if (showPlayBadge)
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.42),
                  shape: BoxShape.circle,
                ),
                child: Padding(
                  padding: EdgeInsets.all(playIconSize * 0.28),
                  child: Icon(
                    Icons.play_arrow_rounded,
                    color: AppColors.white,
                    size: playIconSize,
                  ),
                ),
              ),
            ),
        ],
      );
    }

    final bytes = memoryBytes;
    final url = imageUrl;
    if (bytes != null) {
      return Image.memory(bytes, fit: fit);
    }
    if (url != null) {
      return AppNetworkImage(url: url, fit: fit);
    }
    return const ColoredBox(color: AppColors.scrimDark12);
  }
}
