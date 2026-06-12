import 'package:flutter/material.dart';

import '../../../../shared/widgets/prestataire/prestataire_favorite_button.dart';
import '../agenda/prestataire_availability_badge.dart';
import '../public/media/prestataire_realisation_carousel_scope.dart';

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
    this.microOverlay = false,
    this.showFavoriteButton = true,
  });

  final String prestataireId;
  final double height;
  final double? width;
  final BorderRadius borderRadius;
  final String? fallbackDisplayName;
  final String? fallbackAvatarUrl;
  final bool compactBadge;
  /// Pastilles encore plus petites (cartes accueil).
  final bool microOverlay;
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
          top: microOverlay ? 5 : 8,
          left: showFavoriteButton ? (microOverlay ? 5 : 8) : null,
          right: showFavoriteButton ? null : (microOverlay ? 5 : 8),
          child: PrestataireAvailabilityBadge(
            prestataireId: prestataireId,
            compact: compactBadge,
            micro: microOverlay,
          ),
        ),
        if (showFavoriteButton)
          Positioned(
            top: microOverlay ? 5 : 8,
            right: microOverlay ? 5 : 8,
            child: PrestataireFavoriteButton(
              prestataireId: prestataireId,
              compact: compactBadge,
              micro: microOverlay,
            ),
          ),
      ],
    );
  }
}

