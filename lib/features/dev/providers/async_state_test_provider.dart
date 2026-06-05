import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

enum AsyncStateTestMode { loading, data, error }

final asyncStateTestModeProvider =
    NotifierProvider<AsyncStateTestModeNotifier, AsyncStateTestMode>(
      AsyncStateTestModeNotifier.new,
    );

class AsyncStateTestModeNotifier extends Notifier<AsyncStateTestMode> {
  @override
  AsyncStateTestMode build() {
    return AsyncStateTestMode.loading;
  }

  void setMode(AsyncStateTestMode mode) {
    state = mode;
  }
}

final asyncStateTestProvider = FutureProvider.autoDispose<List<String>>((
  ref,
) async {
  final mode = ref.watch(asyncStateTestModeProvider);

  switch (mode) {
    case AsyncStateTestMode.loading:
      return Completer<List<String>>().future;
    case AsyncStateTestMode.data:
      await Future<void>.delayed(const Duration(milliseconds: 450));
      return const [
        'Prestataire chargée',
        'Services disponibles',
        'Dashboard prêt',
      ];
    case AsyncStateTestMode.error:
      await Future<void>.delayed(const Duration(milliseconds: 450));
      throw StateError('Erreur de test simulée.');
  }
});

