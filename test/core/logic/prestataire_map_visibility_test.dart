import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/logic/prestataire/prestataire_map_visibility.dart';
import 'package:madbeauty/core/models/domain/catalog/prestataire_catalog_entry.dart';
import 'package:madbeauty/core/models/domain/user/lieu_travail.dart';
import 'package:madbeauty/core/models/domain/user/prestataire_profile.dart';

void main() {
  test('filterMapCatalogEntries garde uniquement les profils géolocalisés', () {
    final withGeo = PrestataireCatalogEntry(
      profile: PrestataireProfile(
        id: 'a',
        userId: 'u1',
        nomSalon: 'Salon A',
        latitude: 48.85,
        longitude: 2.35,
        createdAt: DateTime.utc(2026),
      ),
      specialtyNames: const ['Coiffure'],
    );
    final withoutGeo = PrestataireCatalogEntry(
      profile: PrestataireProfile(
        id: 'b',
        userId: 'u2',
        nomSalon: 'Salon B',
        lieuTravail: LieuTravail.both,
        createdAt: DateTime.utc(2026),
      ),
      specialtyNames: const ['Coiffure'],
    );

    final filtered = filterMapCatalogEntries([withGeo, withoutGeo]);

    expect(filtered, [withGeo]);
  });
}
