import 'dart:typed_data';

import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/models/domain/catalog/realisation_media_type.dart';

import '../../../core/errors/app_failure.dart';
import '../../../core/errors/supabase_error_handler.dart';

const profilePhotosBucket = 'profile-photos';
const realisationPhotosBucket = 'realisation-photos';
const reviewPhotosBucket = 'review-photos';
const chatAttachmentsBucket = 'chat-attachments';
const bugReportScreenshotsBucket = 'bug-report-screenshots';
const reelMediaBucket = 'reel-media';
const maxSourceImageBytes = 12 * 1024 * 1024;
const maxSourceVideoBytes = 50 * 1024 * 1024;

typedef StorageUploadProgress = void Function(double progress);

class StorageUploadFile {
  const StorageUploadFile({
    required this.bytes,
    this.fileName,
    this.mimeType,
    this.localPath,
  });

  static Future<StorageUploadFile> fromXFile(XFile file) async {
    return StorageUploadFile(
      bytes: await file.readAsBytes(),
      fileName: file.name,
      mimeType: file.mimeType,
      localPath: file.path,
    );
  }

  final Uint8List bytes;
  final String? fileName;
  final String? mimeType;
  final String? localPath;

  RealisationMediaType get mediaType =>
      StorageService.isVideoFile(this)
          ? RealisationMediaType.video
          : RealisationMediaType.image;

  bool get isVideo => mediaType.isVideo;
}

class StorageService {
  StorageService(this._client);

  final SupabaseClient _client;

  Future<String> uploadAvatar({
    required String userId,
    required StorageUploadFile file,
    StorageUploadProgress? onProgress,
  }) {
    return _uploadImage(
      operation: 'storage.uploadAvatar',
      bucket: profilePhotosBucket,
      pathPrefix: userId,
      baseName: 'avatar',
      file: file,
      onProgress: onProgress,
    );
  }

  Future<String> uploadRealisation({
    required String prestataireId,
    required StorageUploadFile file,
    StorageUploadProgress? onProgress,
  }) {
    if (isVideoFile(file)) {
      return uploadRealisationVideo(
        prestataireId: prestataireId,
        file: file,
        onProgress: onProgress,
      );
    }
    return _uploadImage(
      operation: 'storage.uploadRealisation',
      bucket: realisationPhotosBucket,
      pathPrefix: prestataireId,
      baseName: 'realisation',
      file: file,
      onProgress: onProgress,
    );
  }

  Future<String> uploadRealisationVideo({
    required String prestataireId,
    required StorageUploadFile file,
    StorageUploadProgress? onProgress,
  }) {
    return SupabaseErrorHandler.run(
      operation: 'storage.uploadRealisationVideo',
      action: () async {
        validateVideoFile(file);
        onProgress?.call(0.1);
        final stamp = DateTime.now().millisecondsSinceEpoch;
        final ext = _videoExtensionForFile(file);
        final contentType = _videoContentTypeForFile(file);
        final path = '$prestataireId/realisation_$stamp.$ext';

        await _client.storage.from(realisationPhotosBucket).uploadBinary(
              path,
              file.bytes,
              fileOptions: FileOptions(
                contentType: contentType,
                upsert: false,
              ),
            );
        onProgress?.call(0.9);

        final publicUrl =
            _client.storage.from(realisationPhotosBucket).getPublicUrl(path);
        onProgress?.call(1);
        return publicUrl;
      },
    );
  }

  /// Upload photo ou vidéo pour un Reel (`reel-media` / `{prestataireId}/…`).
  Future<String> uploadReelMedia({
    required String prestataireId,
    required StorageUploadFile file,
    StorageUploadProgress? onProgress,
  }) {
    if (isVideoFile(file)) {
      return SupabaseErrorHandler.run(
        operation: 'storage.uploadReelVideo',
        action: () async {
          validateVideoFile(file);
          onProgress?.call(0.1);
          final stamp = DateTime.now().millisecondsSinceEpoch;
          final ext = _videoExtensionForFile(file);
          final contentType = _videoContentTypeForFile(file);
          final path = '$prestataireId/reel_$stamp.$ext';

          await _client.storage.from(reelMediaBucket).uploadBinary(
                path,
                file.bytes,
                fileOptions: FileOptions(
                  contentType: contentType,
                  upsert: false,
                ),
              );
          onProgress?.call(0.9);
          final publicUrl =
              _client.storage.from(reelMediaBucket).getPublicUrl(path);
          onProgress?.call(1);
          return publicUrl;
        },
      );
    }
    return _uploadImage(
      operation: 'storage.uploadReelImage',
      bucket: reelMediaBucket,
      pathPrefix: prestataireId,
      baseName: 'reel',
      file: file,
      onProgress: onProgress,
    );
  }

  static bool isVideoFile(StorageUploadFile file) {
    final mimeType = file.mimeType?.toLowerCase().trim();
    if (mimeType != null && mimeType.startsWith('video/')) return true;
    final extension = _extensionFromFileName(file.fileName);
    if (extension == null) return false;
    return _isLikelyVideoExtension(extension);
  }

  static bool _isLikelyVideoExtension(String extension) {
    return switch (extension) {
      'mp4' ||
      'm4v' ||
      'mov' ||
      'qt' ||
      'webm' ||
      'avi' ||
      'mkv' ||
      '3gp' ||
      '3g2' ||
      'flv' ||
      'wmv' ||
      'ogv' ||
      'ogg' ||
      'mpeg' ||
      'mpg' ||
      'm2ts' ||
      'mts' ||
      'ts' ||
      'hevc' ||
      'h265' ||
      'divx' ||
      'xvid' ||
      'asf' ||
      'f4v' ||
      'vob' ||
      'rm' ||
      'rmvb' ||
      'amv' =>
        true,
      _ => false,
    };
  }

  /// Chemin : `{userId}/{bookingId}/photo_{stamp}.jpg`
  Future<String> uploadChatAttachment({
    required String userId,
    required String bookingId,
    required StorageUploadFile file,
    StorageUploadProgress? onProgress,
  }) {
    return _uploadImage(
      operation: 'storage.uploadChatAttachment',
      bucket: chatAttachmentsBucket,
      pathPrefix: '$userId/$bookingId',
      baseName: 'photo',
      file: file,
      onProgress: onProgress,
    );
  }

  /// Pièce jointe chat devis (sans réservation) — préfixe conversation.
  Future<String> uploadInquiryChatAttachment({
    required String userId,
    required String conversationId,
    required StorageUploadFile file,
    StorageUploadProgress? onProgress,
  }) {
    return _uploadImage(
      operation: 'storage.uploadInquiryChatAttachment',
      bucket: chatAttachmentsBucket,
      pathPrefix: '$userId/inquiry_$conversationId',
      baseName: 'photo',
      file: file,
      onProgress: onProgress,
    );
  }

  /// Chemin : `{userId}/{reportId}/screenshot_{stamp}.jpg`
  Future<String> uploadBugReportScreenshot({
    required String userId,
    required String reportId,
    required StorageUploadFile file,
    StorageUploadProgress? onProgress,
  }) {
    return _uploadImage(
      operation: 'storage.uploadBugReportScreenshot',
      bucket: bugReportScreenshotsBucket,
      pathPrefix: '$userId/$reportId',
      baseName: 'screenshot',
      file: file,
      onProgress: onProgress,
    );
  }

  /// Chemin : `{userId}/{reviewId}/photo-{stamp}.jpg`
  Future<String> uploadReviewPhoto({
    required String userId,
    required String reviewId,
    required StorageUploadFile file,
    StorageUploadProgress? onProgress,
  }) {
    return _uploadImage(
      operation: 'storage.uploadReviewPhoto',
      bucket: reviewPhotosBucket,
      pathPrefix: '$userId/$reviewId',
      baseName: 'photo',
      file: file,
      onProgress: onProgress,
    );
  }

  Future<void> deleteFile(String path) => SupabaseErrorHandler.run(
    operation: 'storage.deleteFile',
    action: () async {
      final targets = _deleteTargets(path);
      for (final target in targets) {
        if (targets.length == 1) {
          await _client.storage.from(target.bucket).remove([target.path]);
        } else {
          try {
            await _client.storage.from(target.bucket).remove([target.path]);
          } catch (_) {
            // Raw paths can belong to either known bucket. Ignore the bucket
            // that rejects it and let the matching bucket handle the delete.
          }
        }
      }
    },
  );

  Future<String> _uploadImage({
    required String operation,
    required String bucket,
    required String pathPrefix,
    required String baseName,
    required StorageUploadFile file,
    StorageUploadProgress? onProgress,
  }) {
    return SupabaseErrorHandler.run(
      operation: operation,
      action: () async {
        validateImageFile(file);
        onProgress?.call(0.12);
        final compressedBytes = await _compressImage(file.bytes);
        onProgress?.call(0.45);
        final stamp = DateTime.now().millisecondsSinceEpoch;
        final path = '$pathPrefix/${baseName}_$stamp.jpg';

        await _client.storage
            .from(bucket)
            .uploadBinary(
              path,
              compressedBytes,
              fileOptions: const FileOptions(
                contentType: 'image/jpeg',
                upsert: false,
              ),
            );
        onProgress?.call(0.9);

        final publicUrl = _client.storage.from(bucket).getPublicUrl(path);
        onProgress?.call(1);
        return publicUrl;
      },
    );
  }

  static void validateVideoFile(
    StorageUploadFile file, {
    bool pickedAsVideo = false,
  }) {
    if (file.bytes.lengthInBytes > maxSourceVideoBytes) {
      throw const AppFailure(
        'Vidéo trop lourde. Choisis une vidéo de moins de 50 Mo.',
      );
    }

    if (isVideoFile(file) || pickedAsVideo) return;

    throw const AppFailure(
      'Fichier non reconnu comme vidéo. Choisis un fichier vidéo depuis ta galerie ou tes fichiers.',
    );
  }

  static void validateImageFile(StorageUploadFile file) {
    if (file.bytes.lengthInBytes > maxSourceImageBytes) {
      throw const AppFailure(
        'Image trop lourde. Choisis une image de moins de 12 Mo.',
      );
    }

    final mimeType = file.mimeType?.toLowerCase().trim();
    final extension = _extensionFromFileName(file.fileName);
    final supportedMime = switch (mimeType) {
      null || '' => null,
      'image/jpeg' || 'image/jpg' || 'image/png' || 'image/webp' => true,
      _ => false,
    };
    final supportedExtension = switch (extension) {
      'jpg' || 'jpeg' || 'png' || 'webp' => true,
      _ => false,
    };

    if ((supportedMime == false && !supportedExtension) ||
        (supportedMime == null && !supportedExtension)) {
      throw const AppFailure(
        'Format non supporté. Utilise une image JPG, PNG ou WebP.',
      );
    }
  }

  Future<Uint8List> _compressImage(Uint8List bytes) async {
    try {
      final compressed = await FlutterImageCompress.compressWithList(
        bytes,
        minWidth: 1280,
        minHeight: 1280,
        quality: 82,
        format: CompressFormat.jpeg,
      );
      return compressed.isEmpty ? bytes : compressed;
    } catch (_) {
      return bytes;
    }
  }

  List<_StorageObjectRef> _deleteTargets(String rawPath) {
    final path = _objectPathFromPublicUrl(rawPath.trim()) ?? rawPath.trim();
    if (path.isEmpty) return const [];

    for (final bucket in const [profilePhotosBucket, realisationPhotosBucket]) {
      final prefix = '$bucket/';
      if (path.startsWith(prefix)) {
        return [_StorageObjectRef(bucket, path.substring(prefix.length))];
      }
    }

    return const [
      _StorageObjectRef(profilePhotosBucket, ''),
      _StorageObjectRef(realisationPhotosBucket, ''),
    ].map((target) => _StorageObjectRef(target.bucket, path)).toList();
  }

  String? _objectPathFromPublicUrl(String value) {
    final uri = Uri.tryParse(value);
    if (uri == null) return null;

    const marker = '/storage/v1/object/public/';
    final markerIndex = uri.path.indexOf(marker);
    if (markerIndex == -1) return null;

    final encoded = uri.path.substring(markerIndex + marker.length);
    return Uri.decodeComponent(encoded);
  }

  static String? _extensionFromFileName(String? fileName) {
    if (fileName == null || !fileName.contains('.')) return null;
    final ext = fileName.split('.').last.toLowerCase();
    return ext.isEmpty ? null : ext;
  }

  static String _videoExtensionForFile(StorageUploadFile file) {
    final ext = _extensionFromFileName(file.fileName);
    if (ext != null && ext.isNotEmpty) return ext;
    return 'mp4';
  }

  static String _videoContentTypeForFile(StorageUploadFile file) {
    final mimeType = file.mimeType?.toLowerCase().trim();
    if (mimeType != null && mimeType.startsWith('video/')) return mimeType;
    return _videoMimeFromExtension(_extensionFromFileName(file.fileName));
  }

  static String _videoMimeFromExtension(String? extension) {
    return switch (extension) {
      'mov' || 'qt' => 'video/quicktime',
      'webm' => 'video/webm',
      'm4v' => 'video/x-m4v',
      'avi' => 'video/x-msvideo',
      'mkv' => 'video/x-matroska',
      '3gp' => 'video/3gpp',
      '3g2' => 'video/3gpp2',
      'wmv' => 'video/x-ms-wmv',
      'flv' => 'video/x-flv',
      'ogv' || 'ogg' => 'video/ogg',
      'mpeg' || 'mpg' => 'video/mpeg',
      'ts' || 'm2ts' || 'mts' => 'video/mp2t',
      _ => 'video/mp4',
    };
  }
}

class _StorageObjectRef {
  const _StorageObjectRef(this.bucket, this.path);

  final String bucket;
  final String path;
}

