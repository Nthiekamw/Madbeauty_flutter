/// Photo ou vidéo de réalisation pour la modération admin.
class AdminRealisationPhotoSummary {
  const AdminRealisationPhotoSummary({
    required this.id,
    required this.prestataireId,
    required this.prestataireUserId,
    required this.prestataireLabel,
    required this.url,
    required this.createdAt,
    this.ownerEmail,
    this.caption,
    this.mediaType = 'image',
  });

  final String id;
  final String prestataireId;
  final String prestataireUserId;
  final String prestataireLabel;
  final String? ownerEmail;
  final String url;
  final String? caption;
  final String mediaType;
  final DateTime createdAt;

  bool get isVideo => mediaType == 'video';
}
