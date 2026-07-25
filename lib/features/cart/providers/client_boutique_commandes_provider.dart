import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/catalog/boutique_commande.dart';
import '../../../services/supabase/prestataire/boutique/boutique_providers.dart';

/// Historique des commandes boutique du client connecté.
final clientBoutiqueCommandesProvider =
    FutureProvider.autoDispose<List<BoutiqueCommande>>((ref) async {
  final service = ref.watch(boutiqueCommandeServiceProvider);
  if (service == null) return const [];
  return service.listForCurrentClient();
});
