import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../core/models/domain/user/lieu_travail.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/prestataire/photos/photo_realisation_providers.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../models/prestataire_profile_edit_section.dart';
import '../models/prestataire_service_field_set.dart';
import '../providers/prestataire_profile_form_provider.dart';
import '../widgets/prestataire_profile_basics_step.dart';
import '../widgets/prestataire_profile_gallery_step.dart';
import '../widgets/prestataire_profile_load_error.dart';
import '../widgets/prestataire_profile_services_step.dart';

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

  @override
  void initState() {
    super.initState();
    final section = widget.focusedSection;
    if (section != null) {
      _currentStep = section.hubStepIndex;
    }
  }

  @override
  void dispose() {
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
  }

  void _addService() {
    setState(() {
      _services.add(PrestataireServiceFieldSet());
      _servicesError = null;
    });
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
  }

  void _removeService(int index) {
    setState(() {
      final removed = _services.removeAt(index);
      removed.dispose();
      _servicesError = null;
    });
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
        PrestataireProfileEditSection.gallery => _validateGallery(),
      };
    }
    return switch (_currentStep) {
      0 => _validateVitrine(),
      1 => _validateLocation(),
      2 => _validateServices(),
      3 => _validateGallery(),
      _ => true,
    };
  }

  bool _validateGallery() {
    final ok = _galleryPhotos.isNotEmpty || _pendingGallery.isNotEmpty;
    setState(() {
      _galleryError = ok ? null : DiscPrestaCompletion.reqGallery;
    });
    return ok;
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
    );
  }

  void _continue() {
    if (widget.focusedSection != null) {
      _save();
      return;
    }
    switch (_currentStep) {
      case 0:
        if (!_validateVitrine()) return;
        setState(() => _currentStep = 1);
      case 1:
        if (!_validateLocation()) return;
        setState(() => _currentStep = 2);
      case 2:
        if (!_validateServices()) return;
        setState(() => _currentStep = 3);
      case 3:
        _save();
    }
  }

  void _cancel() {
    if (_currentStep == 0) return;
    setState(() => _currentStep -= 1);
  }

  Future<void> _save() async {
    if (!_validateCurrentStep()) return;

    if (widget.focusedSection == null) {
      final vitrineOk = _validateVitrine();
      final locationOk = _validateLocation();
      final servicesOk = _validateServices();
      final galleryOk = _validateGallery();
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
      if (!galleryOk) {
        setState(() => _currentStep = 3);
        return;
      }
    }

    final service = ref.read(prestataireProfileFormServiceProvider);
    if (service == null) {
      _showSnack(DiscPrestaForm.missingSupabase);
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
      _showSnack(DiscPrestaForm.savedToast);
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
      _showSnack(e.message);
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _uploadProgress = null;
      });
      _showSnack(DiscPrestaForm.saveErr);
    }
  }

  void _showSnack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(prestataireProfileFormProvider);

    final focused = widget.focusedSection;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          focused?.screenTitle ?? DiscPrestaProfile.editTitle,
        ),
      ),
      body: async.when(
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
            },
            onPickAvatar: _pickAvatar,
            onPickGallery: _pickGallery,
            onRemoveGalleryPhoto: _removeGalleryPhoto,
            onRemovePendingGallery: (index) => setState(() {
              _pendingGallery.removeAt(index);
              _galleryError = null;
            }),
            onAddService: _addService,
            onRemoveService: _removeService,
            onServicesChanged: () => setState(() => _servicesError = null),
          );
        },
        error: (_, __) => PrestataireProfileLoadError(
          onRetry: () => ref.invalidate(prestataireProfileFormProvider),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
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
    required this.onPickGallery,
    required this.onRemoveGalleryPhoto,
    required this.onRemovePendingGallery,
    required this.onAddService,
    required this.onRemoveService,
    required this.onServicesChanged,
  });

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
  final VoidCallback onPickGallery;
  final ValueChanged<PhotoRealisation> onRemoveGalleryPhoto;
  final ValueChanged<int> onRemovePendingGallery;
  final VoidCallback onAddService;
  final ValueChanged<int> onRemoveService;
  final VoidCallback onServicesChanged;

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
    };
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final focused = focusedSection;

    if (focused != null) {
      return ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
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

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
      children: [
        Text(
          DiscPrestaForm.intro,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
          ),
        ),
        const SizedBox(height: 12),
        Stepper(
          currentStep: currentStep,
          physics: const NeverScrollableScrollPhysics(),
          onStepTapped: onStepTapped,
          onStepContinue: saving ? null : onContinue,
          onStepCancel: saving ? null : onCancel,
          controlsBuilder: (context, details) {
            final isLast = currentStep == 3;
            return Padding(
              padding: const EdgeInsets.only(top: 16),
              child: Row(
                children: [
                  FilledButton(
                    onPressed: details.onStepContinue,
                    child: Text(
                      saving
                          ? DiscPrestaForm.saving
                          : isLast
                          ? DiscPrestaForm.save
                          : DiscPrestaForm.onward,
                    ),
                  ),
                  if (currentStep > 0) ...[
                    const SizedBox(width: 12),
                    TextButton(
                      onPressed: details.onStepCancel,
                      child: const Text(DiscPrestaForm.back),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text(DiscPrestaForm.stepBasics),
              isActive: currentStep == 0,
              state: currentStep > 0 ? StepState.complete : StepState.indexed,
              content: _stepContent(PrestataireProfileEditSection.vitrine),
            ),
            Step(
              title: const Text(DiscPrestaForm.stepLocation),
              isActive: currentStep == 1,
              state: currentStep > 1
                  ? StepState.complete
                  : currentStep == 1
                  ? StepState.editing
                  : StepState.indexed,
              content: _stepContent(PrestataireProfileEditSection.location),
            ),
            Step(
              title: const Text(DiscPrestaForm.stepServices),
              isActive: currentStep == 2,
              state: currentStep > 2
                  ? StepState.complete
                  : currentStep == 2
                  ? StepState.editing
                  : StepState.indexed,
              content: _stepContent(PrestataireProfileEditSection.services),
            ),
            Step(
              title: const Text(DiscPrestaForm.stepGallery),
              isActive: currentStep == 3,
              state: currentStep == 3 ? StepState.editing : StepState.indexed,
              content: _stepContent(PrestataireProfileEditSection.gallery),
            ),
          ],
        ),
      ],
    );
  }
}
