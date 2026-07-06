import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../core/utils/safe_broadcast_stream.dart';
import '../../../services/supabase/supabase_service.dart';

/// Note moyenne temps réel (`prestataire_profiles.note_moyenne`).
final prestataireNoteMoyenneProvider = StreamProvider.autoDispose
    .family<double?, String>((ref, prestataireId) {
  if (!AppConfig.hasSupabase) return const Stream.empty();

  final safe = SafeBroadcastStream<double?>();
  RealtimeChannel? channel;

  Future<void> emitFromRow(Map<String, dynamic>? row) async {
    if (!safe.isActive) return;
    if (row != null) {
      final raw = row['note_moyenne'];
      safe.add(raw == null ? null : (raw as num).toDouble());
      return;
    }
    final response = await SupabaseService.client
        .from('prestataire_profiles')
        .select('note_moyenne')
        .eq('id', prestataireId)
        .maybeSingle();
    if (!safe.isActive) return;
    if (response == null) {
      safe.add(null);
      return;
    }
    final v = (response as Map)['note_moyenne'];
    safe.add(v == null ? null : (v as num).toDouble());
  }

  void startListening() {
    unawaited(() async {
      await emitFromRow(null);
      if (!safe.isActive) return;

      channel = SupabaseService.client
          .channel('presta-note-$prestataireId')
          .onPostgresChanges(
            event: PostgresChangeEvent.update,
            schema: 'public',
            table: 'prestataire_profiles',
            filter: PostgresChangeFilter(
              type: PostgresChangeFilterType.eq,
              column: 'id',
              value: prestataireId,
            ),
            callback: (payload) {
              final record = payload.newRecord;
              if (record.isEmpty || !safe.isActive) return;
              unawaited(emitFromRow(record));
            },
          )
          .subscribe();
    }());
  }

  safe.bind(
    onListen: startListening,
    cleanup: () async {
      final ch = channel;
      channel = null;
      if (ch != null) {
        await SupabaseService.client.removeChannel(ch);
      }
    },
  );

  ref.onDispose(() => safe.dispose());

  return safe.stream;
});

