import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/models/domain/user/user_profile.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../../../services/supabase/storage/storage_providers.dart';
import '../../../services/offline/offline_actions.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../../services/supabase/profile/profile_providers.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/widgets/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery_constrained_body.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/guest/widgets/guest_account_prompt.dart';
import '../../auth/providers/auth_notifier.dart';
import '../widgets/profile_role_space_section.dart';
import '../../home/providers/home_profile_provider.dart';
import '../logic/profile_display.dart';
import '../providers/app_version_provider.dart';
import '../providers/current_user_profile_provider.dart';
import '../widgets/edit_profile_name_dialog.dart';
import '../widgets/profile_account_header.dart';
import '../widgets/profile_account_section.dart';
import '../widgets/profile_favorites_section.dart';
import '../widgets/profile_messages_section.dart';
import '../widgets/profile_admin_section.dart';
import '../widgets/profile_footer_actions.dart';
import '../widgets/profile_my_info_section.dart';
import '../widgets/profile_preferences_section.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Uint8List? _avatarPreviewBytes;
  bool _savingPhoto = false;
  bool _savingName = false;

  Future<bool> _confirmSignOut() async {
    return await showDialog<bool>(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text(ShellStrings.accountSignOutConfirmTitle),
            content: const Text(ShellStrings.accountSignOutConfirmBody),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(ctx).pop(false),
                child: const Text(CoreStrings.actionCancel),
              ),
              FilledButton(
                onPressed: () => Navigator.of(ctx).pop(true),
                child: const Text(ShellStrings.accountActionSignOut),
              ),
            ],
          ),
        ) ??
        false;
  }

  Future<void> _signOut() async {
    if (!await _confirmSignOut() || !mounted) return;
    await ref.read(authNotifierProvider.notifier).signOut();
  }

  Future<void> _confirmDeleteAccount() async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(DiscProfile.deleteAccountTitle),
        content: const Text(DiscProfile.deleteAccountBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text(CoreStrings.actionCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: Theme.of(ctx).colorScheme.error,
            ),
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text(DiscProfile.deleteAccountConfirm),
          ),
        ],
      ),
    );
    if (go != true || !mounted) return;

    try {
      await LocalCacheService.instance.setProfilePushNotificationsEnabled(
        false,
      );
      await LocalCacheService.instance.setProfileGeolocationEnabled(false);
      await ref.read(authNotifierProvider.notifier).signOut();
      if (mounted) {
        AppSnackBar.show(
          context,
          message: DiscProfile.deleteAccountDone,
          kind: AppSnackKind.success,
        );
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.show(
          context,
          message: DiscProfile.deleteAccountErr,
          kind: AppSnackKind.error,
        );
      }
    }
  }

  void _invalidateProfile() {
    ref.invalidate(currentUserProfileProvider);
    ref.invalidate(homeProfileSnapshotProvider);
  }

  void _showSnack(String message, {AppSnackKind kind = AppSnackKind.info}) {
    AppSnackBar.show(context, message: message, kind: kind);
  }

  Future<void> _editName(UserProfile? profile) async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    final result = await showEditProfileNameDialog(
      context: context,
      initialPrenom: profile?.prenom?.trim() ?? '',
      initialNom: profile?.nom?.trim() ?? '',
    );
    if (result == null || !mounted) return;

    final profileService = ref.read(profileServiceProvider);
    if (profileService == null) {
      _showSnack(ShellStrings.profileSaveErr, kind: AppSnackKind.error);
      return;
    }

    if (!await ensureOnline(context, ref)) return;

    setState(() => _savingName = true);
    try {
      await profileService.upsertIdentity(
        userId: user.id,
        prenom: result.prenom,
        nom: result.nom,
      );
      _invalidateProfile();
      if (mounted) {
        _showSnack(ShellStrings.profileSaveOk, kind: AppSnackKind.success);
      }
    } catch (_) {
      if (mounted) _showSnack(ShellStrings.profileSaveErr, kind: AppSnackKind.error);
    } finally {
      if (mounted) setState(() => _savingName = false);
    }
  }

  Future<void> _pickAndUploadPhoto() async {
    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;

    late final StorageUploadFile uploadFile;
    try {
      uploadFile = await StorageUploadFile.fromXFile(picked);
      StorageService.validateImageFile(uploadFile);
    } on AppFailure catch (e) {
      if (mounted) _showSnack(e.message, kind: AppSnackKind.error);
      return;
    }

    setState(() {
      _avatarPreviewBytes = uploadFile.bytes;
      _savingPhoto = true;
    });

    final storage = ref.read(storageServiceProvider);
    final profileService = ref.read(profileServiceProvider);
    if (storage == null || profileService == null) {
      if (mounted) {
        setState(() {
          _savingPhoto = false;
          _avatarPreviewBytes = null;
        });
        _showSnack(ShellStrings.profileSaveErr, kind: AppSnackKind.error);
      }
      return;
    }

    if (!await ensureOnline(context, ref)) {
      if (mounted) {
        setState(() {
          _savingPhoto = false;
          _avatarPreviewBytes = null;
        });
      }
      return;
    }

    try {
      final url = await storage.uploadAvatar(
        userId: user.id,
        file: uploadFile,
      );
      await profileService.upsertAvatar(userId: user.id, avatarUrl: url);
      _invalidateProfile();
      if (mounted) {
        setState(() {
          _savingPhoto = false;
          _avatarPreviewBytes = null;
        });
        _showSnack(ShellStrings.profileSaveOk, kind: AppSnackKind.success);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _savingPhoto = false;
          _avatarPreviewBytes = null;
        });
        _showSnack(ShellStrings.profileSaveErr, kind: AppSnackKind.error);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (ref.watch(isGuestBrowsingProvider)) {
      return DiscoveryBrandScaffold(
        body: Column(
          children: [
            Expanded(
              child: GuestAccountPrompt(
                icon: Icons.person_outline,
                title: AuthStrings.guestProfileTitle,
                message: AuthStrings.guestProfileBody,
              ),
            ),
          ],
        ),
      );
    }

    final user = switch (ref.watch(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final profileAsync = ref.watch(currentUserProfileProvider);
    final versionAsync = ref.watch(appVersionProvider);

    final profile = switch (profileAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };

    final email = user?.email?.trim() ?? '';
    final phone = profile?.telephone?.trim() ?? '';
    final displayName = profileDisplayName(profile: profile, email: email);
    final loadingProfile = profileAsync.isLoading && profile == null;

    final hPad = DiscoveryResponsive.of(context).horizontalPadding;

    return DiscoveryBrandScaffold(
      body: ListView(
        padding: const EdgeInsets.only(bottom: 32),
        children: [
          DiscoveryConstrainedBody(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
          if (loadingProfile)
            const Padding(
              padding: EdgeInsets.all(40),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ProfileAccountHeader(
              profile: profile,
              displayName: displayName,
              email: email,
              avatarBytes: _avatarPreviewBytes,
              photoLoading: _savingPhoto,
              onEditPhoto: _savingPhoto ? null : _pickAndUploadPhoto,
              onEditName: _savingName ? null : () => _editName(profile),
            ),
          if (_savingName)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: const LinearProgressIndicator(minHeight: 2),
            ),
          const SizedBox(height: 20),
          ProfileMyInfoSection(email: email, phone: phone),
          const SizedBox(height: 16),
          const ProfilePreferencesSection(),
          const SizedBox(height: 16),
          const ProfileRoleSpaceSection(),
          const SizedBox(height: 16),
          const ProfileFavoritesSection(),
          const SizedBox(height: 16),
          const ProfileMessagesSection(),
          const SizedBox(height: 16),
          const ProfileAdminSection(),
          const ProfileAccountSection(),
          const SizedBox(height: 20),
          ProfileFooterActions(
            onSignOut: _signOut,
            onDeleteAccount: _confirmDeleteAccount,
          ),
          const SizedBox(height: 20),
          versionAsync.when(
            data: (version) => Padding(
              padding: EdgeInsets.symmetric(horizontal: hPad),
              child: Text(
                '${ShellStrings.profileVersionLabel} $version',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            loading: () => const SizedBox(height: 8),
            error: (_, __) => const SizedBox(height: 8),
          ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
