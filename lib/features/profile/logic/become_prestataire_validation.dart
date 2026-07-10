import '../../../core/constants/app_strings.dart' show AuthStrings, DiscPrestaForm;

class BecomePrestataireFieldErrors {
  const BecomePrestataireFieldErrors({
    this.salonError,
    this.villeError,
    this.codePostalError,
    this.adresseError,
    this.formError,
  });

  final String? salonError;
  final String? villeError;
  final String? codePostalError;
  final String? adresseError;
  final String? formError;

  bool get isValid =>
      salonError == null &&
      villeError == null &&
      codePostalError == null &&
      adresseError == null &&
      formError == null;
}

abstract final class BecomePrestataireValidation {
  BecomePrestataireValidation._();

  static BecomePrestataireFieldErrors validate({
    required String salon,
    required String ville,
    required String codePostal,
    required String adresse,
  }) {
    return BecomePrestataireFieldErrors(
      salonError: salon.trim().isEmpty
          ? AuthStrings.registerValidationSalonEmpty
          : null,
      villeError: ville.trim().isEmpty
          ? AuthStrings.registerValidationVilleEmpty
          : null,
      codePostalError: codePostal.trim().isEmpty
          ? DiscPrestaForm.reqPostalCode
          : null,
      adresseError: adresse.trim().isEmpty ? DiscPrestaForm.reqAddress : null,
    );
  }
}
