import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../core/models/domain/user/lieu_travail.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../../services/supabase/prestataire/photos/photo_realisation_providers.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery/discovery_constrained_body.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../shared/widgets/layout/keyboard_dismiss_area.dart';
import '../logic/prestataire_profile_completeness.dart';
import '../models/prestataire_service_field_set.dart';
import '../providers/prestataire_profile_form_provider.dart';
import '../widgets/profile/prestataire_completion_progress.dart';
import '../widgets/profile/prestataire_profile_basics_step.dart';
import '../widgets/profile/prestataire_profile_gallery_step.dart';
import '../widgets/profile/prestataire_profile_load_error.dart';
import '../widgets/profile/prestataire_profile_services_step.dart';

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
  void initState() {
    super.initState();
    final restored = LocalCacheService.instance.prestataireProfileCompletionPhase;
    if (restored != null) {
      _phase = restored.clamp(0, 4);
    }
  }

  @override
  void dispose() {
    if (_phase >= 0 && _phase < 4) {
      LocalCacheService.instance.setPrestataireProfileCompletionPhase(_phase);
    }
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
    final restored = LocalCacheService.instance.prestataireProfileCompletionPhase;
    if (restored != null) {
      _phase = restored.clamp(0, 4);
      return;
    }
    if (data.isProfessionallyComplete) {
      _phase = 4;
      LocalCacheService.instance.clearPrestataireProfileCompletionPhase();
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
      await LocalCacheService.instance.setPrestataireProfileCompletionPhase(1);
      return;
    }
    if (phase == 1) {
      if (!_validateBasics()) return;
      if (!await _saveProfile()) return;
      if (!mounted) return;
      setState(() => _phase = 2);
      await LocalCacheService.instance.setPrestataireProfileCompletionPhase(2);
      return;
    }
    if (phase == 2) {
      if (!_validateServices()) return;
      if (!await _saveProfile()) return;
      if (!mounted) return;
      setState(() => _phase = 3);
      await LocalCacheService.instance.setPrestataireProfileCompletionPhase(3);
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
      await LocalCacheService.instance.clearPrestataireProfileCompletionPhase();
      return;
    }
    if (phase == 4) {
      await LocalCacheService.instance.clearPrestataireProfileCompletionPhase();
      context.goPrestataireDashboard();
    }
  }

  void _onBack() {
    if (_busy) return;
    if (_phase <= 1) {
      if (_phase == 0) {
        LocalCacheService.instance.clearPrestataireProfileCompletionPhase();
        context.goPrestataireDashboard();
      } else {
        setState(() => _phase = 0);
        LocalCacheService.instance.setPrestataireProfileCompletionPhase(0);
      }
      return;
    }
    setState(() => _phase -= 1);
    LocalCacheService.instance.setPrestataireProfileCompletionPhase(_phase);
  }

  String _heroSubtitle(int phase) => switch (phase) {
        0 => DiscPrestaCompletion.introTimeHint,
        1 => DiscPrestaCompletion.stepBasics,
        2 => DiscPrestaCompletion.stepServices,
        3 => DiscPrestaCompletion.stepGallery,
        4 => DiscPrestaCompletion.stepDone,
        _ => '',
      };

  @override
  Widget build(BuildContext context) {
    final async = ref.watch(prestataireProfileFormProvider);

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

          final subtitle = _heroSubtitle(_phase);

          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _CompletionHeroBar(
                title: DiscPrestaCompletion.title,
                subtitle: subtitle,
                onBack: _onBack,
                busy: _busy,
              ),
              if (showProgress)
                PrestataireCompletionProgress(
                  stepIndex: contentStep,
                  totalSteps: _contentSteps,
                  stepLabel: _stepLabel(_phase),
                ),
              Expanded(
                child: KeyboardDismissArea(
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      return ListView(
                        padding: EdgeInsets.fromLTRB(
                          0,
                          showProgress ? 12 : 8,
                          0,
                          16,
                        ),
                        keyboardDismissBehavior:
                            ScrollViewKeyboardDismissBehavior.onDrag,
                        children: [
                          DiscoveryConstrainedBody(
                            child: LayoutBuilder(
                              builder: (context, cardConstraints) {
                                final useWide =
                                    cardConstraints.maxWidth >= 920;
                                final stepBodyCard = _StepSurfaceCard(
                                  child: _buildStepBody(context, data),
                                );
                                if (!useWide) return stepBodyCard;
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(flex: 58, child: stepBodyCard),
                                    const SizedBox(width: 14),
                                    Expanded(
                                      flex: 34,
                                      child: _StepRail(
                                        phase: _phase,
                                        busy: _busy,
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        ],
                      );
                    },
                  ),
                ),
              ),
              _CompletionBottomActions(
                phase: _phase,
                busy: _busy,
                primaryLabel: _primaryLabel(),
                onPrimary: () => _onPrimaryAction(data),
                onSkipIntro: _busy
                    ? null
                    : () => context.goPrestataireDashboard(),
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
      _ => const _DoneStep(),
    };
  }
}

/// En-tête visuel (dégradé + retour) pour le parcours de complétion.
class _CompletionHeroBar extends StatelessWidget {
  const _CompletionHeroBar({
    required this.title,
    required this.subtitle,
    required this.onBack,
    required this.busy,
  });

  final String title;
  final String subtitle;
  final VoidCallback onBack;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final tertiary = theme.colorScheme.tertiary;

    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(28)),
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              primary.withValues(alpha: isDark ? 0.55 : 0.85),
              theme.colorScheme.primaryContainer.withValues(
                alpha: isDark ? 0.5 : 0.95,
              ),
              tertiary.withValues(alpha: isDark ? 0.28 : 0.45),
            ],
            stops: const [0.0, 0.55, 1.0],
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(6, 10, 20, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                onPressed: busy ? null : onBack,
                icon: const Icon(Icons.arrow_back_rounded),
                color: Colors.white,
                style: IconButton.styleFrom(
                  backgroundColor: Colors.white.withValues(alpha: 0.18),
                  foregroundColor: Colors.white,
                ),
              ),
              const SizedBox(width: 4),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.titleLarge?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w900,
                        color: Colors.white,
                        letterSpacing: -0.4,
                        height: 1.15,
                        shadows: [
                          Shadow(
                            color: Colors.black.withValues(alpha: 0.2),
                            blurRadius: 8,
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: AppFonts.body,
                        color: Colors.white.withValues(alpha: 0.92),
                        height: 1.35,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Carte de contenu d’étape (même style que le reste de l’app).
class _StepSurfaceCard extends StatelessWidget {
  const _StepSurfaceCard({required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    return DiscoverySurfaceCard(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 22),
      child: child,
    );
  }
}

/// Boutons fixes en bas, séparateur visuel.
class _CompletionBottomActions extends StatelessWidget {
  const _CompletionBottomActions({
    required this.phase,
    required this.busy,
    required this.primaryLabel,
    required this.onPrimary,
    required this.onSkipIntro,
  });

  final int phase;
  final bool busy;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final VoidCallback? onSkipIntro;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      elevation: theme.brightness == Brightness.dark ? 0 : 8,
      shadowColor: primary.withValues(alpha: 0.12),
      color: theme.colorScheme.surface.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.92 : 1,
      ),
      child: SafeArea(
        top: false,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (phase == 0)
                TextButton(
                  onPressed: onSkipIntro,
                  child: Text(
                    DiscPrestaCompletion.introLater,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              if (phase == 0) const SizedBox(height: 4),
              FilledButton(
                onPressed: busy ? null : onPrimary,
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                ),
                child: busy
                    ? SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(
                          strokeWidth: 2.2,
                          color: theme.colorScheme.onPrimary,
                        ),
                      )
                    : Text(
                        primaryLabel,
                        style: const TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 16,
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IntroStep extends StatelessWidget {
  const _IntroStep({required this.data});

  final PrestataireProfileFormData data;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final items = data.missingChecklistItems;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Align(
          alignment: Alignment.centerLeft,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: primary.withValues(alpha: 0.22)),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.storefront_outlined, size: 16, color: primary),
                const SizedBox(width: 8),
                Text(
                  DiscPrestaCompletion.stepIntro,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                    color: primary,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(height: 18),
        Text(
          DiscPrestaCompletion.introHeadline,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.4,
            height: 1.15,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          DiscPrestaCompletion.introBody,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 18),
        Container(
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.35),
            border: Border.all(
              color: theme.colorScheme.secondary.withValues(alpha: 0.22),
            ),
          ),
          child: Row(
            children: [
              Icon(
                Icons.schedule_rounded,
                color: theme.colorScheme.secondary,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  DiscPrestaCompletion.introTimeHint,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                    height: 1.35,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (items.isNotEmpty) ...[
          const SizedBox(height: 24),
          Text(
            DiscPrestaCompletion.checklistLead,
            style: theme.textTheme.titleSmall?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            DiscPrestaCompletion.checklistTitle,
            style: theme.textTheme.labelLarge?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          for (var i = 0; i < items.length; i++) ...[
            _ChecklistHighlightCard(item: items[i], index: i + 1),
            if (i < items.length - 1) const SizedBox(height: 10),
          ],
        ],
      ],
    );
  }
}

class _ChecklistHighlightCard extends StatelessWidget {
  const _ChecklistHighlightCard({
    required this.item,
    required this.index,
  });

  final PrestaCompletionChecklistItem item;
  final int index;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final icon = switch (item) {
      PrestaCompletionChecklistItem.basics => Icons.badge_outlined,
      PrestaCompletionChecklistItem.services => Icons.content_cut_rounded,
      PrestaCompletionChecklistItem.gallery => Icons.photo_library_outlined,
    };
    final label = switch (item) {
      PrestaCompletionChecklistItem.basics =>
        DiscPrestaCompletion.checklistBasics,
      PrestaCompletionChecklistItem.services =>
        DiscPrestaCompletion.checklistServices,
      PrestaCompletionChecklistItem.gallery =>
        DiscPrestaCompletion.checklistGallery,
    };

    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        color: theme.colorScheme.surfaceContainerLowest.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.85 : 1,
        ),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
        boxShadow: theme.brightness == Brightness.dark
            ? null
            : [
                BoxShadow(
                  color: primary.withValues(alpha: 0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: IntrinsicHeight(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Container(
              width: 5,
              decoration: BoxDecoration(
                borderRadius: const BorderRadius.horizontal(
                  left: Radius.circular(15),
                ),
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    primary,
                    primary.withValues(alpha: 0.55),
                  ],
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(14, 14, 14, 14),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: primary.withValues(alpha: 0.12),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Center(
                        child: Text(
                          '$index',
                          style: theme.textTheme.titleSmall?.copyWith(
                            fontFamily: AppFonts.display,
                            fontWeight: FontWeight.w900,
                            color: primary,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Icon(icon, size: 20, color: primary),
                          const SizedBox(height: 8),
                          Text(
                            label,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              height: 1.4,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _DoneStep extends StatelessWidget {
  const _DoneStep();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Center(
          child: Container(
            width: 84,
            height: 84,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [
                  primary.withValues(alpha: 0.95),
                  theme.colorScheme.tertiary.withValues(alpha: 0.85),
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: primary.withValues(alpha: 0.35),
                  blurRadius: 20,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(
              Icons.check_rounded,
              color: Colors.white,
              size: 48,
            ),
          ),
        ),
        const SizedBox(height: 22),
        Text(
          DiscPrestaCompletion.doneHeadline,
          textAlign: TextAlign.center,
          style: theme.textTheme.headlineSmall?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w900,
            letterSpacing: -0.3,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          DiscPrestaCompletion.doneBody,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodyLarge?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 22),
        _DoneTipRow(
          icon: Icons.tune_rounded,
          text: DiscPrestaCompletion.doneTip1,
        ),
        const SizedBox(height: 10),
        _DoneTipRow(
          icon: Icons.event_available_rounded,
          text: DiscPrestaCompletion.doneTip2,
        ),
      ],
    );
  }
}

class _DoneTipRow extends StatelessWidget {
  const _DoneTipRow({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              height: 1.45,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}

class _StepRail extends StatelessWidget {
  const _StepRail({required this.phase, required this.busy});

  final int phase;
  final bool busy;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final entries = [
      DiscPrestaCompletion.stepBasics,
      DiscPrestaCompletion.stepServices,
      DiscPrestaCompletion.stepGallery,
      DiscPrestaCompletion.stepDone,
    ];

    return Material(
      color: theme.colorScheme.surface.withValues(
        alpha: theme.brightness == Brightness.dark ? 0.55 : 0.98,
      ),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.12),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Icon(Icons.map_outlined, size: 20, color: primary),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    DiscPrestaCompletion.railTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 14),
            for (var i = 0; i < entries.length; i++)
              _StepRailItem(
                stepNumber: i + 1,
                label: entries[i],
                isLast: i == entries.length - 1,
                active: phase == i + 1 || (phase == 0 && i == 0),
                done: phase > i + 1 || (phase == 4 && i == 3),
              ),
            if (busy) ...[
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  minHeight: 4,
                  color: theme.colorScheme.primary,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StepRailItem extends StatelessWidget {
  const _StepRailItem({
    required this.stepNumber,
    required this.label,
    required this.isLast,
    required this.active,
    required this.done,
  });

  final int stepNumber;
  final String label;
  final bool isLast;
  final bool active;
  final bool done;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final muted = theme.colorScheme.onSurfaceVariant;

    final circleColor = done
        ? primary
        : active
            ? primary
            : theme.colorScheme.surfaceContainerHighest;
    final fg = done || active ? Colors.white : muted;
    final borderColor = active ? theme.colorScheme.tertiary : Colors.transparent;

    return IntrinsicHeight(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            width: 34,
            child: Column(
              children: [
                Container(
                  width: 28,
                  height: 28,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: circleColor,
                    border: Border.all(
                      width: active ? 2.2 : 1,
                      color: active ? borderColor : circleColor,
                    ),
                  ),
                  alignment: Alignment.center,
                  child: done
                      ? const Icon(Icons.check, size: 15, color: Colors.white)
                      : Text(
                          '$stepNumber',
                          style: theme.textTheme.labelMedium?.copyWith(
                            fontFamily: AppFonts.display,
                            fontWeight: FontWeight.w900,
                            color: fg,
                            height: 1,
                          ),
                        ),
                ),
                if (!isLast)
                  Expanded(
                    child: Container(
                      width: 2,
                      margin: const EdgeInsets.only(top: 4, bottom: 4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(2),
                        color: done
                            ? primary.withValues(alpha: 0.55)
                            : muted.withValues(alpha: 0.22),
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Padding(
              padding: EdgeInsets.only(bottom: isLast ? 0 : 12, top: 2),
              child: Text(
                label,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: active ? FontWeight.w800 : FontWeight.w500,
                  color: done || active ? theme.colorScheme.onSurface : muted,
                  height: 1.3,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
