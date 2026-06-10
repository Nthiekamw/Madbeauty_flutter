import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/models/domain/catalog/photo_realisation.dart';
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
      if (form.galleryPhotos.length + form.pendingGallery.length >=
          PrestataireHubConstants.galleryMaxPhotos) {
        break;
      }
      final uploadFile = await StorageUploadFile.fromXFile(file);
      try {
        StorageService.validateImageFile(uploadFile);
        if (!context.mounted) return;
        form.addPendingGallery(uploadFile);
      } on AppFailure {
        // ignore
      }
    }
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
