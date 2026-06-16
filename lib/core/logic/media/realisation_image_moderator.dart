import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

import '../../constants/app_strings.dart';

enum RealisationImageViolationType {
  detectedText,
  contactOrPromoPattern,
}

class RealisationImageModerationResult {
  const RealisationImageModerationResult._({
    required this.isBlocked,
    this.violation,
    this.skippedAutoCheck = false,
  });

  const RealisationImageModerationResult.allowed({this.skippedAutoCheck = false})
      : isBlocked = false,
        violation = null;

  const RealisationImageModerationResult.blocked(this.violation)
      : isBlocked = true,
        skippedAutoCheck = false;

  final bool isBlocked;
  final RealisationImageViolationType? violation;
  final bool skippedAutoCheck;

  String get message => switch (violation) {
        RealisationImageViolationType.detectedText =>
          DiscPrestaForm.galleryPolicyTextDetected,
        RealisationImageViolationType.contactOrPromoPattern =>
          DiscPrestaForm.galleryPolicyPromoDetected,
        null => '',
      };
}

/// Contrôle local des photos de réalisations (OCR : texte / promo interdits).
abstract final class RealisationImageModerator {
  RealisationImageModerator._();

  static const _minDetectedTextLength = 4;

  static final _contactPattern = RegExp(
    r'(@|www\.|https?://|facebook|instagram|tiktok|snapchat|whatsapp|'
    r'0[1-9](?:[\s.\-]?\d{2}){4})',
    caseSensitive: false,
  );

  static final _promoPattern = RegExp(
    r'\b(promo|promotion|réduction|reduction|soldes|gratuit|€|\$|'
    r'prix|tarif|contact|rdv|rendez[- ]?vous)\b',
    caseSensitive: false,
  );

  static bool get supportsOnDeviceScan {
    if (kIsWeb) return false;
    return Platform.isAndroid || Platform.isIOS;
  }

  static Future<RealisationImageModerationResult> validateLocalImagePath(
    String? localPath,
  ) async {
    if (!supportsOnDeviceScan) {
      return const RealisationImageModerationResult.allowed(
        skippedAutoCheck: true,
      );
    }

    final path = localPath?.trim();
    if (path == null || path.isEmpty || !File(path).existsSync()) {
      return const RealisationImageModerationResult.allowed(
        skippedAutoCheck: true,
      );
    }

    final recognizer = TextRecognizer(script: TextRecognitionScript.latin);
    try {
      final recognized = await recognizer.processImage(
        InputImage.fromFilePath(path),
      );
      return analyzeRecognizedText(recognized.text);
    } catch (_) {
      return const RealisationImageModerationResult.allowed(
        skippedAutoCheck: true,
      );
    } finally {
      await recognizer.close();
    }
  }

  static RealisationImageModerationResult analyzeRecognizedText(String raw) {
    final normalized = raw.replaceAll(RegExp(r'\s+'), ' ').trim();
    if (normalized.isEmpty) {
      return const RealisationImageModerationResult.allowed();
    }

    if (_contactPattern.hasMatch(normalized) ||
        _promoPattern.hasMatch(normalized)) {
      return const RealisationImageModerationResult.blocked(
        RealisationImageViolationType.contactOrPromoPattern,
      );
    }

    final letters =
        normalized.replaceAll(RegExp(r'[^A-Za-zÀ-ÿ0-9]'), '');
    if (letters.length >= _minDetectedTextLength) {
      return const RealisationImageModerationResult.blocked(
        RealisationImageViolationType.detectedText,
      );
    }

    return const RealisationImageModerationResult.allowed();
  }
}
