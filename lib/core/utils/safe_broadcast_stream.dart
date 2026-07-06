import 'dart:async';

/// [StreamController.broadcast] avec fermeture sûre (évite add/addError après close).
class SafeBroadcastStream<T> {
  SafeBroadcastStream();

  final StreamController<T> _controller = StreamController<T>.broadcast();
  var _disposed = false;

  Stream<T> get stream => _controller.stream;

  bool get isActive => !_disposed && !_controller.isClosed;

  void add(T event) {
    if (!isActive) return;
    try {
      _controller.add(event);
    } on StateError catch (_) {
      /* course entre isClosed et add */
    }
  }

  void addError(Object error, StackTrace stackTrace) {
    if (!isActive) return;
    try {
      _controller.addError(error, stackTrace);
    } on StateError catch (_) {
      /* course entre isClosed et addError */
    }
  }

  Future<void> dispose({Future<void> Function()? cleanup}) async {
    if (_disposed) return;
    _disposed = true;
    if (cleanup != null) await cleanup();
    if (!_controller.isClosed) {
      try {
        await _controller.close();
      } on StateError catch (_) {}
    }
  }

  void bind({
    required void Function() onListen,
    Future<void> Function()? cleanup,
  }) {
    _controller.onListen = onListen;
    _controller.onCancel = () => unawaited(dispose(cleanup: cleanup));
  }
}
