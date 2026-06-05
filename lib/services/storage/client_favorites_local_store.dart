import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Opération favori en attente de synchronisation Supabase.
enum FavoriteSyncOpKind { add, remove }

class FavoritePendingOp {
  const FavoritePendingOp({
    required this.prestataireId,
    required this.kind,
  });

  final String prestataireId;
  final FavoriteSyncOpKind kind;

  Map<String, dynamic> toJson() => {
        'prestataire_id': prestataireId,
        'kind': kind.name,
      };

  factory FavoritePendingOp.fromJson(Map<String, dynamic> json) {
    final kindName = json['kind'] as String? ?? '';
    return FavoritePendingOp(
      prestataireId: json['prestataire_id'] as String,
      kind: kindName == FavoriteSyncOpKind.remove.name
          ? FavoriteSyncOpKind.remove
          : FavoriteSyncOpKind.add,
    );
  }
}

/// Cache local des favoris (par [clientId]) + file d'attente sync.
abstract final class ClientFavoritesLocalStore {
  ClientFavoritesLocalStore._();

  static const _idsPrefix = 'favorites.ids.v1.';
  static const _pendingPrefix = 'favorites.pending.v1.';

  static String _idsKey(String clientId) => '$_idsPrefix$clientId';
  static String _pendingKey(String clientId) => '$_pendingPrefix$clientId';

  static Future<Set<String>> readIds(String clientId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_idsKey(clientId));
    if (raw == null || raw.isEmpty) return {};
    return raw.split(',').where((s) => s.isNotEmpty).toSet();
  }

  static Future<void> writeIds(String clientId, Set<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final sorted = ids.toList()..sort();
    await prefs.setString(_idsKey(clientId), sorted.join(','));
  }

  static Future<List<FavoritePendingOp>> readPending(String clientId) async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pendingKey(clientId));
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List<dynamic>;
      return [
        for (final e in list)
          FavoritePendingOp.fromJson(Map<String, dynamic>.from(e as Map)),
      ];
    } catch (_) {
      return [];
    }
  }

  static Future<void> writePending(
    String clientId,
    List<FavoritePendingOp> ops,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    if (ops.isEmpty) {
      await prefs.remove(_pendingKey(clientId));
      return;
    }
    await prefs.setString(
      _pendingKey(clientId),
      jsonEncode(ops.map((e) => e.toJson()).toList()),
    );
  }

  static Future<void> enqueuePending(
    String clientId,
    FavoritePendingOp op,
  ) async {
    final current = await readPending(clientId);
    final next = [...current, op];
    await writePending(clientId, next);
  }

  /// Déconnexion : supprime tous les favoris et files d'attente locaux.
  static Future<void> purgeAll() async {
    final prefs = await SharedPreferences.getInstance();
    final toRemove = prefs.getKeys().where(
      (k) => k.startsWith(_idsPrefix) || k.startsWith(_pendingPrefix),
    );
    for (final key in toRemove) {
      await prefs.remove(key);
    }
  }
}

