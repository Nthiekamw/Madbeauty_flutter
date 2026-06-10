import 'package:flutter/material.dart';

import '../../../../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../../../../shared/theme/app_colors.dart';
import '../../../../../../shared/widgets/gallery/fullscreen_photo_gallery.dart';

class PrestataireDetailGalleryStrip extends StatelessWidget {
  const PrestataireDetailGalleryStrip({super.key, required this.photos});

  final List<PhotoRealisation> photos;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      height: 148,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final photo = photos[index];
          return Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: () => FullscreenPhotoGallery.open(
                context,
                urls: photos.map((p) => p.url).toList(),
                captions: photos.map((p) => p.caption).toList(),
                initialIndex: index,
              ),
              borderRadius: BorderRadius.circular(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: AspectRatio(
                  aspectRatio: 0.82,
                  child: Image.network(
                    photo.url,
                    fit: BoxFit.cover,
                    errorBuilder: (_, __, ___) => ColoredBox(
                      color: theme.colorScheme.surfaceContainerHighest,
                      child: Icon(
                        Icons.broken_image_outlined,
                        color: theme.colorScheme.onSurfaceVariant,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
