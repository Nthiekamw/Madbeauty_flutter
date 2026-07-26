import 'package:flutter/material.dart';

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

  bool get servicesAreValid {
    final fromSelection = selectedCategoryIds
        .map((id) => id.trim())
        .where((id) => id.isNotEmpty)
        .toSet();
    final fromServices = services
        .map((s) => s.categorieId?.trim() ?? '')
        .where((id) => id.isNotEmpty)
        .toSet();
    final categoriesOk =
        fromSelection.isNotEmpty || fromServices.isNotEmpty;
    return categoriesOk &&
        services.isNotEmpty &&
        services.every(
          (s) =>
              s.nom.trim().isNotEmpty &&
              s.categorieId != null &&
              s.categorieId!.trim().isNotEmpty &&
              s.prix >= 1 &&
              s.dureeMinutes > 0,
        );
  }

  bool get hasAvatar =>
      avatarUrl != null && avatarUrl!.trim().isNotEmpty;

  /// Suffisant pour ouvrir le dashboard (carte de complétion si détails manquent).
  bool get isOperationalForDashboard =>
      hasMinimalPrestaIdentity && hasSalonAddress && servicesAreValid;

  bool get isProfessionallyComplete {
    return isOperationalForDashboard &&
        hasPostalCode &&
        hasWorkLocation &&
        description.trim().isNotEmpty &&
        hasAvatar;
  }

  List<PrestaCompletionChecklistItem> get missingChecklistItems {
    final items = <PrestaCompletionChecklistItem>[];
    if (!hasMinimalPrestaIdentity ||
        !hasSalonAddress ||
        !hasPostalCode ||
        !hasWorkLocation ||
        description.trim().isEmpty ||
        !hasAvatar) {
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

/// Progression 0—100 du profil (catalogue + enrichissements).
int prestataireProfileCompletionPercent(
  PrestataireProfileFormData data, {
  required bool hasHoraires,
}) {
  const steps = 8;
  var done = 0;
  if (data.hasMinimalPrestaIdentity) done++;
  if (data.hasSalonAddress && data.hasPostalCode && data.hasWorkLocation) {
    done++;
  }
  if (data.description.trim().isNotEmpty) done++;
  if (data.avatarUrl != null && data.avatarUrl!.trim().isNotEmpty) done++;
  if (data.servicesAreValid) done++;
  if (data.hasRealisationGallery) done++;
  if (hasHoraires) done++;
  if (data.hasClientExperienceConfigured) done++;
  return ((done / steps) * 100).round().clamp(0, 100);
}

/// Puces d'action affichées sur la carte de progression profil.
class PrestataireProfileProgressChipAction {
  const PrestataireProfileProgressChipAction({
    required this.label,
    required this.onTap,
    this.required = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool required;
}

List<PrestataireProfileProgressChipAction> prestataireProfileProgressChipActions({
  required PrestataireProfileFormData data,
  required bool hasHoraires,
  required void Function(PrestaCompletionChecklistItem item) onChecklist,
  required void Function(PrestaProfileEnhancementItem item) onEnhancement,
}) {
  final chips = <PrestataireProfileProgressChipAction>[];

  for (final item in data.missingChecklistItems) {
    chips.add(
      PrestataireProfileProgressChipAction(
        label: '+ ${item.label}',
        onTap: () => onChecklist(item),
        required: true,
      ),
    );
  }
  for (final item in data.missingEnhancements(hasHoraires: hasHoraires)) {
    chips.add(
      PrestataireProfileProgressChipAction(
        label: '+ ${item.label}',
        onTap: () => onEnhancement(item),
        required: false,
      ),
    );
  }
  return chips;
}

