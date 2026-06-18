import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/geo/discovery_reference.dart';
import '../../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/discovery/content/discovery_shimmer.dart';
import '../../../../services/location/geolocation_service.dart';
import '../../screens/listing_map_fullscreen_screen.dart';

class ListingMapView extends StatefulWidget {
  const ListingMapView({
    super.key,
    required this.entries,
    this.clientLocation,
    this.locationLoading = false,
    this.borderRadius = const BorderRadius.all(Radius.circular(18)),
    this.showFullscreenButton = true,
    this.overlayPadding = const EdgeInsets.all(12),
  });

  final List<PrestataireCatalogEntry> entries;
  final ClientLocation? clientLocation;
  final bool locationLoading;
  final BorderRadius borderRadius;
  final bool showFullscreenButton;

  /// Marge des boutons / badges au-dessus de la carte.
  final EdgeInsets overlayPadding;

  @override
  State<ListingMapView> createState() => _ListingMapViewState();
}

class _ListingMapViewState extends State<ListingMapView> {
  final _mapController = MapController();
  bool _mapReady = false;
  PrestataireCatalogEntry? _selectedEntry;

  @override
  void didUpdateWidget(covariant ListingMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectedId = _selectedEntry?.profile.id;
    if (selectedId != null &&
        !widget.entries.any((entry) => entry.profile.id == selectedId)) {
      _selectedEntry = null;
    }

    final oldLocation = oldWidget.clientLocation;
    final newLocation = widget.clientLocation;
    if (_mapReady &&
        newLocation != null &&
        (oldLocation?.latitude != newLocation.latitude ||
            oldLocation?.longitude != newLocation.longitude)) {
      _moveToClientLocation(newLocation);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final geoEntries = widget.entries.where((entry) {
      return entry.profile.latitude != null && entry.profile.longitude != null;
    }).toList();

    if (geoEntries.isEmpty) {
      return _MapEmptyState(theme: theme);
    }

    final center = _centerFor(geoEntries, widget.clientLocation);

    final mapStack = Stack(
        fit: StackFit.expand,
        children: [
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: center,
              initialZoom: geoEntries.length == 1 ? 13 : 11,
              onTap: (_, __) => setState(() => _selectedEntry = null),
              onMapReady: () {
                _mapReady = true;
                final clientLocation = widget.clientLocation;
                if (clientLocation != null) {
                  _moveToClientLocation(clientLocation);
                }
              },
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.madbeauty.app',
              ),
              MarkerLayer(
                markers: [
                  if (widget.clientLocation != null)
                    Marker(
                      point: LatLng(
                        widget.clientLocation!.latitude,
                        widget.clientLocation!.longitude,
                      ),
                      width: 46,
                      height: 46,
                      child: const _ClientMarker(),
                    ),
                  for (final entry in geoEntries)
                    Marker(
                      point: LatLng(
                        entry.profile.latitude!,
                        entry.profile.longitude!,
                      ),
                      width: 52,
                      height: 52,
                      child: _PrestataireMarker(
                        entry: entry,
                        selected:
                            _selectedEntry?.profile.id == entry.profile.id,
                        onTap: () => setState(() => _selectedEntry = entry),
                      ),
                    ),
                ],
              ),
              const RichAttributionWidget(
                attributions: [
                  TextSourceAttribution('OpenStreetMap contributors'),
                ],
              ),
            ],
          ),
          if (widget.showFullscreenButton)
            Positioned(
              bottom: widget.overlayPadding.bottom,
              right: widget.overlayPadding.right,
              child: ListingMapOverlayButton(
                icon: Icons.open_in_full_rounded,
                tooltip: DiscList.mapExpandHint,
                onTap: () => _openFullscreen(context),
              ),
            ),
          if (widget.locationLoading)
            Positioned(
              top: widget.overlayPadding.top,
              right: widget.overlayPadding.right,
              child: _LocationLoadingBadge(theme: theme),
            ),
          if (_selectedEntry != null)
            Positioned(
              left: widget.overlayPadding.left,
              right: widget.overlayPadding.right,
              bottom: widget.overlayPadding.bottom,
              child: _PrestataireMapCard(entry: _selectedEntry!),
            ),
        ],
      );

    if (widget.borderRadius == BorderRadius.zero) {
      return mapStack;
    }

    return ClipRRect(
      borderRadius: widget.borderRadius,
      child: mapStack,
    );
  }

  void _openFullscreen(BuildContext context) {
    Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        fullscreenDialog: true,
        builder: (context) => ListingMapFullscreenScreen(
          entries: widget.entries,
          clientLocation: widget.clientLocation,
          locationLoading: widget.locationLoading,
        ),
      ),
    );
  }

  LatLng _centerFor(
    List<PrestataireCatalogEntry> geoEntries,
    ClientLocation? clientLocation,
  ) {
    if (clientLocation != null) {
      return LatLng(clientLocation.latitude, clientLocation.longitude);
    }
    if (geoEntries.isEmpty) {
      return const LatLng(
        kDiscoveryReferenceLatitude,
        kDiscoveryReferenceLongitude,
      );
    }

    var lat = 0.0;
    var lng = 0.0;
    for (final entry in geoEntries) {
      lat += entry.profile.latitude!;
      lng += entry.profile.longitude!;
    }
    return LatLng(lat / geoEntries.length, lng / geoEntries.length);
  }

  void _moveToClientLocation(ClientLocation clientLocation) {
    _mapController.move(
      LatLng(clientLocation.latitude, clientLocation.longitude),
      13,
    );
  }
}

class _PrestataireMarker extends StatelessWidget {
  const _PrestataireMarker({
    required this.entry,
    required this.selected,
    required this.onTap,
  });

  final PrestataireCatalogEntry entry;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Tooltip(
      message: entry.displayName,
      child: Material(
        color: AppColors.transparent,
        child: InkWell(
          customBorder: const CircleBorder(),
          onTap: onTap,
          child: DecoratedBox(
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: selected
                  ? theme.colorScheme.secondary
                  : theme.colorScheme.primary,
              boxShadow: [
                BoxShadow(
                  blurRadius: 8,
                  color: AppColors.scrimDark22,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Icon(Icons.spa_outlined, color: theme.colorScheme.onPrimary),
          ),
        ),
      ),
    );
  }
}

class _ClientMarker extends StatelessWidget {
  const _ClientMarker();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: theme.colorScheme.tertiary,
        border: Border.all(color: theme.colorScheme.surface, width: 3),
        boxShadow: [
          BoxShadow(
            blurRadius: 8,
            color: AppColors.scrimDark20,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Icon(Icons.my_location, color: theme.colorScheme.onTertiary),
    );
  }
}

class _PrestataireMapCard extends StatelessWidget {
  const _PrestataireMapCard({required this.entry});

  final PrestataireCatalogEntry entry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ville = entry.profile.ville?.trim();
    final note = entry.profile.noteMoyenne;

    return SizedBox(
      width: double.infinity,
      child: Card(
        elevation: 8,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
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
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              FilledButton.tonal(
                onPressed: () =>
                    context.pushPrestataireDetail(entry.profile.id),
                style: FilledButton.styleFrom(
                  minimumSize: Size.zero,
                  tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 10,
                  ),
                ),
                child: const Text(DiscList.mapOpenDetail),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class ListingMapOverlayButton extends StatelessWidget {
  const ListingMapOverlayButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.onTap,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.colorScheme.surface.withValues(alpha: 0.94),
        elevation: 3,
        shape: const CircleBorder(),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          customBorder: const CircleBorder(),
          child: Padding(
            padding: const EdgeInsets.all(10),
            child: Icon(
              icon,
              size: 22,
              color: theme.colorScheme.onSurface,
            ),
          ),
        ),
      ),
    );
  }
}

class _LocationLoadingBadge extends StatelessWidget {
  const _LocationLoadingBadge({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: theme.colorScheme.surface,
      borderRadius: BorderRadius.circular(999),
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: DiscoveryShimmer.wrap(
          context: context,
          child: DiscoveryShimmerBox(
            width: 18,
            height: 18,
            borderRadius: BorderRadius.circular(999),
          ),
        ),
      ),
    );
  }
}

class _MapEmptyState extends StatelessWidget {
  const _MapEmptyState({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.map_outlined,
              size: 56,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              DiscList.mapNoGeo,
              textAlign: TextAlign.center,
              style: theme.textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              DiscList.mapNoGeoHint,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

