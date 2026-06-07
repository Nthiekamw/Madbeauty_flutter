import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Callback appelé après une synchro offline réussie (invalidation caches UI).
typedef OfflineSyncAfterFlush = void Function(Ref ref);

final offlineSyncAfterFlushProvider = Provider<OfflineSyncAfterFlush>(
  (ref) => (_) {},
);
