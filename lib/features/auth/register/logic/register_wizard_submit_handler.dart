import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/failure_mapper.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/supabase_service_exception.dart';
import '../../../../core/models/user_role.dart';
import '../../../profile/logic/become_prestataire_draft.dart';
import '../../../profile/storage/become_prestataire_draft_store.dart';
import '../../../prestataire/navigation/prestataire_navigation.dart';
import '../../../../router/navigation_extensions.dart';
import '../../logic/auth_role_cache.dart';
import '../../../../services/auth/post_signup_profile_service.dart';
import '../../../../services/auth/role_service.dart';
import '../../../../services/offline/offline_actions.dart';
import '../../../../services/storage/local_cache_service.dart';
import '../../../../services/supabase/profile/profile_providers.dart';
import '../../../../services/supabase/storage/storage_providers.dart';
import '../../../../services/supabase/storage/storage_service.dart';
import '../../../../shared/utils/phone_number_utils.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/my_roles_provider.dart';
import '../../widgets/auth_success_dialog.dart';
import '../logic/register_wizard_role_intent.dart';
import '../providers/register_wizard_form_controller.dart';
import '../storage/register_pending_password_store.dart';
import '../storage/register_wizard_draft_store.dart';

/// Soumission finale de l'inscription wizard.
class RegisterWizardSubmitHandler {
  static bool _finalizeInFlight = false;

  Future<void> _persistPrestaBecomeDraftFromForm(
    RegisterWizardFormController form,
  ) async {
    final address = form.postalAddress;
    await BecomePrestataireDraftStore.instance.save(
      BecomePrestataireDraft(
        salon: form.salon.text.trim(),
        ville: address.ville.trim(),
        bio: form.bio.text.trim(),
        codePostal: address.codePostal.trim(),
        nomAffiche: form.nomAffiche.text.trim(),
        description: form.description.text.trim(),
        adresse: address.streetLine,
        voieType: address.voieType,
        voieNom: address.voieNom,
        numeroRue: address.numero,
        pays: address.pays,
        step1Submitted: true,
        step2Started: true,
      ),
    );
  }

  Future<void> submit({
    required WidgetRef ref,
    required BuildContext context,
    required bool Function() mounted,
    required RegisterWizardFormController form,
  }) async {
    FocusScope.of(context).unfocus();
    form.setError(null);

    if (!await ensureOnline(context, ref)) return;

    if (!AppConfig.hasSupabase) {
      form.setError(ShellStrings.supabaseMissingTitle);
      return;
    }

    if (!form.validateExtrasStep()) return;

    form.setLoading(true);

    if (!mounted()) return;
    final providerContainer = ProviderScope.containerOf(context);

    try {
      final prenom = form.prenom.text.trim();
      final nom = form.nom.text.trim();
      final email = form.email.text.trim();
      final phoneStored = PhoneNumberUtils.toStored(
        dialCode: form.phoneDialCode,
        local: form.phone.text,
      );
      final phone = phoneStored.isEmpty ? null : phoneStored;

      var sessionUser = providerContainer
          .read(authServiceProvider)
          .currentSession
          ?.user;

      if (!form.signedUpViaOAuth) {
        final hasActiveSession = sessionUser != null &&
            sessionUser.email?.trim().toLowerCase() == email.toLowerCase();

        if (!hasActiveSession) {
          await providerContainer
              .read(authNotifierProvider.notifier)
              .signUpWithPassword(
                email: email,
                password: form.password.text,
                displayName: '$prenom $nom'.trim(),
                prenom: prenom,
                nom: nom,
                phone: phone,
              );

          if (!mounted()) return;

          sessionUser = providerContainer
              .read(authServiceProvider)
              .currentSession
              ?.user;
        }

        if (sessionUser == null) {
          if (form.roleChoice != null) {
            await RegisterWizardRoleIntent.persist(form.roleChoice!);
          }
          if (form.roleChoice == UserRole.prestataire) {
            await LocalCacheService.instance.setSelectedRole('prestataire');
            await LocalCacheService.instance.setSignupShellRole('prestataire');
            await _persistPrestaBecomeDraftFromForm(form);
          }
          await RegisterPendingPasswordStore.instance.save(
            email: email,
            password: form.password.text,
          );
          form.persistDraftOnDispose = false;
          form.saveDebounce?.cancel();
          form.clearPasswordFields();
          await form.persistDraft(pendingEmailVerification: true);
          if (!mounted()) return;
          form.setLoading(false);
          context.goRegisterVerifyEmail(email);
          return;
        }
      } else {
        sessionUser ??=
            providerContainer.read(authServiceProvider).currentSession?.user;
        if (sessionUser == null) {
          form.setLoading(false);
          form.setError(AuthStrings.loginGoogleStarted);
          return;
        }
      }

      await completeRegistrationAfterAuth(
        context: context,
        mounted: mounted,
        form: form,
        session: sessionUser,
        prenom: prenom,
        nom: nom,
        phone: phone,
        providerContainer: providerContainer,
      );
    } on AppFailure catch (e) {
      debugPrint(
        '[RegisterWizard] submit AppFailure: ${e.message} cause=${e.cause}',
      );
      form.pendingEmailVerification = false;
      unawaited(form.persistDraft(pendingEmailVerification: false));
      if (mounted()) {
        form.setLoading(false);
        form.setError(e.message);
      }
    } catch (e, st) {
      debugPrint('[RegisterWizard] submit unexpected: $e');
      debugPrintStack(stackTrace: st);
      form.pendingEmailVerification = false;
      unawaited(form.persistDraft(pendingEmailVerification: false));
      if (mounted()) {
        form.setLoading(false);
        form.setError(CoreStrings.errorUnexpected);
      }
    }
  }

  Future<void> completeRegistrationAfterAuth({
    required BuildContext context,
    required bool Function() mounted,
    required RegisterWizardFormController form,
    required User session,
    required String prenom,
    required String nom,
    String? phone,
    required ProviderContainer providerContainer,
  }) async {
    final uid = session.id;
    final post = PostSignupProfileService.fromEnv();
    final shellRole = form.roleChoice == UserRole.prestataire
        ? 'prestataire'
        : 'client';

    await LocalCacheService.instance.setSelectedRole(shellRole);
    await LocalCacheService.instance.setSignupShellRole(shellRole);

    await post.updateUserIdentity(
      userId: uid,
      prenom: prenom,
      nom: nom,
      phone: phone,
    );

    if (!mounted()) return;

    if (form.roleChoice == UserRole.prestataire) {
      await syncRoleBestEffort(UserRole.prestataire, providerContainer);
      await removeClientRoleBestEffort(providerContainer);
      final address = form.postalAddress;
      await post.updatePrestataireExtras(
        userId: uid,
        nomSalon: form.salon.text.trim(),
        nomAffiche: form.nomAffiche.text.trim().isEmpty
            ? form.salon.text.trim()
            : form.nomAffiche.text.trim(),
        ville: address.ville.trim(),
        codePostal: address.codePostal.trim().isEmpty
            ? null
            : address.codePostal.trim(),
        pays: address.pays.trim().isEmpty ? null : address.pays.trim(),
        description: form.description.text.trim().isEmpty
            ? null
            : form.description.text.trim(),
        bio: form.bio.text.trim(),
        adresse: address.streetLine.isEmpty ? null : address.streetLine,
      );
      await _persistPrestaBecomeDraftFromForm(form);
    } else {
      await syncRoleBestEffort(UserRole.client, providerContainer);
      final formatted = form.postalAddress.formattedLine;
      await post.updateClientExtras(
        userId: uid,
        adresse: formatted.isEmpty ? null : formatted,
      );
      await _saveClientAvatar(form, uid, providerContainer);
    }

    await LocalCacheService.instance.setSelectedRole(shellRole);
    form.persistDraftOnDispose = false;
    form.saveDebounce?.cancel();
    await form.clearDraft();
    await RegisterPendingPasswordStore.instance.clear();

    if (!mounted()) return;
    form.setLoading(false);

    await AuthSuccessDialog.show(
      context,
      title: AuthStrings.registerSuccessTitle,
      body: AuthStrings.registerSuccessBody,
      actionLabel: AuthStrings.registerSuccessCta,
    );
    if (!mounted()) return;

    if (form.roleChoice == UserRole.prestataire) {
      if (!mounted()) return;
      await PrestataireNavigation.afterPrestaRegistration(
        context,
        providerContainer,
      );
    } else {
      context.goHome();
    }
  }

  Future<void> _saveClientAvatar(
    RegisterWizardFormController form,
    String userId,
    ProviderContainer container,
  ) async {
    if (!form.hasClientAvatar) return;

    final profileService = container.read(profileServiceProvider);
    if (profileService == null) return;

    final bytes = form.clientAvatarBytes;
    if (bytes != null) {
      final storage = container.read(storageServiceProvider);
      if (storage == null) return;
      final url = await storage.uploadAvatar(
        userId: userId,
        file: StorageUploadFile(
          bytes: bytes,
          fileName: form.clientAvatarFileName ?? 'avatar.jpg',
          mimeType: form.clientAvatarMimeType ?? 'image/jpeg',
        ),
      );
      await profileService.upsertAvatar(userId: userId, avatarUrl: url);
      return;
    }

    final defaultUrl = form.clientDefaultAvatarUrl?.trim();
    if (defaultUrl != null && defaultUrl.isNotEmpty) {
      await profileService.upsertAvatar(userId: userId, avatarUrl: defaultUrl);
    }
  }

  Future<void> syncRoleBestEffort(
    UserRole role,
    ProviderContainer container,
  ) async {
    if (!AppConfig.hasSupabase) return;
    final rolesService = RoleService.fromEnv();
    try {
      await rolesService.ensureRole(role);
      final serverRoles = await rolesService.getMyRoles();
      await AuthRoleCache.persistServerRoles(serverRoles);
      container.invalidate(myRolesProvider);
    } catch (e) {
      if (!_isRoleSyncForbidden(e)) rethrow;
    }
  }

  Future<void> removeClientRoleBestEffort(ProviderContainer container) async {
    if (!AppConfig.hasSupabase) return;
    final rolesService = RoleService.fromEnv();
    try {
      await rolesService.removeRole(UserRole.client);
      final serverRoles = await rolesService.getMyRoles();
      await AuthRoleCache.persistServerRoles(serverRoles);
      container.invalidate(myRolesProvider);
    } catch (e) {
      if (!_isRoleSyncForbidden(e)) rethrow;
    }
  }

  Future<bool> finalizePendingRegistrationFromDraft({
    required BuildContext context,
    required bool Function() mounted,
    required WidgetRef ref,
    required User session,
  }) async {
    if (_finalizeInFlight) return false;
    _finalizeInFlight = true;

    try {
      final draft = RegisterWizardDraftStore.instance.read();
      if (draft == null) {
        if (mounted()) context.goRegisterResume();
        return false;
      }

      await RegisterWizardRoleIntent.persistFromDraft(draft);

      final form = RegisterWizardFormController();
      form.persistDraftOnDispose = false;
      form.applyDraft(draft);
      form.pendingEmailVerification = false;

      final prenom = draft.prenom.trim();
      final nom = draft.nom.trim();
      final phoneStored = PhoneNumberUtils.toStored(
        dialCode: draft.phoneDialCode,
        local: draft.phone,
      );
      final phone = phoneStored.isEmpty ? null : phoneStored;

      await completeRegistrationAfterAuth(
        context: context,
        mounted: mounted,
        form: form,
        session: session,
        prenom: prenom,
        nom: nom,
        phone: phone,
        providerContainer: ProviderScope.containerOf(context),
      );
      form.dispose();
      return true;
    } finally {
      _finalizeInFlight = false;
    }
  }

  Future<User?> resolveVerifiedUser({
    required WidgetRef ref,
    required String email,
  }) async {
    final authService = ref.read(authServiceProvider);
    final normalized = email.trim();

    var user = authService.currentSession?.user ??
        ref.read(authNotifierProvider).value;
    if (user != null) return user;

    try {
      await authService.refreshSession();
    } catch (_) {}

    user = authService.currentSession?.user ??
        ref.read(authNotifierProvider).value;
    if (user != null) return user;

    final password =
        RegisterPendingPasswordStore.instance.readForEmail(normalized);
    if (password == null || password.isEmpty) return null;

    try {
      return await ref.read(authNotifierProvider.notifier).signInWithPassword(
            email: normalized,
            password: password,
          );
    } on AppFailure catch (e) {
      if (_isEmailNotConfirmedFailure(e)) return null;
      rethrow;
    }
  }

  bool _isEmailNotConfirmedFailure(AppFailure failure) {
    final cause = failure.cause;
    if (cause is AuthException) {
      return FailureMapper.fromAuthException(cause).message ==
          AuthStrings.authEmailNotConfirmed;
    }
    return failure.message == AuthStrings.authEmailNotConfirmed;
  }

  bool _isRoleSyncForbidden(Object error) {
    if (error is SupabaseServiceException) {
      return error.code == '42501' ||
          error.message == AuthStrings.roleChoiceSyncForbidden;
    }
    if (error is AppFailure) {
      return error.message == AuthStrings.roleChoiceSyncForbidden;
    }
    return false;
  }
}
