/// État PWA hors navigateur (mobile natif, desktop).
class PwaInstallBridge {
  PwaInstallBridge._();

  static final PwaInstallBridge instance = PwaInstallBridge._();

  void initialize() {}

  void addListener(void Function() listener) {}

  void removeListener(void Function() listener) {}

  bool get isStandalone => false;

  bool get canPromptInstall => false;

  bool get isIosInstallable => false;

  Future<bool> promptInstall() async => false;
}
