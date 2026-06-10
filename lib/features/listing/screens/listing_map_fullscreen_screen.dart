import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../../services/location/geolocation_service.dart';
import '../widgets/content/listing_map_view.dart';

/// Carte catalogue en plein écran.
class ListingMapFullscreenScreen extends StatelessWidget {
  const ListingMapFullscreenScreen({
    super.key,
    required this.entries,
    this.clientLocation,
    this.locationLoading = false,
  });

  final List<PrestataireCatalogEntry> entries;
  final ClientLocation? clientLocation;
  final bool locationLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: Stack(
        fit: StackFit.expand,
        children: [
          ListingMapView(
            entries: entries,
            clientLocation: clientLocation,
            locationLoading: locationLoading,
            borderRadius: BorderRadius.zero,
            showFullscreenButton: false,
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Align(
                alignment: Alignment.topLeft,
              child: ListingMapOverlayButton(
                icon: Icons.close_fullscreen_rounded,
                tooltip: DiscList.mapCollapseHint,
                onTap: () => Navigator.of(context).maybePop(),
              ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}