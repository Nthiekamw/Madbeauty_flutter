import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../prestataire/providers/catalog/prestataires_provider.dart';

/// Villes distinctes présentes dans le catalogue chargé (tri alphabétique).
final catalogCitiesProvider = Provider<List<String>>((ref) {
  final async = ref.watch(prestatairesListProvider);
  return async.maybeWhen(
    data: (entries) {
      final villes = <String>{};
      for (final entry in entries) {
        final v = entry.profile.ville?.trim();
        if (v != null && v.isNotEmpty) villes.add(v);
      }
      final sorted = villes.toList()
        ..sort((a, b) => a.toLowerCase().compareTo(b.toLowerCase()));
      return sorted;
    },
    orElse: () => const [],
  );
});
