import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/catalog/service_beaute.dart';
import '../../../services/supabase/prestataire/services/service_beaute_providers.dart';

final servicesProvider = FutureProvider.autoDispose
    .family<List<ServiceBeaute>, String>((ref, prestataireId) async {
      final service = ref.watch(serviceBeauteServiceProvider);
      if (service == null) return const [];
      return service.getByPrestataire(prestataireId);
    });

