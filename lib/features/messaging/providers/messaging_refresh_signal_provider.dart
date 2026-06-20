import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Incrémenté à chaque événement temps réel / push messagerie (badges + inbox).
class MessagingRefreshSignalNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void bump() => state = state + 1;
}

final messagingRefreshSignalProvider =
    NotifierProvider<MessagingRefreshSignalNotifier, int>(
  MessagingRefreshSignalNotifier.new,
);

void bumpMessagingRefresh(Ref ref) {
  ref.read(messagingRefreshSignalProvider.notifier).bump();
}

void bumpMessagingRefreshFromWidgetRef(WidgetRef ref) {
  ref.read(messagingRefreshSignalProvider.notifier).bump();
}
