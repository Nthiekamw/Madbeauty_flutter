import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../services/supabase/prestataire/photos/photo_realisation_providers.dart';

final realisationPhotosProvider = FutureProvider.autoDispose
    .family<List<PhotoRealisation>, String>((ref, prestataireId) async {
      final service = ref.watch(photoRealisationServiceProvider);
      if (service == null) return const [];
      return service.getByPrestataire(prestataireId);
    });

