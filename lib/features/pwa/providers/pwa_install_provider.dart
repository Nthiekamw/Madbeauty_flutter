import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/pwa/pwa_install_bridge.dart';
import '../../../services/storage/local_cache_service.dart';

/// État du bandeau « Installer l’app » (Flutter Web / PWA).
class PwaInstallState {
  const PwaInstallState({
    required this.bannerVisible,
    required this.profileInstallAvailable,
    required this.canPromptInstall,
    required this.isIosInstallable,
  });

  /// Bandeau haut de page (respecte les fermetures utilisateur).
  final bool bannerVisible;

  /// Bouton profil : web mobile, pas encore installé.
  final bool profileInstallAvailable;
  final bool canPromptInstall;
  final bool isIosInstallable;

  bool get showIosInstructions => isIosInstallable && !canPromptInstall;
}

final pwaInstallProvider =
    NotifierProvider<PwaInstallNotifier, PwaInstallState>(PwaInstallNotifier.new);

class PwaInstallNotifier extends Notifier<PwaInstallState> {
  static const _dismissCooldown = Duration(days: 14);
  static const _maxDismissCount = 5;

  final _bridge = PwaInstallBridge.instance;

  @override
  PwaInstallState build() {
    if (!kIsWeb) {
      return const PwaInstallState(
        bannerVisible: false,
        profileInstallAvailable: false,
        canPromptInstall: false,
        isIosInstallable: false,
      );
    }

    _bridge.initialize();
    _bridge.addListener(_onBridgeChanged);
    ref.onDispose(() => _bridge.removeListener(_onBridgeChanged));

    return _computeState();
  }

  void _onBridgeChanged() {
    state = _computeState();
  }

  PwaInstallState _computeState() {
    final canPrompt = _bridge.canPromptInstall;
    final iosInstallable = _bridge.isIosInstallable;
    final installable = canPrompt || iosInstallable;
    final profileInstallAvailable =
        kIsWeb && !_bridge.isStandalone && installable;

    if (!profileInstallAvailable) {
      return PwaInstallState(
        bannerVisible: false,
        profileInstallAvailable: false,
        canPromptInstall: canPrompt,
        isIosInstallable: iosInstallable,
      );
    }

    return PwaInstallState(
      bannerVisible: !_isDismissed(),
      profileInstallAvailable: true,
      canPromptInstall: canPrompt,
      isIosInstallable: iosInstallable,
    );
  }

  bool _isDismissed() {
    final cache = LocalCacheService.instance;
    if (cache.pwaInstallBannerDismissCount >= _maxDismissCount) return true;

    final dismissedAt = cache.pwaInstallBannerDismissedAtMs;
    if (dismissedAt == null) return false;

    final elapsed = DateTime.now().millisecondsSinceEpoch - dismissedAt;
    return elapsed < _dismissCooldown.inMilliseconds;
  }

  Future<bool> install() => _bridge.promptInstall();

  Future<void> dismiss() async {
    final cache = LocalCacheService.instance;
    await cache.setPwaInstallBannerDismissedAtMs(
      DateTime.now().millisecondsSinceEpoch,
    );
    await cache.setPwaInstallBannerDismissCount(
      cache.pwaInstallBannerDismissCount + 1,
    );
    state = _computeState();
  }
}
