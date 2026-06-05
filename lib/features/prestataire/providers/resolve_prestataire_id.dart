import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/prestataire/catalog/prestataire_catalog_providers.dart';
import '../../auth/providers/auth_notifier.dart';
import 'current_prestataire_provider.dart';
import 'prestataire_profile_form_provider.dart';

/// ID prestataire pour horaires / congés — évite les échecs silencieux si
/// [currentPrestataireProvider] n'est pas encore synchronisé après sauvegarde profil.
Future<String?> resolveConnectedPrestataireId(ProviderContainer container) async {
  var presta = await container.read(currentPrestataireProvider.future);
  if (presta != null) return presta.id;

  container.invalidate(currentPrestataireProvider);
  presta = await container.read(currentPrestataireProvider.future);
  if (presta != null) return presta.id;

  final form = await container.read(prestataireProfileFormProvider.future);
  final formId = form.prestataireId?.trim();
  if (formId != null && formId.isNotEmpty) return formId;

  final user = await container.read(authNotifierProvider.future);
  if (user == null) return null;

  final catalog = container.read(prestataireServiceProvider);
  if (catalog == null) return null;

  final id = await catalog.ensureProfileForUser(user.id);
  container.invalidate(currentPrestataireProvider);
  return id;
}
