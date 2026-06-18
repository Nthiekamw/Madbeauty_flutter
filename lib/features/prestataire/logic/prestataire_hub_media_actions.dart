import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../core/models/domain/catalog/realisation_media_type.dart';
import '../../../services/supabase/prestataire/photos/photo_realisation_providers.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../models/pending_realisation_upload.dart';
import '../providers/hub/prestataire_hub_form_controller.dart';
import '../providers/profile/prestataire_profile_form_provider.dart';
import '../providers/resolve_prestataire_id.dart';
import 'prestataire_hub_constants.dart';
import 'realisation_gallery_grouping.dart';

/// Sélection avatar / galerie et horaires (hors écran).
abstract final class PrestataireHubMediaActions {
  PrestataireHubMediaActions._();

  static Future<void> pickAvatar(
    BuildContext context,
    PrestataireHubFormController form,
  ) async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    final uploadFile = await StorageUploadFile.fromXFile(picked);
    try {
      StorageService.validateImageFile(uploadFile);
    } on AppFailure catch (e) {
      if (!context.mounted) return;
      form.setAvatarError(e.message);
      return;
    }
    if (!context.mounted) return;
    form.setAvatarFromUpload(
      bytes: uploadFile.bytes,
      fileName: uploadFile.fileName,
      mimeType: uploadFile.mimeType,
    );
  }

  static Future<void> pickGalleryForSlot(
    WidgetRef ref,
    BuildContext context,
    PrestataireHubFormController form,
    RealisationGallerySlot slot,
  ) async {
    final picked = await ImagePicker().pickMultiImage(
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked.isEmpty) return;
    for (final file in picked) {
      if (form.galleryMediaCount >= PrestataireHubConstants.galleryMaxPhotos) {
        break;
      }
      final uploadFile = await StorageUploadFile.fromXFile(file);
      try {
        StorageService.validateImageFile(uploadFile);
        if (!context.mounted) return;
        form.clearGalleryError();
        final pending = PendingRealisationUpload(
          file: uploadFile,
          categorieId: slot.categorieId,
          specialtyLabel: slot.specialtyLabel,
        );
        form.addPendingGalleryUpload(pending);
        await _persistGalleryUpload(ref, form, pending);
      } on AppFailure catch (e) {
        if (!context.mounted) return;
        form.setGalleryError(e.message);
      }
    }
  }

  static Future<void> pickGalleryVideoForSlot(
    WidgetRef ref,
    BuildContext context,
    PrestataireHubFormController form,
    RealisationGallerySlot slot,
  ) async {
    if (_galleryVideoCount(form) >= PrestataireHubConstants.galleryMaxVideos) {
      form.setGalleryError(
        'Tu peux ajouter au maximum ${PrestataireHubConstants.galleryMaxVideos} vidéos.',
      );
      return;
    }
    if (form.galleryMediaCount >= PrestataireHubConstants.galleryMaxPhotos) {
      form.setGalleryError(
        'Tu as atteint la limite de ${PrestataireHubConstants.galleryMaxPhotos} médias.',
      );
      return;
    }

    final picked = await ImagePicker().pickVideo(
      source: ImageSource.gallery,
      maxDuration: const Duration(minutes: 2),
    );
    if (picked == null) return;

    final uploadFile = await StorageUploadFile.fromXFile(picked);
    try {
      StorageService.validateVideoFile(uploadFile);
    } on AppFailure catch (e) {
      if (!context.mounted) return;
      form.setGalleryError(e.message);
      return;
    }
    if (!context.mounted) return;
    form.clearGalleryError();
    final pending = PendingRealisationUpload(
      file: uploadFile,
      categorieId: slot.categorieId,
      specialtyLabel: slot.specialtyLabel,
    );
    form.addPendingGalleryUpload(pending);
    await _persistGalleryUpload(ref, form, pending);
  }

  static Future<void> _persistGalleryUpload(
    WidgetRef ref,
    PrestataireHubFormController form,
    PendingRealisationUpload pending,
  ) async {
    if (!form.pendingGallery.contains(pending)) return;

    final prestataireId = form.loadedData?.prestataireId ??
        await resolveConnectedPrestataireId(ref.container);
    final photoService = ref.read(photoRealisationServiceProvider);
    if (prestataireId == null || photoService == null) return;

    try {
      final categorieId = pending.categorieId.trim();
      final caption = pending.specialtyLabel.trim();
      final photo = await photoService.uploadAndCreate(
        prestataireId: prestataireId,
        file: pending.file,
        categorieId: categorieId.isEmpty ? null : categorieId,
        caption: caption.isEmpty ? null : caption,
      );
      if (!form.pendingGallery.contains(pending)) return;
      form.removePendingGallery(pending);
      form.addGalleryPhoto(photo);
      ref.invalidate(prestataireProfileFormProvider);
    } on AppFailure catch (e) {
      form.setGalleryError(e.message);
    } catch (_) {
      // Garde le pending : nouvel essai à la fermeture ou au prochain save.
    }
  }

  /// Envoie les médias encore en attente (fermeture app / save différé).
  static Future<void> flushPendingGalleryUploads(
    WidgetRef ref,
    PrestataireHubFormController form,
  ) async {
    if (form.pendingGallery.isEmpty) return;
    final batch = List<PendingRealisationUpload>.from(form.pendingGallery);
    for (final pending in batch) {
      await _persistGalleryUpload(ref, form, pending);
    }
  }

  static int _galleryVideoCount(PrestataireHubFormController form) {
    final existing =
        form.galleryPhotos.where((p) => p.mediaType.isVideo).length;
    final pending = form.pendingGallery.where((f) => f.file.isVideo).length;
    return existing + pending;
  }

  static Future<void> removeGalleryPhoto(
    WidgetRef ref,
    BuildContext context,
    PrestataireHubFormController form,
    PhotoRealisation photo,
  ) async {
    final photoService = ref.read(photoRealisationServiceProvider);
    if (photoService == null) return;
    await photoService.delete(photo.id);
    if (!context.mounted) return;
    form.removeGalleryPhoto(photo);
  }

  static Future<void> pickHoraireTime(
    BuildContext context,
    PrestataireHubFormController form,
    int index,
    bool isStart,
  ) async {
    final jours = form.horaireWeek;
    if (jours == null) return;
    final jour = jours[index];
    final initial = isStart ? jour.debut : jour.fin;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null || !context.mounted) return;
    form.updateHoraireTime(index, isStart, picked);
  }
}
