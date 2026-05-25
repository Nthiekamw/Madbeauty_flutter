import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

/// Section ciblée du formulaire profil prestataire.
enum PrestataireProfileEditSection {
  vitrine,
  location,
  services,
  gallery,
  clientExperience;

  static PrestataireProfileEditSection? fromQuery(String? raw) {
    if (raw == null || raw.trim().isEmpty) return null;
    return switch (raw.trim()) {
      'vitrine' => vitrine,
      'location' => location,
      'services' => services,
      'gallery' => gallery,
      'client-experience' => clientExperience,
      'clientExperience' => clientExperience,
      _ => null,
    };
  }

  String get queryValue => switch (this) {
    clientExperience => 'client-experience',
    _ => name,
  };

  int get hubStepIndex => switch (this) {
    vitrine => 0,
    location => 1,
    services => 2,
    gallery => 3,
    clientExperience => 4,
  };

  String get screenTitle => switch (this) {
    vitrine => DiscPrestaProfile.editVitrine,
    location => DiscPrestaProfile.editLocation,
    services => DiscPrestaProfile.editServices,
    gallery => DiscPrestaProfile.editGallery,
    clientExperience => DiscPrestaComfort.editTitle,
  };

  String get menuTitle => switch (this) {
    vitrine => DiscPrestaProfile.menuVitrine,
    location => DiscPrestaProfile.menuLocation,
    services => DiscPrestaProfile.menuServices,
    gallery => DiscPrestaProfile.menuGallery,
    clientExperience => DiscPrestaComfort.menuTitle,
  };

  String get menuSubtitle => switch (this) {
    vitrine => DiscPrestaProfile.menuVitrineHint,
    location => DiscPrestaProfile.menuLocationHint,
    services => DiscPrestaProfile.menuServicesHint,
    gallery => DiscPrestaProfile.menuGalleryHint,
    clientExperience => DiscPrestaComfort.menuHint,
  };

  IconData get icon => switch (this) {
    vitrine => Icons.storefront_rounded,
    location => Icons.place_outlined,
    services => Icons.design_services_outlined,
    gallery => Icons.photo_library_outlined,
    clientExperience => Icons.favorite_outline_rounded,
  };
}
