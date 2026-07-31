import 'dart:io';

import 'package:share_plus/share_plus.dart';

Future<bool> shareIcsNativeFile({
  required String fileName,
  required String icsContent,
  required String subject,
}) async {
  final file = File('${Directory.systemTemp.path}/$fileName');
  await file.writeAsString(icsContent, flush: true);
  final result = await SharePlus.instance.share(
    ShareParams(
      files: [XFile(file.path, mimeType: 'text/calendar')],
      subject: subject,
    ),
  );
  return result.status != ShareResultStatus.unavailable;
}
