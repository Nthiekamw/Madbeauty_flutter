import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/supabase_service_exception.dart';
import '../../../../core/models/user_role.dart';
import '../../../profile/logic/become_prestataire_draft.dart';
import '../../../profile/storage/become_prestataire_draft_store.dart';
import '../../../prestataire/navigation/prestataire_navigation.dart';
import '../../../../router/navigation_extensions.dart';
import '../../logic/auth_role_cache.dart';
import '../../phone_otp/models/phone_otp_flow.dart';
import '../../phone_otp/providers/phone_otp_verification_controller.dart';
import '../../../../services/auth/post_signup_profile_service.dart';
import '../../../../services/auth/role_service.dart';
import '../../../../services/offline/offline_actions.dart';
import '../../../../services/storage/local_cache_service.dart';
import '../../../../shared/utils/phone_number_utils.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/my_roles_provider.dart';
import '../../widgets/auth_success_dialog.dart';
import '../providers/register_wizard_form_controller.dart';

/// Soumission finale et OTP téléphone pour l'inscription wizard.
class RegisterWizardSubmitHandler {
  Future<void> sendRegisterPhoneOtp({
    required WidgetRef ref,
    required BuildContext context,
    required bool Function() mounted,
    required RegisterWizardFormController form,
    required Future<void> Function() onSubmit,
  }) async {
    if (!await ensureOnline(context, ref)) return;

    form.setLoading(true);
    form.setError(null);

    try {
      final pending = await ref.read(authNotifierProvider.notifier).sendPhoneOtp(
            phoneE164: form.phoneE164,
            shouldCreateUser: true,
          );
      if (!mounted()) return;

      if (pending.autoVerified) {
        await updatePhoneSignupMetadata(ref: ref, form: form);
        if (!mounted()) return;
        form.signedUpViaPhone = true;
        form.pendingPhoneVerification = false;
        form.setLoading(false);
        AppSnackBar.success(context, AuthStrings.registerPhoneVerified);
        await form.persistDraft(
          signedUpViaPhone: true,
          pendingPhoneVerification: false,
        );
        if (!mounted()) return;
        unawaited(onSubmit());
        return;
      }

      ref.read(phoneOtpVerificationControllerProvider.notifier).beginSession(
            flow: PhoneOtpFlow.register,
            phoneE164: form.phoneE164,
            pending: pending,
          );
      form.setLoading(false);
      form.pendingPhoneVerification = true;
      await form.persistDraft(pendingPhoneVerification: true);
      if (!mounted()) return;
      AppSnackBar.info(context, AuthStrings.loginOtpSentSms);
      context.pushVerifyPhone(
        flow: PhoneOtpFlow.register.queryValue,
        phone: form.phoneE164,
      );
    } on AppFailure catch (e) {
      if (mounted()) {
        form.setLoading(false);
        form.setError(e.message);
      }
    } catch (_) {
      if (mounted()) {
        form.setLoading(false);
        form.setError(CoreStrings.errorUnexpected);
      }
    }
  }

  Future<void> updatePhoneSignupMetadata({
    required WidgetRef ref,
    required RegisterWizardFormController form,
  }) async {
    final prenom = form.prenom.text.trim();
    final nom = form.nom.text.trim();
    final phoneStored = PhoneNumberUtils.toStored(
      dialCode: form.phoneDialCode,
      local: form.phone.text,
    );
    await ref.read(authServiceProvider).updateUser(
          UserAttributes(
            data: <String, dynamic>{
              'full_name': '$prenom $nom'.trim(),
              if (prenom.isNotEmpty) 'prenom': prenom,
              if (nom.isNotEmpty) 'nom': nom,
              if (phoneStored.isNotEmpty) 'phone': phoneStored,
            },
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

    if (form.usePhoneSignUp &&
        !form.signedUpViaOAuth &&
        !form.signedUpViaPhone) {
      unawaited(sendRegisterPhoneOtp(
        ref: ref,
        context: context,
        mounted: mounted,
        form: form,
        onSubmit: () => submit(
          ref: ref,
          context: context,
          mounted: mounted,
          form: form,
        ),
      ));
      return;
    }

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

      if (!form.signedUpViaOAuth && !form.signedUpViaPhone) {
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
          await form.persistDraft(pendingEmailVerification: true);
          if (!mounted()) return;
          form.setLoading(false);
          context.goRegisterVerifyEmail(email);
          return;
        }
      } else if (form.signedUpViaPhone) {
        sessionUser ??=
            providerContainer.read(authServiceProvider).currentSession?.user;
        if (sessionUser == null) {
          form.setLoading(false);
          form.setError(AuthStrings.authPhoneOtpSessionExpired);
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
      await post.updatePrestataireExtras(
        userId: uid,
        nomSalon: form.salon.text.trim(),
        nomAffiche: form.nomAffiche.text.trim().isEmpty
            ? form.salon.text.trim()
            : form.nomAffiche.text.trim(),
        ville: form.ville.text.trim(),
        codePostal: form.codePostal.text.trim().isEmpty
            ? null
            : form.codePostal.text.trim(),
        description: form.description.text.trim().isEmpty
            ? null
            : form.description.text.trim(),
        bio: form.bio.text.trim(),
        adresse: form.adresse.text.trim().isEmpty
            ? null
            : form.adresse.text.trim(),
      );
    } else {
      await syncRoleBestEffort(UserRole.client, providerContainer);
      await post.updateClientExtras(
        userId: uid,
        adresse: form.adresse.text.trim().isEmpty
            ? null
            : form.adresse.text.trim(),
      );
    }

    await LocalCacheService.instance.setSelectedRole(shellRole);
    form.persistDraftOnDispose = false;
    form.saveDebounce?.cancel();
    await form.clearDraft();

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
      await BecomePrestataireDraftStore.instance.save(
        BecomePrestataireDraft(
          salon: form.salon.text.trim(),
          ville: form.ville.text.trim(),
          bio: form.bio.text.trim(),
          codePostal: form.codePostal.text.trim(),
          nomAffiche: form.nomAffiche.text.trim(),
          description: form.description.text.trim(),
          adresse: form.adresse.text.trim(),
          step1Submitted: true,
          step2Started: true,
        ),
      );
      if (!mounted()) return;
      await PrestataireNavigation.afterPrestaRegistration(
        context,
        providerContainer,
      );
    } else {
      context.goHome();
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
