import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../shared/prestataire_metric_tile.dart';

class PrestataireProfileStatsStrip extends StatelessWidget {
  const PrestataireProfileStatsStrip({
    super.key,
    required this.servicesCount,
    required this.specialtiesCount,
    required this.photosCount,
  });

  final int servicesCount;
  final int specialtiesCount;
  final int photosCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return PrestataireMetricStrip(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      metrics: [
        PrestataireMetricTile(
          icon: Icons.design_services_outlined,
          label: DiscPrestaProfile.statServices,
          value: '$servicesCount',
          accent: theme.colorScheme.primary,
        ),
        PrestataireMetricTile(
          icon: Icons.category_outlined,
          label: DiscPrestaProfile.statSpecialties,
          value: '$specialtiesCount',
          accent: theme.colorScheme.secondary,
        ),
        PrestataireMetricTile(
          icon: Icons.photo_library_outlined,
          label: DiscPrestaProfile.statPhotos,
          value: '$photosCount',
          accent: theme.colorScheme.tertiary,
        ),
      ],
    );
  }
}
