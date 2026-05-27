import 'dart:async';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/models/domain/availability/horaire_plage.dart';
import '../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../core/models/domain/user/lieu_travail.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/prestataire/photos/photo_realisation_providers.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../models/prestataire_profile_edit_section.dart';
import '../models/prestataire_service_field_set.dart';
import '../providers/prestataire_profile_form_provider.dart';
import '../widgets/prestataire_form_scroll_view.dart';
import '../widgets/prestataire_profile_basics_step.dart';
import '../widgets/prestataire_profile_client_experience_step.dart';
import '../logic/prestataire_profile_completeness.dart';
import '../models/weekly_jour_horaire.dart';
import '../providers/disponibilite_provider.dart';
import '../widgets/prestataire_onboarding_finish_dialog.dart';
import '../widgets/prestataire_profile_gallery_step.dart';
import '../widgets/prestataire_profile_load_error.dart';
import '../widgets/prestataire_profile_services_step.dart';
import '../widgets/prestataire_weekly_horaires_editor.dart';
import '../../../services/supabase/disponibilite/disponibilite_service_providers.dart';
import '../providers/current_prestataire_provider.dart';
import '../../profile/logic/prestataire_hub_onboarding_draft.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/discovery_surface_card.dart';
import '../../../shared/widgets/keyboard_dismiss_area.dart';

/// Formulaire de profil professionnel prestataire.
class PrestataireHubScreen extends ConsumerStatefulWidget {
  const PrestataireHubScreen({super.key, this.focusedSection});

  final PrestataireProfileEditSection? focusedSection;

  @override
  ConsumerState<PrestataireHubScreen> createState() =>
      _PrestataireHubScreenState();
}

class _PrestataireHubScreenState extends ConsumerState<PrestataireHubScreen> {
  static const _galleryMaxPhotos = 10;
  static const wizardStepCount = 6;
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
    _disposeServices();
    for (final service in data.services) {
      _services.add(PrestataireServiceFieldSet.fromData(service));
    }
    _hydrated = true;
    if (!force) {
      _prepareOnboardingDraftRestore();
    }
  }

  void _addService() {
    setState(() {
      _services.add(PrestataireServiceFieldSet());
      _servicesError = null;
    });
    _schedulePersistHubDraft();
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

  void _removeService(int index) {
    setState(() {
      final removed = _services.removeAt(index);
      removed.dispose();
      _servicesError = null;
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
        PrestataireProfileEditSection.horaires => true,
      };
    }
    return switch (_currentStep) {
      0 => _validateVitrine(),
      1 => _validateLocation(),
      2 => _validateServices(),
      _ => true,
    };
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

  Future<bool> _saveHorairesIfNeeded() async {
    final jours = _horaireWeek;
    if (jours == null || !jours.hasAnyOpenDay) return true;
    if (!jours.validatePlages()) {
      setState(() => _horairesError = DiscPrestaHoraires.invalidPlage);
      return false;
    }
    final service = ref.read(disponibiliteServiceProvider);
    final presta = await ref.read(currentPrestataireProvider.future);
    if (service == null || presta == null) {
      setState(() => _horairesError = DiscPrestaHoraires.saveErr);
      return false;
    }
    await service.setHoraires(presta.id, jours.toPlages());
    invalidateDisponibiliteProviders(ref);
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

  bool _validateServices() {
    var valid = true;
    setState(() {
      _servicesError =
          _services.isEmpty ? DiscPrestaForm.reqService : null;
      valid = _servicesError == null;

      for (final service in _services) {
        final name = service.nomController.text.trim();
        final price = _parsePrice(service.prixController.text);
        final duration = int.tryParse(service.dureeController.text.trim());
        final categorieId = service.categorieId?.trim();

        service.nomError =
            name.isEmpty ? DiscPrestaForm.reqSvcName : null;
        service.categorieError =
            categorieId == null || categorieId.isEmpty
            ? DiscPrestaForm.reqSvcCategory
            : null;
        service.prixError = price == null || price < 0
            ? DiscPrestaForm.svcPriceBad
            : null;
        service.dureeError = duration == null || duration <= 0
            ? DiscPrestaForm.svcDurationBad
            : null;

        valid =
            valid &&
            service.nomError == null &&
            service.categorieError == null &&
            service.prixError == null &&
            service.dureeError == null;
      }
    });
    return valid;
  }

  double? _parsePrice(String raw) {
    return double.tryParse(raw.trim().replaceAll(',', '.'));
  }

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
      services: _services.map((service) {
        return PrestataireServiceFormData(
          id: service.id,
          nom: service.nomController.text.trim(),
          description: service.descriptionController.text.trim(),
          categorieId: service.categorieId,
          prix: _parsePrice(service.prixController.text) ?? 0,
          dureeMinutes:
              int.tryParse(service.dureeController.text.trim()) ?? 60,
        );
      }).toList(),
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
      if (!_validateServices()) return;
      setState(() => _currentStep = 3);
      unawaited(_persistOnboardingHubDraft());
      return;
    }
    if (step == 3) {
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
      _save();
    }
  }

  void _cancel() {
    if (_currentStep == 0) return;
    setState(() => _currentStep -= 1);
    unawaited(_persistOnboardingHubDraft());
  }

  Future<void> _completeLater() async {
    FocusScope.of(context).unfocus();
    await _persistOnboardingHubDraft();

    final canSaveCore = _validateVitrine() &&
        _validateLocation() &&
        _validateServices();
    final service = ref.read(prestataireProfileFormServiceProvider);

    if (canSaveCore && service != null) {
      setState(() => _saving = true);
      try {
        await service.save(_buildSavePayload());
        if (_horaireWeek != null && _horaireWeek!.hasAnyOpenDay) {
          await _saveHorairesIfNeeded();
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
    _showSnack(
      DiscPrestaForm.completeLaterSaved,
      kind: AppSnackKind.info,
    );
    context.goPrestataireDashboard();
  }

  Future<void> _save() async {
    if (!_validateCurrentStep()) return;

    if (widget.focusedSection == null) {
      final vitrineOk = _validateVitrine();
      final locationOk = _validateLocation();
      final servicesOk = _validateServices();
      if (!vitrineOk) {
        setState(() => _currentStep = 0);
        return;
      }
      if (!locationOk) {
        setState(() => _currentStep = 1);
        return;
      }
      if (!servicesOk) {
        setState(() => _currentStep = 2);
        return;
      }
    }

    final service = ref.read(prestataireProfileFormServiceProvider);
    if (service == null) {
      _showSnack(DiscPrestaForm.missingSupabase, kind: AppSnackKind.warning);
      return;
    }

    if (widget.focusedSection == null) {
      final horairesOk = await _saveHorairesIfNeeded();
      if (!horairesOk) {
        setState(() => _currentStep = 5);
        return;
      }
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

      var updated = await ref.refresh(prestataireProfileFormProvider.future);
      final prestataireId = updated.prestataireId;
      final photoService = ref.read(photoRealisationServiceProvider);
      if (prestataireId != null &&
          photoService != null &&
          _pendingGallery.isNotEmpty) {
        for (final file in _pendingGallery) {
          await photoService.uploadAndCreate(
            prestataireId: prestataireId,
            file: file,
          );
        }
        _pendingGallery.clear();
        updated = await ref.refresh(prestataireProfileFormProvider.future);
      }
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
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Theme.of(context).colorScheme.surface,
          foregroundColor: Theme.of(context).colorScheme.onSurface,
          surfaceTintColor: Colors.transparent,
          scrolledUnderElevation: 0,
          title: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(focused?.screenTitle ?? DiscPrestaProfile.editTitle),
              if (onboarding && focused == null)
                Text(
                  DiscPrestaForm.hubWizardProgressLabel(
                    _currentStep + 1,
                    wizardStepCount,
                  ),
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
            ],
          ),
          actions: [
            if (onboarding && focused == null)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: Theme.of(context).colorScheme.primary,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed: _saving ? null : _completeLater,
                child: const Text(DiscPrestaForm.completeLater),
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
            galleryPhotos: _galleryPhotos,
            pendingGallery: _pendingGallery,
            galleryError: _galleryError,
            onStepTapped: (step) => setState(() => _currentStep = step),
            onContinue: _continue,
            onCancel: _cancel,
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
            onAddService: _addService,
            onRemoveService: _removeService,
            onServicesChanged: () => setState(() => _servicesError = null),
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
            onboardingWizard: onboarding && focused == null,
            onCompleteLater: _completeLater,
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
    required this.galleryPhotos,
    required this.pendingGallery,
    required this.galleryError,
    required this.onStepTapped,
    required this.onContinue,
    required this.onCancel,
    required this.onBasicsChanged,
    required this.onLieuTravailChanged,
    required this.onPickAvatar,
    required this.defaultAvatarUrls,
    required this.selectedDefaultAvatarUrl,
    required this.onSelectDefaultAvatar,
    required this.onPickGallery,
    required this.onRemoveGalleryPhoto,
    required this.onRemovePendingGallery,
    required this.onAddService,
    required this.onRemoveService,
    required this.onServicesChanged,
    required this.horaireWeek,
    required this.horairesError,
    required this.onToggleHoraireDay,
    required this.onPickHoraireStart,
    required this.onPickHoraireEnd,
    required this.onboardingWizard,
    required this.onCompleteLater,
  });

  static const wizardStepCount = _PrestataireHubScreenState.wizardStepCount;
  static const optionalFromStep = 3;

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
  final List<PhotoRealisation> galleryPhotos;
  final List<StorageUploadFile> pendingGallery;
  final String? galleryError;
  final ValueChanged<int> onStepTapped;
  final VoidCallback onContinue;
  final VoidCallback onCancel;
  final VoidCallback onBasicsChanged;
  final ValueChanged<LieuTravail> onLieuTravailChanged;
  final VoidCallback onPickAvatar;
  final List<String> defaultAvatarUrls;
  final String? selectedDefaultAvatarUrl;
  final ValueChanged<String> onSelectDefaultAvatar;
  final VoidCallback onPickGallery;
  final ValueChanged<PhotoRealisation> onRemoveGalleryPhoto;
  final ValueChanged<int> onRemovePendingGallery;
  final VoidCallback onAddService;
  final ValueChanged<int> onRemoveService;
  final VoidCallback onServicesChanged;
  final List<WeeklyJourHoraire>? horaireWeek;
  final String? horairesError;
  final void Function(int index, bool enabled) onToggleHoraireDay;
  final Future<void> Function(int index) onPickHoraireStart;
  final Future<void> Function(int index) onPickHoraireEnd;
  final bool onboardingWizard;
  final VoidCallback onCompleteLater;

  Widget _stepContent(PrestataireProfileEditSection section) {
    return switch (section) {
      PrestataireProfileEditSection.vitrine => PrestataireProfileBasicsStep(
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
      PrestataireProfileEditSection.services => PrestataireProfileServicesStep(
        categories: data.categories,
        services: services,
        errorText: servicesError,
        suggestionNomController: suggestionNomController,
        suggestionDescController: suggestionDescController,
        onAdd: onAddService,
        onRemove: onRemoveService,
        onChanged: onServicesChanged,
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
        ),
      PrestataireProfileEditSection.horaires => horaireWeek == null
          ? const Center(child: CircularProgressIndicator())
          : PrestataireWeeklyHorairesEditor(
              jours: horaireWeek!,
              errorText: horairesError,
              onToggleDay: onToggleHoraireDay,
              onPickStart: onPickHoraireStart,
              onPickEnd: onPickHoraireEnd,
            ),
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focused = focusedSection;

    if (focused != null) {
      return PrestataireFormScrollView(
        children: [
          _stepContent(focused),
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

    final currentSection = switch (currentStep) {
      0 => PrestataireProfileEditSection.vitrine,
      1 => PrestataireProfileEditSection.location,
      2 => PrestataireProfileEditSection.services,
      3 => PrestataireProfileEditSection.gallery,
      4 => PrestataireProfileEditSection.clientExperience,
      _ => PrestataireProfileEditSection.horaires,
    };
    final currentTitle = switch (currentStep) {
      0 => DiscPrestaForm.stepBasics,
      1 => DiscPrestaForm.stepLocation,
      2 => DiscPrestaForm.stepServices,
      3 => DiscPrestaForm.stepGallery,
      4 => DiscPrestaForm.stepComfort,
      _ => DiscPrestaForm.stepHoraires,
    };
    final currentSubtitle = switch (currentStep) {
      4 =>
        'Décris ton confort et tes conditions pour instaurer la confiance, clarifier tes règles et augmenter les réservations confirmées.',
      _ => DiscPrestaForm.intro,
    };
    final isLast = currentStep == wizardStepCount - 1;
    final isOptional = currentStep >= optionalFromStep && !isLast;
    final continueLabel = saving
        ? DiscPrestaForm.saving
        : isLast
            ? DiscPrestaForm.save
            : DiscPrestaForm.onward;

    final steps = _hubSteps;
    final stepMeta = steps[currentStep.clamp(0, steps.length - 1)];

    final stepBody = Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        _HubHeroCard(
          step: currentStep + 1,
          total: wizardStepCount,
          title: currentTitle,
          subtitle: currentSubtitle,
          icon: stepMeta.icon,
          saving: saving,
          progress: (currentStep + 1) / wizardStepCount,
        ),
        const SizedBox(height: 12),
        if (onboardingWizard) _HubStepChipsRow(
          steps: steps,
          currentStep: currentStep,
          enabled: !saving,
          onTap: onStepTapped,
        ),
        if (onboardingWizard) const SizedBox(height: 12),
        _HubStepSurface(child: _stepContent(currentSection)),
        const SizedBox(height: 18),
        FilledButton(
          onPressed: saving ? null : onContinue,
          style: FilledButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(14),
            ),
          ),
          child: Text(
            continueLabel,
            style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 16),
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 10,
          runSpacing: 8,
          children: [
            if (currentStep > 0)
              TextButton(
                style: TextButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurface,
                  textStyle: const TextStyle(fontWeight: FontWeight.w700),
                ),
                onPressed: saving ? null : onCancel,
                child: const Text(DiscPrestaForm.back),
              ),
            if (isOptional)
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(
                  foregroundColor: theme.colorScheme.onSurfaceVariant,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ).copyWith(
                  side: WidgetStatePropertyAll(
                    BorderSide(
                      color: theme.colorScheme.outline.withValues(alpha: 0.24),
                    ),
                  ),
                ),
                onPressed: saving ? null : onContinue,
                icon: const Icon(Icons.fast_forward_rounded, size: 16),
                label: const Text(DiscPrestaForm.skipStep),
              ),
            if (onboardingWizard && isOptional)
              FilledButton.tonalIcon(
                style: FilledButton.styleFrom(
                  foregroundColor: theme.colorScheme.onPrimaryContainer,
                  backgroundColor: theme.colorScheme.primaryContainer.withValues(
                    alpha: 0.55,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: saving ? null : onCompleteLater,
                icon: const Icon(Icons.schedule_outlined, size: 16),
                label: const Text(DiscPrestaForm.completeLater),
              ),
          ],
        ),
      ],
    );

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 980;
        if (!wide) {
          return PrestataireFormScrollView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
            children: [stepBody],
          );
        }
        return PrestataireFormScrollView(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(flex: 62, child: stepBody),
                const SizedBox(width: 14),
                Expanded(
                  flex: 38,
                  child: _HubRailOverview(
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

class _HubStepMeta {
  const _HubStepMeta({
    required this.title,
    required this.icon,
  });

  final String title;
  final IconData icon;
}

const List<_HubStepMeta> _hubSteps = [
  _HubStepMeta(title: DiscPrestaForm.stepBasics, icon: Icons.storefront_outlined),
  _HubStepMeta(title: DiscPrestaForm.stepLocation, icon: Icons.location_on_outlined),
  _HubStepMeta(title: DiscPrestaForm.stepServices, icon: Icons.content_cut_rounded),
  _HubStepMeta(title: DiscPrestaForm.stepGallery, icon: Icons.photo_library_outlined),
  _HubStepMeta(title: DiscPrestaForm.stepComfort, icon: Icons.favorite_rounded),
  _HubStepMeta(title: DiscPrestaForm.stepHoraires, icon: Icons.schedule_rounded),
];

class _HubHeroCard extends StatelessWidget {
  const _HubHeroCard({
    required this.step,
    required this.total,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.saving,
    required this.progress,
  });

  final int step;
  final int total;
  final String title;
  final String subtitle;
  final IconData icon;
  final bool saving;
  final double progress;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final tertiary = theme.colorScheme.tertiary;

    return ClipRRect(
      borderRadius: BorderRadius.circular(20),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primary.withValues(alpha: isDark ? 0.55 : 0.85),
              theme.colorScheme.primaryContainer.withValues(
                alpha: isDark ? 0.55 : 0.95,
              ),
              tertiary.withValues(alpha: isDark ? 0.22 : 0.38),
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
          border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 44,
                      height: 44,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.18),
                        borderRadius: BorderRadius.circular(14),
                        border: Border.all(
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      ),
                      child: Icon(icon, color: Colors.white),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Étape $step / $total',
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontFamily: AppFonts.display,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            title,
                            style: theme.textTheme.titleLarge?.copyWith(
                              fontFamily: AppFonts.display,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              letterSpacing: -0.4,
                              height: 1.1,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (saving)
                      Padding(
                        padding: const EdgeInsets.only(top: 6),
                        child: SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: Colors.white.withValues(alpha: 0.95),
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 10),
                Text(
                  subtitle,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: Colors.white.withValues(alpha: 0.92),
                    height: 1.35,
                  ),
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 12),
                ClipRRect(
                  borderRadius: BorderRadius.circular(999),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 7,
                    backgroundColor: Colors.white.withValues(alpha: 0.16),
                    color: Colors.white.withValues(alpha: 0.92),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HubStepSurface extends StatelessWidget {
  const _HubStepSurface({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DiscoverySurfaceCard(
      padding: const EdgeInsets.fromLTRB(20, 18, 20, 20),
      child: child,
    );
  }
}

class _HubStepChipsRow extends StatelessWidget {
  const _HubStepChipsRow({
    required this.steps,
    required this.currentStep,
    required this.enabled,
    required this.onTap,
  });

  final List<_HubStepMeta> steps;
  final int currentStep;
  final bool enabled;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        children: [
          for (var i = 0; i < steps.length; i++) ...[
            ChoiceChip(
              avatar: Icon(
                steps[i].icon,
                size: 16,
                color: i == currentStep
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              label: Text(steps[i].title),
              selected: i == currentStep,
              onSelected: !enabled ? null : (_) => onTap(i),
              labelStyle: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
                color: i == currentStep
                    ? theme.colorScheme.onPrimary
                    : theme.colorScheme.onSurfaceVariant,
              ),
              selectedColor: theme.colorScheme.primary,
              backgroundColor:
                  theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.6),
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(alpha: 0.14),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(999),
              ),
            ),
            if (i < steps.length - 1) const SizedBox(width: 10),
          ],
        ],
      ),
    );
  }
}

class _HubRailOverview extends StatelessWidget {
  const _HubRailOverview({
    required this.steps,
    required this.currentStep,
    required this.saving,
    required this.onTap,
  });

  final List<_HubStepMeta> steps;
  final int currentStep;
  final bool saving;
  final ValueChanged<int>? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(Icons.map_outlined, size: 20, color: primary),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Vue d’ensemble',
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < steps.length; i++) ...[
            _HubRailItem(
              index: i + 1,
              title: steps[i].title,
              icon: steps[i].icon,
              active: i == currentStep,
              done: i < currentStep,
              enabled: onTap != null && !saving,
              onTap: () => onTap?.call(i),
            ),
            if (i < steps.length - 1) const SizedBox(height: 10),
          ],
          if (saving) ...[
            const SizedBox(height: 12),
            LinearProgressIndicator(minHeight: 4, color: primary),
          ],
        ],
      ),
    );
  }
}

class _HubRailItem extends StatelessWidget {
  const _HubRailItem({
    required this.index,
    required this.title,
    required this.icon,
    required this.active,
    required this.done,
    required this.enabled,
    required this.onTap,
  });

  final int index;
  final String title;
  final IconData icon;
  final bool active;
  final bool done;
  final bool enabled;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;
    final color = done || active ? primary : muted;

    final tile = Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(14),
        color: active
            ? primary.withValues(alpha: 0.10)
            : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.35),
        border: Border.all(
          color: active
              ? primary.withValues(alpha: 0.22)
              : theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 30,
            height: 30,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: done || active ? primary : theme.colorScheme.surface,
              border: Border.all(
                color: done || active
                    ? primary.withValues(alpha: 0.25)
                    : theme.colorScheme.outline.withValues(alpha: 0.18),
              ),
            ),
            alignment: Alignment.center,
            child: done
                ? const Icon(Icons.check_rounded, size: 16, color: Colors.white)
                : Text(
                    '$index',
                    style: theme.textTheme.labelMedium?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w900,
                      color: done || active ? Colors.white : muted,
                      height: 1,
                    ),
                  ),
          ),
          const SizedBox(width: 10),
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              title,
              style: theme.textTheme.bodyMedium?.copyWith(
                fontWeight: active ? FontWeight.w800 : FontWeight.w600,
                color: done || active ? theme.colorScheme.onSurface : muted,
              ),
            ),
          ),
        ],
      ),
    );

    if (!enabled) return tile;
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: tile,
      ),
    );
  }
}
