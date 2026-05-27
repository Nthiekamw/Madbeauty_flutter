import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService {
  LocalCacheService._(this._prefs);

  static const String lastSignedInEmailKey = 'auth.last_signed_in_email';
  static const String profileSnapshotKey = 'profile.snapshot';
  static const String selectedRoleKey = 'auth.selected_role';
  /// Espace choisi à l’inscription (conservé tant que la session est active).
  static const String signupShellRoleKey = 'auth.signup_shell_role';
  static const String cachedServerRolesKey = 'auth.cached_server_roles';
  static const String onboardingCompletedKey = 'app.onboarding_completed';
  static const String guestModeActiveKey = 'auth.guest_mode_active';
  static const String profilePushNotificationsKey =
      'profile.push_notifications_enabled';
  static const String profileGeolocationKey = 'profile.geolocation_enabled';
  static const String prestataireCompletionPhaseKey =
      'prestataire.profile_completion_phase';

  /// `true` une fois que la demande de permission système (push) a été faite au moins une fois.
  static const String pushPermissionPromptedKey =
      'push.permission_prompted_v1';

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

  bool get onboardingCompleted =>
      _prefs.getBool(onboardingCompletedKey) ?? false;

  Future<bool> setOnboardingCompleted({bool value = true}) =>
      _prefs.setBool(onboardingCompletedKey, value);

  bool get guestModeActive => _prefs.getBool(guestModeActiveKey) ?? false;

  Future<bool> setGuestModeActive(bool value) =>
      _prefs.setBool(guestModeActiveKey, value);

  bool get profilePushNotificationsEnabled =>
      _prefs.getBool(profilePushNotificationsKey) ?? false;

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

  int? get prestataireProfileCompletionPhase =>
      _prefs.getInt(prestataireCompletionPhaseKey);

  Future<bool> setPrestataireProfileCompletionPhase(int phase) =>
      _prefs.setInt(prestataireCompletionPhaseKey, phase);

  Future<bool> clearPrestataireProfileCompletionPhase() =>
      remove(prestataireCompletionPhaseKey);
}

