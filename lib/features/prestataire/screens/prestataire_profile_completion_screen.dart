import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../core/models/domain/user/lieu_travail.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/prestataire/photos/photo_realisation_providers.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app_snack_bar.dart';
import '../../../shared/widgets/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery_surface_card.dart';
import '../../../shared/widgets/keyboard_dismiss_area.dart';
import '../logic/prestataire_profile_completeness.dart';
import '../models/prestataire_service_field_set.dart';
import '../providers/prestataire_profile_form_provider.dart';
import '../widgets/prestataire_completion_progress.dart';
import '../widgets/prestataire_profile_basics_step.dart';
import '../widgets/prestataire_profile_gallery_step.dart';
import '../widgets/prestataire_profile_load_error.dart';
import '../widgets/prestataire_profile_services_step.dart';

/// Parcours guidé post-inscription : complétion du profil pro étape par étape.
class PrestataireProfileCompletionScreen extends ConsumerStatefulWidget {
  const PrestataireProfileCompletionScreen({super.key});

  @override
  ConsumerState<PrestataireProfileCompletionScreen> createState() =>
      _PrestataireProfileCompletionScreenState();
}

class _PrestataireProfileCompletionScreenState
    extends ConsumerState<PrestataireProfileCompletionScreen> {
  static const _contentSteps = 4;
  static const _maxGalleryPhotos = 10;

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

  /// 0 intro, 1 basics, 2 services, 3 gallery, 4 done.
  var _phase = 0;
  var _hydrated = false;
  var _busy = false;
  double? _uploadProgress;
  LieuTravail? _lieuTravail;
  Uint8List? _avatarBytes;
  String? _avatarFileName;
  String? _avatarMimeType;
  String? _avatarUrl;
  List<PhotoRealisation> _galleryPhotos = [];
  final _pendingGallery = <StorageUploadFile>[];

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

  PrestataireProfileFormData? _loadedData;

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
    for (final s in _services) {
      s.dispose();
    }
    super.dispose();
  }

  void _hydrate(PrestataireProfileFormData data) {
    if (_hydrated) return;
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
    _avatarUrl = data.avatarUrl;
    _galleryPhotos = List<PhotoRealisation>.from(data.realisationPhotos);
    _suggestionNomController.text = data.suggestionCategorieNom;
    _suggestionDescController.text = data.suggestionCategorieDescription;
    for (final service in data.services) {
      _services.add(PrestataireServiceFieldSet.fromData(service));
    }
    _hydrated = true;
    _jumpToFirstIncomplete(data);
  }

  void _jumpToFirstIncomplete(PrestataireProfileFormData data) {
    if (data.isProfessionallyComplete) {
      _phase = 4;
      return;
    }
    final missing = data.missingChecklistItems;
    if (missing.isEmpty) {
      _phase = 4;
      return;
    }
    _phase = switch (missing.first) {
      PrestaCompletionChecklistItem.basics => 1,
      PrestaCompletionChecklistItem.services => 2,
      PrestaCompletionChecklistItem.gallery => 3,
    };
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

  Future<void> _pickGallery() async {
    final picked = await ImagePicker().pickMultiImage(
      maxWidth: 1600,
      imageQuality: 85,
    );
    if (picked.isEmpty) return;
    final next = <StorageUploadFile>[];
    for (final file in picked) {
      if (_galleryPhotos.length + _pendingGallery.length + next.length >=
          _maxGalleryPhotos) {
        break;
      }
      final uploadFile = await StorageUploadFile.fromXFile(file);
      try {
        StorageService.validateImageFile(uploadFile);
        next.add(uploadFile);
      } on AppFailure {
        // ignore invalid files
      }
    }
    if (!mounted || next.isEmpty) return;
    setState(() {
      _pendingGallery.addAll(next);
      _galleryError = null;
    });
  }

  bool _validateBasics() {
    final nom = _nomController.text.trim();
    final nomAffiche = _nomAfficheController.text.trim();
    final description = _descriptionController.text.trim();
    final expPro = _experienceProController.text.trim();
    final ville = _villeController.text.trim();
    final cp = _codePostalController.text.trim();
    final adresse = _adresseController.text.trim();
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
          : description.length > 200
          ? DiscPrestaForm.descriptionTooLong
          : null;
      _experienceProError = expPro.length > 150
          ? DiscPrestaForm.experienceProTooLong
          : null;
      _villeError = ville.isEmpty ? DiscPrestaForm.reqCity : null;
      _codePostalError = cp.isEmpty ? DiscPrestaForm.reqPostalCode : null;
      _adresseError = adresse.isEmpty ? DiscPrestaForm.reqAddress : null;
      _lieuTravailError =
          _lieuTravail == null ? DiscPrestaForm.reqWorkLocation : null;
    });

    return _avatarError == null &&
        _nomError == null &&
        _nomAfficheError == null &&
        _descriptionError == null &&
        _experienceProError == null &&
        _villeError == null &&
        _codePostalError == null &&
        _adresseError == null &&
        _lieuTravailError == null;
  }

  bool _validateServices() {
    var valid = true;
    setState(() {
      _servicesError = _services.isEmpty ? DiscPrestaForm.reqService : null;
      valid = _servicesError == null;
      for (final service in _services) {
        final name = service.nomController.text.trim();
        final price = _parsePrice(service.prixController.text);
        final duration = _parseDuration(service.dureeController.text);

        service.nomError = name.isEmpty ? DiscPrestaForm.reqSvcName : null;
        service.categorieError = service.categorieId == null ||
                service.categorieId!.trim().isEmpty
            ? DiscPrestaForm.reqSvcCategory
            : null;
        service.prixError =
            price == null || price < 0 ? DiscPrestaForm.svcPriceBad : null;
        service.dureeError =
            duration == null || duration <= 0 ? DiscPrestaForm.svcDurationBad : null;

        valid = valid &&
            service.nomError == null &&
            service.categorieError == null &&
            service.prixError == null &&
            service.dureeError == null;
      }
    });
    return valid;
  }

  double? _parsePrice(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return 0;
    return double.tryParse(t.replaceAll(',', '.'));
  }

  int? _parseDuration(String raw) {
    final t = raw.trim();
    if (t.isEmpty) return 60;
    return int.tryParse(t);
  }

  PrestataireProfileSavePayload _buildSavePayload() {
    final lieu = _lieuTravail ?? _loadedData?.lieuTravail ?? LieuTravail.both;
    return PrestataireProfileSavePayload(
      nomSalon: _nomController.text,
      nomAffiche: _nomAfficheController.text,
      bio: _bioController.text,
      description: _descriptionController.text,
      experienceProfessionnelle: _experienceProController.text,
      anneesExperience: _anneesExperienceController.text,
      ville: _villeController.text,
      adresse: _adresseController.text,
      codePostal: _codePostalController.text,
      lieuTravail: lieu,
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
          dureeMinutes: _parseDuration(service.dureeController.text) ?? 60,
        );
      }).toList(),
      suggestionCategorieNom: _suggestionNomController.text,
      suggestionCategorieDescription: _suggestionDescController.text,
      confortClient: _loadedData?.confortClient ?? const [],
      conditionsService: _loadedData?.conditionsService ?? const [],
    );
  }

  Future<bool> _saveProfile() async {
    final service = ref.read(prestataireProfileFormServiceProvider);
    if (service == null) {
      _snack(DiscPrestaForm.missingSupabase, kind: AppSnackKind.warning);
      return false;
    }
    setState(() {
      _busy = true;
      _uploadProgress = _avatarBytes == null ? null : 0;
    });
    try {
      await service.save(
        _buildSavePayload(),
        onAvatarUploadProgress: (p) {
          if (mounted) setState(() => _uploadProgress = p);
        },
      );
      final updated = await ref.refresh(prestataireProfileFormProvider.future);
      if (!mounted) return false;
      setState(() {
        _busy = false;
        _uploadProgress = null;
        _loadedData = updated;
        _avatarBytes = null;
        _avatarUrl = updated.avatarUrl;
        _galleryPhotos = List<PhotoRealisation>.from(updated.realisationPhotos);
      });
      return true;
    } on AppFailure catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _uploadProgress = null;
        });
        _snack(e.message, kind: AppSnackKind.error);
      }
      return false;
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _uploadProgress = null;
        });
        _snack(DiscPrestaForm.saveErr, kind: AppSnackKind.error);
      }
      return false;
    }
  }

  Future<bool> _uploadPendingGallery() async {
    final photoService = ref.read(photoRealisationServiceProvider);
    final prestataireId = _loadedData?.prestataireId ??
        (await ref.read(prestataireProfileFormProvider.future)).prestataireId;
    if (photoService == null || prestataireId == null) {
      _snack(DiscPrestaForm.missingSupabase, kind: AppSnackKind.warning);
      return false;
    }
    if (_pendingGallery.isEmpty) return true;

    setState(() {
      _busy = true;
      _uploadProgress = 0;
    });
    try {
      var done = 0;
      final total = _pendingGallery.length;
      for (final file in _pendingGallery) {
        await photoService.uploadAndCreate(
          prestataireId: prestataireId,
          file: file,
          onProgress: (p) {
            if (!mounted) return;
            setState(() => _uploadProgress = (done + p) / total);
          },
        );
        done++;
      }
      ref.invalidate(prestataireProfileFormProvider);
      final updated = await ref.read(prestataireProfileFormProvider.future);
      if (!mounted) return false;
      setState(() {
        _busy = false;
        _uploadProgress = null;
        _pendingGallery.clear();
        _galleryPhotos = List<PhotoRealisation>.from(updated.realisationPhotos);
        _loadedData = updated;
      });
      return true;
    } on AppFailure catch (e) {
      if (mounted) {
        setState(() {
          _busy = false;
          _uploadProgress = null;
        });
        _snack(e.message, kind: AppSnackKind.error);
      }
      return false;
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _uploadProgress = null;
        });
        _snack(DiscPrestaForm.saveErr, kind: AppSnackKind.error);
      }
      return false;
    }
  }

  Future<void> _removeExistingPhoto(PhotoRealisation photo) async {
    final photoService = ref.read(photoRealisationServiceProvider);
    if (photoService == null) return;
    setState(() => _busy = true);
    try {
      await photoService.delete(photo.id);
      setState(() {
        _galleryPhotos = _galleryPhotos.where((p) => p.id != photo.id).toList();
        _busy = false;
      });
      ref.invalidate(prestataireProfileFormProvider);
    } catch (_) {
      if (mounted) setState(() => _busy = false);
    }
  }

  void _snack(String message, {AppSnackKind kind = AppSnackKind.info}) {
    if (!mounted) return;
    AppSnackBar.show(context, message: message, kind: kind);
  }

  Future<void> _onPrimaryAction(PrestataireProfileFormData data) async {
    if (_busy) return;
    final phase = _phase;
    if (phase == 0) {
      setState(() => _phase = 1);
      return;
    }
    if (phase == 1) {
      if (!_validateBasics()) return;
      if (!await _saveProfile()) return;
      if (!mounted) return;
      setState(() => _phase = 2);
      return;
    }
    if (phase == 2) {
      if (!_validateServices()) return;
      if (!await _saveProfile()) return;
      if (!mounted) return;
      setState(() => _phase = 3);
      return;
    }
    if (phase == 3) {
      setState(() => _galleryError = null);
      if (_pendingGallery.isNotEmpty) {
        if (!await _uploadPendingGallery()) return;
      }
      if (!await _saveProfile()) return;
      if (!mounted) return;
      setState(() => _phase = 4);
      return;
    }
    if (phase == 4) {
      context.goPrestataireDashboard();
    }
  }

  void _onBack() {
    if (_busy) return;
    if (_phase <= 1) {
      if (_phase == 0) {
        context.goPrestataireDashboard();
      } else {
        setState(() => _phase = 0);
      }
      return;
    }
    setState(() => _phase -= 1);
  }

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(prestataireProfileFormProvider);
    final theme = Theme.of(context);

    return DiscoveryBrandScaffold(
      body: async.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (_, __) => PrestataireProfileLoadError(
          onRetry: () => ref.invalidate(prestataireProfileFormProvider),
        ),
        data: (data) {
          _hydrate(data);
          final contentStep = _phase.clamp(1, _contentSteps);
          final showProgress = _phase >= 1 && _phase <= _contentSteps;

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 8, 16, 0),
                child: Row(
                  children: [
                    IconButton(
                      onPressed: _onBack,
                      icon: const Icon(Icons.arrow_back_rounded),
                    ),
                    Expanded(
                      child: Text(
                        DiscPrestaCompletion.title,
                        style: theme.textTheme.titleLarge?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              if (showProgress)
                PrestataireCompletionProgress(
                  stepIndex: contentStep,
                  totalSteps: _contentSteps,
                  stepLabel: _stepLabel(_phase),
                ),
              Expanded(
                child: KeyboardDismissArea(
                  child: ListView(
                    padding: const EdgeInsets.fromLTRB(0, 16, 0, 24),
                    keyboardDismissBehavior:
                        ScrollViewKeyboardDismissBehavior.onDrag,
                    children: [
                      DiscoverySurfaceCard(
                        padding: const EdgeInsets.all(20),
                        child: _buildStepBody(context, data),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    if (_phase == 0) ...[
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => context.goPrestataireDashboard(),
                        child: const Text(DiscPrestaCompletion.introLater),
                      ),
                      const SizedBox(height: 8),
                    ],
                    FilledButton(
                      onPressed: _busy ? null : () => _onPrimaryAction(data),
                      child: Text(_primaryLabel()),
                    ),
                  ],
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  String _stepLabel(int phase) => switch (phase) {
    1 => DiscPrestaCompletion.stepBasics,
    2 => DiscPrestaCompletion.stepServices,
    3 => DiscPrestaCompletion.stepGallery,
    _ => DiscPrestaCompletion.stepDone,
  };

  String _primaryLabel() {
    if (_busy) return DiscPrestaForm.saving;
    return switch (_phase) {
      0 => DiscPrestaCompletion.introStart,
      4 => DiscPrestaCompletion.doneCta,
      3 => DiscPrestaForm.save,
      _ => DiscPrestaForm.onward,
    };
  }

  Widget _buildStepBody(BuildContext context, PrestataireProfileFormData data) {
    final theme = Theme.of(context);
    return switch (_phase) {
      0 => _IntroStep(data: data),
      1 => PrestataireProfileBasicsStep(
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
        nomError: _nomError,
        nomAfficheError: _nomAfficheError,
        descriptionError: _descriptionError,
        experienceProError: _experienceProError,
        villeError: _villeError,
        codePostalError: _codePostalError,
        adresseError: _adresseError,
        lieuTravailError: _lieuTravailError,
        avatarError: _avatarError,
        uploadProgress: _uploadProgress,
        onPickAvatar: _pickAvatar,
        onLieuTravailChanged: (v) => setState(() {
          _lieuTravail = v;
          _lieuTravailError = null;
        }),
        onChanged: () => setState(() {
          _avatarError = null;
          _nomError = null;
          _nomAfficheError = null;
          _descriptionError = null;
          _experienceProError = null;
          _villeError = null;
          _codePostalError = null;
          _adresseError = null;
        }),
      ),
      2 => PrestataireProfileServicesStep(
        categories: data.categories,
        services: _services,
        errorText: _servicesError,
        suggestionNomController: _suggestionNomController,
        suggestionDescController: _suggestionDescController,
        onAdd: () => setState(() {
          _services.add(PrestataireServiceFieldSet());
          _servicesError = null;
        }),
        onRemove: (index) => setState(() {
          final removed = _services.removeAt(index);
          removed.dispose();
          _servicesError = null;
        }),
        onChanged: () => setState(() => _servicesError = null),
      ),
      3 => PrestataireProfileGalleryStep(
        photos: _galleryPhotos,
        pendingPreviews: _pendingGallery.map((f) => f.bytes).toList(),
        errorText: _galleryError,
        uploading: _busy && _pendingGallery.isNotEmpty,
        uploadProgress: _uploadProgress,
        onPick: _pickGallery,
        onRemoveExisting: _removeExistingPhoto,
        onRemovePending: (index) => setState(() {
          _pendingGallery.removeAt(index);
        }),
      ),
      _ => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 56,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(height: 16),
          Text(
            DiscPrestaCompletion.doneHeadline,
            style: theme.textTheme.headlineSmall?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            DiscPrestaCompletion.doneBody,
            style: theme.textTheme.bodyMedium?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.45,
            ),
          ),
        ],
      ),
    };
  }
}

class _IntroStep extends StatelessWidget {
  const _IntroStep({required this.data});

  final PrestataireProfileFormData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final items = data.missingChecklistItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          DiscPrestaCompletion.introHeadline,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          DiscPrestaCompletion.introBody,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.45,
          ),
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 20),
          Text(
            DiscPrestaCompletion.checklistTitle,
            style: theme.textTheme.titleSmall?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          for (final item in items) _ChecklistRow(item: item),
        ],
      ],
    );
  }
}

class _ChecklistRow extends StatelessWidget {
  const _ChecklistRow({required this.item});

  final PrestaCompletionChecklistItem item;

  @override
  Widget build(BuildContext context) {
    final label = switch (item) {
      PrestaCompletionChecklistItem.basics =>
        DiscPrestaCompletion.checklistBasics,
      PrestaCompletionChecklistItem.services =>
        DiscPrestaCompletion.checklistServices,
      PrestaCompletionChecklistItem.gallery =>
        DiscPrestaCompletion.checklistGallery,
    };

    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            Icons.radio_button_unchecked,
            size: 20,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(child: Text(label)),
        ],
      ),
    );
  }
}
