import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';

enum ContentReportTargetType {
  prestataireProfile('prestataire_profile'),
  conversation('conversation'),
  message('message');

  const ContentReportTargetType(this.value);
  final String value;
}

class ContentReportService {
  ContentReportService(this._client);

  final SupabaseClient _client;

  Future<void> submit({
    required ContentReportTargetType targetType,
    required String targetId,
    required String reason,
    String? details,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'contentReport.submit',
        action: () async {
          final userId = _client.auth.currentUser?.id;
          if (userId == null) {
            throw StateError('Utilisateur non connecté');
          }
          await _client.from('content_reports').insert({
            'reporter_user_id': userId,
            'target_type': targetType.value,
            'target_id': targetId,
            'reason': reason.trim(),
            if (details != null && details.trim().isNotEmpty)
              'details': details.trim(),
          });
        },
      );
}
