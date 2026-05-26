import '../../../services/supabase/prestataire/profile_form/prestataire_profile_form_service.dart';

/// Critères alignés spec onboarding prestataire.
extension PrestataireProfileCompleteness on PrestataireProfileFormData {
  bool get hasMinimalPrestaIdentity =>
      nomSalon.trim().isNotEmpty && ville.trim().isNotEmpty;

  bool get hasDisplayName => nomAffiche.trim().isNotEmpty;

  bool get hasSalonAddress => adresse.trim().isNotEmpty;

  bool get hasPostalCode => codePostal.trim().isNotEmpty;

  bool get hasWorkLocation => lieuTravail != null;

  bool get hasRealisationGallery => realisationPhotos.isNotEmpty;

  bool get servicesAreValid =>
      services.isNotEmpty &&
      services.every(
        (s) =>
            s.nom.trim().isNotEmpty &&
            s.categorieId != null &&
            s.categorieId!.trim().isNotEmpty,
      );

  bool get isProfessionallyComplete {
    final hasAvatar = avatarUrl != null && avatarUrl!.trim().isNotEmpty;
    return hasMinimalPrestaIdentity &&
        hasDisplayName &&
        hasSalonAddress &&
        hasPostalCode &&
        hasWorkLocation &&
        description.trim().isNotEmpty &&
        hasAvatar &&
        servicesAreValid;
  }

  List<PrestaCompletionChecklistItem> get missingChecklistItems {
    final items = <PrestaCompletionChecklistItem>[];
    if (!hasMinimalPrestaIdentity ||
        !hasDisplayName ||
        !hasSalonAddress ||
        !hasPostalCode ||
        !hasWorkLocation ||
        description.trim().isEmpty) {
      items.add(PrestaCompletionChecklistItem.basics);
    }
    if (!servicesAreValid) {
      items.add(PrestaCompletionChecklistItem.services);
    }
    return items;
  }

  bool get hasClientExperienceConfigured =>
      confortClient.isNotEmpty || conditionsService.isNotEmpty;

  /// Enrichissements optionnels (hors catalogue minimal).
  List<PrestaProfileEnhancementItem> missingEnhancements({
    required bool hasHoraires,
  }) {
    final items = <PrestaProfileEnhancementItem>[];
    if (!hasClientExperienceConfigured) {
      items.add(PrestaProfileEnhancementItem.clientExperience);
    }
    if (!hasRealisationGallery) {
      items.add(PrestaProfileEnhancementItem.gallery);
    }
    if (!hasHoraires) {
      items.add(PrestaProfileEnhancementItem.horaires);
    }
    return items;
  }

  bool isProfileFullyEnriched({required bool hasHoraires}) =>
      isProfessionallyComplete &&
      missingEnhancements(hasHoraires: hasHoraires).isEmpty;
}

enum PrestaCompletionChecklistItem {
  basics,
  services,
  gallery,
}

enum PrestaProfileEnhancementItem {
  clientExperience,
  gallery,
  horaires,
}

extension PrestaCompletionChecklistLabels on PrestaCompletionChecklistItem {
  String get label => switch (this) {
    PrestaCompletionChecklistItem.basics => 'Vitrine, adresse & lieu',
    PrestaCompletionChecklistItem.services => 'Services & tarifs',
    PrestaCompletionChecklistItem.gallery => 'Réalisations',
  };
}

extension PrestaProfileEnhancementLabels on PrestaProfileEnhancementItem {
  String get label => switch (this) {
    PrestaProfileEnhancementItem.clientExperience =>
      'Confort client & conditions',
    PrestaProfileEnhancementItem.gallery => 'Photos de réalisations',
    PrestaProfileEnhancementItem.horaires => 'Horaires de disponibilité',
  };
}
