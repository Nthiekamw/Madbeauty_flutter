import '../../../core/models/domain/admin/admin_realisation_photo_summary.dart';

/// Galerie admin regroupée par compte prestataire.
class AdminRealisationPhotoUserGroup {
  const AdminRealisationPhotoUserGroup({
    required this.prestataireId,
    required this.prestataireUserId,
    required this.label,
    required this.photos,
    this.ownerEmail,
  });

  final String prestataireId;
  final String prestataireUserId;
  final String label;
  final String? ownerEmail;
  final List<AdminRealisationPhotoSummary> photos;

  int get photoCount => photos.length;
}

List<AdminRealisationPhotoUserGroup> groupAdminRealisationPhotosByUser(
  List<AdminRealisationPhotoSummary> items,
) {
  if (items.isEmpty) return const [];

  final byUser = <String, List<AdminRealisationPhotoSummary>>{};
  for (final photo in items) {
    final key = photo.prestataireUserId.isNotEmpty
        ? photo.prestataireUserId
        : photo.prestataireId;
    byUser.putIfAbsent(key, () => []).add(photo);
  }

  final groups = <AdminRealisationPhotoUserGroup>[];
  for (final entry in byUser.entries) {
    final photos = List<AdminRealisationPhotoSummary>.from(entry.value)
      ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
    final first = photos.first;
    groups.add(
      AdminRealisationPhotoUserGroup(
        prestataireId: first.prestataireId,
        prestataireUserId: first.prestataireUserId,
        label: first.prestataireLabel,
        ownerEmail: first.ownerEmail,
        photos: photos,
      ),
    );
  }

  groups.sort((a, b) {
    final byLabel = a.label.toLowerCase().compareTo(b.label.toLowerCase());
    if (byLabel != 0) return byLabel;
    return a.prestataireUserId.compareTo(b.prestataireUserId);
  });

  return groups;
}
