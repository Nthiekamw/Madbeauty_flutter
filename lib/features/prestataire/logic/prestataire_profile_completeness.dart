import '../../../services/supabase/prestataire/profile_form/prestataire_profile_form_service.dart';

/// Critères alignés sur [PrestataireHubScreen] (profil visible / réservable).
extension PrestataireProfileCompleteness on PrestataireProfileFormData {
  bool get hasMinimalPrestaIdentity =>
      nomSalon.trim().isNotEmpty && ville.trim().isNotEmpty;

  bool get isProfessionallyComplete {
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;
    return hasMinimalPrestaIdentity &&
        bio.trim().isNotEmpty &&
        hasAvatar &&
        selectedCategoryIds.isNotEmpty &&
        services.isNotEmpty;
  }
}
