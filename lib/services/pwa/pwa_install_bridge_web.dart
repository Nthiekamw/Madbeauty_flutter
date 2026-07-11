// ignore_for_file: avoid_web_libraries_in_flutter

import 'dart:html' as html;
import 'dart:js_util' as js_util;

/// Capture `beforeinstallprompt` et détecte le mode standalone (PWA).
class PwaInstallBridge {
  PwaInstallBridge._();

  static final PwaInstallBridge instance = PwaInstallBridge._();

  final Set<void Function()> _listeners = {};
  Object? _deferredPrompt;
  bool _initialized = false;

  void initialize() {
    if (_initialized) return;
    _initialized = true;

    html.window.addEventListener('beforeinstallprompt', (html.Event event) {
      event.preventDefault();
      _deferredPrompt = event;
      _notify();
    });

    html.window.addEventListener('appinstalled', (_) {
      _deferredPrompt = null;
      _notify();
    });
  }

  void addListener(void Function() listener) => _listeners.add(listener);

  void removeListener(void Function() listener) => _listeners.remove(listener);

  void _notify() {
    for (final listener in _listeners.toList()) {
      listener();
    }
  }

  bool get isStandalone {
    if (html.window.matchMedia('(display-mode: standalone)').matches) {
      return true;
    }
    final standalone = js_util.getProperty(html.window.navigator, 'standalone');
    return standalone == true;
  }

  bool get canPromptInstall => _deferredPrompt != null;

  bool get isIosInstallable {
    if (isStandalone) return false;
    final ua = html.window.navigator.userAgent.toLowerCase();
    final isAppleMobile =
        ua.contains('iphone') || ua.contains('ipad') || ua.contains('ipod');
    if (!isAppleMobile) return false;
    return !ua.contains('crios') && !ua.contains('fxios');
  }

  Future<bool> promptInstall() async {
    final prompt = _deferredPrompt;
    if (prompt == null) return false;

    try {
      await js_util.promiseToFuture<void>(
        js_util.callMethod(prompt, 'prompt', []),
      );
      final choice = await js_util.promiseToFuture<Object?>(
        js_util.getProperty(prompt, 'userChoice'),
      );
      _deferredPrompt = null;
      _notify();
      if (choice == null) return false;
      final outcome = js_util.getProperty(choice, 'outcome');
      return outcome == 'accepted';
    } catch (_) {
      _deferredPrompt = null;
      _notify();
      return false;
    }
  }
}
