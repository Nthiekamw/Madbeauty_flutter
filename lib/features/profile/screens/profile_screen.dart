import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/models/domain/user/user_profile.dart';
import '../../../core/models/user_role.dart';
import '../../../core/providers/runtime_providers.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../../../services/supabase/storage/storage_providers.dart';
import '../../../services/supabase/profile/profile_providers.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../auth/providers/my_roles_provider.dart';
import '../../auth/widgets/role_switch_section.dart';
import '../../home/providers/home_profile_provider.dart';
import '../logic/profile_display.dart';
import '../providers/app_version_provider.dart';
import '../providers/current_user_profile_provider.dart';
import '../widgets/edit_profile_name_dialog.dart';
import '../widgets/profile_account_header.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  Uint8List? _avatarPreviewBytes;
  bool _savingPhoto = false;
  bool _savingName = false;

  Future<void> _confirmSignOut() async {
    final go = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text(ShellStrings.accountSignOutConfirmTitle),
        content: const Text(ShellStrings.accountSignOutConfirmBody),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('Se déconnecter'),
          ),
        ],
      ),
    );
    if (go != true || !mounted) return;
    await ref.read(authNotifierProvider.notifier).signOut();
  }

  void _invalidateProfile() {
    ref.invalidate(currentUserProfileProvider);
    ref.invalidate(homeProfileSnapshotProvider);
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
      _showSnack(ShellStrings.profileSaveErr);
      return;
    }

    final isOnline = await ref.read(connectivityServiceProvider).isOnline();
    if (!isOnline) {
      _showSnack(ShellStrings.profileSaveErr);
      return;
    }

    setState(() => _savingName = true);
    try {
      await profileService.upsertIdentity(
        userId: user.id,
        prenom: result.prenom,
        nom: result.nom,
      );
      _invalidateProfile();
      if (mounted) _showSnack(ShellStrings.profileSaveOk);
    } catch (_) {
      if (mounted) _showSnack(ShellStrings.profileSaveErr);
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
      if (mounted) _showSnack(e.message);
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
        _showSnack(ShellStrings.profileSaveErr);
      }
      return;
    }

    final isOnline = await ref.read(connectivityServiceProvider).isOnline();
    if (!isOnline) {
      if (mounted) {
        setState(() {
          _savingPhoto = false;
          _avatarPreviewBytes = null;
        });
        _showSnack(ShellStrings.profileSaveErr);
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
        _showSnack(ShellStrings.profileSaveOk);
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _savingPhoto = false;
          _avatarPreviewBytes = null;
        });
        _showSnack(ShellStrings.profileSaveErr);
      }
    }
  }

  void _showSnack(String message) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authSnapshot = ref.watch(authNotifierProvider);
    final user = switch (authSnapshot) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final profileAsync = ref.watch(currentUserProfileProvider);
    final rolesAsync = ref.watch(myRolesProvider);
    final versionAsync = ref.watch(appVersionProvider);

    final profile = switch (profileAsync) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final roles = switch (rolesAsync) {
      AsyncData(:final value) => value,
      _ => const <UserRole>[],
    };

    final email = user?.email?.trim() ?? '';
    final displayName = profileDisplayName(profile: profile, email: email);
    final rolesLabel = profileRolesLabel(roles);
    final loadingProfile = profileAsync.isLoading && profile == null;

    return Scaffold(
      appBar: AppBar(title: const Text(DiscNav.profileTitle)),
      body: ListView(
        children: [
          if (loadingProfile)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(child: CircularProgressIndicator()),
            )
          else
            ProfileAccountHeader(
              profile: profile,
              displayName: displayName,
              email: email,
              rolesLabel: rolesLabel,
              avatarBytes: _avatarPreviewBytes,
              photoLoading: _savingPhoto,
              onEditPhoto: _savingPhoto ? null : _pickAndUploadPhoto,
              onEditName: _savingName ? null : () => _editName(profile),
            ),
          if (_savingName)
            const LinearProgressIndicator(minHeight: 2),
          const Divider(height: 24),
          const RoleSwitchSection(sectionTitle: DiscNav.profileSpace),
          ListTile(
            leading: Icon(
              Icons.event_available_outlined,
              color: theme.colorScheme.primary,
            ),
            title: Text(DiscNav.myReservationsTitle),
            subtitle: Text(
              DiscNav.profileResHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            trailing: Icon(
              Icons.chevron_right,
              color: theme.colorScheme.outline,
            ),
            onTap: () => context.goMyReservations(),
          ),
          const Divider(height: 1),
          ListTile(
            leading: Icon(Icons.logout, color: theme.colorScheme.error),
            title: Text(
              ShellStrings.accountActionSignOut,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            onTap: _confirmSignOut,
          ),
          const SizedBox(height: 24),
          versionAsync.when(
            data: (version) => Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 32),
              child: Text(
                '${ShellStrings.profileVersionLabel} $version',
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
            loading: () => const SizedBox(height: 48),
            error: (_, __) => const SizedBox(height: 48),
          ),
        ],
      ),
    );
  }
}
