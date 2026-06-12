import 'package:flutter/material.dart';

import '../../../../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../../../../core/models/domain/catalog/realisation_media_type.dart';
import '../../../../../../shared/theme/app_colors.dart';
import '../../../../../../shared/widgets/gallery/fullscreen_realisation_gallery.dart';
import '../../../../../../shared/widgets/prestataire/realisation_media_cover.dart';

class PrestataireDetailGalleryStrip extends StatelessWidget {
  const PrestataireDetailGalleryStrip({super.key, required this.photos});

  final List<PhotoRealisation> photos;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 168,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: photos.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final photo = photos[index];
          return Material(
            color: AppColors.transparent,
            child: InkWell(
              onTap: () => FullscreenRealisationGallery.open(
                context,
                items: photos,
                initialIndex: index,
              ),
              borderRadius: BorderRadius.circular(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: SizedBox(
                  width: 124,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      RealisationMediaCover(
                        mediaType: photo.mediaType,
                        imageUrl: photo.url,
                        playVideoPreview: photo.mediaType.isVideo,
                        showPlayBadge: photo.mediaType.isVideo,
                        playIconSize: 30,
                      ),
                      if (photo.mediaType.isVideo)
                        Positioned(
                          left: 8,
                          bottom: 8,
                          child: DecoratedBox(
                            decoration: BoxDecoration(
                              color: Colors.black.withValues(alpha: 0.55),
                              borderRadius: BorderRadius.circular(999),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.symmetric(
                                horizontal: 7,
                                vertical: 3,
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.videocam_rounded,
                                    size: 12,
                                    color: AppColors.white,
                                  ),
                                  SizedBox(width: 4),
                                  Text(
                                    'Vidéo',
                                    style: TextStyle(
                                      color: AppColors.white,
                                      fontSize: 10,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                    ],
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
