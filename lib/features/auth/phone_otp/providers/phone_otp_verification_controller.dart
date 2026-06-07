import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../services/auth/phone_auth_service.dart';
import '../../../../shared/utils/phone_number_utils.dart';
import '../../login/logic/login_validators.dart';
import '../../providers/auth_notifier.dart';
import '../../register/logic/register_wizard_draft.dart';
import '../../register/storage/register_wizard_draft_store.dart';
import '../models/phone_otp_flow.dart';

final phoneOtpVerificationControllerProvider =
    NotifierProvider<PhoneOtpVerificationController, PhoneOtpVerificationState>(
  PhoneOtpVerificationController.new,
);

class PhoneOtpVerificationState {
  const PhoneOtpVerificationState({
    this.flow,
    this.phoneE164,
    this.pending,
    this.otpError,
    this.submitError,
    this.infoMessage,
    this.isBusy = false,
    this.isResending = false,
    this.loginSucceeded = false,
    this.registerSucceeded = false,
  });

  final PhoneOtpFlow? flow;
  final String? phoneE164;
  final PhoneOtpPending? pending;
  final String? otpError;
  final String? submitError;
  final String? infoMessage;
  final bool isBusy;
  final bool isResending;
  final bool loginSucceeded;
  final bool registerSucceeded;

  bool get hasSession => pending != null;

  PhoneOtpVerificationState copyWith({
    PhoneOtpFlow? flow,
    String? phoneE164,
    PhoneOtpPending? pending,
    String? otpError,
    String? submitError,
    String? infoMessage,
    bool? isBusy,
    bool? isResending,
    bool? loginSucceeded,
    bool? registerSucceeded,
    bool clearOtpError = false,
    bool clearSubmitError = false,
    bool clearInfoMessage = false,
    bool clearPending = false,
    bool clearSuccessFlags = false,
  }) {
    return PhoneOtpVerificationState(
      flow: flow ?? this.flow,
      phoneE164: phoneE164 ?? this.phoneE164,
      pending: clearPending ? null : (pending ?? this.pending),
      otpError: clearOtpError ? null : (otpError ?? this.otpError),
      submitError: clearSubmitError ? null : (submitError ?? this.submitError),
      infoMessage: clearInfoMessage ? null : (infoMessage ?? this.infoMessage),
      isBusy: isBusy ?? this.isBusy,
      isResending: isResending ?? this.isResending,
      loginSucceeded: clearSuccessFlags
          ? false
          : (loginSucceeded ?? this.loginSucceeded),
      registerSucceeded: clearSuccessFlags
          ? false
          : (registerSucceeded ?? this.registerSucceeded),
    );
  }
}

class PhoneOtpVerificationController extends Notifier<PhoneOtpVerificationState> {
  static const _retryCooldown = Duration(seconds: 2);
  DateTime? _nextAllowedActionAt;

  @override
  PhoneOtpVerificationState build() => const PhoneOtpVerificationState();

  void beginSession({
    required PhoneOtpFlow flow,
    required String phoneE164,
    required PhoneOtpPending pending,
  }) {
    state = PhoneOtpVerificationState(
      flow: flow,
      phoneE164: phoneE164.trim(),
      pending: pending,
      infoMessage: pending.autoVerified ? null : AuthStrings.loginOtpSentSms,
    );
  }

  void bootstrapFromRoute({
    required PhoneOtpFlow flow,
    required String phoneE164,
  }) {
    if (state.pending != null) return;
    state = PhoneOtpVerificationState(
      flow: flow,
      phoneE164: phoneE164.trim(),
      submitError: AuthStrings.authPhoneOtpSessionExpired,
    );
  }

  void reset() {
    state = const PhoneOtpVerificationState();
  }

  void acknowledgeSubmitError() {
    state = state.copyWith(clearSubmitError: true);
  }

  void acknowledgeInfoMessage() {
    state = state.copyWith(clearInfoMessage: true);
  }

  void acknowledgeLoginSucceeded() {
    state = state.copyWith(clearSuccessFlags: true);
  }

  void acknowledgeRegisterSucceeded() {
    state = state.copyWith(clearSuccessFlags: true);
  }

  void onOtpChanged(String _) {
    state = state.copyWith(clearOtpError: true, clearSubmitError: true);
  }

  Future<void> verify(String rawOtp) async {
    if (_isCoolingDown()) return;

    final pending = state.pending;
    if (pending == null) {
      state = state.copyWith(submitError: AuthStrings.authPhoneOtpSessionExpired);
      return;
    }

    final otpErr = LoginValidators.otpCode(rawOtp);
    if (otpErr != null) {
      state = state.copyWith(otpError: otpErr);
      return;
    }

    if (!AppConfig.hasSupabase) {
      state = state.copyWith(submitError: ShellStrings.supabaseMissingTitle);
      return;
    }

    state = state.copyWith(
      isBusy: true,
      clearOtpError: true,
      clearSubmitError: true,
    );

    User? signedInUser;
    try {
      signedInUser = await ref.read(authNotifierProvider.notifier).verifyPhoneOtpAndSignIn(
            pending: pending,
            token: rawOtp,
          );
    } on AppFailure catch (e) {
      if (!ref.mounted) return;
      _nextAllowedActionAt = DateTime.now().add(_retryCooldown);
      state = state.copyWith(
        isBusy: false,
        submitError: e.message,
      );
      return;
    } catch (e) {
      if (!ref.mounted) return;
      _nextAllowedActionAt = DateTime.now().add(_retryCooldown);
      state = state.copyWith(
        isBusy: false,
        submitError: e is AppFailure ? e.message : CoreStrings.errorUnexpected,
      );
      return;
    }
    if (!ref.mounted) return;

    final user = signedInUser ?? ref.read(authServiceProvider).currentSession?.user;
    if (user == null) {
      state = state.copyWith(
        isBusy: false,
        submitError: CoreStrings.errorUnexpected,
      );
      return;
    }

    if (state.flow == PhoneOtpFlow.register) {
      try {
        await _applyRegisterMetadata();
        await _markRegisterPhoneVerified();
      } on AppFailure catch (e) {
        if (!ref.mounted) return;
        state = state.copyWith(isBusy: false, submitError: e.message);
        return;
      } catch (_) {
        if (!ref.mounted) return;
        state = state.copyWith(
          isBusy: false,
          submitError: CoreStrings.errorUnexpected,
        );
        return;
      }
      if (!ref.mounted) return;
      state = state.copyWith(
        isBusy: false,
        registerSucceeded: true,
      );
      return;
    }

    state = state.copyWith(
      isBusy: false,
      loginSucceeded: true,
    );
  }

  Future<void> resend() async {
    if (_isCoolingDown()) return;

    final phone = state.phoneE164?.trim() ?? '';
    final flow = state.flow;
    if (phone.isEmpty || flow == null) {
      state = state.copyWith(submitError: AuthStrings.authPhoneOtpSessionExpired);
      return;
    }

    final phErr = LoginValidators.phoneE164(phone);
    if (phErr != null) {
      state = state.copyWith(submitError: phErr);
      return;
    }

    if (!AppConfig.hasSupabase) {
      state = state.copyWith(submitError: ShellStrings.supabaseMissingTitle);
      return;
    }

    state = state.copyWith(
      isResending: true,
      clearSubmitError: true,
      clearOtpError: true,
    );

    try {
      final pending = await ref.read(authNotifierProvider.notifier).sendPhoneOtp(
            phoneE164: phone,
            shouldCreateUser: flow == PhoneOtpFlow.register,
          );
      if (!ref.mounted) return;

      if (pending.autoVerified) {
        if (flow == PhoneOtpFlow.register) {
          await _applyRegisterMetadata();
          await _markRegisterPhoneVerified();
          if (!ref.mounted) return;
          state = state.copyWith(
            isResending: false,
            pending: pending,
            registerSucceeded: true,
          );
          return;
        }
        state = state.copyWith(
          isResending: false,
          pending: pending,
          loginSucceeded: true,
        );
        return;
      }

      state = state.copyWith(
        isResending: false,
        pending: pending,
        infoMessage: AuthStrings.loginOtpSentSms,
      );
    } on AppFailure catch (e) {
      if (!ref.mounted) return;
      _nextAllowedActionAt = DateTime.now().add(_retryCooldown);
      state = state.copyWith(isResending: false, submitError: e.message);
    } catch (_) {
      if (!ref.mounted) return;
      _nextAllowedActionAt = DateTime.now().add(_retryCooldown);
      state = state.copyWith(
        isResending: false,
        submitError: CoreStrings.errorUnexpected,
      );
    }
  }

  bool _isCoolingDown() {
    final nextAllowed = _nextAllowedActionAt;
    if (nextAllowed != null && DateTime.now().isBefore(nextAllowed)) {
      state = state.copyWith(submitError: AuthStrings.loginRetryCooldown);
      return true;
    }
    return false;
  }

  Future<void> _applyRegisterMetadata() async {
    final draft = RegisterWizardDraftStore.instance.read();
    if (draft == null) return;

    final prenom = draft.prenom.trim();
    final nom = draft.nom.trim();
    final phone = draft.phone.trim().isEmpty
        ? (state.phoneE164 ?? '')
        : PhoneNumberUtils.toStored(
            dialCode: draft.phoneDialCode,
            local: draft.phone,
          );

    await ref.read(authServiceProvider).updateUser(
          UserAttributes(
            data: <String, dynamic>{
              'full_name': '$prenom $nom'.trim(),
              if (prenom.isNotEmpty) 'prenom': prenom,
              if (nom.isNotEmpty) 'nom': nom,
              if (phone.isNotEmpty) 'phone': phone,
            },
          ),
        );
  }

  Future<void> _markRegisterPhoneVerified() async {
    final draft = RegisterWizardDraftStore.instance.read();
    if (draft == null) return;

    final updated = RegisterWizardDraft(
      step: draft.step,
      prenom: draft.prenom,
      nom: draft.nom,
      phone: draft.phone,
      phoneDialCode: draft.phoneDialCode,
      email: draft.email,
      password: draft.password,
      confirmPassword: draft.confirmPassword,
      adresse: draft.adresse,
      salon: draft.salon,
      nomAffiche: draft.nomAffiche,
      codePostal: draft.codePostal,
      description: draft.description,
      ville: draft.ville,
      bio: draft.bio,
      signedUpViaOAuth: draft.signedUpViaOAuth,
      pendingGoogleSignIn: draft.pendingGoogleSignIn,
      signedUpViaPhone: true,
      phoneRequiredOnExtras: draft.phoneRequiredOnExtras,
      pendingEmailVerification: draft.pendingEmailVerification,
      pendingPhoneVerification: false,
      role: draft.role,
    );
    await RegisterWizardDraftStore.instance.save(updated);
  }
}
