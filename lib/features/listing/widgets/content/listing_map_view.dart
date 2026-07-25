import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/geo/discovery_reference.dart';
import '../../../../core/logic/prestataire/prestataire_map_visibility.dart';
import '../../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/discovery/content/discovery_shimmer.dart';
import '../../../../services/location/geolocation_service.dart';
import '../../../../services/location/route_directions_service.dart';
import '../../screens/listing_map_fullscreen_screen.dart';
import 'listing_map_prestataire_card.dart';

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
  final _routeService = RouteDirectionsService();
  bool _mapReady = false;
  PrestataireCatalogEntry? _selectedEntry;
  RouteDirections? _route;
  bool _routeLoading = false;
  int _routeRequestId = 0;

  @override
  void dispose() {
    _routeRequestId++;
    _routeService.close();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ListingMapView oldWidget) {
    super.didUpdateWidget(oldWidget);
    final selectedId = _selectedEntry?.profile.id;
    if (selectedId != null &&
        !widget.entries.any((entry) => entry.profile.id == selectedId)) {
      _clearSelection();
    }

    final oldLocation = oldWidget.clientLocation;
    final newLocation = widget.clientLocation;
    if (_mapReady &&
        newLocation != null &&
        (oldLocation?.latitude != newLocation.latitude ||
            oldLocation?.longitude != newLocation.longitude)) {
      if (_selectedEntry != null) {
        _loadRouteForSelection(_selectedEntry!);
      } else {
        _moveToClientLocation(newLocation);
      }
    }
  }

  void _clearSelection() {
    _routeRequestId++;
    setState(() {
      _selectedEntry = null;
      _route = null;
      _routeLoading = false;
    });
  }

  void _selectEntry(PrestataireCatalogEntry entry) {
    setState(() {
      _selectedEntry = entry;
      _route = null;
    });
    _loadRouteForSelection(entry);
  }

  Future<void> _loadRouteForSelection(PrestataireCatalogEntry entry) async {
    final client = widget.clientLocation;
    final destLat = entry.profile.latitude;
    final destLng = entry.profile.longitude;
    if (client == null || destLat == null || destLng == null) {
      setState(() {
        _route = null;
        _routeLoading = false;
      });
      return;
    }

    final requestId = ++_routeRequestId;
    setState(() => _routeLoading = true);

    final route = await _routeService.drivingRoute(
      originLat: client.latitude,
      originLng: client.longitude,
      destLat: destLat,
      destLng: destLng,
    );

    if (!mounted || requestId != _routeRequestId) return;

    setState(() {
      _route = route;
      _routeLoading = false;
    });
    _fitRoute(route);
  }

  void _fitRoute(RouteDirections route) {
    if (!_mapReady || route.points.length < 2) return;
    try {
      _mapController.fitCamera(
        CameraFit.bounds(
          bounds: LatLngBounds.fromPoints(route.points),
          padding: EdgeInsets.fromLTRB(
            widget.overlayPadding.left + 36,
            widget.overlayPadding.top + 48,
            widget.overlayPadding.right + 36,
            widget.overlayPadding.bottom + 140,
          ),
          maxZoom: 15,
        ),
      );
    } catch (_) {
      // Bounds invalides : on laisse la caméra en place.
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final geoEntries = filterMapCatalogEntries(widget.entries);

    if (geoEntries.isEmpty) {
      return _MapEmptyState(theme: theme);
    }

    final center = _centerFor(geoEntries, widget.clientLocation);
    final routePoints = _route?.points ?? const <LatLng>[];

    final mapStack = Stack(
      fit: StackFit.expand,
      children: [
        FlutterMap(
          mapController: _mapController,
          options: MapOptions(
            initialCenter: center,
            initialZoom: geoEntries.length == 1 ? 13 : 11,
            onTap: (_, __) => _clearSelection(),
            onMapReady: () {
              _mapReady = true;
              final route = _route;
              if (route != null) {
                _fitRoute(route);
                return;
              }
              final clientLocation = widget.clientLocation;
              if (clientLocation != null) {
                _moveToClientLocation(clientLocation);
              }
            },
          ),
          children: [
            TileLayer(
              urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
              userAgentPackageName: 'com.madbeauty.madbeauty',
            ),
            if (routePoints.length >= 2)
              PolylineLayer(
                polylines: [
                  Polyline(
                    points: routePoints,
                    strokeWidth: 4.5,
                    color: theme.colorScheme.tertiary.withValues(alpha: 0.92),
                    borderStrokeWidth: 2,
                    borderColor: theme.colorScheme.surface.withValues(
                      alpha: 0.85,
                    ),
                  ),
                ],
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
                      onTap: () => _selectEntry(entry),
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
            bottom: widget.overlayPadding.bottom +
                (_selectedEntry != null ? 132 : 0),
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
            child: ListingMapPrestataireCard(
              entry: _selectedEntry!,
              clientLocation: widget.clientLocation,
              route: _route,
              routeLoading: _routeLoading,
            ),
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
