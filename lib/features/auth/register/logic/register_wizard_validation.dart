import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/user_role.dart';
import 'register_validators.dart';

class RegisterWizardFieldErrors {
  const RegisterWizardFieldErrors({
    this.prenomError,
    this.nomError,
    this.phoneError,
    this.emailError,
    this.passwordError,
    this.confirmError,
    this.salonError,
    this.villeError,
    this.roleError,
  });

  final String? prenomError;
  final String? nomError;
  final String? phoneError;
  final String? emailError;
  final String? passwordError;
  final String? confirmError;
  final String? salonError;
  final String? villeError;
  final String? roleError;

  bool get step0Valid =>
      prenomError == null &&
      nomError == null &&
      phoneError == null &&
      emailError == null &&
      passwordError == null &&
      confirmError == null;

  bool get extrasValid =>
      phoneError == null && salonError == null && villeError == null;
}

abstract final class RegisterWizardValidation {
  RegisterWizardValidation._();

  static RegisterWizardFieldErrors validateStep0({
    required String prenom,
    required String nom,
    required String phone,
    required String dialCode,
    required String email,
    required String password,
    required String confirmPassword,
    required bool signedUpViaOAuth,
    required bool usePhoneSignUp,
    required bool phoneRequiredOnExtras,
  }) {
    final pErr = prenom.isEmpty
        ? AuthStrings.registerValidationPrenomEmpty
        : null;
    final nErr =
        nom.isEmpty ? AuthStrings.registerValidationNomEmpty : null;

    String? phErr;
    final requirePhoneOnStep0 =
        usePhoneSignUp || (signedUpViaOAuth && !phoneRequiredOnExtras);
    if (requirePhoneOnStep0) {
      phErr = RegisterValidators.phoneLocal(phone, dialCode: dialCode);
    }

    String? emailErr;
    String? pwErr;
    String? confirmErr;
    if (!signedUpViaOAuth && !usePhoneSignUp) {
      emailErr = RegisterValidators.email(email);
      pwErr = RegisterValidators.password(password);
      confirmErr = password != confirmPassword
          ? AuthStrings.registerValidationPasswordMismatch
          : null;
    }

    return RegisterWizardFieldErrors(
      prenomError: pErr,
      nomError: nErr,
      phoneError: phErr,
      emailError: emailErr,
      passwordError: pwErr,
      confirmError: confirmErr,
    );
  }

  static RegisterWizardFieldErrors validateExtras({
    required bool phoneRequiredOnExtras,
    required String phone,
    required String dialCode,
    required bool isPresta,
    required String salon,
    required String ville,
  }) {
    String? phErr;
    if (phoneRequiredOnExtras) {
      phErr = RegisterValidators.phoneLocal(phone, dialCode: dialCode);
    }

    String? salonErr;
    String? villeErr;
    if (isPresta) {
      salonErr = salon.isEmpty
          ? AuthStrings.registerValidationSalonEmpty
          : null;
      villeErr =
          ville.isEmpty ? AuthStrings.registerValidationVilleEmpty : null;
    }

    return RegisterWizardFieldErrors(
      phoneError: phErr,
      salonError: salonErr,
      villeError: villeErr,
    );
  }

  static String? validateRole(UserRole? role) {
    if (role == null) return AuthStrings.registerValidationRoleEmpty;
    return null;
  }
}
