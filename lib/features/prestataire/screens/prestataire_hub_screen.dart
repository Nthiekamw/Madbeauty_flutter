import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/models/domain/availability/horaire_plage.dart';
import '../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../core/models/domain/user/lieu_travail.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/prestataire/photos/photo_realisation_providers.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../models/prestataire_profile_edit_section.dart';
import '../models/prestataire_service_catalog_selection.dart';
import '../models/prestataire_service_field_set.dart';
import '../providers/prestataire_profile_form_provider.dart';
import '../widgets/profile/hub/prestataire_hub_layout.dart';
import '../widgets/profile/prestataire_hub_step_frame.dart';
import '../widgets/profile/overview/prestataire_form_scroll_view.dart';
import '../widgets/profile/steps/prestataire_hub_steps.dart';
import '../widgets/profile/steps/service_wizard_shine.dart';
import '../logic/prestataire_profile_completeness.dart';
import '../models/weekly_jour_horaire.dart';
import '../providers/disponibilite_provider.dart';
import '../widgets/dialogs/prestataire_onboarding_finish_dialog.dart';
import '../widgets/profile/overview/prestataire_profile_load_error.dart';
import '../widgets/workspace/prestataire_brand_scaffold.dart';
import '../widgets/profile/schedule/prestataire_indisponibilites_editor.dart';
import '../widgets/profile/schedule/prestataire_weekly_horaires_editor.dart';
import '../widgets/profile/subscription/prestataire_subscription_onboarding_panel.dart';
import '../../../services/supabase/disponibilite/disponibilite_service_providers.dart';
import '../providers/current_prestataire_provider.dart';
import '../providers/resolve_prestataire_id.dart';
import '../../profile/logic/prestataire_hub_onboarding_draft.dart';
import '../navigation/prestataire_hub_wizard_navigation.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/layout/keyboard_dismiss_area.dart';

/// Formulaire de profil professionnel prestataire.
class PrestataireHubScreen extends ConsumerStatefulWidget {
  const PrestataireHubScreen({
    super.key,
    this.focusedSection,
    this.initialStep,
  });

  final PrestataireProfileEditSection? focusedSection;

  /// Étape initiale du wizard (0–6) lorsque [focusedSection] est null.
  final int? initialStep;

  @override
  ConsumerState<PrestataireHubScreen> createState() =>
      _PrestataireHubScreenState();
}

class _PrestataireHubScreenState extends ConsumerState<PrestataireHubScreen> {
  static const _galleryMaxPhotos = 10;
  static const wizardStepCount = 7;
  static const optionalFromStep = 4;
  static const _defaultAvatarUrls = <String>[
    'https://api.dicebear.com/9.x/adventurer/png?seed=MadBeauty1',
    'https://api.dicebear.com/9.x/adventurer/png?seed=MadBeauty2',
    'https://api.dicebear.com/9.x/adventurer/png?seed=MadBeauty3',
    'https://api.dicebear.com/9.x/adventurer/png?seed=MadBeauty4',
    'https://api.dicebear.com/9.x/adventurer/png?seed=MadBeauty5',
    'https://api.dicebear.com/9.x/adventurer/png?seed=MadBeauty6',
  ];

  final _nomController = TextEditingController();
  final _nomAfficheController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _experienceProController = TextEditingController();
  final _anneesExperienceController = TextEditingController();
  final _bioController = TextEditingController();
  final _villeController = TextEditingController();
  final _codePostalController = TextEditingController();
  final _adresseController = TextEditingController();
  final _suggestionNomController = TextEditingController();
  final _suggestionDescController = TextEditingController();
  final _services = <PrestataireServiceFieldSet>[];
  var _catalogSelection = PrestataireServiceCatalogSelection();
  final _selectedComfortIds = <String>{};
  final _selectedConditionIds = <String>{};

  var _currentStep = 0;
  var _hydrated = false;
  var _saving = false;
  double? _uploadProgress;
  LieuTravail? _lieuTravail;
  Uint8List? _avatarBytes;
  String? _avatarFileName;
  String? _avatarMimeType;
  String? _avatarUrl;

  String? _avatarError;
  String? _nomError;
  String? _nomAfficheError;
  String? _descriptionError;
  String? _experienceProError;
  String? _villeError;
  String? _codePostalError;
  String? _adresseError;
  String? _lieuTravailError;
  String? _servicesError;
  String? _pricingError;
  String? _galleryError;
  List<PhotoRealisation> _galleryPhotos = [];
  final _pendingGallery = <StorageUploadFile>[];
  PrestataireProfileFormData? _loadedData;
  final _hubDraftDebouncer = HubOnboardingDraftDebouncer();
  var _hubDraftApplied = false;
  List<WeeklyJourHoraire>? _horaireWeek;
  var _horairesHydrated = false;
  var _horairesFromDraft = false;
  String? _horairesError;

  @override
  void initState() {
    super.initState();
    final section = widget.focusedSection;
    if (section != null) {
      _currentStep = section.hubStepIndex;
    } else if (widget.initialStep != null) {
      _currentStep = widget.initialStep!.clamp(0, wizardStepCount - 1);
      unawaited(
        PrestataireHubWizardNavigation.prepareWizardSession(step: _currentStep),
      );
    }
    if (PrestataireHubOnboardingDraft.isActive) {
      unawaited(PrestataireHubOnboardingDraft.markStep2Started());
      _attachOnboardingDraftListeners();
    }
  }

  void _onOnboardingFieldChanged() => _schedulePersistHubDraft();

  void _attachOnboardingDraftListeners() {
    for (final c in [
      _nomController,
      _nomAfficheController,
      _descriptionController,
      _experienceProController,
      _anneesExperienceController,
      _bioController,
      _villeController,
      _codePostalController,
      _adresseController,
      _suggestionNomController,
      _suggestionDescController,
    ]) {
      c.addListener(_onOnboardingFieldChanged);
    }
  }

  void _detachOnboardingDraftListeners() {
    for (final c in [
      _nomController,
      _nomAfficheController,
      _descriptionController,
      _experienceProController,
      _anneesExperienceController,
      _bioController,
      _villeController,
      _codePostalController,
      _adresseController,
      _suggestionNomController,
      _suggestionDescController,
    ]) {
      c.removeListener(_onOnboardingFieldChanged);
    }
  }

  void _schedulePersistHubDraft() {
    if (!PrestataireHubOnboardingDraft.isActive) return;
    _hubDraftDebouncer.schedule(_persistOnboardingHubDraft);
  }

  Future<void> _persistOnboardingHubDraft() async {
    if (!PrestataireHubOnboardingDraft.isActive) return;
    try {
      await _persistOnboardingHubDraftUnchecked();
    } catch (_) {
      // Brouillon local : ne pas bloquer la navigation.
    }
  }

  Future<void> _persistOnboardingHubDraftUnchecked() async {
    if (!PrestataireHubOnboardingDraft.isActive) return;
    final step = widget.focusedSection?.hubStepIndex ?? _currentStep;
    await PrestataireHubOnboardingDraft.persist(
      currentStep: step,
      nomSalon: _nomController.text,
      nomAffiche: _nomAfficheController.text,
      bio: _bioController.text,
      description: _descriptionController.text,
      experienceProfessionnelle: _experienceProController.text,
      anneesExperience: _anneesExperienceController.text,
      ville: _villeController.text,
      codePostal: _codePostalController.text,
      adresse: _adresseController.text,
      lieuTravail: _lieuTravail,
      avatarUrl: _avatarUrl,
      suggestionCategorieNom: _suggestionNomController.text,
      suggestionCategorieDescription: _suggestionDescController.text,
      confortClient: _selectedComfortIds,
      conditionsService: _selectedConditionIds,
      services: _services,
      horaireWeek: _horaireWeek,
    );
  }

  void _maybeApplyOnboardingHubDraft() {
    if (_hubDraftApplied || !PrestataireHubOnboardingDraft.isActive) return;
    final hub = PrestataireHubOnboardingDraft.readHub();
    if (hub == null) return;

    PrestataireHubOnboardingDraft.applyHubDraft(
      hub: hub,
      setCurrentStep: (step) {
        if (widget.focusedSection == null) {
          _currentStep = step.clamp(0, wizardStepCount - 1);
        }
      },
      nomController: _nomController,
      nomAfficheController: _nomAfficheController,
      bioController: _bioController,
      descriptionController: _descriptionController,
      experienceProController: _experienceProController,
      anneesExperienceController: _anneesExperienceController,
      villeController: _villeController,
      codePostalController: _codePostalController,
      adresseController: _adresseController,
      setLieuTravail: (value) => _lieuTravail = value,
      setAvatarUrl: (url) => _avatarUrl = url,
      suggestionNomController: _suggestionNomController,
      suggestionDescController: _suggestionDescController,
      setComfortIds: (ids) {
        _selectedComfortIds
          ..clear()
          ..addAll(ids);
      },
      setConditionIds: (ids) {
        _selectedConditionIds
          ..clear()
          ..addAll(ids);
      },
      replaceServices: (list) {
        _disposeServices();
        _services.addAll(list);
      },
      setHoraireWeek: (week) {
        _horaireWeek = week;
        _horairesHydrated = true;
        _horairesFromDraft = true;
      },
    );
    _hubDraftApplied = true;
  }

  void _prepareOnboardingDraftRestore() {
    if (!PrestataireHubOnboardingDraft.isActive) return;
    PrestataireHubOnboardingDraft.seedBasicsFromBecomeDraft(
      nomController: _nomController,
      villeController: _villeController,
      bioController: _bioController,
      nomAfficheController: _nomAfficheController,
    );
    _maybeApplyOnboardingHubDraft();
    if (!_hubDraftApplied) {
      unawaited(_persistOnboardingHubDraft());
    }
  }

  @override
  void dispose() {
    if (PrestataireHubOnboardingDraft.isActive) {
      _detachOnboardingDraftListeners();
      unawaited(_persistOnboardingHubDraft());
    }
    _hubDraftDebouncer.dispose();
    _nomController.dispose();
    _nomAfficheController.dispose();
    _descriptionController.dispose();
    _experienceProController.dispose();
    _anneesExperienceController.dispose();
    _bioController.dispose();
    _villeController.dispose();
    _codePostalController.dispose();
    _adresseController.dispose();
    _suggestionNomController.dispose();
    _suggestionDescController.dispose();
    _disposeServices();
    super.dispose();
  }

  void _disposeServices() {
    for (final service in _services) {
      service.dispose();
    }
    _services.clear();
  }

  void _hydrate(PrestataireProfileFormData data, {bool force = false}) {
    if (_hydrated && !force) return;
    _loadedData = data;
    _nomController.text = data.nomSalon;
    _nomAfficheController.text = data.nomAffiche;
    _descriptionController.text = data.description;
    _experienceProController.text = data.experienceProfessionnelle;
    _anneesExperienceController.text = data.anneesExperience;
    _bioController.text = data.bio;
    _villeController.text = data.ville;
    _codePostalController.text = data.codePostal;
    _adresseController.text = data.adresse;
    _lieuTravail = data.lieuTravail;
    _selectedComfortIds
      ..clear()
      ..addAll(data.confortClient);
    _selectedConditionIds
      ..clear()
      ..addAll(data.conditionsService);
    _suggestionNomController.text = data.suggestionCategorieNom;
    _suggestionDescController.text = data.suggestionCategorieDescription;
    _galleryPhotos = List<PhotoRealisation>.from(data.realisationPhotos);
    _avatarUrl = data.avatarUrl;
    _avatarBytes = null;
    _avatarFileName = null;
    _avatarMimeType = null;
    _catalogSelection = PrestataireServiceCatalogSelection.fromProfileData(
      selectedCategoryIds: data.selectedCategoryIds,
      services: data.services,
      legacySuggestionLabels: data.customSpecialtyLabels,
    );
    _disposeServices();
    for (final service in data.services) {
      _services.add(PrestataireServiceFieldSet.fromData(service));
    }
    _hydrated = true;
    if (!force) {
      _prepareOnboardingDraftRestore();
    }
  }

  Future<void> _pickAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null) return;

    final uploadFile = await StorageUploadFile.fromXFile(picked);
    try {
      StorageService.validateImageFile(uploadFile);
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() => _avatarError = e.message);
      return;
    }
    if (!mounted) return;

    setState(() {
      _avatarBytes = uploadFile.bytes;
      _avatarFileName = uploadFile.fileName;
      _avatarMimeType = uploadFile.mimeType;
      _avatarError = null;
    });
    _schedulePersistHubDraft();
  }

  void _selectDefaultAvatar(String avatarUrl) {
    setState(() {
      _avatarUrl = avatarUrl;
      _avatarBytes = null;
      _avatarFileName = null;
      _avatarMimeType = null;
      _avatarError = null;
    });
    _schedulePersistHubDraft();
  }

  Future<void> _pickGallery() async {
    final picked = await ImagePicker().pickMultiImage(
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked.isEmpty) return;
    for (final file in picked) {
      if (_galleryPhotos.length + _pendingGallery.length >= _galleryMaxPhotos) {
        break;
      }
      final uploadFile = await StorageUploadFile.fromXFile(file);
      try {
        StorageService.validateImageFile(uploadFile);
        if (!mounted) return;
        setState(() {
          _pendingGallery.add(uploadFile);
          _galleryError = null;
        });
      } on AppFailure {
        // ignore
      }
    }
  }

  Future<void> _removeGalleryPhoto(PhotoRealisation photo) async {
    final photoService = ref.read(photoRealisationServiceProvider);
    if (photoService == null) return;
    await photoService.delete(photo.id);
    if (!mounted) return;
    setState(() {
      _galleryPhotos = _galleryPhotos.where((p) => p.id != photo.id).toList();
    });
  }

  bool _validateVitrine() {
    final nom = _nomController.text.trim();
    final nomAffiche = _nomAfficheController.text.trim();
    final description = _descriptionController.text.trim();
    final experiencePro = _experienceProController.text.trim();
    final hasAvatar =
        _avatarBytes != null ||
        (_avatarUrl != null && _avatarUrl!.trim().isNotEmpty);

    setState(() {
      _avatarError = hasAvatar ? null : DiscPrestaForm.reqPhoto;
      _nomError = nom.isEmpty ? DiscPrestaForm.reqNameSalon : null;
      _nomAfficheError =
          nomAffiche.isEmpty ? DiscPrestaForm.reqDisplayName : null;
      _descriptionError = description.isEmpty
          ? DiscPrestaForm.reqDescription
          : description.characters.length > 200
          ? DiscPrestaForm.descriptionTooLong
          : null;
      _experienceProError = experiencePro.length > 150
          ? DiscPrestaForm.experienceProTooLong
          : null;
    });

    return _avatarError == null &&
        _nomError == null &&
        _nomAfficheError == null &&
        _descriptionError == null &&
        _experienceProError == null;
  }

  bool _validateLocation() {
    final ville = _villeController.text.trim();
    final codePostal = _codePostalController.text.trim();
    final adresse = _adresseController.text.trim();

    setState(() {
      _villeError = ville.isEmpty ? DiscPrestaForm.reqCity : null;
      _codePostalError =
          codePostal.isEmpty ? DiscPrestaForm.reqPostalCode : null;
      _adresseError = adresse.isEmpty ? DiscPrestaForm.reqAddress : null;
      _lieuTravailError =
          _lieuTravail == null ? DiscPrestaForm.reqWorkLocation : null;
    });

    return _villeError == null &&
        _codePostalError == null &&
        _adresseError == null &&
        _lieuTravailError == null;
  }

  bool _validateCurrentStep() {
    final focused = widget.focusedSection;
    if (focused != null) {
      return switch (focused) {
        PrestataireProfileEditSection.vitrine => _validateVitrine(),
        PrestataireProfileEditSection.location => _validateLocation(),
        PrestataireProfileEditSection.services => _validateServices(),
        PrestataireProfileEditSection.gallery => true,
        PrestataireProfileEditSection.clientExperience => true,
        PrestataireProfileEditSection.horaires => _validateHoraires(),
      };
    }
    return switch (_currentStep) {
      0 => _validateVitrine(),
      1 => _validateLocation(),
      2 => _validateServices(),
      3 => _validateHoraires(),
      _ => true,
    };
  }

  bool _validateHoraires() {
    final jours = _horaireWeek;
    if (jours == null) {
      setState(() => _horairesError = DiscPrestaHoraires.loadErr);
      return false;
    }
    if (!jours.hasAnyOpenDay) {
      setState(() => _horairesError = DiscPrestaHoraires.reqOpenDay);
      return false;
    }
    if (!jours.validatePlages()) {
      setState(() => _horairesError = DiscPrestaHoraires.invalidPlage);
      return false;
    }
    setState(() => _horairesError = null);
    return true;
  }

  /// Première étape obligatoire (0–3) non valide, ou `null` si tout est OK.
  int? _firstMandatoryStepFailure() {
    if (!_validateVitrine()) return 0;
    if (!_validateLocation()) return 1;
    if (!_validateServices()) return 2;
    if (!_validateHoraires()) return 3;
    return null;
  }

  Future<void> _prepareSavePayload() async {
    FocusScope.of(context).unfocus();
    await _persistOnboardingHubDraft();
    _syncServicesFromCatalog();
  }

  void _ensureHoraireWeek(List<HorairePlage> plages) {
    if (_horairesHydrated) return;
    _horaireWeek = WeeklyJourHoraire.fromPlages(plages);
    _horairesHydrated = true;
  }

  Future<void> _pickHoraireTime(int index, bool isStart) async {
    final jours = _horaireWeek;
    if (jours == null) return;
    final jour = jours[index];
    final initial = isStart ? jour.debut : jour.fin;
    final picked = await showTimePicker(
      context: context,
      initialTime: initial,
    );
    if (picked == null || !mounted) return;
    setState(() {
      if (isStart) {
        jour.debut = picked;
      } else {
        jour.fin = picked;
      }
      _horairesError = null;
    });
    _schedulePersistHubDraft();
  }

  bool get _shouldPersistHoraires =>
      widget.focusedSection == null ||
      widget.focusedSection == PrestataireProfileEditSection.horaires ||
      _currentStep == 3;

  Future<bool> _saveHorairesIfNeeded() async {
    final jours = _horaireWeek;
    if (jours == null) return true;

    if (jours.hasAnyOpenDay && !jours.validatePlages()) {
      setState(() => _horairesError = DiscPrestaHoraires.invalidPlage);
      if (mounted) {
        _showSnack(DiscPrestaHoraires.invalidPlage, kind: AppSnackKind.error);
      }
      return false;
    }

    final service = ref.read(disponibiliteServiceProvider);
    final prestaId = await resolveConnectedPrestataireId(ref.container);
    if (service == null || prestaId == null) {
      setState(() => _horairesError = DiscPrestaHoraires.congesProfileErr);
      if (mounted) {
        _showSnack(DiscPrestaHoraires.congesProfileErr, kind: AppSnackKind.error);
      }
      return false;
    }

    await service.setHoraires(prestaId, jours.toPlages());
    invalidateDisponibiliteProviders(ref);
    if (mounted && widget.focusedSection == PrestataireProfileEditSection.horaires) {
      _showSnack(DiscPrestaHoraires.saveOk, kind: AppSnackKind.success);
    }
    return true;
  }

  Future<void> _maybeShowFinishSummary(PrestataireProfileFormData data) async {
    if (widget.focusedSection != null) return;

    final horaires = await ref.read(prestataireHorairesProvider.future);
    final hasHoraires = horaires.isNotEmpty;
    final requiredMissing =
        data.missingChecklistItems.map((item) => item.label).toList();
    final optionalMissing = data
        .missingEnhancements(hasHoraires: hasHoraires)
        .map((item) => item.label)
        .toList();

    if (data.isProfileFullyEnriched(hasHoraires: hasHoraires) &&
        requiredMissing.isEmpty) {
      return;
    }

    if (!mounted) return;
    await showPrestataireOnboardingFinishDialog(
      context: context,
      professionallyComplete: data.isProfessionallyComplete,
      requiredMissing: requiredMissing,
      optionalMissing: optionalMissing,
      onCompleteProfile: () {
        if (context.canPop()) {
          context.pop();
        }
        context.goPrestataireProfile();
      },
    );
  }

  void _syncServicesFromCatalog() {
    final preserved = <String, ({String? id, String prix, String duree})>{};
    for (final s in _services) {
      final idKey = s.id?.trim();
      if (idKey != null && idKey.isNotEmpty) {
        preserved[idKey] = (
          id: s.id,
          prix: s.prixController.text,
          duree: s.dureeController.text,
        );
      }
      preserved[s.nomController.text.trim().toLowerCase()] = (
        id: s.id,
        prix: s.prixController.text,
        duree: s.dureeController.text,
      );
    }
    final existing = _services
        .map(
          (s) => PrestataireServiceFormData(
            id: s.id,
            nom: s.nomController.text.trim(),
            description: s.descriptionController.text.trim(),
            categorieId: s.categorieId,
            prix: _parsePrice(s.prixController.text) ?? 0,
            dureeMinutes:
                int.tryParse(s.dureeController.text.trim()) ?? 60,
          ),
        )
        .toList();
    final generated =
        _catalogSelection.toServiceFormData(existing: existing);
    _disposeServices();
    for (final service in generated) {
      final nameKey = service.nom.trim().toLowerCase();
      final keep = (service.id != null ? preserved[service.id!] : null) ??
          preserved[nameKey];
      _services.add(
        PrestataireServiceFieldSet(
          id: keep?.id ?? service.id,
          nom: service.nom,
          description: service.description,
          categorieId: service.categorieId,
          prix: keep?.prix ?? _prixFieldText(service.prix),
          duree: keep?.duree ?? service.dureeMinutes.toString(),
        ),
      );
    }
  }

  /// Texte affiché dans le champ prix (vide si non renseigné).
  String _prixFieldText(double prix) {
    if (prix <= 0) return '';
    return prix == prix.roundToDouble()
        ? prix.toInt().toString()
        : prix.toStringAsFixed(2);
  }

  bool _validatePricing() {
    var valid = true;
    for (final service in _services) {
      final price = _parsePrice(service.prixController.text);
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
    return valid;
  }

  bool _validateServices() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_catalogSelection.isValid &&
        (_services.isEmpty ||
            _services.length != _catalogSelection.specialtyCount)) {
      _syncServicesFromCatalog();
    }

    var valid = true;
    setState(() {
      if (!_catalogSelection.isValid) {
        _servicesError = _catalogSelection.selectedMains.isEmpty
            ? DiscPrestaForm.reqCatalogMain
            : DiscPrestaForm.reqCatalogSpecialty;
        _pricingError = null;
        valid = false;
      } else {
        _servicesError = null;
        if (_services.isEmpty) {
          _pricingError = DiscPrestaForm.pricingEmptyHint;
          valid = false;
        } else {
          final pricingOk = _validatePricing();
          _pricingError = pricingOk ? null : DiscPrestaForm.reqPricing;
          valid = pricingOk;
        }
      }
    });
    return valid;
  }

  double? _parsePrice(String raw) => parsePrestataireServicePrice(raw);

  PrestataireProfileSavePayload _buildSavePayload() {
    return PrestataireProfileSavePayload(
      nomSalon: _nomController.text.trim(),
      nomAffiche: _nomAfficheController.text.trim(),
      bio: _bioController.text.trim(),
      description: _descriptionController.text.trim(),
      experienceProfessionnelle: _experienceProController.text.trim(),
      anneesExperience: _anneesExperienceController.text.trim(),
      ville: _villeController.text.trim(),
      adresse: _adresseController.text.trim(),
      codePostal: _codePostalController.text.trim(),
      lieuTravail: _lieuTravail ?? _loadedData?.lieuTravail ?? LieuTravail.both,
      avatarBytes: _avatarBytes,
      avatarFileName: _avatarFileName,
      avatarMimeType: _avatarMimeType,
      avatarUrl: _avatarUrl,
      services: _catalogSelection.toServiceFormData(
        existing: _services
            .map(
              (s) => PrestataireServiceFormData(
                id: s.id,
                nom: s.nomController.text.trim(),
                description: s.descriptionController.text.trim(),
                categorieId: s.categorieId,
                prix: _parsePrice(s.prixController.text) ?? 0,
                dureeMinutes:
                    int.tryParse(s.dureeController.text.trim()) ?? 60,
              ),
            )
            .toList(),
      ),
      specialtyCategoryIds: _catalogSelection.allCategoryIds,
      customSpecialtyLabels: _catalogSelection.allCustomLabels,
      suggestionCategorieNom: _suggestionNomController.text.trim(),
      suggestionCategorieDescription: _suggestionDescController.text.trim(),
      confortClient: _selectedComfortIds.toList(),
      conditionsService: _selectedConditionIds.toList(),
    );
  }

  void _toggleComfort(String id) {
    setState(() {
      if (_selectedComfortIds.contains(id)) {
        _selectedComfortIds.remove(id);
      } else {
        _selectedComfortIds.add(id);
      }
    });
    _schedulePersistHubDraft();
  }

  void _toggleCondition(String id) {
    setState(() {
      if (_selectedConditionIds.contains(id)) {
        _selectedConditionIds.remove(id);
      } else {
        _selectedConditionIds.add(id);
      }
    });
    _schedulePersistHubDraft();
  }

  void _addCustomComfort(String encodedId) {
    setState(() {
      if (!_selectedComfortIds.contains(encodedId)) {
        _selectedComfortIds.add(encodedId);
      }
    });
    _schedulePersistHubDraft();
  }

  void _addCustomCondition(String encodedId) {
    setState(() {
      if (!_selectedConditionIds.contains(encodedId)) {
        _selectedConditionIds.add(encodedId);
      }
    });
    _schedulePersistHubDraft();
  }

  void _continue() {
    if (widget.focusedSection != null) {
      _save();
      return;
    }
    final step = _currentStep;
    if (step == 0) {
      if (!_validateVitrine()) return;
      setState(() => _currentStep = 1);
      unawaited(_persistOnboardingHubDraft());
      return;
    }
    if (step == 1) {
      if (!_validateLocation()) return;
      setState(() => _currentStep = 2);
      unawaited(_persistOnboardingHubDraft());
      return;
    }
    if (step == 2) {
      FocusScope.of(context).unfocus();
      if (!_validateServices()) return;
      setState(() => _currentStep = 3);
      unawaited(_persistOnboardingHubDraft());
      return;
    }
    if (step == 3) {
      if (!_validateHoraires()) return;
      setState(() => _currentStep = 4);
      unawaited(_persistOnboardingHubDraft());
      return;
    }
    if (step == 4) {
      setState(() => _currentStep = 5);
      unawaited(_persistOnboardingHubDraft());
      return;
    }
    if (step == 5) {
      setState(() => _currentStep = 6);
      unawaited(_persistOnboardingHubDraft());
      return;
    }
    if (step == 6) {
      _save();
    }
  }

  void _cancel() {
    if (_currentStep == 0) return;
    setState(() => _currentStep -= 1);
    unawaited(_persistOnboardingHubDraft());
  }

  void _skip() {
    if (widget.focusedSection != null) return;
    FocusScope.of(context).unfocus();
    final step = _currentStep;
    if (step < optionalFromStep) return;
    if (step >= wizardStepCount - 1) {
      unawaited(_save());
      return;
    }
    setState(() => _currentStep += 1);
    unawaited(_persistOnboardingHubDraft());
  }

  Future<void> _completeLater() async {
    await _prepareSavePayload();

    final failed = _firstMandatoryStepFailure();
    final service = ref.read(prestataireProfileFormServiceProvider);

    var profileSaved = false;
    if (failed == null && service != null) {
      setState(() => _saving = true);
      try {
        await service.save(_buildSavePayload());
        ref.invalidate(currentPrestataireProvider);
        final horairesOk = await _saveHorairesIfNeeded();
        if (!horairesOk && mounted) {
          _showSnack(DiscPrestaHoraires.saveErr, kind: AppSnackKind.warning);
        } else {
          profileSaved = await _uploadPendingGalleryIfNeeded();
        }
      } on AppFailure catch (e) {
        if (mounted) {
          _showSnack(e.message, kind: AppSnackKind.error);
        }
      } catch (_) {
        if (mounted) {
          _showSnack(DiscPrestaForm.saveErr, kind: AppSnackKind.error);
        }
      } finally {
        if (mounted) setState(() => _saving = false);
      }
    }

    if (!mounted) return;
    if (profileSaved) {
      _showSnack(
        DiscPrestaForm.completeLaterSaved,
        kind: AppSnackKind.success,
      );
    } else if (failed != null) {
      setState(() => _currentStep = failed);
      _showSnack(
        DiscPrestaForm.completeLaterNeedsCore,
        kind: AppSnackKind.warning,
      );
      return;
    }
    context.goPrestataireDashboard();
  }

  Future<bool> _uploadPendingGalleryIfNeeded() async {
    final updated = await ref.read(prestataireProfileFormProvider.future);
    final prestataireId = updated.prestataireId;
    final photoService = ref.read(photoRealisationServiceProvider);
    if (prestataireId == null ||
        photoService == null ||
        _pendingGallery.isEmpty) {
      return true;
    }

    for (final file in _pendingGallery) {
      await photoService.uploadAndCreate(
        prestataireId: prestataireId,
        file: file,
      );
    }
    _pendingGallery.clear();
    ref.invalidate(prestataireProfileFormProvider);
    return true;
  }

  Future<void> _save() async {
    await _prepareSavePayload();

    final wizard = widget.focusedSection == null;
    if (wizard) {
      final failed = _firstMandatoryStepFailure();
      if (failed != null) {
        setState(() => _currentStep = failed);
        _showSnack(
          DiscPrestaForm.completeLaterNeedsCore,
          kind: AppSnackKind.warning,
        );
        return;
      }
    } else if (!_validateCurrentStep()) {
      return;
    }

    final service = ref.read(prestataireProfileFormServiceProvider);
    if (service == null) {
      _showSnack(DiscPrestaForm.missingSupabase, kind: AppSnackKind.warning);
      return;
    }

    setState(() {
      _saving = true;
      _uploadProgress = _avatarBytes == null ? null : 0;
    });
    try {
      await service.save(
        _buildSavePayload(),
        onAvatarUploadProgress: (progress) {
          if (!mounted) return;
          setState(() => _uploadProgress = progress);
        },
      );

      ref.invalidate(currentPrestataireProvider);

      if (_shouldPersistHoraires) {
        final horairesOk = await _saveHorairesIfNeeded();
        if (!horairesOk) {
          if (!mounted) return;
          setState(() {
            _saving = false;
            _uploadProgress = null;
            if (widget.focusedSection == null) {
              _currentStep = 3;
            }
          });
          return;
        }
      }

      var updated = await ref.refresh(prestataireProfileFormProvider.future);
      await _uploadPendingGalleryIfNeeded();
      updated = await ref.read(prestataireProfileFormProvider.future);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _uploadProgress = null;
        _hydrate(updated, force: true);
      });
      _showSnack(DiscPrestaForm.savedToast, kind: AppSnackKind.success);
      if (PrestataireHubOnboardingDraft.isActive &&
          updated.isProfessionallyComplete) {
        await PrestataireHubOnboardingDraft.clearAfterProfileComplete();
      }
      await _maybeShowFinishSummary(updated);
      if (mounted) {
        if (context.canPop()) {
          context.pop();
        } else {
          context.goPrestataireDashboard();
        }
      }
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _uploadProgress = null;
      });
      _showSnack(e.message, kind: AppSnackKind.error);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _uploadProgress = null;
      });
      _showSnack(DiscPrestaForm.saveErr, kind: AppSnackKind.error);
    }
  }

  void _showSnack(String message, {AppSnackKind kind = AppSnackKind.info}) {
    if (!mounted) return;
    AppSnackBar.show(context, message: message, kind: kind);
  }

  @override
  Widget build(BuildContext context) {
    final compactTopAction = MediaQuery.sizeOf(context).width < 390;
    final async = ref.watch(prestataireProfileFormProvider);
    final horairesAsync = ref.watch(prestataireHorairesProvider);
    horairesAsync.whenData((plages) {
      if (!_horairesHydrated && !_horairesFromDraft && mounted) {
        setState(() => _ensureHoraireWeek(plages));
      }
    });

    final focused = widget.focusedSection;

    final onboarding = PrestataireHubOnboardingDraft.isActive;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && onboarding) {
          unawaited(_persistOnboardingHubDraft());
        }
      },
      child: PrestataireBrandScaffold(
        appBar: prestataireBrandAppBar(
          context: context,
          title: Text(
            focused?.screenTitle ?? DiscPrestaProfile.editTitle,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
              color: Theme.of(context).colorScheme.onSurface,
              letterSpacing: -0.3,
            ),
          ),
          actions: [
            if (onboarding &&
                focused == null &&
                _currentStep >= optionalFromStep &&
                _currentStep < wizardStepCount - 1)
              TextButton(
                onPressed: _saving ? null : _completeLater,
                child: Text(
                  compactTopAction
                      ? DiscPrestaForm.onboardingFinishLater
                      : DiscPrestaForm.completeLater,
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                ),
              ),
          ],
        ),
        body: KeyboardDismissArea(
          child: async.when(
            data: (data) {
              _hydrate(data);
              return _PrestataireProfileForm(
                data: data,
            focusedSection: focused,
            currentStep: _currentStep,
            saving: _saving,
            uploadProgress: _uploadProgress,
            nomController: _nomController,
            nomAfficheController: _nomAfficheController,
            descriptionController: _descriptionController,
            experienceProController: _experienceProController,
            anneesExperienceController: _anneesExperienceController,
            bioController: _bioController,
            villeController: _villeController,
            codePostalController: _codePostalController,
            adresseController: _adresseController,
            lieuTravail: _lieuTravail,
            avatarUrl: _avatarUrl,
            avatarBytes: _avatarBytes,
            services: _services,
            catalogSelection: _catalogSelection,
            suggestionNomController: _suggestionNomController,
            suggestionDescController: _suggestionDescController,
            selectedComfortIds: _selectedComfortIds,
            selectedConditionIds: _selectedConditionIds,
            onComfortToggled: _toggleComfort,
            onConditionToggled: _toggleCondition,
            onAddCustomComfort: _addCustomComfort,
            onAddCustomCondition: _addCustomCondition,
            avatarError: _avatarError,
            nomError: _nomError,
            nomAfficheError: _nomAfficheError,
            descriptionError: _descriptionError,
            experienceProError: _experienceProError,
            villeError: _villeError,
            codePostalError: _codePostalError,
            adresseError: _adresseError,
            lieuTravailError: _lieuTravailError,
            servicesError: _servicesError,
            pricingError: _pricingError,
            galleryPhotos: _galleryPhotos,
            pendingGallery: _pendingGallery,
            galleryError: _galleryError,
            onStepTapped: (step) => setState(() => _currentStep = step),
            onContinue: _continue,
            onCancel: _cancel,
            onSkip: _skip,
            onCompleteLater: _completeLater,
            onBasicsChanged: () {
              setState(() {
                _avatarError = null;
                _nomError = null;
                _nomAfficheError = null;
                _descriptionError = null;
                _experienceProError = null;
                _villeError = null;
                _codePostalError = null;
                _adresseError = null;
                _lieuTravailError = null;
              });
            },
            onLieuTravailChanged: (value) {
              setState(() {
                _lieuTravail = value;
                _lieuTravailError = null;
              });
              _schedulePersistHubDraft();
            },
            onPickAvatar: _pickAvatar,
            defaultAvatarUrls: _defaultAvatarUrls,
            selectedDefaultAvatarUrl: _avatarBytes == null ? _avatarUrl : null,
            onSelectDefaultAvatar: _selectDefaultAvatar,
            onPickGallery: _pickGallery,
            onRemoveGalleryPhoto: _removeGalleryPhoto,
            onRemovePendingGallery: (index) => setState(() {
              _pendingGallery.removeAt(index);
              _galleryError = null;
            }),
            onCatalogChanged: () => setState(() {
              _servicesError = null;
              _pricingError = null;
              _syncServicesFromCatalog();
            }),
            onPricingChanged: () => setState(() {
              _pricingError = null;
            }),
            horaireWeek: _horaireWeek,
            horairesError: _horairesError,
            onToggleHoraireDay: (index, enabled) {
              final jours = _horaireWeek;
              if (jours == null) return;
              setState(() {
                jours[index].enabled = enabled;
                _horairesError = null;
              });
              _schedulePersistHubDraft();
            },
            onPickHoraireStart: (index) => _pickHoraireTime(index, true),
            onPickHoraireEnd: (index) => _pickHoraireTime(index, false),
            onCapaciteChanged: (index, capacite) {
              final jours = _horaireWeek;
              if (jours == null) return;
              setState(() {
                jours[index].capaciteSimultanee = capacite;
                _horairesError = null;
              });
              _schedulePersistHubDraft();
            },
            onboardingWizard: focused == null,
              );
            },
            error: (_, __) => PrestataireProfileLoadError(
              onRetry: () => ref.invalidate(prestataireProfileFormProvider),
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
          ),
        ),
      ),
    );
  }
}

class _PrestataireProfileForm extends StatelessWidget {
  const _PrestataireProfileForm({
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
    required this.bioController,
    required this.villeController,
    required this.codePostalController,
    required this.adresseController,
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
    required this.onPickGallery,
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

  static const wizardStepCount = _PrestataireHubScreenState.wizardStepCount;
  static const optionalFromStep = _PrestataireHubScreenState.optionalFromStep;

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
  final TextEditingController bioController;
  final TextEditingController villeController;
  final TextEditingController codePostalController;
  final TextEditingController adresseController;
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
  final List<StorageUploadFile> pendingGallery;
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
  final VoidCallback onPickGallery;
  final ValueChanged<PhotoRealisation> onRemoveGalleryPhoto;
  final ValueChanged<int> onRemovePendingGallery;
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
        bioController: bioController,
        villeController: villeController,
        codePostalController: codePostalController,
        adresseController: adresseController,
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
        bioController: bioController,
        villeController: villeController,
        codePostalController: codePostalController,
        adresseController: adresseController,
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
      ),
      PrestataireProfileEditSection.gallery => PrestataireProfileGalleryStep(
        photos: galleryPhotos,
        pendingPreviews: pendingGallery.map((f) => f.bytes).toList(),
        errorText: galleryError,
        uploading: false,
        uploadProgress: null,
        onPick: onPickGallery,
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
          ? const Center(child: CircularProgressIndicator())
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

    final isSubscriptionStep = currentStep == 6;
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
              ? const PrestataireSubscriptionOnboardingPanel(
                  compact: true,
                  embeddedInHub: true,
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

const List<PrestataireHubStepMeta> kPrestataireHubSteps = [
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepBasics,
    icon: Icons.storefront_outlined,
  ),
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepLocation,
    icon: Icons.location_on_outlined,
  ),
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepServices,
    icon: Icons.content_cut_rounded,
  ),
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepHoraires,
    icon: Icons.schedule_rounded,
  ),
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepGallery,
    icon: Icons.photo_library_outlined,
  ),
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepComfort,
    icon: Icons.favorite_rounded,
  ),
  PrestataireHubStepMeta(
    title: DiscPrestaForm.stepSubscription,
    icon: Icons.card_membership_outlined,
  ),
];
