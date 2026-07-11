import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/models/domain/user/user_profile.dart';
import '../../support/navigation/user_support_navigation.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../../../services/supabase/storage/storage_providers.dart';
import '../../../services/offline/offline_actions.dart';
import '../../../services/supabase/profile/profile_providers.dart';
import '../../../shared/widgets/discovery/content/discovery_shimmer.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery/discovery_constrained_body.dart';
import '../../client/widgets/workspace/client_workspace_shell.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/guest/widgets/guest_account_prompt.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../auth/providers/my_roles_provider.dart';
import '../../../core/models/user_role.dart';
import '../widgets/sections/profile_role_space_section.dart';
import '../../home/providers/home_profile_provider.dart';
import '../logic/account_deletion_flow.dart';
import '../logic/profile_display.dart';
import '../providers/app_version_provider.dart';
import '../providers/current_user_profile_provider.dart';
import '../widgets/account/edit_profile_name_dialog.dart';
import '../../../services/supabase/referral/referral_providers.dart';
import '../widgets/account/profile_account_header.dart';
import '../widgets/account/profile_account_section.dart';
import '../widgets/sections/profile_admin_section.dart';
import '../widgets/layout/profile_footer_actions.dart';
import '../widgets/sections/profile_my_info_section.dart';
import '../widgets/layout/profile_page_insets.dart';
import '../widgets/sections/profile_appearance_section.dart';
import '../widgets/sections/profile_favorites_section.dart';
import '../widgets/sections/profile_preferences_section.dart';
import '../widgets/sections/profile_pwa_install_section.dart';

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
    await runAccountDeletionRequestFlow(context: context, ref: ref);
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
      if (DiscoveryResponsive.of(context).useWebSiteLayout) {
        return ClientWorkspaceShell(
          title: ShellStrings.navClientProfile,
          subtitle: DiscProfile.webPageSubtitle,
          child: GuestAccountPrompt(
            icon: Icons.person_outline,
            title: AuthStrings.guestProfileTitle,
            message: AuthStrings.guestProfileBody,
          ),
        );
      }
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
    final isAmbassador = ref
        .watch(myReferralInfoProvider)
        .maybeWhen(data: (i) => i?.isAmbassador ?? false, orElse: () => false);
    final isAdmin = ref
        .watch(myRolesProvider)
        .maybeWhen(
          data: (roles) => roles.contains(UserRole.admin),
          orElse: () => false,
        );

    final useWebLayout = DiscoveryResponsive.of(context).useWebSiteLayout;
    final pagePadding = useWebLayout
        ? const EdgeInsets.fromLTRB(20, 20, 20, 0)
        : ProfilePageInsets.page(context);

    final profileSections = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (loadingProfile)
          DiscoveryShimmer.wrap(
            context: context,
            child: Row(
              children: [
                Container(
                  width: 72,
                  height: 72,
                  decoration: BoxDecoration(
                    color: DiscoveryShimmer.colors(
                      Theme.of(context),
                    ).track,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        height: 18,
                        width: 140,
                        decoration: BoxDecoration(
                          color: DiscoveryShimmer.colors(
                            Theme.of(context),
                          ).track,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(
                        height: 14,
                        width: 200,
                        decoration: BoxDecoration(
                          color: DiscoveryShimmer.colors(
                            Theme.of(context),
                          ).track,
                          borderRadius: BorderRadius.circular(6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )
        else
          ProfileAccountHeader(
            profile: profile,
            displayName: displayName,
            email: email,
            avatarBytes: _avatarPreviewBytes,
            photoLoading: _savingPhoto,
            showAmbassadorBadge: isAmbassador,
            showAdminBadge: isAdmin,
            onEditPhoto: _savingPhoto ? null : _pickAndUploadPhoto,
            onEditName: _savingName ? null : () => _editName(profile),
          ),
        if (_savingName) ...[
          const SizedBox(height: 8),
          const LinearProgressIndicator(minHeight: 2),
        ],
        const SizedBox(height: ProfilePageInsets.sectionGap),
        const ProfileRoleSpaceSection(),
        if (!loadingProfile) ...[
          const SizedBox(height: ProfilePageInsets.sectionGap),
          ProfileMyInfoSection(email: email, phone: phone),
        ],
        const SizedBox(height: ProfilePageInsets.sectionGap),
        const ProfileFavoritesSection(),
        const SizedBox(height: ProfilePageInsets.sectionGap),
        const ProfileAppearanceSection(),
        const SizedBox(height: ProfilePageInsets.sectionGap),
        const ProfilePreferencesSection(),
        const SizedBox(height: ProfilePageInsets.sectionGap),
        const ProfilePwaInstallSection(),
        const SizedBox(height: ProfilePageInsets.sectionGap),
        const ProfileAdminSection(),
        const ProfileAccountSection(),
        const SizedBox(height: ProfilePageInsets.sectionGap),
        ProfileFooterActions(
          onSupportUser: () => openUserSupportChat(context, ref),
          onSignOut: _signOut,
          onDeleteAccount: _confirmDeleteAccount,
        ),
        const SizedBox(height: ProfilePageInsets.sectionGap),
        versionAsync.when(
          data: (version) => Text(
            '${ShellStrings.profileVersionLabel} $version',
            textAlign: TextAlign.center,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          loading: () => const SizedBox(height: 8),
          error: (_, __) => const SizedBox(height: 8),
        ),
      ],
    );

    final profileBody = ListView(
      padding: const EdgeInsets.only(bottom: 32),
      children: [
        Padding(
          padding: pagePadding,
          child: useWebLayout
              ? profileSections
              : DiscoveryConstrainedBody(child: profileSections),
        ),
      ],
    );

    if (useWebLayout) {
      return ClientWorkspaceShell(
        title: ShellStrings.navClientProfile,
        subtitle: DiscProfile.webPageSubtitle,
        child: profileBody,
      );
    }

    return DiscoveryBrandScaffold(body: profileBody);
  }
}

