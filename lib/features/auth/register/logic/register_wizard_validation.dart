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
    this.codePostalError,
    this.adresseError,
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
  final String? codePostalError;
  final String? adresseError;
  final String? roleError;

  bool get step0Valid =>
      prenomError == null &&
      nomError == null &&
      phoneError == null &&
      emailError == null &&
      passwordError == null &&
      confirmError == null;

  bool get extrasValid =>
      phoneError == null &&
      salonError == null &&
      villeError == null &&
      codePostalError == null &&
      adresseError == null;
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
    bool signedUpViaApple = false,
    bool oauthProvidedPrenom = false,
    bool oauthProvidedNom = false,
  }) {
    // Guideline App Store 4 — Sign in with Apple : ne jamais exiger
    // nom / e-mail après Authentication Services (déjà fournis par Apple).
    final skipIdentity = signedUpViaApple;
    final pErr = !skipIdentity && !oauthProvidedPrenom && prenom.isEmpty
        ? AuthStrings.registerValidationPrenomEmpty
        : null;
    final nErr = !skipIdentity && !oauthProvidedNom && nom.isEmpty
        ? AuthStrings.registerValidationNomEmpty
        : null;
    final phErr = RegisterValidators.phoneLocal(phone, dialCode: dialCode);

    String? emailErr;
    String? pwErr;
    String? confirmErr;
    if (!signedUpViaOAuth) {
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
    required bool isPresta,
    required String salon,
    required String ville,
    required String codePostal,
    required String adresse,
  }) {
    String? salonErr;
    String? villeErr;
    String? codePostalErr;
    String? adresseErr;
    if (isPresta) {
      salonErr = salon.isEmpty
          ? AuthStrings.registerValidationSalonEmpty
          : null;
      villeErr =
          ville.isEmpty ? AuthStrings.registerValidationVilleEmpty : null;
      codePostalErr =
          codePostal.isEmpty ? DiscPrestaForm.reqPostalCode : null;
      adresseErr = adresse.isEmpty ? DiscPrestaForm.reqAddress : null;
    }

    return RegisterWizardFieldErrors(
      salonError: salonErr,
      villeError: villeErr,
      codePostalError: codePostalErr,
      adresseError: adresseErr,
    );
  }

  static String? validateRole(UserRole? role) {
    if (role == null) return AuthStrings.registerValidationRoleEmpty;
    return null;
  }
}
