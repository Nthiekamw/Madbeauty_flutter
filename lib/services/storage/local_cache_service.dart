import 'package:shared_preferences/shared_preferences.dart';

class LocalCacheService {
  LocalCacheService._(this._prefs);

  static const String lastSignedInEmailKey = 'auth.last_signed_in_email';
  static const String profileSnapshotKey = 'profile.snapshot';
  static const String selectedRoleKey = 'auth.selected_role';
  static const String cachedServerRolesKey = 'auth.cached_server_roles';
  static const String onboardingCompletedKey = 'app.onboarding_completed';

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
}
