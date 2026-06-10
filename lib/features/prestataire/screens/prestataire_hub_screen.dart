import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/layout/keyboard_dismiss_area.dart';
import '../../profile/logic/prestataire_hub_onboarding_draft.dart';
import '../logic/prestataire_hub_constants.dart';
import '../logic/prestataire_hub_media_actions.dart';
import '../logic/prestataire_hub_save_actions.dart';
import '../models/prestataire_profile_edit_section.dart';
import '../navigation/prestataire_hub_wizard_navigation.dart';
import '../providers/hub/prestataire_hub_form_controller.dart';
import '../providers/profile/prestataire_profile_form_provider.dart';
import '../providers/agenda/disponibilite_provider.dart';
import '../../../services/stripe/stripe_subscription_providers.dart';
import '../widgets/profile/hub/prestataire_hub_screen_body.dart';
import '../widgets/profile/overview/layout/prestataire_profile_load_error.dart';
import '../widgets/workspace/prestataire_brand_scaffold.dart';

/// Formulaire de profil professionnel prestataire.
class PrestataireHubScreen extends ConsumerStatefulWidget {
  const PrestataireHubScreen({
    super.key,
    this.focusedSection,
    this.initialStep,
  });

  final PrestataireProfileEditSection? focusedSection;
  final int? initialStep;

  @override
  ConsumerState<PrestataireHubScreen> createState() =>
      _PrestataireHubScreenState();
}

class _PrestataireHubScreenState extends ConsumerState<PrestataireHubScreen> {
  late final PrestataireHubFormController _form;

  PrestataireHubSaveActions get _save => PrestataireHubSaveActions(
        ref: ref,
        form: _form,
        focusedSection: widget.focusedSection,
        mounted: () => mounted,
        showSnack: _showSnack,
        context: context,
      );

  @override
  void initState() {
    super.initState();
    _form = PrestataireHubFormController(
      focusedSection: widget.focusedSection,
      initialStep: widget.initialStep,
    );
    _form.addListener(_onFormChanged);
    if (widget.initialStep != null && widget.focusedSection == null) {
      unawaited(
        PrestataireHubWizardNavigation.prepareWizardSession(
          step: _form.currentStep,
        ),
      );
    }
    _form.attachOnboardingIfNeeded();
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    _form.removeListener(_onFormChanged);
    _form.dispose();
    super.dispose();
  }

  void _continue() {
    if (widget.focusedSection != null) {
      unawaited(_save.save());
      return;
    }
    if (_form.currentStep == 6) {
      final status = ref.read(prestataireSubscriptionStatusProvider).value;
      if (status == null || !status.isActive) {
        _showSnack(
          DiscPrestaSub.subscriptionRequiredForCatalog,
          kind: AppSnackKind.error,
        );
        return;
      }
    }
    if (_form.currentStep == 2) {
      FocusScope.of(context).unfocus();
    }
    final shouldSave = _form.advanceWizardStep();
    if (shouldSave) {
      unawaited(_save.save());
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
      if (!_form.horairesHydrated &&
          !_form.horairesFromDraft &&
          mounted) {
        setState(() => _form.ensureHoraireWeek(plages));
      }
    });

    final focused = widget.focusedSection;
    final onboarding = PrestataireHubOnboardingDraft.isActive;

    return PopScope(
      onPopInvokedWithResult: (didPop, result) {
        if (didPop && onboarding) {
          unawaited(_form.persistHubDraftOnExit());
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
                _form.currentStep >= PrestataireHubConstants.optionalFromStep &&
                _form.currentStep <
                    PrestataireHubConstants.wizardStepCount - 1)
              TextButton(
                onPressed: _form.saving ? null : _save.completeLater,
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
              _form.hydrate(data);
              return PrestataireHubScreenBody(
                data: data,
                focusedSection: focused,
                currentStep: _form.currentStep,
                saving: _form.saving,
                uploadProgress: _form.uploadProgress,
                nomController: _form.nomController,
                nomAfficheController: _form.nomAfficheController,
                descriptionController: _form.descriptionController,
                experienceProController: _form.experienceProController,
                anneesExperienceController: _form.anneesExperienceController,
                bioController: _form.bioController,
                villeController: _form.villeController,
                codePostalController: _form.codePostalController,
                adresseController: _form.adresseController,
                lieuTravail: _form.lieuTravail,
                avatarUrl: _form.avatarUrl,
                avatarBytes: _form.avatarBytes,
                services: _form.services,
                catalogSelection: _form.catalogSelection,
                suggestionNomController: _form.suggestionNomController,
                suggestionDescController: _form.suggestionDescController,
                selectedComfortIds: _form.selectedComfortIds,
                selectedConditionIds: _form.selectedConditionIds,
                onComfortToggled: _form.toggleComfort,
                onConditionToggled: _form.toggleCondition,
                onAddCustomComfort: _form.addCustomComfort,
                onAddCustomCondition: _form.addCustomCondition,
                avatarError: _form.avatarError,
                nomError: _form.nomError,
                nomAfficheError: _form.nomAfficheError,
                descriptionError: _form.descriptionError,
                experienceProError: _form.experienceProError,
                villeError: _form.villeError,
                codePostalError: _form.codePostalError,
                adresseError: _form.adresseError,
                lieuTravailError: _form.lieuTravailError,
                servicesError: _form.servicesError,
                pricingError: _form.pricingError,
                galleryPhotos: _form.galleryPhotos,
                pendingGallery: _form.pendingGallery,
                galleryError: _form.galleryError,
                onStepTapped: _form.setCurrentStep,
                onContinue: _continue,
                onCancel: _form.cancelWizardStep,
                onSkip: () {
                  if (_form.skipWizardStep()) {
                    unawaited(_save.save());
                  }
                },
                onCompleteLater: _save.completeLater,
                onBasicsChanged: _form.clearBasicsErrors,
                onLieuTravailChanged: _form.setLieuTravail,
                onPickAvatar: () =>
                    PrestataireHubMediaActions.pickAvatar(context, _form),
                defaultAvatarUrls: PrestataireHubConstants.defaultAvatarUrls,
                selectedDefaultAvatarUrl:
                    _form.avatarBytes == null ? _form.avatarUrl : null,
                onSelectDefaultAvatar: _form.selectDefaultAvatar,
                onPickGallery: () =>
                    PrestataireHubMediaActions.pickGallery(context, _form),
                onRemoveGalleryPhoto: (photo) =>
                    PrestataireHubMediaActions.removeGalleryPhoto(
                      ref,
                      context,
                      _form,
                      photo,
                    ),
                onRemovePendingGallery: _form.removePendingGalleryAt,
                onCatalogChanged: _form.onCatalogChanged,
                onPricingChanged: _form.onPricingChanged,
                horaireWeek: _form.horaireWeek,
                horairesError: _form.horairesError,
                onToggleHoraireDay: _form.toggleHoraireDay,
                onPickHoraireStart: (i) => PrestataireHubMediaActions
                    .pickHoraireTime(context, _form, i, true),
                onPickHoraireEnd: (i) => PrestataireHubMediaActions
                    .pickHoraireTime(context, _form, i, false),
                onCapaciteChanged: _form.setCapacite,
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
