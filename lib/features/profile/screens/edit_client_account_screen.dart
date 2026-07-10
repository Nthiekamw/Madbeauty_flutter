import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/logic/address/postal_address.dart';
import '../../../core/models/domain/user/client_profile.dart';
import '../../../core/models/domain/user/user_profile.dart';
import '../../../services/offline/offline_actions.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../../../services/supabase/storage/storage_providers.dart';
import '../../../services/supabase/profile/client_profile_providers.dart';
import '../../../services/supabase/profile/profile_providers.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/layout/web_flow_panel.dart';
import '../../../shared/layout/web_flow_scaffold.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/utils/phone_number_utils.dart';
import '../../../shared/widgets/app/app_button.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_detail_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_form_scroll_view.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../auth/register/logic/register_validators.dart';
import '../../home/providers/home_profile_provider.dart';
import '../logic/profile_display.dart';
import '../providers/current_user_profile_provider.dart';
import '../widgets/account/edit_client_account_avatar_section.dart';
import '../widgets/account/edit_client_account_form.dart';

class EditClientAccountScreen extends ConsumerStatefulWidget {
  const EditClientAccountScreen({super.key});

  @override
  ConsumerState<EditClientAccountScreen> createState() =>
      _EditClientAccountScreenState();
}

class _EditClientAccountScreenState extends ConsumerState<EditClientAccountScreen> {
  final _prenom = TextEditingController();
  final _nom = TextEditingController();
  final _phone = TextEditingController();
  final _voieNom = TextEditingController();
  final _numeroRue = TextEditingController();
  final _codePostal = TextEditingController();
  final _city = TextEditingController();
  final _country = TextEditingController(text: PostalAddress.defaultCountry);

  String _phoneDialCode = '+33';
  String _voieType = PostalVoieTypes.defaultType;
  bool _bound = false;
  bool _saving = false;
  bool _savingPhoto = false;
  String? _error;
  String? _prenomError;
  String? _nomError;
  String? _phoneError;
  Uint8List? _avatarPreviewBytes;

  @override
  void dispose() {
    _prenom.dispose();
    _nom.dispose();
    _phone.dispose();
    _voieNom.dispose();
    _numeroRue.dispose();
    _codePostal.dispose();
    _city.dispose();
    _country.dispose();
    super.dispose();
  }

  PostalAddress get _postalAddress => PostalAddress(
    voieType: _voieType,
    voieNom: _voieNom.text,
    numero: _numeroRue.text,
    codePostal: _codePostal.text,
    ville: _city.text,
    pays: _country.text,
  );

  void _bindFields(UserProfile? profile, ClientProfile? client) {
    if (_bound) return;
    _prenom.text = profile?.prenom?.trim() ?? '';
    _nom.text = profile?.nom?.trim() ?? '';
    final parsed = PhoneNumberUtils.parseStored(profile?.telephone);
    _phoneDialCode = parsed.dialCode;
    _phone.text = parsed.local;
    final address = (client?.voieNom?.trim().isNotEmpty ?? false) ||
            (client?.codePostal?.trim().isNotEmpty ?? false) ||
            (client?.ville?.trim().isNotEmpty ?? false)
        ? PostalAddress(
            voieType: client?.voieType?.trim().isNotEmpty == true
                ? client!.voieType!.trim()
                : PostalVoieTypes.defaultType,
            voieNom: client?.voieNom?.trim() ?? '',
            numero: client?.numeroRue?.trim() ?? '',
            codePostal: client?.codePostal?.trim() ?? '',
            ville: client?.ville?.trim() ?? '',
            pays: client?.pays?.trim().isNotEmpty == true
                ? client!.pays!.trim()
                : PostalAddress.defaultCountry,
          )
        : PostalAddress.tryParse(client?.adresse);
    _voieType = address.voieType;
    _voieNom.text = address.voieNom;
    _numeroRue.text = address.numero;
    _codePostal.text = address.codePostal;
    _city.text = address.ville;
    _country.text =
        address.pays.isEmpty ? PostalAddress.defaultCountry : address.pays;
    _bound = true;
  }

  void _invalidateProfile() {
    ref.invalidate(currentUserProfileProvider);
    ref.invalidate(currentClientProfileProvider);
    ref.invalidate(homeProfileSnapshotProvider);
  }

  bool _validate() {
    final prenom = _prenom.text.trim();
    final nom = _nom.text.trim();
    final prenomErr = prenom.isEmpty && nom.isEmpty
        ? DiscProfile.editAccountNameRequired
        : null;
    final phoneLocal = _phone.text.trim();
    final phoneErr = phoneLocal.isEmpty
        ? null
        : RegisterValidators.phoneLocal(phoneLocal, dialCode: _phoneDialCode);
    setState(() {
      _prenomError = prenomErr;
      _nomError = prenomErr;
      _phoneError = phoneErr;
      _error = null;
    });
    return prenomErr == null && phoneErr == null;
  }

  Future<void> _save() async {
    FocusScope.of(context).unfocus();
    if (!_validate()) return;

    final user = ref.read(authNotifierProvider).value;
    if (user == null) return;

    final profileService = ref.read(profileServiceProvider);
    final clientService = ref.read(clientProfileServiceProvider);
    if (profileService == null || clientService == null) {
      setState(() => _error = DiscProfile.editAccountError);
      return;
    }

    if (!await ensureOnline(context, ref)) return;

    setState(() {
      _saving = true;
      _error = null;
    });

    try {
      final phoneStored = PhoneNumberUtils.toStored(
        dialCode: _phoneDialCode,
        local: _phone.text,
      );
      await profileService.upsertClientDetails(
        userId: user.id,
        prenom: _prenom.text.trim(),
        nom: _nom.text.trim(),
        telephone: phoneStored.isEmpty ? null : phoneStored,
      );
      await clientService.updateAddress(
        userId: user.id,
        address: _postalAddress,
      );
      _invalidateProfile();
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: DiscProfile.editAccountSaved,
        kind: AppSnackKind.success,
      );
      context.pop();
    } on AppFailure catch (e) {
      if (mounted) setState(() => _error = e.message);
    } catch (_) {
      if (mounted) setState(() => _error = DiscProfile.editAccountError);
    } finally {
      if (mounted) setState(() => _saving = false);
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
      if (mounted) {
        AppSnackBar.show(context, message: e.message, kind: AppSnackKind.error);
      }
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
        AppSnackBar.show(
          context,
          message: DiscProfile.editAccountError,
          kind: AppSnackKind.error,
        );
      }
      return;
    }

    if (!mounted) return;
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
      final url = await storage.uploadAvatar(userId: user.id, file: uploadFile);
      await profileService.upsertAvatar(userId: user.id, avatarUrl: url);
      _invalidateProfile();
      if (mounted) {
        setState(() {
          _savingPhoto = false;
          _avatarPreviewBytes = null;
        });
        AppSnackBar.show(
          context,
          message: ShellStrings.profileSaveOk,
          kind: AppSnackKind.success,
        );
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _savingPhoto = false;
          _avatarPreviewBytes = null;
        });
        AppSnackBar.show(
          context,
          message: ShellStrings.profileSaveErr,
          kind: AppSnackKind.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final user = switch (ref.watch(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final profileAsync = ref.watch(currentUserProfileProvider);
    final clientAsync = ref.watch(currentClientProfileProvider);

    final email = user?.email?.trim() ?? '';
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;

    final body = profileAsync.when(
      loading: () => const DiscoveryDetailSkeleton(),
      error: (_, __) => DiscoveryEmptyState(
        icon: Icons.cloud_off_outlined,
        title: CoreStrings.networkErrorTitle,
        body: CoreStrings.networkErrorBody,
        iconColor: Theme.of(context).colorScheme.error,
        actionLabel: DiscList.retry,
        onAction: () => ref.invalidate(currentUserProfileProvider),
      ),
      data: (profile) => clientAsync.when(
        loading: () => const DiscoveryDetailSkeleton(),
        error: (_, __) => DiscoveryEmptyState(
          icon: Icons.cloud_off_outlined,
          title: CoreStrings.networkErrorTitle,
          body: CoreStrings.networkErrorBody,
          iconColor: Theme.of(context).colorScheme.error,
          actionLabel: DiscList.retry,
          onAction: () => ref.invalidate(currentClientProfileProvider),
        ),
        data: (client) {
          _bindFields(profile, client);
          final displayName =
              profileDisplayName(profile: profile, email: email);

          final layout = DiscoveryResponsive.of(context);
          return DiscoveryFormScrollView(
            padding: EdgeInsets.fromLTRB(
              useWeb ? 20 : layout.horizontalPadding,
              useWeb ? 16 : 8,
              useWeb ? 20 : layout.horizontalPadding,
              20,
            ),
            children: [
              if (!useWeb)
                Row(
                  children: [
                    IconButton(
                      onPressed: _saving ? null : () => context.pop(),
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Text(
                        DiscProfile.editAccountTitle,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              if (!useWeb)
                Text(
                  DiscProfile.editAccountSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              if (!useWeb) const SizedBox(height: 20),
              if (useWeb)
                Text(
                  DiscProfile.editAccountSubtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.35,
                  ),
                ),
              if (useWeb) const SizedBox(height: 16),
              EditClientAccountAvatarSection(
                displayName: displayName,
                email: email,
                profile: profile,
                avatarBytes: _avatarPreviewBytes,
                loading: _savingPhoto,
                onChangePhoto: _savingPhoto ? null : _pickAndUploadPhoto,
              ),
              const SizedBox(height: 12),
              DiscoverySurfaceCard(
                padding: const EdgeInsets.all(12),
                includeHorizontalMargin: !useWeb,
                child: EditClientAccountForm(
                  prenomController: _prenom,
                  nomController: _nom,
                  phoneController: _phone,
                  phoneDialCode: _phoneDialCode,
                  phoneError: _phoneError,
                  onPhoneDialCodeChanged: (code) {
                    setState(() {
                      _phoneDialCode = code;
                      _phoneError = null;
                    });
                  },
                  onPhoneChanged: () {
                    if (_phoneError != null) {
                      setState(() => _phoneError = null);
                    }
                  },
                  voieType: _voieType,
                  onVoieTypeChanged: (value) {
                    setState(() => _voieType = value);
                  },
                  voieNomController: _voieNom,
                  numeroController: _numeroRue,
                  codePostalController: _codePostal,
                  cityController: _city,
                  countryController: _country,
                  onAddressChanged: () => setState(() {}),
                  email: email,
                  prenomError: _prenomError,
                  nomError: _nomError,
                  errorText: _error,
                ),
              ),
              const SizedBox(height: 16),
              AppButton(
                onPressed: _saving ? null : _save,
                isLoading: _saving,
                child: Text(DiscProfile.editAccountSave),
              ),
            ],
          );
        },
      ),
    );

    if (useWeb) {
      return WebFlowScaffold(
        appBar: AppBar(title: const Text(DiscProfile.editAccountTitle)),
        body: WebFlowPanel(child: body),
      );
    }

    return DiscoveryBrandScaffold(body: body);
  }
}

