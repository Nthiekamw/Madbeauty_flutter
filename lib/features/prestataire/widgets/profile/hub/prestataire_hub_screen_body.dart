import 'dart:typed_data';

import 'package:flutter/material.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../../../core/models/domain/user/lieu_travail.dart';
import '../../../../../services/supabase/prestataire/profile_form/prestataire_profile_form_service.dart';
import '../../../logic/prestataire_hub_constants.dart';
import '../../../logic/professional_experience_entries.dart';
import '../../../logic/realisation_gallery_grouping.dart';
import '../../../models/pending_realisation_upload.dart';
import '../../../models/prestataire_profile_edit_section.dart';
import '../../../models/prestataire_service_catalog_selection.dart';
import '../../../models/prestataire_service_field_set.dart';
import '../../../models/weekly_jour_horaire.dart';
import '../overview/layout/prestataire_form_scroll_view.dart';
import '../prestataire_hub_step_frame.dart';
import '../schedule/prestataire_indisponibilites_editor.dart';
import '../schedule/prestataire_weekly_horaires_editor.dart';
import '../../../logic/prestataire_subscription_service_count.dart';
import '../steps/hub/prestataire_hub_steps.dart';
import '../subscription/prestataire_subscription_onboarding_panel.dart';
import 'prestataire_hub_layout.dart';

/// Corps du formulaire hub (wizard + sections ciblées).
class PrestataireHubScreenBody extends StatelessWidget {
  const PrestataireHubScreenBody({
    super.key,
    required this.data,
    required this.focusedSection,
    required this.currentStep,
    required this.saving,
    required this.uploadProgress,
    required this.nomController,
    required this.nomAfficheController,
    required this.descriptionController,
    required this.experienceProController,
    required this.anneesExperienceController,
    required this.professionalExperiences,
    required this.onToggleProfessionalExperience,
    required this.onProfessionalExperienceYearsChanged,
    required this.onRemoveProfessionalExperience,
    required this.bioController,
    required this.villeController,
    required this.codePostalController,
    required this.adresseController,
    required this.voieType,
    required this.onVoieTypeChanged,
    required this.voieNomController,
    required this.numeroRueController,
    required this.paysController,
    required this.onPostalAddressChanged,
    required this.paysCode,
    required this.lieuTravail,
    required this.avatarUrl,
    required this.avatarBytes,
    required this.services,
    required this.catalogSelection,
    required this.suggestionNomController,
    required this.suggestionDescController,
    required this.selectedComfortIds,
    required this.selectedConditionIds,
    required this.onComfortToggled,
    required this.onConditionToggled,
    required this.onAddCustomComfort,
    required this.onAddCustomCondition,
    required this.avatarError,
    required this.nomError,
    required this.nomAfficheError,
    required this.descriptionError,
    required this.experienceProError,
    required this.villeError,
    required this.codePostalError,
    required this.adresseError,
    required this.lieuTravailError,
    required this.servicesError,
    this.pricingError,
    required this.galleryPhotos,
    required this.pendingGallery,
    required this.galleryError,
    required this.onStepTapped,
    required this.onContinue,
    required this.onCancel,
    required this.onSkip,
    required this.onCompleteLater,
    required this.onBasicsChanged,
    required this.onLieuTravailChanged,
    required this.onPickAvatar,
    required this.defaultAvatarUrls,
    required this.selectedDefaultAvatarUrl,
    required this.onSelectDefaultAvatar,
    required this.onPickGalleryForSlot,
    required this.onPickGalleryVideoForSlot,
    required this.onRemoveGalleryPhoto,
    required this.onRemovePendingGallery,
    required this.onCatalogChanged,
    required this.onPricingChanged,
    required this.horaireWeek,
    required this.horairesError,
    required this.onToggleHoraireDay,
    required this.onPickHoraireStart,
    required this.onPickHoraireEnd,
    required this.onCapaciteChanged,
    required this.onboardingWizard,
  });

  static const wizardStepCount = PrestataireHubConstants.wizardStepCount;
  static const optionalFromStep = PrestataireHubConstants.optionalFromStep;

  final PrestataireProfileFormData data;
  final PrestataireProfileEditSection? focusedSection;
  final int currentStep;
  final bool saving;
  final double? uploadProgress;
  final TextEditingController nomController;
  final TextEditingController nomAfficheController;
  final TextEditingController descriptionController;
  final TextEditingController experienceProController;
  final TextEditingController anneesExperienceController;
  final List<ProfessionalExperienceEntry> professionalExperiences;
  final ValueChanged<String> onToggleProfessionalExperience;
  final void Function(String role, String years) onProfessionalExperienceYearsChanged;
  final ValueChanged<String> onRemoveProfessionalExperience;
  final TextEditingController bioController;
  final TextEditingController villeController;
  final TextEditingController codePostalController;
  final TextEditingController adresseController;
  final String voieType;
  final ValueChanged<String> onVoieTypeChanged;
  final TextEditingController voieNomController;
  final TextEditingController numeroRueController;
  final TextEditingController paysController;
  final VoidCallback onPostalAddressChanged;
  final String paysCode;
  final LieuTravail? lieuTravail;
  final String? avatarUrl;
  final Uint8List? avatarBytes;
  final List<PrestataireServiceFieldSet> services;
  final PrestataireServiceCatalogSelection catalogSelection;
  final TextEditingController suggestionNomController;
  final TextEditingController suggestionDescController;
  final Set<String> selectedComfortIds;
  final Set<String> selectedConditionIds;
  final ValueChanged<String> onComfortToggled;
  final ValueChanged<String> onConditionToggled;
  final ValueChanged<String> onAddCustomComfort;
  final ValueChanged<String> onAddCustomCondition;
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
  final List<PhotoRealisation> galleryPhotos;
  final List<PendingRealisationUpload> pendingGallery;
  final String? galleryError;
  final ValueChanged<int> onStepTapped;
  final VoidCallback onContinue;
  final VoidCallback onCancel;
  final VoidCallback onSkip;
  final VoidCallback onCompleteLater;
  final VoidCallback onBasicsChanged;
  final ValueChanged<LieuTravail> onLieuTravailChanged;
  final VoidCallback onPickAvatar;
  final List<String> defaultAvatarUrls;
  final String? selectedDefaultAvatarUrl;
  final ValueChanged<String> onSelectDefaultAvatar;
  final ValueChanged<RealisationGallerySlot> onPickGalleryForSlot;
  final ValueChanged<RealisationGallerySlot> onPickGalleryVideoForSlot;
  final ValueChanged<PhotoRealisation> onRemoveGalleryPhoto;
  final ValueChanged<PendingRealisationUpload> onRemovePendingGallery;
  final VoidCallback onCatalogChanged;
  final VoidCallback onPricingChanged;
  final List<WeeklyJourHoraire>? horaireWeek;
  final String? horairesError;
  final void Function(int index, bool enabled) onToggleHoraireDay;
  final Future<void> Function(int index) onPickHoraireStart;
  final Future<void> Function(int index) onPickHoraireEnd;
  final void Function(int index, int capacite) onCapaciteChanged;
  final bool onboardingWizard;

  String _hubStepGoal(int step) => switch (step) {
        0 => DiscPrestaForm.hubGoalBasics,
        1 => DiscPrestaForm.hubGoalLocation,
        2 => DiscPrestaForm.hubGoalServices,
        3 => DiscPrestaForm.hubGoalHoraires,
        4 => DiscPrestaForm.hubGoalGallery,
        5 => DiscPrestaForm.hubGoalComfort,
        _ => DiscPrestaForm.hubGoalSubscription,
      };

  HubStepRequirement? _hubStepRequirement(int step) => switch (step) {
        0 || 1 || 2 || 3 => HubStepRequirement.required,
        4 || 5 => HubStepRequirement.recommended,
        _ => HubStepRequirement.optional,
      };

  Widget _stepContent(
    PrestataireProfileEditSection section, {
    bool guided = false,
  }) {
    return switch (section) {
      PrestataireProfileEditSection.vitrine => PrestataireProfileBasicsStep(
        guidedMode: guided,
        nomController: nomController,
        nomAfficheController: nomAfficheController,
        descriptionController: descriptionController,
        experienceProController: experienceProController,
        anneesExperienceController: anneesExperienceController,
        professionalExperiences: professionalExperiences,
        onToggleProfessionalExperience: onToggleProfessionalExperience,
        onProfessionalExperienceYearsChanged: onProfessionalExperienceYearsChanged,
        onRemoveProfessionalExperience: onRemoveProfessionalExperience,
        bioController: bioController,
        villeController: villeController,
        codePostalController: codePostalController,
        adresseController: adresseController,
        voieType: voieType,
        onVoieTypeChanged: onVoieTypeChanged,
        voieNomController: voieNomController,
        numeroRueController: numeroRueController,
        paysController: paysController,
        onPostalAddressChanged: onPostalAddressChanged,
        lieuTravail: lieuTravail,
        avatarUrl: avatarUrl,
        avatarBytes: avatarBytes,
        nomError: nomError,
        nomAfficheError: nomAfficheError,
        descriptionError: descriptionError,
        experienceProError: experienceProError,
        villeError: villeError,
        codePostalError: codePostalError,
        adresseError: adresseError,
        lieuTravailError: lieuTravailError,
        avatarError: avatarError,
        uploadProgress: uploadProgress,
        onPickAvatar: onPickAvatar,
        defaultAvatarUrls: defaultAvatarUrls,
        selectedDefaultAvatarUrl: selectedDefaultAvatarUrl,
        onSelectDefaultAvatar: onSelectDefaultAvatar,
        onLieuTravailChanged: onLieuTravailChanged,
        onChanged: onBasicsChanged,
        vitrineOnly: true,
      ),
      PrestataireProfileEditSection.location => PrestataireProfileBasicsStep(
        guidedMode: guided,
        nomController: nomController,
        nomAfficheController: nomAfficheController,
        descriptionController: descriptionController,
        experienceProController: experienceProController,
        anneesExperienceController: anneesExperienceController,
        professionalExperiences: professionalExperiences,
        onToggleProfessionalExperience: onToggleProfessionalExperience,
        onProfessionalExperienceYearsChanged: onProfessionalExperienceYearsChanged,
        onRemoveProfessionalExperience: onRemoveProfessionalExperience,
        bioController: bioController,
        villeController: villeController,
        codePostalController: codePostalController,
        adresseController: adresseController,
        voieType: voieType,
        onVoieTypeChanged: onVoieTypeChanged,
        voieNomController: voieNomController,
        numeroRueController: numeroRueController,
        paysController: paysController,
        onPostalAddressChanged: onPostalAddressChanged,
        lieuTravail: lieuTravail,
        avatarUrl: avatarUrl,
        avatarBytes: avatarBytes,
        nomError: nomError,
        nomAfficheError: nomAfficheError,
        descriptionError: descriptionError,
        experienceProError: experienceProError,
        villeError: villeError,
        codePostalError: codePostalError,
        adresseError: adresseError,
        lieuTravailError: lieuTravailError,
        avatarError: avatarError,
        uploadProgress: uploadProgress,
        onPickAvatar: onPickAvatar,
        defaultAvatarUrls: defaultAvatarUrls,
        selectedDefaultAvatarUrl: selectedDefaultAvatarUrl,
        onSelectDefaultAvatar: onSelectDefaultAvatar,
        onLieuTravailChanged: onLieuTravailChanged,
        onChanged: onBasicsChanged,
        locationOnly: true,
      ),
      PrestataireProfileEditSection.services =>
          PrestataireOnboardingServicesPanel(
        key: const ValueKey('presta-services-guided-wizard'),
        catalogSelection: catalogSelection,
        services: services,
        catalogError: servicesError,
        pricingError: pricingError,
        onCatalogChanged: onCatalogChanged,
        onPricingChanged: onPricingChanged,
        editMode: !guided,
      ),
      PrestataireProfileEditSection.gallery => PrestataireProfileGalleryStep(
        photos: galleryPhotos,
        pendingUploads: pendingGallery,
        slots: buildRealisationGallerySlots(
          catalogSelection: catalogSelection,
          serviceFields: services,
        ),
        errorText: galleryError,
        uploading: false,
        uploadProgress: null,
        onPickForSlot: onPickGalleryForSlot,
        onPickVideoForSlot: onPickGalleryVideoForSlot,
        onRemoveExisting: onRemoveGalleryPhoto,
        onRemovePending: onRemovePendingGallery,
        embeddedInHub: guided,
      ),
      PrestataireProfileEditSection.clientExperience =>
        PrestataireProfileClientExperienceStep(
          selectedComfortIds: selectedComfortIds,
          selectedConditionIds: selectedConditionIds,
          onComfortToggled: onComfortToggled,
          onConditionToggled: onConditionToggled,
          onAddCustomComfort: onAddCustomComfort,
          onAddCustomCondition: onAddCustomCondition,
          onChanged: onBasicsChanged,
          embeddedInHub: guided,
        ),
      PrestataireProfileEditSection.horaires => horaireWeek == null
          ? const DiscoveryListSkeleton(
              rowCount: 3,
              rowHeight: 56,
              padding: EdgeInsets.symmetric(vertical: 8),
            )
          : Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                PrestataireWeeklyHorairesEditor(
                  jours: horaireWeek!,
                  errorText: horairesError,
                  onToggleDay: onToggleHoraireDay,
                  onPickStart: onPickHoraireStart,
                  onPickEnd: onPickHoraireEnd,
                  onCapaciteChanged: onCapaciteChanged,
                  showIntro: !guided,
                  embeddedInHub: guided,
                ),
                SizedBox(
                  height: guided
                      ? PrestataireHubLayout.blockGap
                      : 28,
                ),
                PrestataireIndisponibilitesEditor(embeddedInHub: guided),
              ],
            ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final focused = focusedSection;

    if (focused != null) {
      return PrestataireFormScrollView(
        padding: PrestataireHubLayout.pagePadding(context),
        children: [
          _stepContent(focused, guided: false),
          const SizedBox(height: 20),
          FilledButton(
            onPressed: saving ? null : onContinue,
            child: Text(
              saving ? DiscPrestaForm.saving : DiscPrestaForm.save,
            ),
          ),
        ],
      );
    }

    final isSubscriptionStep = currentStep == wizardStepCount - 1;
    final currentSection = switch (currentStep) {
      0 => PrestataireProfileEditSection.vitrine,
      1 => PrestataireProfileEditSection.location,
      2 => PrestataireProfileEditSection.services,
      3 => PrestataireProfileEditSection.horaires,
      4 => PrestataireProfileEditSection.gallery,
      5 => PrestataireProfileEditSection.clientExperience,
      _ => PrestataireProfileEditSection.horaires,
    };
    final currentTitle = switch (currentStep) {
      0 => DiscPrestaForm.stepBasics,
      1 => DiscPrestaForm.stepLocation,
      2 => DiscPrestaForm.stepServices,
      3 => DiscPrestaForm.stepHoraires,
      4 => DiscPrestaForm.stepGallery,
      5 => DiscPrestaForm.stepComfort,
      _ => DiscPrestaSub.onboardingTitle,
    };
    final stepGoal = _hubStepGoal(currentStep);
    final stepRequirement = _hubStepRequirement(currentStep);
    final isLast = currentStep == wizardStepCount - 1;
    final isOptionalStep =
        onboardingWizard && currentStep >= optionalFromStep && !isLast;
    final continueLabel = saving
        ? DiscPrestaForm.saving
        : isLast
            ? DiscPrestaForm.saveProfile
            : DiscPrestaForm.onward;

    final steps = kPrestataireHubSteps;
    final stepMeta = steps[currentStep.clamp(0, steps.length - 1)];
    final wrapStepInSurfaceCard = !isSubscriptionStep &&
        currentSection == PrestataireProfileEditSection.gallery;

    Widget stepInner = _stepContent(
      currentSection,
      guided: onboardingWizard,
    );
    if (wrapStepInSurfaceCard) {
      stepInner = PrestataireHubSurfaceCard(child: stepInner);
    }

    final stepBody = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (onboardingWizard) ...[
          PrestataireHubWizardProgress(
            currentStep: currentStep,
            totalSteps: wizardStepCount,
            saving: saving,
          ),
          const SizedBox(height: 8),
          PrestataireHubWizardStepCaption(
            currentStep: currentStep,
            totalSteps: wizardStepCount,
            stepTitle: currentTitle,
          ),
          const SizedBox(height: PrestataireHubLayout.sectionGap),
          PrestataireHubStepNavigator(
            steps: steps,
            currentStep: currentStep,
            enabled: !saving,
            onTap: onStepTapped,
          ),
          const SizedBox(height: PrestataireHubLayout.sectionGap),
        ],
        PrestataireHubStepFrame(
          stepIndex: currentStep + 1,
          stepTotal: wizardStepCount,
          icon: stepMeta.icon,
          title: currentTitle,
          goal: stepGoal,
          requirement: stepRequirement,
          stepTip: DiscPrestaForm.hubStepTip(currentStep),
          child: isSubscriptionStep
              ? PrestataireSubscriptionOnboardingPanel(
                  compact: true,
                  embeddedInHub: true,
                  plannedServiceCount:
                      PrestataireSubscriptionServiceCount.fromHubForm(
                    catalogSelection: catalogSelection,
                    serviceFields: services,
                  ),
                )
              : stepInner,
        ),
        const SizedBox(height: PrestataireHubLayout.blockGap),
        PrestataireHubStepActions(
          primaryLabel: continueLabel,
          onPrimary: onContinue,
          saving: saving,
          onBack: currentStep > 0 ? onCancel : null,
          onSkip: isOptionalStep ? onSkip : null,
          onCompleteLater: isOptionalStep ? onCompleteLater : null,
          showSkip: isOptionalStep,
          showCompleteLater: isOptionalStep,
        ),
      ],
    );

    final pagePad = PrestataireHubLayout.pagePadding(context);

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        if (!wide) {
          return PrestataireFormScrollView(
            padding: pagePad,
            children: [stepBody],
          );
        }
        return PrestataireFormScrollView(
          padding: pagePad,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 62, child: stepBody),
                const SizedBox(width: PrestataireHubLayout.blockGap),
                Expanded(
                  flex: 38,
                  child: PrestataireHubStepsRail(
                    steps: steps,
                    currentStep: currentStep,
                    saving: saving,
                    onTap: !saving ? onStepTapped : null,
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}
