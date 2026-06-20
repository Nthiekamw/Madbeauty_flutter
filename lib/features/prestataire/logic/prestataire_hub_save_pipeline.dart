import 'dart:typed_data';

import '../../../core/models/domain/user/lieu_travail.dart';
import '../../../services/supabase/prestataire/profile_form/prestataire_profile_form_service.dart';
import '../models/prestataire_service_catalog_selection.dart';
import '../models/prestataire_service_field_set.dart';
import '../widgets/profile/steps/services/service_wizard_shine.dart';

abstract final class PrestataireHubSavePipeline {
  PrestataireHubSavePipeline._();

  /// Texte affiché dans le champ prix (vide si non renseigné).
  static String prixFieldText(double prix) {
    if (prix <= 0) return '';
    return prix == prix.roundToDouble()
        ? prix.toInt().toString()
        : prix.toStringAsFixed(2);
  }

  static void syncServicesFromCatalog({
    required List<PrestataireServiceFieldSet> services,
    required PrestataireServiceCatalogSelection catalogSelection,
  }) {
    final preservedById = <String, ({String? id, String prix, String duree})>{};
    final preservedByName = <String, ({String? id, String prix, String duree})>{};
    final preservedByCategory =
        <String, ({String? id, String prix, String duree})>{};

    for (final s in services) {
      final entry = (
        id: s.id,
        prix: s.prixController.text,
        duree: s.dureeController.text,
      );
      final idKey = s.id?.trim();
      if (idKey != null && idKey.isNotEmpty) {
        preservedById[idKey] = entry;
      }
      final nameKey = s.nomController.text.trim().toLowerCase();
      if (nameKey.isNotEmpty) {
        preservedByName[nameKey] = entry;
      }
      final catId = s.categorieId?.trim();
      if (catId != null && catId.isNotEmpty) {
        preservedByCategory[catId] = entry;
      }
    }
    final existing = services
        .map(
          (s) => PrestataireServiceFormData(
            id: s.id,
            nom: s.nomController.text.trim(),
            description: s.descriptionController.text.trim(),
            categorieId: s.categorieId,
            prix: parsePrestataireServicePrice(s.prixController.text) ?? 0,
            dureeMinutes:
                parsePrestataireServiceDuration(s.dureeController.text) ?? 60,
          ),
        )
        .toList();
    final generated =
        catalogSelection.toServiceFormData(existing: existing);

    for (final service in services) {
      service.dispose();
    }
    services.clear();

    for (final service in generated) {
      final nameKey = service.nom.trim().toLowerCase();
      final keep = (service.id != null ? preservedById[service.id!] : null) ??
          (service.categorieId != null
              ? preservedByCategory[service.categorieId!]
              : null) ??
          preservedByName[nameKey];
      services.add(
        PrestataireServiceFieldSet(
          id: keep?.id ?? service.id,
          nom: service.nom,
          description: service.description,
          categorieId: service.categorieId,
          prix: keep?.prix ?? prixFieldText(service.prix),
          duree: keep?.duree ?? service.dureeMinutes.toString(),
        ),
      );
    }
  }

  static PrestataireProfileSavePayload buildSavePayload({
    required String nomSalon,
    required String nomAffiche,
    required String bio,
    required String description,
    required String experienceProfessionnelle,
    required String anneesExperience,
    required String ville,
    required String adresse,
    required String codePostal,
    required String pays,
    required LieuTravail lieuTravail,
    required Uint8List? avatarBytes,
    required String? avatarFileName,
    required String? avatarMimeType,
    required String? avatarUrl,
    required List<PrestataireServiceFieldSet> services,
    required PrestataireServiceCatalogSelection catalogSelection,
    required String suggestionCategorieNom,
    required String suggestionCategorieDescription,
    required List<String> confortClient,
    required List<String> conditionsService,
  }) {
    final existingServices = services
        .map(
          (s) => PrestataireServiceFormData(
            id: s.id,
            nom: s.nomController.text.trim(),
            description: s.descriptionController.text.trim(),
            categorieId: s.categorieId,
            prix: parsePrestataireServicePrice(s.prixController.text) ?? 0,
            dureeMinutes:
                parsePrestataireServiceDuration(s.dureeController.text) ?? 60,
          ),
        )
        .toList();

    return PrestataireProfileSavePayload(
      nomSalon: nomSalon,
      nomAffiche: nomAffiche,
      bio: bio,
      description: description,
      experienceProfessionnelle: experienceProfessionnelle,
      anneesExperience: anneesExperience,
      ville: ville,
      adresse: adresse,
      codePostal: codePostal,
      pays: pays,
      lieuTravail: lieuTravail,
      avatarBytes: avatarBytes,
      avatarFileName: avatarFileName,
      avatarMimeType: avatarMimeType,
      avatarUrl: avatarUrl,
      services: catalogSelection.toServiceFormData(existing: existingServices),
      specialtyCategoryIds: catalogSelection.allCategoryIds,
      customSpecialtyLabels: catalogSelection.allCustomLabels,
      suggestionCategorieNom: suggestionCategorieNom,
      suggestionCategorieDescription: suggestionCategorieDescription,
      confortClient: confortClient,
      conditionsService: conditionsService,
    );
  }
}
