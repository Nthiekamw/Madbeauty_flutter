import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/logic/market/invalidate_market_catalog.dart';
import '../../../core/providers/market_country_provider.dart';
import '../../../services/location/location_providers.dart';

/// Lance la détection automatique du marché au démarrage (sans bandeau).
class MarketCountryCoordinator extends ConsumerStatefulWidget {
  const MarketCountryCoordinator({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<MarketCountryCoordinator> createState() =>
      _MarketCountryCoordinatorState();
}

class _MarketCountryCoordinatorState
    extends ConsumerState<MarketCountryCoordinator> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      _runAutoDetection();
    });
  }

  Future<void> _runAutoDetection() async {
    final changed = await ref
        .read(marketCountryProvider.notifier)
        .autoDetectIfNeeded(ref.read(marketDetectionServiceProvider));
    if (!mounted || !changed) return;
    invalidateMarketCatalog(ref);
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
