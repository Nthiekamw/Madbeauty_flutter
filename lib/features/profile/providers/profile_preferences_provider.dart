import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/permissions/permissions_providers.dart';
import '../../../services/storage/local_cache_service.dart';

class ProfilePreferencesState {
  const ProfilePreferencesState({
    required this.pushNotificationsEnabled,
    required this.geolocationEnabled,
  });

  final bool pushNotificationsEnabled;
  final bool geolocationEnabled;

  ProfilePreferencesState copyWith({
    bool? pushNotificationsEnabled,
    bool? geolocationEnabled,
  }) {
    return ProfilePreferencesState(
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      geolocationEnabled: geolocationEnabled ?? this.geolocationEnabled,
    );
  }
}

final profilePreferencesProvider =
    NotifierProvider<ProfilePreferencesNotifier, ProfilePreferencesState>(
      ProfilePreferencesNotifier.new,
    );

class ProfilePreferencesNotifier extends Notifier<ProfilePreferencesState> {
  @override
  ProfilePreferencesState build() {
    final cache = LocalCacheService.instance;
    return ProfilePreferencesState(
      pushNotificationsEnabled: cache.profilePushNotificationsEnabled,
      geolocationEnabled: cache.profileGeolocationEnabled,
    );
  }

  /// Aligne le toggle avec l’autorisation système (ex. après création de compte).
  Future<void> refreshFromSystem() async {
    final permissions = ref.read(appPermissionsServiceProvider);
    final osGranted = await permissions.areNotificationsGranted();
    var enabled = LocalCacheService.instance.profilePushNotificationsEnabled;

    if (!osGranted && enabled) {
      enabled = false;
      await LocalCacheService.instance.setProfilePushNotificationsEnabled(
        false,
      );
    }

    if (enabled != state.pushNotificationsEnabled) {
      state = state.copyWith(pushNotificationsEnabled: enabled);
    }
  }

  Future<bool> setPushNotifications(bool enabled) async {
    final permissions = ref.read(appPermissionsServiceProvider);

    if (enabled) {
      final granted = await permissions.requestNotifications();
      if (!granted) {
        return false;
      }
    }

    await LocalCacheService.instance.setProfilePushNotificationsEnabled(
      enabled,
    );
    state = state.copyWith(pushNotificationsEnabled: enabled);
    return true;
  }

  Future<bool> setGeolocation(bool enabled) async {
    if (enabled) {
      final granted = await ref.read(appPermissionsServiceProvider).requestLocation();
      if (!granted) {
        return false;
      }
    }

    await LocalCacheService.instance.setProfileGeolocationEnabled(enabled);
    state = state.copyWith(geolocationEnabled: enabled);
    return true;
  }
}

