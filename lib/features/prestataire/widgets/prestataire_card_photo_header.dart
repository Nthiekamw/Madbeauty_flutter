import 'package:flutter/material.dart';

import '../../../shared/widgets/prestataire_favorite_button.dart';
import 'prestataire_availability_badge.dart';
import 'prestataire_realisation_carousel_scope.dart';

/// Bandeau photo (réalisations) + pastille disponibilité + favori.
class PrestataireCardPhotoHeader extends StatelessWidget {
  const PrestataireCardPhotoHeader({
    super.key,
    required this.prestataireId,
    required this.height,
    this.width,
    this.borderRadius = BorderRadius.zero,
    this.fallbackDisplayName,
    this.fallbackAvatarUrl,
    this.compactBadge = false,
    this.showFavoriteButton = true,
  });

  final String prestataireId;
  final double height;
  final double? width;
  final BorderRadius borderRadius;
  final String? fallbackDisplayName;
  final String? fallbackAvatarUrl;
  final bool compactBadge;
  final bool showFavoriteButton;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        PrestataireRealisationCarouselScope(
          prestataireId: prestataireId,
          height: height,
          width: width,
          borderRadius: borderRadius,
          fallbackDisplayName: fallbackDisplayName,
          fallbackAvatarUrl: fallbackAvatarUrl,
        ),
        Positioned(
          top: 8,
          left: 8,
          child: PrestataireAvailabilityBadge(
            prestataireId: prestataireId,
            compact: compactBadge,
          ),
        ),
        if (showFavoriteButton)
          Positioned(
            top: 8,
            right: 8,
            child: PrestataireFavoriteButton(
              prestataireId: prestataireId,
              compact: compactBadge,
            ),
          ),
      ],
    );
  }
}
