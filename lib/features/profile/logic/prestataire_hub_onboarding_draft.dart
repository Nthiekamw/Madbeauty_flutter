import 'dart:async';

import 'package:flutter/material.dart';

import '../../../core/models/domain/user/lieu_travail.dart';
import '../../prestataire/models/horaire_day_draft.dart';
import '../../prestataire/models/prestataire_service_catalog_selection.dart';
import '../../prestataire/models/prestataire_service_field_set.dart';
import '../../prestataire/models/weekly_jour_horaire.dart';
import '../../../core/logic/address/postal_country_format.dart';
import 'become_prestataire_draft.dart';
import 'become_prestataire_hub_draft.dart';
import '../storage/become_prestataire_draft_store.dart';

/// Sauvegarde / restauration du hub prestataire pendant l'onboarding.
abstract final class PrestataireHubOnboardingDraft {
  PrestataireHubOnboardingDraft._();

  static const maxHubStepIndex = 6;

  static bool get isActive {
    final draft = BecomePrestataireDraftStore.instance.read();
    return draft != null && draft.step1Submitted;
  }

  static bool get hasPendingCompletion => isActive;

  static Future<void> markStep2Started() async {
    final current = BecomePrestataireDraftStore.instance.read();
    if (current == null) return;
    await BecomePrestataireDraftStore.instance.save(
      current.copyWith(step2Started: true),
    );
  }

  /// Reprise ou entrée wizard : positionne l’étape courante dans le brouillon hub.
  static Future<void> seedCurrentStep(int step) async {
    final current = BecomePrestataireDraftStore.instance.read();
    if (current == null) return;
    final clamped = step.clamp(0, maxHubStepIndex);
    final existing = current.hub;
    final hub = existing == null
        ? hubDraftFromBecomeDraft(current, currentStep: clamped)
        : BecomePrestataireHubDraft(
            currentStep: clamped,
            nomSalon: existing.nomSalon,
            nomAffiche: existing.nomAffiche,
            bio: existing.bio,
            description: existing.description,
            experienceProfessionnelle: existing.experienceProfessionnelle,
            anneesExperience: existing.anneesExperience,
            ville: existing.ville,
            codePostal: existing.codePostal,
            adresse: existing.adresse,
            pays: existing.pays,
            lieuTravail: existing.lieuTravail,
            avatarUrl: existing.avatarUrl,
            suggestionCategorieNom: existing.suggestionCategorieNom,
            suggestionCategorieDescription:
                existing.suggestionCategorieDescription,
            confortClient: existing.confortClient,
            conditionsService: existing.conditionsService,
            services: existing.services,
            horaires: existing.horaires,
            catalogSelection: existing.catalogSelection,
          );
    await BecomePrestataireDraftStore.instance.save(
      current.copyWith(step2Started: true, hub: hub),
    );
  }

  static Future<void> persist({
    required int currentStep,
    required String nomSalon,
    required String nomAffiche,
    required String bio,
    required String description,
    required String experienceProfessionnelle,
    required String anneesExperience,
    required String ville,
    required String codePostal,
    required String adresse,
    required String pays,
    required LieuTravail? lieuTravail,
    required String? avatarUrl,
    required String suggestionCategorieNom,
    required String suggestionCategorieDescription,
    required Set<String> confortClient,
    required Set<String> conditionsService,
    required List<PrestataireServiceFieldSet> services,
    required PrestataireServiceCatalogSelection catalogSelection,
    List<WeeklyJourHoraire>? horaireWeek,
  }) async {
    if (!isActive) return;

    final current = BecomePrestataireDraftStore.instance.read();
    if (current == null) return;

    final horaires = horaireWeek == null
        ? const <HoraireDayDraft>[]
        : horaireWeek.map(HoraireDayDraft.fromWeekly).toList();

    final hub = BecomePrestataireHubDraft(
      currentStep: currentStep.clamp(0, maxHubStepIndex),
      nomSalon: nomSalon,
      nomAffiche: nomAffiche,
      bio: bio,
      description: description,
      experienceProfessionnelle: experienceProfessionnelle,
      anneesExperience: anneesExperience,
      ville: ville,
      codePostal: codePostal,
      adresse: adresse,
      pays: pays,
      lieuTravail: lieuTravail?.value,
      avatarUrl: avatarUrl,
      suggestionCategorieNom: suggestionCategorieNom,
      suggestionCategorieDescription: suggestionCategorieDescription,
      confortClient: confortClient.toList(),
      conditionsService: conditionsService.toList(),
      services: services
          .map(
            (s) => BecomePrestataireHubServiceDraft(
              id: s.id,
              nom: s.nomController.text,
              description: s.descriptionController.text,
              categorieId: s.categorieId,
              prix: s.prixController.text,
              duree: s.dureeController.text,
            ),
          )
          .toList(),
      horaires: horaires,
      catalogSelection: catalogSelection.toJson(),
    );

    await BecomePrestataireDraftStore.instance.save(
      current.copyWith(step2Started: true, hub: hub),
    );
  }

  static BecomePrestataireHubDraft? readHub() {
    return BecomePrestataireDraftStore.instance.read()?.hub;
  }

  /// Reprend les champs saisis à l'inscription (étape 3) dans les champs vides.
  static void seedBasicsFromBecomeDraft({
    required TextEditingController nomController,
    required TextEditingController villeController,
    required TextEditingController bioController,
    required TextEditingController nomAfficheController,
    TextEditingController? descriptionController,
    TextEditingController? codePostalController,
    TextEditingController? adresseController,
  }) {
    final draft = BecomePrestataireDraftStore.instance.read();
    if (draft == null) return;

    void seedIfEmpty(TextEditingController controller, String value) {
      if (controller.text.trim().isEmpty && value.trim().isNotEmpty) {
        controller.text = value.trim();
      }
    }

    seedIfEmpty(nomController, draft.salon);
    seedIfEmpty(villeController, draft.ville);
    seedIfEmpty(bioController, draft.bio);
    final affiche = draft.nomAffiche.trim().isNotEmpty
        ? draft.nomAffiche
        : draft.salon;
    seedIfEmpty(nomAfficheController, affiche);
    if (descriptionController != null) {
      seedIfEmpty(descriptionController, draft.description);
    }
    if (codePostalController != null) {
      seedIfEmpty(codePostalController, draft.codePostal);
    }
    if (adresseController != null) {
      final address = draft.adresse.trim().isNotEmpty
          ? draft.adresse
          : draft.postalAddress.streetLine;
      seedIfEmpty(adresseController, address);
    }
  }

  /// Reprend l'adresse structurée de l'inscription (étape 3) dans le formulaire hub.
  static void seedLocationFromBecomeDraft({
    required TextEditingController villeController,
    required TextEditingController codePostalController,
    required TextEditingController voieNomController,
    required TextEditingController numeroRueController,
    required TextEditingController paysController,
    required void Function(String voieType) setVoieType,
    required void Function(String isoCode) setPaysCode,
  }) {
    final draft = BecomePrestataireDraftStore.instance.read();
    if (draft == null) return;

    final address = draft.postalAddress;
    if (address.isEmpty) return;

    void seedIfEmpty(TextEditingController controller, String value) {
      if (controller.text.trim().isEmpty && value.trim().isNotEmpty) {
        controller.text = value.trim();
      }
    }

    seedIfEmpty(villeController, address.ville);
    seedIfEmpty(codePostalController, address.codePostal);
    seedIfEmpty(voieNomController, address.voieNom);
    seedIfEmpty(numeroRueController, address.numero);

    if (voieNomController.text.trim().isNotEmpty ||
        numeroRueController.text.trim().isNotEmpty) {
      setVoieType(address.voieType);
    }

    if (paysController.text.trim().isEmpty && address.pays.trim().isNotEmpty) {
      paysController.text = address.pays.trim();
    }
    setPaysCode(postalCountryIso2(address.pays));
  }

  static BecomePrestataireHubDraft hubDraftFromBecomeDraft(
    BecomePrestataireDraft draft, {
    required int currentStep,
  }) {
    final address = draft.postalAddress;
    return BecomePrestataireHubDraft(
      currentStep: currentStep,
      nomSalon: draft.salon,
      nomAffiche:
          draft.nomAffiche.trim().isNotEmpty ? draft.nomAffiche : draft.salon,
      bio: draft.bio,
      description: draft.description,
      ville: draft.ville,
      codePostal: draft.codePostal,
      adresse: draft.adresse.trim().isNotEmpty
          ? draft.adresse
          : address.streetLine,
      pays: address.pays.trim().isEmpty
          ? 'FR'
          : address.pays.trim().toUpperCase(),
    );
  }

  static PrestataireServiceCatalogSelection? catalogSelectionFromHub(
    BecomePrestataireHubDraft hub,
  ) {
    final raw = hub.catalogSelection;
    if (raw != null && raw.isNotEmpty) {
      return PrestataireServiceCatalogSelection.fromJson(raw);
    }
    if (hub.services.isEmpty) return null;
    return PrestataireServiceCatalogSelection.fromServiceDrafts(
      hub.services.map((s) => (nom: s.nom, categorieId: s.categorieId)),
    );
  }

  static void applyHubDraft({
    required BecomePrestataireHubDraft hub,
    required void Function(int step) setCurrentStep,
    required TextEditingController nomController,
    required TextEditingController nomAfficheController,
    required TextEditingController bioController,
    required TextEditingController descriptionController,
    required TextEditingController experienceProController,
    required TextEditingController anneesExperienceController,
    required TextEditingController villeController,
    required TextEditingController codePostalController,
    required TextEditingController adresseController,
    required void Function(String code) setPays,
    required void Function(LieuTravail? value) setLieuTravail,
    required void Function(String? url) setAvatarUrl,
    required TextEditingController suggestionNomController,
    required TextEditingController suggestionDescController,
    required void Function(Set<String> ids) setComfortIds,
    required void Function(Set<String> ids) setConditionIds,
    required void Function(List<PrestataireServiceFieldSet> services)
        replaceServices,
    required void Function(List<WeeklyJourHoraire> week) setHoraireWeek,
  }) {
    setCurrentStep(hub.currentStep.clamp(0, maxHubStepIndex));
    nomController.text = hub.nomSalon;
    nomAfficheController.text = hub.nomAffiche;
    bioController.text = hub.bio;
    descriptionController.text = hub.description;
    experienceProController.text = hub.experienceProfessionnelle;
    anneesExperienceController.text = hub.anneesExperience;
    villeController.text = hub.ville;
    codePostalController.text = hub.codePostal;
    adresseController.text = hub.adresse;
    setPays(hub.pays);
    setLieuTravail(LieuTravail.fromValue(hub.lieuTravail));
    setAvatarUrl(hub.avatarUrl);
    suggestionNomController.text = hub.suggestionCategorieNom;
    suggestionDescController.text = hub.suggestionCategorieDescription;
    setComfortIds(hub.confortClient.toSet());
    setConditionIds(hub.conditionsService.toSet());
    replaceServices(
      hub.services
          .map(
            (s) => PrestataireServiceFieldSet(
              id: s.id,
              nom: s.nom,
              description: s.description,
              categorieId: s.categorieId,
              prix: s.prix,
              duree: s.duree,
            ),
          )
          .toList(),
    );
    if (hub.horaires.isNotEmpty) {
      setHoraireWeek(weeklyHorairesFromDrafts(hub.horaires));
    }
  }

  static Future<void> clearAfterProfileComplete() async {
    await BecomePrestataireDraftStore.instance.clear();
  }
}

/// Débounce les écritures du brouillon hub.
class HubOnboardingDraftDebouncer {
  HubOnboardingDraftDebouncer({this.delay = const Duration(milliseconds: 350)});

  final Duration delay;
  Timer? _timer;

  void schedule(Future<void> Function() action) {
    _timer?.cancel();
    _timer = Timer(delay, () {
      unawaited(action());
    });
  }

  void dispose() => _timer?.cancel();
}

