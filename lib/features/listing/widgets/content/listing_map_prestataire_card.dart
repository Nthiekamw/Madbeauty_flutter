import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../services/location/geolocation_service.dart';
import '../../../../services/location/route_directions_service.dart';
import '../../../../shared/utils/maps_directions_launcher.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';

/// Carte bas de sélection d’un prestataire sur la carte listing.
class ListingMapPrestataireCard extends StatelessWidget {
  const ListingMapPrestataireCard({
    super.key,
    required this.entry,
    this.clientLocation,
    this.route,
    this.routeLoading = false,
    this.onOpenDirections,
  });

  final PrestataireCatalogEntry entry;
  final ClientLocation? clientLocation;
  final RouteDirections? route;
  final bool routeLoading;
  final VoidCallback? onOpenDirections;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ville = entry.profile.ville?.trim();
    final note = entry.profile.noteMoyenne;
    final hasCoords =
        entry.profile.latitude != null && entry.profile.longitude != null;

    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: theme.colorScheme.primaryContainer,
                    foregroundColor: theme.colorScheme.onPrimaryContainer,
                    child: const Icon(Icons.spa_outlined),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          entry.displayName,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Wrap(
                          spacing: 8,
                          runSpacing: 4,
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            if (ville != null && ville.isNotEmpty)
                              Text(
                                ville,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            if (note != null)
                              Text(
                                '★ ${note.toStringAsFixed(1)}',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.primary,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                            if (routeLoading)
                              Text(
                                DiscList.mapDirectionsLoading,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              )
                            else if (route != null)
                              Text(
                                DiscList.mapRouteSummary(
                                  distanceKm: route!.distanceKm,
                                  duration: route!.duration,
                                  approximate: route!.isApproximate,
                                ),
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.tertiary,
                                  fontWeight: FontWeight.w700,
                                ),
                              )
                            else if (clientLocation == null && hasCoords)
                              Text(
                                DiscList.mapDirectionsNeedLocation,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              LayoutBuilder(
                builder: (context, constraints) {
                  final narrow = constraints.maxWidth < 340;
                  final directionsBtn = OutlinedButton.icon(
                    onPressed: hasCoords
                        ? () => _openDirections(context)
                        : null,
                    icon: const Icon(Icons.directions_rounded, size: 18),
                    label: Text(
                      clientLocation != null
                          ? DiscList.mapDirectionsOpenExternal
                          : DiscList.mapDirections,
                    ),
                    style: OutlinedButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                  );
                  final detailBtn = FilledButton.tonal(
                    onPressed: () =>
                        context.pushPrestataireDetail(entry.profile.id),
                    style: FilledButton.styleFrom(
                      minimumSize: const Size(0, 44),
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                    ),
                    child: const Text(DiscList.mapOpenDetail),
                  );
                  if (narrow) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        directionsBtn,
                        const SizedBox(height: 8),
                        detailBtn,
                      ],
                    );
                  }
                  return Row(
                    children: [
                      Expanded(child: directionsBtn),
                      const SizedBox(width: 8),
                      Expanded(child: detailBtn),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),
      );
  }

  Future<void> _openDirections(BuildContext context) async {
    onOpenDirections?.call();
    final lat = entry.profile.latitude;
    final lng = entry.profile.longitude;
    if (lat == null || lng == null) return;

    final ok = await MapsDirectionsLauncher.openDirections(
      destLat: lat,
      destLng: lng,
      destLabel: entry.displayName,
      originLat: clientLocation?.latitude,
      originLng: clientLocation?.longitude,
    );
    if (!context.mounted) return;
    if (!ok) {
      AppSnackBar.error(context, DiscList.mapDirectionsOpenFailed);
    }
  }
}
