import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../firebase_runtime_helpers.dart';
import '../../../services/auth/biometric_auth_providers.dart';
import '../../../services/notifications/booking_push_notifications.dart';
import '../../../services/notifications/in_app_notifications_provider.dart';
import '../../../services/permissions/permissions_providers.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../../services/supabase/profile/profile_providers.dart';
import '../../../core/constants/app_strings.dart';
import '../../auth/providers/auth_notifier.dart';

class ProfilePreferencesState {
  const ProfilePreferencesState({
    required this.pushNotificationsEnabled,
    required this.geolocationEnabled,
    required this.biometricUnlockEnabled,
  });

  final bool pushNotificationsEnabled;
  final bool geolocationEnabled;
  final bool biometricUnlockEnabled;

  ProfilePreferencesState copyWith({
    bool? pushNotificationsEnabled,
    bool? geolocationEnabled,
    bool? biometricUnlockEnabled,
  }) {
    return ProfilePreferencesState(
      pushNotificationsEnabled:
          pushNotificationsEnabled ?? this.pushNotificationsEnabled,
      geolocationEnabled: geolocationEnabled ?? this.geolocationEnabled,
      biometricUnlockEnabled:
          biometricUnlockEnabled ?? this.biometricUnlockEnabled,
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
      biometricUnlockEnabled: cache.profileBiometricUnlockEnabled,
    );
  }

  /// Aligne le toggle avec l’autorisation système (ex. après création de compte).
  Future<void> refreshFromSystem() async {
    if (!isFirebaseConfiguredForPush()) return;

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
    if (!isFirebaseConfiguredForPush()) {
      await LocalCacheService.instance.setProfilePushNotificationsEnabled(
        enabled,
      );
      state = state.copyWith(pushNotificationsEnabled: enabled);
      if (enabled) {
        ref.invalidate(inAppNotificationsSyncProvider);
        unawaited(ref.read(inAppNotificationsSyncProvider.future));
      }
      return true;
    }

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

    if (enabled && isFirebaseConfiguredForPush()) {
      final user = switch (ref.read(authNotifierProvider)) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (user != null) {
        unawaited(
          BookingPushNotifications.instance.syncForUser(
            userId: user.id,
            profileService: ref.read(profileServiceProvider),
          ),
        );
      }
    }

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

  Future<bool> setBiometricUnlock(bool enabled) async {
    if (!enabled) {
      await LocalCacheService.instance.setProfileBiometricUnlockEnabled(false);
      ref.read(biometricUnlockSessionProvider.notifier).lock();
      state = state.copyWith(biometricUnlockEnabled: false);
      return true;
    }

    final bio = ref.read(biometricAuthServiceProvider);
    final availability = await bio.checkAvailability();
    if (!availability.isUsable) {
      return false;
    }

    final ok = await bio.authenticate(
      reason: DiscProfile.prefBiometricAuthReason,
    );
    if (!ok) return false;

    await LocalCacheService.instance.setProfileBiometricUnlockEnabled(true);
    ref.read(biometricUnlockSessionProvider.notifier).unlock();
    state = state.copyWith(biometricUnlockEnabled: true);
    return true;
  }
}
