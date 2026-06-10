import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/admin/admin_audit_entry.dart';
import '../supabase_service.dart';

class AdminAuditService {
  AdminAuditService(this._client);

  final SupabaseClient _client;

  factory AdminAuditService.fromEnv() => AdminAuditService(SupabaseService.client);

  Future<List<AdminAuditEntry>> listAuditLog({int limit = 100}) async {
    return SupabaseErrorHandler.run(
      operation: 'adminAudit.listAuditLog',
      action: () async {
        final rows = await _client.rpc(
          'admin_list_audit_log',
          params: {'p_limit': limit},
        );
        return _mapAudit(rows);
      },
    );
  }

  Future<List<AdminVerificationEvent>> listVerificationEvents({
    int limit = 100,
  }) async {
    return SupabaseErrorHandler.run(
      operation: 'adminAudit.listVerificationEvents',
      action: () async {
        final rows = await _client.rpc(
          'admin_list_verification_events',
          params: {'p_limit': limit},
        );
        final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
        return list
            .map(
              (row) => AdminVerificationEvent(
                id: row['id'] as String? ?? '',
                prestataireId: row['prestataire_id'] as String? ?? '',
                nomSalon: row['nom_salon'] as String?,
                actorUserId: row['actor_user_id'] as String? ?? '',
                actorDisplayName: row['actor_display_name'] as String?,
                action: row['action'] as String? ?? '',
                note: row['note'] as String?,
                createdAt: DateTime.tryParse(
                      (row['created_at'] as String?) ?? '',
                    ) ??
                    DateTime.fromMillisecondsSinceEpoch(0),
              ),
            )
            .toList();
      },
    );
  }

  List<AdminAuditEntry> _mapAudit(dynamic rows) {
    final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
    return list
        .map(
          (row) => AdminAuditEntry(
            id: row['id'] as String? ?? '',
            actorUserId: row['actor_user_id'] as String? ?? '',
            actorDisplayName: row['actor_display_name'] as String?,
            action: row['action'] as String? ?? '',
            entityType: row['entity_type'] as String? ?? '',
            entityId: row['entity_id'] as String? ?? '',
            metadata: row['metadata'] is Map
                ? Map<String, dynamic>.from(row['metadata'] as Map)
                : null,
            createdAt: DateTime.tryParse(
                  (row['created_at'] as String?) ?? '',
                ) ??
                DateTime.fromMillisecondsSinceEpoch(0),
          ),
        )
        .toList();
  }
}
