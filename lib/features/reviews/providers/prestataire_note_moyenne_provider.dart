import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/config/app_config.dart';
import '../../../services/supabase/supabase_service.dart';

/// Note moyenne temps réel (`prestataire_profiles.note_moyenne`).
final prestataireNoteMoyenneProvider = StreamProvider.autoDispose
    .family<double?, String>((ref, prestataireId) {
  if (!AppConfig.hasSupabase) return const Stream.empty();

  final controller = StreamController<double?>.broadcast();
  RealtimeChannel? channel;

  Future<void> emitFromRow(Map<String, dynamic>? row) async {
    if (row != null) {
      final raw = row['note_moyenne'];
      if (!controller.isClosed) {
        controller.add(raw == null ? null : (raw as num).toDouble());
      }
      return;
    }
    final response = await SupabaseService.client
        .from('prestataire_profiles')
        .select('note_moyenne')
        .eq('id', prestataireId)
        .maybeSingle();
    if (controller.isClosed) return;
    if (response == null) {
      controller.add(null);
      return;
    }
    final v = (response as Map)['note_moyenne'];
    controller.add(v == null ? null : (v as num).toDouble());
  }

  controller.onListen = () async {
    await emitFromRow(null);

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
            if (record.isEmpty) return;
            unawaited(emitFromRow(record));
          },
        )
        .subscribe();
  };

  ref.onDispose(() async {
    final ch = channel;
    if (ch != null) {
      await SupabaseService.client.removeChannel(ch);
    }
    if (!controller.isClosed) await controller.close();
  });

  return controller.stream;
});
