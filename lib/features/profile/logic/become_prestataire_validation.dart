import '../../../core/constants/app_strings.dart' show AuthStrings, DiscPrestaForm;

class BecomePrestataireFieldErrors {
  const BecomePrestataireFieldErrors({
    this.salonError,
    this.villeError,
    this.codePostalError,
    this.formError,
  });

  final String? salonError;
  final String? villeError;
  final String? codePostalError;
  final String? formError;

  bool get isValid =>
      salonError == null &&
      villeError == null &&
      codePostalError == null &&
      formError == null;
}

abstract final class BecomePrestataireValidation {
  BecomePrestataireValidation._();

  static BecomePrestataireFieldErrors validate({
    required String salon,
    required String ville,
    required String codePostal,
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
    );
  }
}
