import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Avis de bannissement différé (écran welcome si pas de contexte dialogue).
final pendingBanNoticeProvider =
    NotifierProvider<PendingBanNoticeNotifier, PendingBanNotice?>(
  PendingBanNoticeNotifier.new,
);

class PendingBanNotice {
  const PendingBanNotice([this.reason]);

  final String? reason;
}

class PendingBanNoticeNotifier extends Notifier<PendingBanNotice?> {
  @override
  PendingBanNotice? build() => null;

  void arm([String? reason]) => state = PendingBanNotice(reason);

  PendingBanNotice? take() {
    final value = state;
    state = null;
    return value;
  }
}
