import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService {
  LocalCacheService._(this._prefs);

  static const String lastSignedInEmailKey = 'auth.last_signed_in_email';
  static const String profileSnapshotKey = 'profile.snapshot';
  static const String selectedRoleKey = 'auth.selected_role';
  /// Espace choisi à l'inscription (conservé tant que la session est active).
  static const String signupShellRoleKey = 'auth.signup_shell_role';
  static const String cachedServerRolesKey = 'auth.cached_server_roles';
  static const String onboardingCompletedKey = 'app.onboarding_completed';
  static const String guestModeActiveKey = 'auth.guest_mode_active';
  static const String profilePushNotificationsKey =
      'profile.push_notifications_enabled';
  static const String profileGeolocationKey = 'profile.geolocation_enabled';
  static const String profileBiometricUnlockKey =
      'profile.biometric_unlock_enabled';
  /// `true` une fois que la demande de permission système (push) a été faite au moins une fois.
  static const String pushPermissionPromptedKey =
      'push.permission_prompted_v1';

  /// Code parrain reçu via lien d'invitation (à appliquer après connexion).
  static const String pendingReferralCodeKey = 'referral.pending_code_v1';
  static const String clientHomeLayoutKey = 'client.home_layout_v1';
  static const String appThemeModeKey = 'app.theme_mode_v1';
  static const String appLanguageCodeKey = 'app.language_code_v1';
  static const String passwordRecoveryPendingKey =
      'auth.password_recovery_pending_v1';
  static const String pwaInstallBannerDismissedAtKey =
      'pwa.install_banner_dismissed_at_ms_v1';
  static const String pwaInstallBannerDismissCountKey =
      'pwa.install_banner_dismiss_count_v1';

  static LocalCacheService? _instance;

  final SharedPreferences _prefs;

  static Future<void> initialize() async {
    final prefs = await SharedPreferences.getInstance();
    _instance = LocalCacheService._(prefs);
  }

  static LocalCacheService get instance {
    final value = _instance;
    if (value == null) {
      throw StateError(
        'LocalCacheService non initialisé. Appeler initialize() au démarrage.',
      );
    }
    return value;
  }

  String? getString(String key) => _prefs.getString(key);

  Future<bool> setString(String key, String value) => _prefs.setString(key, value);

  Future<bool> remove(String key) => _prefs.remove(key);

  String? get selectedRole => getString(selectedRoleKey);

  Future<bool> setSelectedRole(String role) => setString(selectedRoleKey, role);

  Future<bool> clearSelectedRole() => remove(selectedRoleKey);

  String? get signupShellRole => getString(signupShellRoleKey);

  Future<bool> setSignupShellRole(String role) =>
      setString(signupShellRoleKey, role);

  Future<bool> clearSignupShellRole() => remove(signupShellRoleKey);

  List<String> get cachedServerRoles {
    final raw = getString(cachedServerRolesKey);
    if (raw == null || raw.isEmpty) return const [];
    return raw.split(',').where((r) => r.isNotEmpty).toList();
  }

  Future<bool> setCachedServerRoles(List<String> roles) =>
      setString(cachedServerRolesKey, roles.join(','));

  Future<bool> clearCachedServerRoles() => remove(cachedServerRolesKey);

  String? get pendingReferralCode => getString(pendingReferralCodeKey);

  Future<bool> setPendingReferralCode(String code) =>
      setString(pendingReferralCodeKey, code.trim().toUpperCase());

  Future<bool> clearPendingReferralCode() => remove(pendingReferralCodeKey);

  bool get onboardingCompleted =>
      _prefs.getBool(onboardingCompletedKey) ?? false;

  Future<bool> setOnboardingCompleted({bool value = true}) =>
      _prefs.setBool(onboardingCompletedKey, value);

  bool get guestModeActive => _prefs.getBool(guestModeActiveKey) ?? false;

  Future<bool> setGuestModeActive(bool value) =>
      _prefs.setBool(guestModeActiveKey, value);

  bool get profilePushNotificationsEnabled =>
      _prefs.getBool(profilePushNotificationsKey) ?? true;

  Future<bool> setProfilePushNotificationsEnabled(bool value) =>
      _prefs.setBool(profilePushNotificationsKey, value);

  bool get pushPermissionPrompted =>
      _prefs.getBool(pushPermissionPromptedKey) ?? false;

  Future<bool> setPushPermissionPrompted({bool value = true}) =>
      _prefs.setBool(pushPermissionPromptedKey, value);

  bool get profileGeolocationEnabled =>
      _prefs.getBool(profileGeolocationKey) ?? true;

  Future<bool> setProfileGeolocationEnabled(bool value) =>
      _prefs.setBool(profileGeolocationKey, value);

  bool get profileBiometricUnlockEnabled =>
      _prefs.getBool(profileBiometricUnlockKey) ?? false;

  Future<bool> setProfileBiometricUnlockEnabled(bool value) =>
      _prefs.setBool(profileBiometricUnlockKey, value);

  String? get clientHomeLayoutJson => getString(clientHomeLayoutKey);

  Future<bool> setClientHomeLayoutJson(String value) =>
      setString(clientHomeLayoutKey, value);

  String? get appThemeMode => getString(appThemeModeKey);

  Future<bool> setAppThemeMode(String value) =>
      setString(appThemeModeKey, value);

  String? get appLanguageCode => getString(appLanguageCodeKey);

  Future<bool> setAppLanguageCode(String value) =>
      setString(appLanguageCodeKey, value);

  bool get passwordRecoveryPending =>
      _prefs.getBool(passwordRecoveryPendingKey) ?? false;

  Future<bool> setPasswordRecoveryPending(bool value) =>
      _prefs.setBool(passwordRecoveryPendingKey, value);

  Future<bool> clearPasswordRecoveryPending() =>
      remove(passwordRecoveryPendingKey);

  int? get pwaInstallBannerDismissedAtMs {
    final raw = _prefs.getInt(pwaInstallBannerDismissedAtKey);
    return raw;
  }

  Future<bool> setPwaInstallBannerDismissedAtMs(int value) =>
      _prefs.setInt(pwaInstallBannerDismissedAtKey, value);

  int get pwaInstallBannerDismissCount =>
      _prefs.getInt(pwaInstallBannerDismissCountKey) ?? 0;

  Future<bool> setPwaInstallBannerDismissCount(int value) =>
      _prefs.setInt(pwaInstallBannerDismissCountKey, value);
}


