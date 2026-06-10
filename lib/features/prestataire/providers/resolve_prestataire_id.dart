import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/prestataire/catalog/prestataire_catalog_providers.dart';
import '../../auth/providers/auth_notifier.dart';
import 'profile/current_prestataire_provider.dart';
import 'profile/prestataire_profile_form_provider.dart';

/// ID prestataire pour horaires / congés — crée un profil minimal si besoin
/// (onboarding hub avant la première sauvegarde complète).
Future<String?> resolveConnectedPrestataireId(ProviderContainer container) async {
  final user = await container.read(authNotifierProvider.future);
  if (user == null) return null;

  final catalog = container.read(prestataireServiceProvider);
  if (catalog == null) return null;

  try {
    final existing = await catalog.getByUserId(user.id);
    if (existing != null) return existing.id;

    final formService = container.read(prestataireProfileFormServiceProvider);
    final id = formService != null
        ? await formService.ensureProfileForBilling()
        : await catalog.ensureProfileForUser(user.id);

    container.invalidate(currentPrestataireProvider);
    container.invalidate(prestataireProfileFormProvider);
    return id;
  } catch (_) {
    return null;
  }
}
