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

  static bool isVideoFile(StorageUploadFile file) {
    final mimeType = file.mimeType?.toLowerCase().trim();
    if (mimeType != null && mimeType.startsWith('video/')) return true;
    final extension = _extensionFromFileName(file.fileName);
    return switch (extension) {
      'mp4' || 'mov' || 'm4v' || 'webm' => true,
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

  static void validateVideoFile(StorageUploadFile file) {
    if (file.bytes.lengthInBytes > maxSourceVideoBytes) {
      throw const AppFailure(
        'Vidéo trop lourde. Choisis une vidéo de moins de 50 Mo.',
      );
    }

    final mimeType = file.mimeType?.toLowerCase().trim();
    final extension = _extensionFromFileName(file.fileName);
    final supportedMime = switch (mimeType) {
      null || '' => null,
      'video/mp4' ||
      'video/quicktime' ||
      'video/webm' ||
      'video/x-m4v' =>
        true,
      _ => false,
    };
    final supportedExtension = switch (extension) {
      'mp4' || 'mov' || 'm4v' || 'webm' => true,
      _ => false,
    };

    if ((supportedMime == false && !supportedExtension) ||
        (supportedMime == null && !supportedExtension)) {
      throw const AppFailure(
        'Format vidéo non supporté. Utilise un fichier MP4, MOV ou WebM.',
      );
    }
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
    return switch (ext) {
      'mov' => 'mov',
      'webm' => 'webm',
      'm4v' => 'm4v',
      _ => 'mp4',
    };
  }

  static String _videoContentTypeForFile(StorageUploadFile file) {
    final mimeType = file.mimeType?.toLowerCase().trim();
    if (mimeType != null && mimeType.startsWith('video/')) return mimeType;
    return switch (_videoExtensionForFile(file)) {
      'mov' => 'video/quicktime',
      'webm' => 'video/webm',
      _ => 'video/mp4',
    };
  }
}

class _StorageObjectRef {
  const _StorageObjectRef(this.bucket, this.path);

  final String bucket;
  final String path;
}

