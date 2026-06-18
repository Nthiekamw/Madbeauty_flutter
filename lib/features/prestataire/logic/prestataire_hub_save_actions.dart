import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/disponibilite/disponibilite_service_providers.dart';
import '../../../services/supabase/prestataire/photos/photo_realisation_providers.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../profile/logic/prestataire_hub_onboarding_draft.dart';
import '../logic/prestataire_profile_completeness.dart';
import '../models/prestataire_profile_edit_section.dart';
import '../models/weekly_jour_horaire.dart';
import '../providers/profile/current_prestataire_provider.dart';
import '../providers/agenda/disponibilite_provider.dart';
import '../providers/hub/prestataire_hub_form_controller.dart';
import '../models/pending_realisation_upload.dart';
import '../providers/profile/prestataire_profile_form_provider.dart';
import '../providers/resolve_prestataire_id.dart';
import '../widgets/dialogs/prestataire_onboarding_finish_dialog.dart';

typedef PrestataireHubSnack = void Function(
  String message, {
  AppSnackKind kind,
});

/// Sauvegarde profil, horaires et galerie (async hors écran).
class PrestataireHubSaveActions {
  PrestataireHubSaveActions({
    required this.ref,
    required this.form,
    required this.focusedSection,
    required this.mounted,
    required this.showSnack,
    required this.context,
  });

  final WidgetRef ref;
  final PrestataireHubFormController form;
  final PrestataireProfileEditSection? focusedSection;
  final bool Function() mounted;
  final PrestataireHubSnack showSnack;
  final BuildContext context;

  Future<void> prepareSavePayload() async {
    FocusScope.of(context).unfocus();
    await form.persistHubDraftOnExit();
    form.syncServicesFromCatalog();
  }

  Future<bool> saveHorairesIfNeeded() async {
    final jours = form.horaireWeek;
    if (jours == null) return true;

    if (jours.hasAnyOpenDay && !jours.validatePlages()) {
      form.setHorairesError(DiscPrestaHoraires.invalidPlage);
      if (mounted()) {
        showSnack(DiscPrestaHoraires.invalidPlage, kind: AppSnackKind.error);
      }
      return false;
    }

    final service = ref.read(disponibiliteServiceProvider);
    final prestaId = await resolveConnectedPrestataireId(ref.container);
    if (service == null || prestaId == null) {
      form.setHorairesError(DiscPrestaHoraires.congesProfileErr);
      if (mounted()) {
        showSnack(DiscPrestaHoraires.congesProfileErr, kind: AppSnackKind.error);
      }
      return false;
    }

    await service.setHoraires(prestaId, jours.toPlages());
    invalidateDisponibiliteProviders(ref);
    if (mounted() && focusedSection == PrestataireProfileEditSection.horaires) {
      showSnack(DiscPrestaHoraires.saveOk, kind: AppSnackKind.success);
    }
    return true;
  }

  Future<bool> uploadPendingGalleryIfNeeded() async {
    if (form.pendingGallery.isEmpty) return true;

    final batch = List<PendingRealisationUpload>.from(form.pendingGallery);
    final updated = await ref.read(prestataireProfileFormProvider.future);
    var prestataireId = updated.prestataireId;
    prestataireId ??= await resolveConnectedPrestataireId(ref.container);
    final photoService = ref.read(photoRealisationServiceProvider);
    if (prestataireId == null || photoService == null) {
      return false;
    }

    for (final upload in batch) {
      if (!form.pendingGallery.contains(upload)) continue;
      try {
        final categorieId = upload.categorieId.trim();
        final caption = upload.specialtyLabel.trim();
        final photo = await photoService.uploadAndCreate(
          prestataireId: prestataireId,
          file: upload.file,
          categorieId: categorieId.isEmpty ? null : categorieId,
          caption: caption.isEmpty ? null : caption,
        );
        form.removePendingGallery(upload);
        form.addGalleryPhoto(photo);
      } on AppFailure catch (e) {
        if (mounted()) {
          showSnack(e.message, kind: AppSnackKind.error);
        }
        return false;
      }
    }
    ref.invalidate(prestataireProfileFormProvider);
    return true;
  }

  Future<void> maybeShowFinishSummary(PrestataireProfileFormData data) async {
    if (focusedSection != null) return;

    final horaires = await ref.read(prestataireHorairesProvider.future);
    final hasHoraires = horaires.isNotEmpty;
    final requiredMissing =
        data.missingChecklistItems.map((item) => item.label).toList();
    final optionalMissing = data
        .missingEnhancements(hasHoraires: hasHoraires)
        .map((item) => item.label)
        .toList();

    if (data.isProfileFullyEnriched(hasHoraires: hasHoraires) &&
        requiredMissing.isEmpty) {
      return;
    }

    if (!mounted()) return;
    await showPrestataireOnboardingFinishDialog(
      context: context,
      professionallyComplete: data.isProfessionallyComplete,
      requiredMissing: requiredMissing,
      optionalMissing: optionalMissing,
      onCompleteProfile: () {
        if (context.canPop()) {
          context.pop();
        }
        context.goPrestataireProfile();
      },
    );
  }

  Future<void> completeLater() async {
    await prepareSavePayload();

    final failed = form.firstMandatoryStepFailure();
    final service = ref.read(prestataireProfileFormServiceProvider);

    var profileSaved = false;
    if (failed == null && service != null) {
      form.setSaving(true);
      try {
        await service.save(form.buildSavePayload());
        ref.invalidate(currentPrestataireProvider);
        final horairesOk = await saveHorairesIfNeeded();
        if (!horairesOk && mounted()) {
          showSnack(DiscPrestaHoraires.saveErr, kind: AppSnackKind.warning);
        } else {
          profileSaved = await uploadPendingGalleryIfNeeded();
        }
      } on AppFailure catch (e) {
        if (mounted()) {
          showSnack(e.message, kind: AppSnackKind.error);
        }
      } catch (_) {
        if (mounted()) {
          showSnack(DiscPrestaForm.saveErr, kind: AppSnackKind.error);
        }
      } finally {
        if (mounted()) form.setSaving(false);
      }
    }

    if (!mounted()) return;
    if (profileSaved) {
      if (PrestataireHubOnboardingDraft.isActive) {
        await PrestataireHubOnboardingDraft.clearAfterProfileComplete();
      }
      showSnack(DiscPrestaForm.completeLaterSaved, kind: AppSnackKind.success);
    } else if (failed != null) {
      form.setCurrentStep(failed);
      showSnack(
        DiscPrestaForm.completeLaterNeedsCore,
        kind: AppSnackKind.warning,
      );
      return;
    }
    context.goPrestataireDashboard();
  }

  Future<void> save() async {
    await prepareSavePayload();

    final wizard = focusedSection == null;
    if (wizard) {
      final failed = form.firstMandatoryStepFailure();
      if (failed != null) {
        form.setCurrentStep(failed);
        showSnack(
          DiscPrestaForm.completeLaterNeedsCore,
          kind: AppSnackKind.warning,
        );
        return;
      }
    } else if (!form.validateCurrentStep()) {
      return;
    }

    final service = ref.read(prestataireProfileFormServiceProvider);
    if (service == null) {
      showSnack(DiscPrestaForm.missingSupabase, kind: AppSnackKind.warning);
      return;
    }

    form.setSaving(true);
    form.setUploadProgress(form.avatarBytes == null ? null : 0);
    try {
      await service.save(
        form.buildSavePayload(),
        onAvatarUploadProgress: (progress) {
          if (!mounted()) return;
          form.setUploadProgress(progress);
        },
      );

      ref.invalidate(currentPrestataireProvider);

      if (form.shouldPersistHoraires) {
        final horairesOk = await saveHorairesIfNeeded();
        if (!horairesOk) {
          if (!mounted()) return;
          form.setSaving(false);
          form.setUploadProgress(null);
          if (focusedSection == null) {
            form.setCurrentStep(3);
          }
          return;
        }
      }

      var updated = await ref.refresh(prestataireProfileFormProvider.future);
      await uploadPendingGalleryIfNeeded();
      updated = await ref.read(prestataireProfileFormProvider.future);
      if (!mounted()) return;
      form.setSaving(false);
      form.setUploadProgress(null);
      form.hydrate(updated, force: true);
      showSnack(DiscPrestaForm.savedToast, kind: AppSnackKind.success);
      if (PrestataireHubOnboardingDraft.isActive && wizard) {
        await PrestataireHubOnboardingDraft.clearAfterProfileComplete();
      }
      await maybeShowFinishSummary(updated);
      if (mounted()) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.goPrestataireDashboard();
        }
      }
    } on AppFailure catch (e) {
      if (!mounted()) return;
      form.setSaving(false);
      form.setUploadProgress(null);
      showSnack(e.message, kind: AppSnackKind.error);
    } catch (_) {
      if (!mounted()) return;
      form.setSaving(false);
      form.setUploadProgress(null);
      showSnack(DiscPrestaForm.saveErr, kind: AppSnackKind.error);
    }
  }
}
