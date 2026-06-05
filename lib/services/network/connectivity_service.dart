import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:flutter/services.dart';

class ConnectivityService {
  ConnectivityService(this._connectivity);

  final Connectivity _connectivity;

  factory ConnectivityService.create() => ConnectivityService(Connectivity());

  Stream<bool> get onlineStatusStream async* {
    try {
      await for (final results in _connectivity.onConnectivityChanged) {
        yield _isOnline(results);
      }
    } on MissingPluginException {
      // Fallback dev/runtime: plugin non enregistre (hot-restart, build stale, etc.)
      yield true;
    }
  }

  Future<bool> isOnline() async {
    try {
      final results = await _connectivity.checkConnectivity();
      return _isOnline(results);
    } on MissingPluginException {
      // On degrade en "online" pour ne pas casser l'UX.
      return true;
    }
  }

  bool _isOnline(List<ConnectivityResult> results) =>
      !results.contains(ConnectivityResult.none);
}

