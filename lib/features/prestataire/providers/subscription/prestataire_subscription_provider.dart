import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../services/supabase/supabase_service.dart';
import '../profile/prestataire_profile_form_provider.dart';

/// Services beauté publiés du prestataire connecté (pour le palier d’abonnement).
final prestatairePublishedServiceCountProvider = FutureProvider<int>((ref) async {
  final data = await ref.watch(prestataireProfileFormProvider.future);
  final prestaId = data.prestataireId;
  if (prestaId == null || prestaId.isEmpty) {
    return data.services.length;
  }

  final response = await SupabaseService.client
      .from('services_beaute')
      .select('id')
      .eq('prestataire_id', prestaId)
      .eq('is_actif', true);

  final rows = response as List;
  if (rows.isNotEmpty) return rows.length;
  return data.services.length;
});
