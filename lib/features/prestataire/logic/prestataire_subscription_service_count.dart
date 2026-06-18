import '../../../services/supabase/prestataire/profile_form/prestataire_profile_form_service.dart';
import '../../profile/storage/become_prestataire_draft_store.dart';
import '../models/prestataire_service_catalog_selection.dart';
import '../models/prestataire_service_field_set.dart';

/// Calcule le nombre de services pour le palier d'abonnement (solo / multi).
abstract final class PrestataireSubscriptionServiceCount {
  PrestataireSubscriptionServiceCount._();

  static int fromHubForm({
    required PrestataireServiceCatalogSelection catalogSelection,
    required List<PrestataireServiceFieldSet> serviceFields,
  }) {
    if (catalogSelection.isValid) {
      return catalogSelection.specialtyCount;
    }
    return serviceFields
        .where((service) => service.nomController.text.trim().isNotEmpty)
        .length;
  }

  static int fromHubDraft() {
    final hub = BecomePrestataireDraftStore.instance.read()?.hub;
    if (hub == null) return 0;
    return hub.services.where((service) => service.nom.trim().isNotEmpty).length;
  }

  static int fromProfileData(PrestataireProfileFormData data) {
    var count = data.services.length;

    final catalog = PrestataireServiceCatalogSelection.fromProfileData(
      selectedCategoryIds: data.selectedCategoryIds,
      services: data.services,
      legacySuggestionLabels: data.customSpecialtyLabels,
    );
    if (catalog.isValid) {
      count = _max(count, catalog.specialtyCount);
    }

    count = _max(count, fromHubDraft());
    return count;
  }

  static int resolve({
    required int publishedCount,
    int? plannedCount,
  }) {
    return _max(publishedCount, plannedCount ?? 0);
  }

  static int _max(int a, int b) => a > b ? a : b;
}
