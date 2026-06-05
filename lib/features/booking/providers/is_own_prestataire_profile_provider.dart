import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../prestataire/providers/current_prestataire_provider.dart';

/// `true` si [prestataireId] correspond au profil pro de l'utilisateur connecté.
final isOwnPrestataireProfileProvider = FutureProvider.autoDispose
    .family<bool, String>((ref, prestataireId) async {
      final id = prestataireId.trim();
      if (id.isEmpty) return false;

      final own = await ref.watch(currentPrestataireProvider.future);
      if (own == null) return false;
      return own.id == id;
    });

