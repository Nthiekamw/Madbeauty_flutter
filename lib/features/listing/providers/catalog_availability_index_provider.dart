import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../prestataire/providers/prestataire_open_slots_provider.dart';
import '../../prestataire/providers/prestataires_provider.dart';

/// Disponibilité des prestataires du catalogue chargé (pour filtre « Dispo »).
final catalogAvailabilityIndexProvider =
    FutureProvider.autoDispose<Map<String, bool>>((ref) async {
      final entries = ref.watch(prestatairesListProvider).value ?? const [];
      if (entries.isEmpty) return const {};

      final results = await Future.wait(
        entries.map((entry) async {
          final id = entry.profile.id;
          final open = await ref.watch(prestataireHasOpenSlotsProvider(id).future);
          return MapEntry(id, open);
        }),
      );

      return Map<String, bool>.fromEntries(results);
    });
