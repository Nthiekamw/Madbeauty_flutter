import '../../../services/supabase/storage/storage_service.dart';

/// Média en attente d’envoi, rattaché à une spécialité.
class PendingRealisationUpload {
  const PendingRealisationUpload({
    required this.file,
    required this.categorieId,
    required this.specialtyLabel,
  });

  final StorageUploadFile file;
  final String categorieId;
  final String specialtyLabel;
}
