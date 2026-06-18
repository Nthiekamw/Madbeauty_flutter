import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/supabase/supabase_service.dart';
import '../../logic/prestataire_subscription_service_count.dart';
import '../profile/prestataire_profile_form_provider.dart';

/// Nombre de services prévu dans le wizard hub (étape abonnement).
final prestataireSubscriptionPlannedServiceCountProvider =
    NotifierProvider<PrestataireSubscriptionPlannedServiceCountNotifier, int?>(
  PrestataireSubscriptionPlannedServiceCountNotifier.new,
);

class PrestataireSubscriptionPlannedServiceCountNotifier extends Notifier<int?> {
  @override
  int? build() => null;

  void setPlannedCount(int? count) => state = count;

  void clear() => state = null;
}

/// Services du prestataire pour le palier d'abonnement (publiés + brouillon hub).
final prestatairePublishedServiceCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
  final data = await ref.watch(prestataireProfileFormProvider.future);
  final planned = ref.watch(prestataireSubscriptionPlannedServiceCountProvider);

  var count = PrestataireSubscriptionServiceCount.fromProfileData(data);

  final prestaId = data.prestataireId;
  if (prestaId != null && prestaId.isNotEmpty) {
    final response = await SupabaseService.client
        .from('services_beaute')
        .select('id')
        .eq('prestataire_id', prestaId)
        .eq('is_actif', true);

    final dbCount = (response as List).length;
    if (dbCount > count) count = dbCount;
  }

  return PrestataireSubscriptionServiceCount.resolve(
    publishedCount: count,
    plannedCount: planned,
  );
});
