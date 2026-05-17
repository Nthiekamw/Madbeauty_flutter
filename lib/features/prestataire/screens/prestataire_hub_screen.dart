import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../auth/widgets/role_switch_section.dart';
import '../../../core/errors/app_failure.dart';
import '../../../router/app_router.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../models/prestataire_service_field_set.dart';
import '../providers/prestataire_profile_form_provider.dart';
import '../widgets/prestataire_profile_basics_step.dart';
import '../widgets/prestataire_profile_load_error.dart';
import '../widgets/prestataire_profile_services_step.dart';
import '../widgets/prestataire_profile_specialties_step.dart';

/// Formulaire de profil professionnel prestataire.
class PrestataireHubScreen extends ConsumerStatefulWidget {
  const PrestataireHubScreen({super.key});

  @override
  ConsumerState<PrestataireHubScreen> createState() =>
      _PrestataireHubScreenState();
}

class _PrestataireHubScreenState extends ConsumerState<PrestataireHubScreen> {
  final _nomController = TextEditingController();
  final _bioController = TextEditingController();
  final _villeController = TextEditingController();
  final _services = <PrestataireServiceFieldSet>[];

  var _currentStep = 0;
  var _hydrated = false;
  var _saving = false;
  double? _uploadProgress;
  var _selectedCategoryIds = <String>{};
  Uint8List? _avatarBytes;
  String? _avatarFileName;
  String? _avatarMimeType;
  String? _avatarUrl;

  String? _avatarError;
  String? _nomError;
  String? _bioError;
  String? _villeError;
  String? _specialtyError;
  String? _servicesError;

  @override
  void dispose() {
    _nomController.dispose();
    _bioController.dispose();
    _villeController.dispose();
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
    _nomController.text = data.nomSalon;
    _bioController.text = data.bio;
    _villeController.text = data.ville;
    _avatarUrl = data.avatarUrl;
    _avatarBytes = null;
    _avatarFileName = null;
    _avatarMimeType = null;
    _selectedCategoryIds = Set<String>.from(data.selectedCategoryIds);
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

  bool _validateBasics() {
    final nom = _nomController.text.trim();
    final bio = _bioController.text.trim();
    final ville = _villeController.text.trim();
    final hasAvatar =
        _avatarBytes != null ||
        (_avatarUrl != null && _avatarUrl!.trim().isNotEmpty);

    setState(() {
      _avatarError = hasAvatar
          ? null
          : DiscPrestaForm.reqPhoto;
      _nomError = nom.isEmpty
          ? DiscPrestaForm.reqNameSalon
          : null;
      _bioError = bio.isEmpty
          ? DiscPrestaForm.reqBio
          : bio.length > 300
          ? DiscPrestaForm.bioTooLong
          : null;
      _villeError = ville.isEmpty
          ? DiscPrestaForm.reqCity
          : null;
    });

    return _avatarError == null &&
        _nomError == null &&
        _bioError == null &&
        _villeError == null;
  }

  bool _validateSpecialties() {
    setState(() {
      _specialtyError = _selectedCategoryIds.isEmpty
          ? DiscPrestaForm.reqSpecialty
          : null;
    });
    return _specialtyError == null;
  }

  bool _validateServices() {
    var valid = true;
    setState(() {
      _servicesError = _services.isEmpty
          ? DiscPrestaForm.reqService
          : null;
      valid = _servicesError == null;

      for (final service in _services) {
        final name = service.nomController.text.trim();
        final price = _parsePrice(service.prixController.text);
        final duration = int.tryParse(service.dureeController.text.trim());

        service.nomError = name.isEmpty
            ? DiscPrestaForm.reqSvcName
            : null;
        service.prixError = price == null || price <= 0
            ? DiscPrestaForm.svcPriceBad
            : null;
        service.dureeError = duration == null || duration <= 0
            ? DiscPrestaForm.svcDurationBad
            : null;

        valid =
            valid &&
            service.nomError == null &&
            service.prixError == null &&
            service.dureeError == null;
      }
    });
    return valid;
  }

  double? _parsePrice(String raw) {
    return double.tryParse(raw.trim().replaceAll(',', '.'));
  }

  void _continue() {
    switch (_currentStep) {
      case 0:
        if (!_validateBasics()) return;
        setState(() => _currentStep = 1);
      case 1:
        if (!_validateSpecialties()) return;
        setState(() => _currentStep = 2);
      case 2:
        _save();
    }
  }

  void _cancel() {
    if (_currentStep == 0) return;
    setState(() => _currentStep -= 1);
  }

  Future<void> _save() async {
    final basicsOk = _validateBasics();
    final specialtiesOk = _validateSpecialties();
    final servicesOk = _validateServices();
    if (!basicsOk) {
      setState(() => _currentStep = 0);
      return;
    }
    if (!specialtiesOk) {
      setState(() => _currentStep = 1);
      return;
    }
    if (!servicesOk) {
      setState(() => _currentStep = 2);
      return;
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
        PrestataireProfileSavePayload(
          nomSalon: _nomController.text,
          bio: _bioController.text,
          ville: _villeController.text,
          avatarBytes: _avatarBytes,
          avatarFileName: _avatarFileName,
          avatarMimeType: _avatarMimeType,
          categoryIds: _selectedCategoryIds,
          services: _services.map((service) {
            return PrestataireServiceFormData(
              id: service.id,
              nom: service.nomController.text.trim(),
              prix: _parsePrice(service.prixController.text)!,
              dureeMinutes: int.parse(service.dureeController.text.trim()),
            );
          }).toList(),
        ),
        onAvatarUploadProgress: (progress) {
          if (!mounted) return;
          setState(() => _uploadProgress = progress);
        },
      );

      final updated = await ref.refresh(prestataireProfileFormProvider.future);
      if (!mounted) return;
      setState(() {
        _saving = false;
        _uploadProgress = null;
        _hydrate(updated, force: true);
      });
      _showSnack(DiscPrestaForm.savedToast);
      if (mounted) {
        context.goNamed(AppRouteNames.prestataireDashboard);
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

    return Scaffold(
      appBar: AppBar(
        title: Text(DiscNav.prestHub),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop()
              ? context.pop()
              : context.goPrestataireDashboard(),
        ),
      ),
      body: async.when(
        data: (data) {
          _hydrate(data);
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const RoleSwitchSection(sectionTitle: DiscNav.profileSpace),
              Expanded(
                child: _PrestataireProfileForm(
            data: data,
            currentStep: _currentStep,
            saving: _saving,
            uploadProgress: _uploadProgress,
            nomController: _nomController,
            bioController: _bioController,
            villeController: _villeController,
            avatarUrl: _avatarUrl,
            avatarBytes: _avatarBytes,
            services: _services,
            selectedCategoryIds: _selectedCategoryIds,
            avatarError: _avatarError,
            nomError: _nomError,
            bioError: _bioError,
            villeError: _villeError,
            specialtyError: _specialtyError,
            servicesError: _servicesError,
            onStepTapped: (step) => setState(() => _currentStep = step),
            onContinue: _continue,
            onCancel: _cancel,
            onBasicsChanged: () {
              setState(() {
                _avatarError = null;
                _nomError = null;
                _bioError = null;
                _villeError = null;
              });
            },
            onPickAvatar: _pickAvatar,
            onSpecialtyToggled: (id, selected) {
              setState(() {
                if (selected) {
                  _selectedCategoryIds.add(id);
                } else {
                  _selectedCategoryIds.remove(id);
                }
                _specialtyError = null;
              });
            },
            onAddService: _addService,
            onRemoveService: _removeService,
            onServicesChanged: () => setState(() => _servicesError = null),
                ),
              ),
            ],
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
    required this.currentStep,
    required this.saving,
    required this.uploadProgress,
    required this.nomController,
    required this.bioController,
    required this.villeController,
    required this.avatarUrl,
    required this.avatarBytes,
    required this.services,
    required this.selectedCategoryIds,
    required this.avatarError,
    required this.nomError,
    required this.bioError,
    required this.villeError,
    required this.specialtyError,
    required this.servicesError,
    required this.onStepTapped,
    required this.onContinue,
    required this.onCancel,
    required this.onBasicsChanged,
    required this.onPickAvatar,
    required this.onSpecialtyToggled,
    required this.onAddService,
    required this.onRemoveService,
    required this.onServicesChanged,
  });

  final PrestataireProfileFormData data;
  final int currentStep;
  final bool saving;
  final double? uploadProgress;
  final TextEditingController nomController;
  final TextEditingController bioController;
  final TextEditingController villeController;
  final String? avatarUrl;
  final Uint8List? avatarBytes;
  final List<PrestataireServiceFieldSet> services;
  final Set<String> selectedCategoryIds;
  final String? avatarError;
  final String? nomError;
  final String? bioError;
  final String? villeError;
  final String? specialtyError;
  final String? servicesError;
  final ValueChanged<int> onStepTapped;
  final VoidCallback onContinue;
  final VoidCallback onCancel;
  final VoidCallback onBasicsChanged;
  final VoidCallback onPickAvatar;
  final void Function(String id, bool selected) onSpecialtyToggled;
  final VoidCallback onAddService;
  final ValueChanged<int> onRemoveService;
  final VoidCallback onServicesChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
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
            final isLast = currentStep == 2;
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
                      child: const Text(
                        DiscPrestaForm.back,
                      ),
                    ),
                  ],
                ],
              ),
            );
          },
          steps: [
            Step(
              title: const Text(
                DiscPrestaForm.stepBasics,
              ),
              isActive: currentStep == 0,
              state: currentStep > 0 ? StepState.complete : StepState.indexed,
              content: PrestataireProfileBasicsStep(
                nomController: nomController,
                bioController: bioController,
                villeController: villeController,
                avatarUrl: avatarUrl,
                avatarBytes: avatarBytes,
                nomError: nomError,
                bioError: bioError,
                villeError: villeError,
                avatarError: avatarError,
                uploadProgress: uploadProgress,
                onPickAvatar: onPickAvatar,
                onChanged: onBasicsChanged,
              ),
            ),
            Step(
              title: const Text(
                DiscPrestaForm.stepSpecialties,
              ),
              isActive: currentStep == 1,
              state: currentStep > 1
                  ? StepState.complete
                  : currentStep == 1
                  ? StepState.editing
                  : StepState.indexed,
              content: PrestataireProfileSpecialtiesStep(
                categories: data.categories,
                selectedCategoryIds: selectedCategoryIds,
                errorText: specialtyError,
                onToggle: onSpecialtyToggled,
              ),
            ),
            Step(
              title: const Text(
                DiscPrestaForm.stepServices,
              ),
              isActive: currentStep == 2,
              state: currentStep == 2 ? StepState.editing : StepState.indexed,
              content: PrestataireProfileServicesStep(
                services: services,
                errorText: servicesError,
                onAdd: onAddService,
                onRemove: onRemoveService,
                onChanged: onServicesChanged,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
