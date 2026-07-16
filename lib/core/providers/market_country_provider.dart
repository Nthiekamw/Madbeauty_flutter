import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../config/market_config.dart';
import '../logic/market/market_country_resolver.dart';
import '../logic/address/postal_country_format.dart';
import '../../services/location/market_detection_service.dart';
import '../../services/storage/local_cache_service.dart';
import '../../services/supabase/profile/client_profile_providers.dart';

/// Code pays ISO du marché actif (catalogue, découverte).
final marketCountryProvider =
    NotifierProvider<MarketCountryNotifier, String>(MarketCountryNotifier.new);

class MarketCountryNotifier extends Notifier<String> {
  @override
  String build() {
    final cache = LocalCacheService.instance;
    final profileAsync = ref.watch(currentClientProfileProvider);
    final profileCountry = profileAsync.maybeWhen(
      data: (profile) => profile?.pays,
      orElse: () => null,
    );
    return MarketCountryResolver.resolve(
      cache: cache,
      profileCountryCode: profileCountry,
    );
  }

  /// Rafraîchit le marché auto (locale / GPS) au démarrage.
  ///
  /// Sur mobile, demande la localisation si la locale n’indique pas un pays
  /// supporté (ex. `fr` sans région → ambigu FR/BE/CA).
  Future<bool> autoDetectIfNeeded(MarketDetectionService detection) async {
    final profileCountry = ref.read(currentClientProfileProvider).maybeWhen(
          data: (profile) => profile?.pays?.trim(),
          orElse: () => null,
        );
    // Adresse profil = source de vérité : pas d’override GPS.
    if (profileCountry != null && profileCountry.isNotEmpty) {
      final resolved = _resolveCurrent();
      if (resolved == state) return false;
      state = resolved;
      return true;
    }

    final detected = await detection.tryDetect(requestPermission: true);
    final cache = LocalCacheService.instance;
    final previousAuto = cache.marketCountryAutoCode?.trim();

    if (detected == null) {
      if (previousAuto == null || previousAuto.isEmpty) {
        final resolved = _resolveCurrent();
        if (resolved == state) return false;
        state = resolved;
        return true;
      }
      // Ne pas effacer un auto code valide si la détection échoue ponctuellement
      // (GPS timeout) — on conserve le cache.
      final resolved = _resolveCurrent();
      if (resolved == state) return false;
      state = resolved;
      return true;
    }

    final normalized = MarketConfig.normalizeCountryCode(detected);
    await cache.setMarketCountryAutoCode(normalized);
    await cache.setMarketCountryAutoDetected(true);

    final resolved = _resolveCurrent();
    if (resolved == state && previousAuto == normalized) return false;
    state = resolved;
    return true;
  }

  /// Met à jour le marché auto depuis une position GPS (ex. après autorisation).
  /// Ignoré si le client a déjà un pays d’adresse en profil.
  Future<bool> applyDetectedCoordinates({
    required double latitude,
    required double longitude,
    required MarketDetectionService detection,
  }) async {
    final profileCountry = ref.read(currentClientProfileProvider).maybeWhen(
          data: (profile) => profile?.pays?.trim(),
          orElse: () => null,
        );
    if (profileCountry != null && profileCountry.isNotEmpty) return false;

    final iso = await detection.countryFromCoordinates(
      latitude: latitude,
      longitude: longitude,
    );
    if (iso == null) return false;

    final normalized = MarketConfig.normalizeCountryCode(iso);
    final cache = LocalCacheService.instance;
    final previous = cache.marketCountryAutoCode?.trim();
    if (previous == normalized && state == normalized) return false;

    await cache.setMarketCountryAutoCode(normalized);
    await cache.setMarketCountryAutoDetected(true);

    final resolved = _resolveCurrent();
    if (resolved == state) return false;
    state = resolved;
    return true;
  }

  /// Choix manuel (sans adresse enregistrée — voir [MarketCountryResolver]).
  Future<void> setMarketCountry(String isoCode) async {
    final profileCountry = ref.read(currentClientProfileProvider).maybeWhen(
          data: (profile) => profile?.pays?.trim(),
          orElse: () => null,
        );
    if (profileCountry != null && profileCountry.isNotEmpty) return;

    final normalized = MarketConfig.normalizeCountryCode(isoCode);
    if (!MarketConfig.isSupported(normalized)) return;

    final cache = LocalCacheService.instance;
    await cache.setMarketCountryManualCode(normalized);
    await cache.setMarketCountryManual(true);

    final resolved = _resolveCurrent();
    if (resolved == state) return;
    state = resolved;
  }

  /// Efface le choix manuel et relance la résolution auto → profil.
  Future<void> resetToProfileCountry() async {
    final cache = LocalCacheService.instance;
    await cache.setMarketCountryManual(false);
    await cache.remove(LocalCacheService.marketCountryManualCodeKey);
    state = _resolveCurrent();
  }

  /// Applique le pays enregistré dans l’adresse client comme marché catalogue.
  Future<void> applySavedClientAddressCountry(String? countryRaw) async {
    final iso = postalCountryIso2(countryRaw);
    if (!MarketConfig.isSupported(iso)) return;

    final normalized = MarketConfig.normalizeCountryCode(iso);
    final cache = LocalCacheService.instance;
    await cache.setMarketCountryAutoCode(normalized);
    await cache.setMarketCountryAutoDetected(true);
    await cache.setMarketCountryManualCode(normalized);
    await cache.setMarketCountryManual(true);

    if (state != normalized) state = normalized;
  }

  String _resolveCurrent() {
    final cache = LocalCacheService.instance;
    final profile = ref.read(currentClientProfileProvider).maybeWhen(
          data: (value) => value?.pays,
          orElse: () => null,
        );
    return MarketCountryResolver.resolve(
      cache: cache,
      profileCountryCode: profile,
    );
  }
}
