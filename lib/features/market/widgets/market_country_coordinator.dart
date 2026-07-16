import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logic/market/invalidate_market_catalog.dart';
import '../../../core/providers/market_country_provider.dart';
import '../../../features/listing/providers/client_location_provider.dart';
import '../../../services/location/location_providers.dart';

/// Lance la détection automatique du marché au démarrage et resynchronise
/// quand le GPS devient disponible (cas fréquent sur mobile).
class MarketCountryCoordinator extends ConsumerStatefulWidget {
  const MarketCountryCoordinator({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MarketCountryCoordinator> createState() =>
      _MarketCountryCoordinatorState();
}

class _MarketCountryCoordinatorState
    extends ConsumerState<MarketCountryCoordinator> {
  bool _startupDone = false;
  String? _lastAppliedGpsKey;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      unawaited(_runAutoDetection());
    });
  }

  Future<void> _runAutoDetection() async {
    final changed = await ref
        .read(marketCountryProvider.notifier)
        .autoDetectIfNeeded(ref.read(marketDetectionServiceProvider));
    _startupDone = true;
    if (!mounted || !changed) return;
    invalidateMarketCatalog(ref);
  }

  Future<void> _applyGpsIfNeeded(ClientLocation location) async {
    if (!_startupDone) return;
    final key =
        '${location.latitude.toStringAsFixed(3)},'
        '${location.longitude.toStringAsFixed(3)}';
    if (_lastAppliedGpsKey == key) return;
    _lastAppliedGpsKey = key;

    final changed = await ref
        .read(marketCountryProvider.notifier)
        .applyDetectedCoordinates(
          latitude: location.latitude,
          longitude: location.longitude,
          detection: ref.read(marketDetectionServiceProvider),
        );
    if (!mounted || !changed) return;
    invalidateMarketCatalog(ref);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(clientLocationProvider, (previous, next) {
      final location = switch (next) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (location == null) return;
      unawaited(_applyGpsIfNeeded(location));
    });

    return widget.child;
  }
}
