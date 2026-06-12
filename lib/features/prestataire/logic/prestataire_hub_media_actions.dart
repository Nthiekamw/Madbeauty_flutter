import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../core/models/domain/catalog/realisation_media_type.dart';
import '../../../services/supabase/prestataire/photos/photo_realisation_providers.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../logic/prestataire_hub_constants.dart';
import '../providers/hub/prestataire_hub_form_controller.dart';

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

  static Future<void> pickGallery(
    BuildContext context,
    PrestataireHubFormController form,
  ) async {
    final picked = await ImagePicker().pickMultiImage(
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked.isEmpty) return;
    for (final file in picked) {
      if (_galleryMediaCount(form) >= PrestataireHubConstants.galleryMaxPhotos) {
        break;
      }
      final uploadFile = await StorageUploadFile.fromXFile(file);
      try {
        StorageService.validateImageFile(uploadFile);
        if (!context.mounted) return;
        form.addPendingGallery(uploadFile);
      } on AppFailure catch (e) {
        if (!context.mounted) return;
        form.setGalleryError(e.message);
      }
    }
  }

  static Future<void> pickGalleryVideo(
    BuildContext context,
    PrestataireHubFormController form,
  ) async {
    if (_galleryVideoCount(form) >= PrestataireHubConstants.galleryMaxVideos) {
      form.setGalleryError(
        'Tu peux ajouter au maximum ${PrestataireHubConstants.galleryMaxVideos} vidéos.',
      );
      return;
    }
    if (_galleryMediaCount(form) >= PrestataireHubConstants.galleryMaxPhotos) {
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
    form.addPendingGallery(uploadFile);
  }

  static int _galleryMediaCount(PrestataireHubFormController form) =>
      form.galleryPhotos.length + form.pendingGallery.length;

  static int _galleryVideoCount(PrestataireHubFormController form) {
    final existing =
        form.galleryPhotos.where((p) => p.mediaType.isVideo).length;
    final pending = form.pendingGallery.where((f) => f.isVideo).length;
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
