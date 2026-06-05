import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/geo/geo_point.dart';
import '../../../core/models/domain/catalog/prestataire_catalog_entry.dart';
import '../../listing/providers/catalog_availability_index_provider.dart';
import '../../listing/providers/discovery_origin_provider.dart';
import '../../listing/providers/listing_catalog_provider.dart';
import '../models/prestataires_filter_state.dart';
import 'prestataire_filters_provider.dart';

final prestatairesListProvider =
    Provider<AsyncValue<List<PrestataireCatalogEntry>>>((ref) {
      final state = ref.watch(listingCatalogNotifierProvider);

      if (state.loadingInitial && state.entries.isEmpty) {
        return const AsyncLoading();
      }

      if (state.errorMessage != null && state.entries.isEmpty) {
        return AsyncError(
          state.errorMessage ?? DiscList.catalogLoadErr,
          StackTrace.current,
        );
      }

      return AsyncData(state.entries);
    });

final prestatairesFilteredProvider =
    Provider<AsyncValue<List<PrestataireCatalogEntry>>>((ref) {
      final asyncList = ref.watch(prestatairesListProvider);
      final filters = ref.watch(prestatairesFilterProvider);
      final origin = ref.watch(discoveryOriginProvider);
      final availability = ref.watch(catalogAvailabilityIndexProvider);
      return asyncList.whenData((entries) {
        var list = filterPrestataireEntries(entries, filters, origin: origin);
        if (filters.availableOnly) {
          final map = availability.value;
          if (map != null) {
            list = list.where((e) => map[e.profile.id] == true).toList();
          }
        }
        return list;
      });
    });

List<PrestataireCatalogEntry> filterPrestataireEntries(
  List<PrestataireCatalogEntry> entries,
  PrestatairesFilterState filters, {
  required GeoPoint origin,
}) {
  final list = entries
      .where((e) => e.matchesSearch(filters.query))
      .where((e) => e.matchesCategoryFilter(filters.categoryId))
      .toList();

  switch (filters.sort) {
    case PrestatairesSort.rating:
      list.sort(_compareByRating);
    case PrestatairesSort.distance:
      list.sort((a, b) => _compareByDistance(a, b, origin));
  }

  return list;
}

int _compareByRating(PrestataireCatalogEntry a, PrestataireCatalogEntry b) {
  final na = a.profile.noteMoyenne;
  final nb = b.profile.noteMoyenne;
  if (na != null && nb != null && na != nb) return nb.compareTo(na);
  if (na != null && nb == null) return -1;
  if (na == null && nb != null) return 1;
  return b.profile.createdAt.compareTo(a.profile.createdAt);
}

int _compareByDistance(
  PrestataireCatalogEntry a,
  PrestataireCatalogEntry b,
  GeoPoint origin,
) {
  final da = a.distanceKmFrom(origin);
  final db = b.distanceKmFrom(origin);
  final aInf = da.isInfinite;
  final bInf = db.isInfinite;
  if (aInf && bInf) return 0;
  if (aInf) return 1;
  if (bInf) return -1;
  return da.compareTo(db);
}

