import 'package:flutter/material.dart';

import '../../../core/geo/geo_point.dart';
import '../../../core/models/domain/user/prestataire_profile.dart';
import '../../../shared/layout/discovery_responsive.dart';
import 'prestataire_home_list_card.dart';
import 'prestataire_horizontal_list_skeleton.dart';

/// Liste horizontale virtualisée de cartes prestataire (accueil).
class PrestataireHomeHorizontalList extends StatelessWidget {
  const PrestataireHomeHorizontalList({
    super.key,
    required this.profiles,
    this.distanceOrigin,
    this.limit,
  });

  final List<PrestataireProfile> profiles;
  final GeoPoint? distanceOrigin;

  /// Limite d'affichage ; le reste est accessible via « Tout voir ».
  final int? limit;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    final maxItems = limit ?? layout.homeHorizontalPreviewLimit;
    final visible = profiles.length <= maxItems
        ? profiles
        : profiles.sublist(0, maxItems);

    return SizedBox(
      height: layout.homeListCardHeight,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        itemCount: visible.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (context, index) {
          return PrestataireHomeListCard(
            profile: visible[index],
            distanceOrigin: distanceOrigin,
            cardWidth: layout.homeListCardWidth,
            cardHeight: layout.homeListCardHeight,
            photoHeight: layout.homeListPhotoHeight,
          );
        },
      ),
    );
  }
}

/// Squelette responsive pour [PrestataireHomeHorizontalList].
class PrestataireHomeHorizontalListSkeleton extends StatelessWidget {
  const PrestataireHomeHorizontalListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    return PrestataireHorizontalListSkeleton(
      height: layout.homeListCardHeight,
      cardWidth: layout.homeListCardWidth,
    );
  }
}

