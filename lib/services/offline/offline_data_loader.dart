import '../network/connectivity_service.dart';

/// Charge des données avec repli cache si hors ligne ou erreur réseau.
class OfflineDataLoader {
  OfflineDataLoader(this._connectivity);

  final ConnectivityService _connectivity;

  Future<bool> get isOnline => _connectivity.isOnline();

  Future<T> load<T>({
    required Future<T> Function() fetchRemote,
    required T? Function() readCache,
    required Future<void> Function(T data) writeCache,
    required T fallback,
  }) async {
    final online = await isOnline;
    if (!online) {
      return readCache() ?? fallback;
    }

    try {
      final data = await fetchRemote();
      await writeCache(data);
      return data;
    } catch (_) {
      return readCache() ?? fallback;
    }
  }
}

