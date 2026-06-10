import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../models/prestataire_profile_edit_section.dart';
import '../models/prestataire_service_catalog_selection.dart';
import '../models/prestataire_service_field_set.dart';
import '../models/weekly_jour_horaire.dart';
import '../widgets/profile/steps/services/service_wizard_shine.dart';

/// Erreurs de validation affichées dans le formulaire hub.
class PrestataireHubFieldErrors {
  const PrestataireHubFieldErrors({
    this.avatarError,
    this.nomError,
    this.nomAfficheError,
    this.descriptionError,
    this.experienceProError,
    this.villeError,
    this.codePostalError,
    this.adresseError,
    this.lieuTravailError,
    this.servicesError,
    this.pricingError,
    this.galleryError,
    this.horairesError,
  });

  final String? avatarError;
  final String? nomError;
  final String? nomAfficheError;
  final String? descriptionError;
  final String? experienceProError;
  final String? villeError;
  final String? codePostalError;
  final String? adresseError;
  final String? lieuTravailError;
  final String? servicesError;
  final String? pricingError;
  final String? galleryError;
  final String? horairesError;

  PrestataireHubFieldErrors merge(PrestataireHubFieldErrors other) {
    return PrestataireHubFieldErrors(
      avatarError: other.avatarError ?? avatarError,
      nomError: other.nomError ?? nomError,
      nomAfficheError: other.nomAfficheError ?? nomAfficheError,
      descriptionError: other.descriptionError ?? descriptionError,
      experienceProError: other.experienceProError ?? experienceProError,
      villeError: other.villeError ?? villeError,
      codePostalError: other.codePostalError ?? codePostalError,
      adresseError: other.adresseError ?? adresseError,
      lieuTravailError: other.lieuTravailError ?? lieuTravailError,
      servicesError: other.servicesError ?? servicesError,
      pricingError: other.pricingError ?? pricingError,
      galleryError: other.galleryError ?? galleryError,
      horairesError: other.horairesError ?? horairesError,
    );
  }

  bool get vitrineValid =>
      avatarError == null &&
      nomError == null &&
      nomAfficheError == null &&
      descriptionError == null &&
      experienceProError == null;

  bool get locationValid =>
      villeError == null &&
      codePostalError == null &&
      adresseError == null &&
      lieuTravailError == null;

  bool get servicesValid => servicesError == null && pricingError == null;

  bool get horairesValid => horairesError == null;
}

abstract final class PrestataireHubValidation {
  PrestataireHubValidation._();

  static PrestataireHubFieldErrors validateVitrine({
    required String nom,
    required String nomAffiche,
    required String description,
    required String experiencePro,
    required bool hasAvatar,
  }) {
    return PrestataireHubFieldErrors(
      avatarError: hasAvatar ? null : DiscPrestaForm.reqPhoto,
      nomError: nom.isEmpty ? DiscPrestaForm.reqNameSalon : null,
      nomAfficheError:
          nomAffiche.isEmpty ? DiscPrestaForm.reqDisplayName : null,
      descriptionError: description.isEmpty
          ? DiscPrestaForm.reqDescription
          : description.characters.length > 200
          ? DiscPrestaForm.descriptionTooLong
          : null,
      experienceProError: experiencePro.length > 150
          ? DiscPrestaForm.experienceProTooLong
          : null,
    );
  }

  static PrestataireHubFieldErrors validateLocation({
    required String ville,
    required String codePostal,
    required String adresse,
    required bool hasLieuTravail,
  }) {
    return PrestataireHubFieldErrors(
      villeError: ville.isEmpty ? DiscPrestaForm.reqCity : null,
      codePostalError:
          codePostal.isEmpty ? DiscPrestaForm.reqPostalCode : null,
      adresseError: adresse.isEmpty ? DiscPrestaForm.reqAddress : null,
      lieuTravailError:
          hasLieuTravail ? null : DiscPrestaForm.reqWorkLocation,
    );
  }

  static PrestataireHubFieldErrors validateHoraires({
    required List<WeeklyJourHoraire>? horaireWeek,
  }) {
    final jours = horaireWeek;
    if (jours == null) {
      return const PrestataireHubFieldErrors(
        horairesError: DiscPrestaHoraires.loadErr,
      );
    }
    if (!jours.hasAnyOpenDay) {
      return const PrestataireHubFieldErrors(
        horairesError: DiscPrestaHoraires.reqOpenDay,
      );
    }
    if (!jours.validatePlages()) {
      return const PrestataireHubFieldErrors(
        horairesError: DiscPrestaHoraires.invalidPlage,
      );
    }
    return const PrestataireHubFieldErrors(horairesError: null);
  }

  static ({bool valid, PrestataireHubFieldErrors errors}) validatePricing(
    List<PrestataireServiceFieldSet> services,
  ) {
    var valid = true;
    for (final service in services) {
      final price = parsePrestataireServicePrice(service.prixController.text);
      final duration = parsePrestataireServiceDuration(
        service.dureeController.text,
      );
      service.prixError =
          price == null || price < 1 ? DiscPrestaForm.svcPriceBad : null;
      service.dureeError =
          duration == null || duration <= 0 ? DiscPrestaForm.svcDurationBad : null;
      valid = valid &&
          service.prixError == null &&
          service.dureeError == null;
    }
    return (
      valid: valid,
      errors: PrestataireHubFieldErrors(
        pricingError: valid ? null : DiscPrestaForm.reqPricing,
      ),
    );
  }

  static ({bool valid, PrestataireHubFieldErrors errors}) validateServices({
    required PrestataireServiceCatalogSelection catalogSelection,
    required List<PrestataireServiceFieldSet> services,
  }) {
    if (!catalogSelection.isValid) {
      return (
        valid: false,
        errors: PrestataireHubFieldErrors(
          servicesError: catalogSelection.selectedMains.isEmpty
              ? DiscPrestaForm.reqCatalogMain
              : DiscPrestaForm.reqCatalogSpecialty,
          pricingError: null,
        ),
      );
    }
    if (services.isEmpty) {
      return (
        valid: false,
        errors: const PrestataireHubFieldErrors(
          servicesError: null,
          pricingError: DiscPrestaForm.pricingEmptyHint,
        ),
      );
    }
    final pricing = validatePricing(services);
    return (valid: pricing.valid, errors: pricing.errors);
  }

  static bool validateCurrentStep({
    required PrestataireProfileEditSection? focusedSection,
    required int currentStep,
    required PrestataireHubFieldErrors Function() validateVitrineFn,
    required PrestataireHubFieldErrors Function() validateLocationFn,
    required PrestataireHubFieldErrors Function() validateServicesFn,
    required PrestataireHubFieldErrors Function() validateHorairesFn,
    required void Function(PrestataireHubFieldErrors errors) applyErrors,
  }) {
    if (focusedSection != null) {
      final errors = switch (focusedSection) {
        PrestataireProfileEditSection.vitrine => validateVitrineFn(),
        PrestataireProfileEditSection.location => validateLocationFn(),
        PrestataireProfileEditSection.services => validateServicesFn(),
        PrestataireProfileEditSection.gallery => const PrestataireHubFieldErrors(),
        PrestataireProfileEditSection.clientExperience =>
          const PrestataireHubFieldErrors(),
        PrestataireProfileEditSection.horaires => validateHorairesFn(),
      };
      applyErrors(errors);
      return switch (focusedSection) {
        PrestataireProfileEditSection.vitrine => errors.vitrineValid,
        PrestataireProfileEditSection.location => errors.locationValid,
        PrestataireProfileEditSection.services => errors.servicesValid,
        PrestataireProfileEditSection.gallery => true,
        PrestataireProfileEditSection.clientExperience => true,
        PrestataireProfileEditSection.horaires => errors.horairesValid,
      };
    }
    final errors = switch (currentStep) {
      0 => validateVitrineFn(),
      1 => validateLocationFn(),
      2 => validateServicesFn(),
      3 => validateHorairesFn(),
      _ => const PrestataireHubFieldErrors(),
    };
    applyErrors(errors);
    return switch (currentStep) {
      0 => errors.vitrineValid,
      1 => errors.locationValid,
      2 => errors.servicesValid,
      3 => errors.horairesValid,
      _ => true,
    };
  }

  /// Première étape obligatoire (0–3) non valide, ou `null` si tout est OK.
  static int? firstMandatoryStepFailure({
    required PrestataireHubFieldErrors Function() validateVitrineFn,
    required PrestataireHubFieldErrors Function() validateLocationFn,
    required PrestataireHubFieldErrors Function() validateServicesFn,
    required PrestataireHubFieldErrors Function() validateHorairesFn,
    required void Function(PrestataireHubFieldErrors errors) applyErrors,
  }) {
    var errors = validateVitrineFn();
    applyErrors(errors);
    if (!errors.vitrineValid) return 0;

    errors = validateLocationFn();
    applyErrors(errors);
    if (!errors.locationValid) return 1;

    errors = validateServicesFn();
    applyErrors(errors);
    if (!errors.servicesValid) return 2;

    errors = validateHorairesFn();
    applyErrors(errors);
    if (!errors.horairesValid) return 3;

    return null;
  }
}
