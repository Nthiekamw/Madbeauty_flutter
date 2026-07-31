import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/config/salon_vip_config.dart';
import '../supabase_service.dart';
import 'client_prestataire_relation_service.dart';

final clientPrestataireRelationServiceProvider =
    Provider<ClientPrestataireRelationService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return ClientPrestataireRelationService(SupabaseService.client);
});

/// VIP du client connecté chez ce salon (checkout / fiche).
final isCurrentClientVipAtPrestataireProvider =
    FutureProvider.autoDispose.family<bool, String>((ref, prestataireId) async {
  final service = ref.watch(clientPrestataireRelationServiceProvider);
  if (service == null || prestataireId.trim().isEmpty) return false;
  return service.isCurrentClientVipAtPrestataire(prestataireId);
});

/// VIP d’une cliente chez le salon courant (vue presta).
final isClientVipForPairProvider = FutureProvider.autoDispose
    .family<bool, ({String clientId, String prestataireId})>((ref, pair) async {
  final service = ref.watch(clientPrestataireRelationServiceProvider);
  if (service == null) return false;
  if (pair.clientId.isEmpty || pair.prestataireId.isEmpty) return false;
  return service.isClientVipAtPrestataire(
    clientId: pair.clientId,
    prestataireId: pair.prestataireId,
  );
});

/// Pourcentage VIP à appliquer au checkout, ou null.
final clientVipDiscountPercentProvider =
    Provider.autoDispose.family<int?, String>((ref, prestataireId) {
  final isVip = ref.watch(isCurrentClientVipAtPrestataireProvider(prestataireId));
  return isVip.maybeWhen(
    data: (vip) => vip ? SalonVipConfig.discountPercent : null,
    orElse: () => null,
  );
});
