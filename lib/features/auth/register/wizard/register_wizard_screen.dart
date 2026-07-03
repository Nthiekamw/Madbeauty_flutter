import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../router/navigation_extensions.dart';
import '../../guest/guest_mode_provider.dart';
import '../../providers/auth_notifier.dart';
import '../../widgets/auth_form_scaffold.dart';
import '../../../../services/supabase/storage/storage_service.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';
import '../logic/register_wizard_constants.dart';
import '../logic/register_wizard_oauth_handler.dart';
import '../logic/register_wizard_submit_handler.dart';
import '../providers/register_wizard_form_controller.dart';
import '../widgets/register_wizard_bottom_bar.dart';
import '../widgets/register_wizard_progress_bar.dart';
import '../widgets/register_wizard_screen_body.dart';
/// Inscription en 3 étapes : identité → rôle → infos complémentaires.
class RegisterWizardScreen extends ConsumerStatefulWidget {
  const RegisterWizardScreen({
    super.key,
    this.autoResumeFinalize = false,
  });

  final bool autoResumeFinalize;

  @override
  ConsumerState<RegisterWizardScreen> createState() =>
      _RegisterWizardScreenState();
}

class _RegisterWizardScreenState extends ConsumerState<RegisterWizardScreen>
    with WidgetsBindingObserver {
  late final RegisterWizardFormController _form;
  final _oauth = RegisterWizardOAuthHandler();
  final _submitHandler = RegisterWizardSubmitHandler();
  bool _autoResumeTriggered = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _form = RegisterWizardFormController();
    _form.addListener(_onFormChanged);

    WidgetsBinding.instance.addPostFrameCallback((_) {
      exitGuestMode(ref);
      final hasSession =
          ref.read(authServiceProvider).currentSession?.user != null;
      if (widget.autoResumeFinalize &&
          !_autoResumeTriggered &&
          hasSession &&
          _form.step == 2 &&
          !_form.loading) {
        _autoResumeTriggered = true;
        unawaited(_submit());
      }
      if (_form.googleLaunched && !_form.signedUpViaOAuth) {
        unawaited(_tryCompletePendingGoogleSignIn());
      }
      final draft = _form.currentDraft();
      if (draft.pendingGoogleSignIn &&
          !hasSession &&
          !_form.signedUpViaOAuth) {
        unawaited(_clearStalePendingGoogleSignIn());
      }
      unawaited(_recoverGoogleSessionIfNeeded());
    });
  }

  void _onFormChanged() {
    if (mounted) setState(() {});
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      unawaited(_recoverGoogleSessionIfNeeded());
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _oauth.dispose();
    _form.removeListener(_onFormChanged);
    _form.dispose();
    super.dispose();
  }

  Future<void> _onOAuthConnected(User user) => _oauth.onOAuthConnected(
        context: context,
        mounted: () => mounted,
        form: _form,
        user: user,
      );

  Future<void> _googleSignIn() => _oauth.googleSignIn(
        ref: ref,
        context: context,
        mounted: () => mounted,
        form: _form,
        onOAuthConnected: _onOAuthConnected,
      );

  Future<void> _appleSignIn() => _oauth.appleSignIn(
        ref: ref,
        context: context,
        mounted: () => mounted,
        form: _form,
        onOAuthConnected: _onOAuthConnected,
      );

  Future<void> _recoverGoogleSessionIfNeeded() => _oauth.recoverGoogleSessionIfNeeded(
        ref: ref,
        form: _form,
        onOAuthConnected: _onOAuthConnected,
      );

  Future<void> _tryCompletePendingGoogleSignIn() =>
      _recoverGoogleSessionIfNeeded();

  Future<void> _clearStalePendingGoogleSignIn() =>
      _oauth.clearStalePendingGoogleSignIn(
        ref: ref,
        mounted: () => mounted,
        form: _form,
        tryCompletePending: _tryCompletePendingGoogleSignIn,
      );

  void _goToPreviousStep() {
    FocusScope.of(context).unfocus();
    _form.goToPreviousStep();
  }

  void _next() {
    FocusScope.of(context).unfocus();
    _form.advanceStep();
  }

  Future<void> _submit() => _submitHandler.submit(
        ref: ref,
        context: context,
        mounted: () => mounted,
        form: _form,
      );

  Future<void> _pickClientAvatar() async {
    final picked = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      maxWidth: 1024,
      imageQuality: 85,
    );
    if (picked == null || !mounted) return;
    try {
      final file = await StorageUploadFile.fromXFile(picked);
      StorageService.validateImageFile(file);
      _form.setClientAvatarFile(
        bytes: file.bytes,
        fileName: file.fileName ?? 'avatar.jpg',
        mimeType: file.mimeType ?? 'image/jpeg',
      );
    } on AppFailure catch (e) {
      if (!mounted) return;
      AppSnackBar.show(context, message: e.message, kind: AppSnackKind.error);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: CoreStrings.errorUnexpected,
        kind: AppSnackKind.error,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      if (_form.signedUpViaOAuth || _form.step != 0) return;
      final user = switch (next) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (user == null) return;
      final hadUser = switch (previous) {
        AsyncData(:final value) => value != null,
        _ => false,
      };
      if (hadUser && !_form.googleSigningIn && !_form.googleLaunched) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        unawaited(_recoverGoogleSessionIfNeeded());
      });
    });

    final theme = Theme.of(context);
    final formEnabled =
        AppConfig.hasSupabase && !_form.loading && !_form.googleSigningIn;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    final stepTitle = switch (_form.step) {
      0 => AuthStrings.registerStepIdentityTitle,
      1 => AuthStrings.registerStepRoleTitle,
      _ => AuthStrings.registerStepExtrasTitle,
    };
    final stepSubtitle = switch (_form.step) {
      0 => AuthStrings.registerStepIdentitySubtitle,
      1 => AuthStrings.registerStepRoleSubtitle,
      _ when _form.isPresta => AuthStrings.registerStepExtrasPrestaSubtitle,
      _ => AuthStrings.registerStepExtrasClientSubtitle,
    };

    final stepLabel = switch (_form.step) {
      0 => AuthStrings.registerStepLabelIdentity,
      1 => AuthStrings.registerStepLabelRole,
      _ => AuthStrings.registerStepLabelExtras,
    };

    return AuthFormScaffold(
      title: stepTitle,
      subtitle: stepSubtitle,
      showLogo: false,
      compact: true,
      scrollable: true,
      headerAccessory: RegisterWizardProgressBar(
        currentStep: _form.step,
        totalSteps: RegisterWizardConstants.totalSteps,
        stepLabel: stepLabel,
        compact: true,
      ),
      onBack: _form.loading
          ? () {}
          : () {
              if (_form.step == 0) {
                _form.persistDraftOnDispose = false;
                _form.saveDebounce?.cancel();
                unawaited(_form.clearDraft());
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goWelcome();
                }
              } else {
                _goToPreviousStep();
              }
            },
      isBackEnabled: !_form.loading,
      bottomBar: RegisterWizardBottomBar(
        showBack: _form.step > 0,
        isLoading: _form.loading,
        enabled: formEnabled,
        primaryLabel: _form.stepPrimaryLabel(),
        onBack: _goToPreviousStep,
        onPrimary: _form.loading
            ? null
            : () {
                if (_form.step < 2) {
                  _next();
                } else {
                  _submit();
                }
              },
      ),
      child: RegisterWizardScreenBody(
        form: _form,
        formEnabled: formEnabled,
        theme: theme,
        onSurfaceVariant: onSurfaceVariant,
        onGoogleSignIn: _form.googleSigningIn ? null : _googleSignIn,
        onAppleSignIn: _form.googleSigningIn ? null : _appleSignIn,
        onPickClientAvatar: _pickClientAvatar,
      ),
    );
  }
}
