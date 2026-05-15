import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/user/prestataire_profile.dart';
import '../../../services/supabase/prestataire/catalog/prestataire_catalog_providers.dart';
import '../../auth/providers/auth_notifier.dart';

final currentPrestataireProvider =
    FutureProvider.autoDispose<PrestataireProfile?>((ref) async {
      final user = await ref.watch(authNotifierProvider.future);
      if (user == null) return null;

      final service = ref.watch(prestataireServiceProvider);
      if (service == null) return null;

      return service.getByUserId(user.id);
    });

/// Alias conservé avec l’orthographe demandée côté fonctionnalité.
final currentPrestatiaireProvider = currentPrestataireProvider;
