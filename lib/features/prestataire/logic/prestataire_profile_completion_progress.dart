import 'package:flutter/material.dart';

import '../../../services/supabase/prestataire/profile_form/prestataire_profile_form_service.dart';
import 'prestataire_profile_completeness.dart';

/// Progression 0–100 du profil (catalogue + enrichissements).
int prestataireProfileCompletionPercent(
  PrestataireProfileFormData data, {
  required bool hasHoraires,
}) {
  const steps = 8;
  var done = 0;
  if (data.hasMinimalPrestaIdentity && data.hasDisplayName) done++;
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

/// Puces d’action affichées sur la carte de complétion.
class PrestataireCompletionChipAction {
  const PrestataireCompletionChipAction({
    required this.label,
    required this.onTap,
    this.required = true,
  });

  final String label;
  final VoidCallback onTap;
  final bool required;
}

List<PrestataireCompletionChipAction> prestataireCompletionChipActions({
  required PrestataireProfileFormData data,
  required bool hasHoraires,
  required void Function(PrestaCompletionChecklistItem item) onChecklist,
  required void Function(PrestaProfileEnhancementItem item) onEnhancement,
  required VoidCallback onPayments,
}) {
  final chips = <PrestataireCompletionChipAction>[];

  for (final item in data.missingChecklistItems) {
    chips.add(
      PrestataireCompletionChipAction(
        label: '+ ${item.label}',
        onTap: () => onChecklist(item),
        required: true,
      ),
    );
  }
  for (final item in data.missingEnhancements(hasHoraires: hasHoraires)) {
    chips.add(
      PrestataireCompletionChipAction(
        label: '+ ${item.label}',
        onTap: () => onEnhancement(item),
        required: false,
      ),
    );
  }
  if (data.isProfessionallyComplete) {
    chips.add(
      PrestataireCompletionChipAction(
        label: '+ Paiements en ligne',
        onTap: onPayments,
        required: false,
      ),
    );
  }
  return chips;
}
