import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/errors/supabase_service_exception.dart';
import '../../../../core/models/user_role.dart';
import '../../../../router/app_router.dart';
import '../../../../router/navigation_extensions.dart';
import '../../logic/auth_role_cache.dart';
import '../../../prestataire/navigation/prestataire_navigation.dart';
import '../../../profile/logic/become_prestataire_draft.dart';
import '../../../profile/storage/become_prestataire_draft_store.dart';
import '../../../../services/auth/post_signup_profile_service.dart';
import '../../../../services/auth/role_service.dart';
import '../../../../services/offline/offline_actions.dart';
import '../../../../services/storage/local_cache_service.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/auth_form_styles.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';
import '../../../../shared/utils/phone_number_utils.dart';
import '../../../../shared/widgets/app/app_text_field.dart';
import '../../../../shared/widgets/phone/phone_number_field.dart';
import '../../guest/guest_mode_provider.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/my_roles_provider.dart';
import '../../widgets/auth_error_banner.dart';
import '../../widgets/auth_success_dialog.dart';
import '../../widgets/auth_form_card.dart';
import '../../widgets/auth_form_scaffold.dart';
import '../../widgets/auth_google_button.dart';
import '../../widgets/auth_or_divider.dart';
import '../../widgets/auth_role_card.dart';
import '../../widgets/auth_step_section.dart';
import '../widgets/register_field_row.dart';
import '../widgets/register_optional_panel.dart';
import '../widgets/register_wizard_bottom_bar.dart';
import '../widgets/register_wizard_progress_bar.dart';
import '../logic/register_validators.dart';
import '../logic/register_wizard_draft.dart';
import '../storage/register_wizard_draft_store.dart';

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

class _RegisterWizardScreenState extends ConsumerState<RegisterWizardScreen> {
  static const _totalSteps = 3;
  static const _fieldGap = 10.0;
  static const _sectionGap = 12.0;

  int _step = 0;
  Timer? _saveDebounce;
  bool _restoredDraft = false;
  bool _persistDraftOnDispose = true;
  bool _autoResumeTriggered = false;

  final _prenom = TextEditingController();
  final _nom = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  final _adresse = TextEditingController();
  final _salon = TextEditingController();
  final _nomAffiche = TextEditingController();
  final _codePostal = TextEditingController();
  final _description = TextEditingController();
  final _ville = TextEditingController();
  final _bio = TextEditingController();

  UserRole? _roleChoice;
  String _phoneDialCode = '+33';
  String? _error;
  String? _prenomError;
  String? _nomError;
  String? _phoneError;
  String? _emailError;
  String? _passwordError;
  String? _confirmError;
  String? _salonError;
  String? _villeError;
  bool _loading = false;
  bool _signedUpViaOAuth = false;
  bool _googleLaunched = false;
  bool _phoneRequiredOnExtras = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void initState() {
    super.initState();
    final draft = RegisterWizardDraftStore.instance.read();
    if (draft != null) {
      _applyDraft(draft);
      _restoredDraft =
          draft.showResumeBanner && !widget.autoResumeFinalize;
    }
    _attachAutosave();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      exitGuestMode(ref);
      final hasSession =
          ref.read(authServiceProvider).currentSession?.user != null;
      if (widget.autoResumeFinalize &&
          !_autoResumeTriggered &&
          hasSession &&
          _step == 2 &&
          !_loading) {
        _autoResumeTriggered = true;
        unawaited(_submit());
      }
    });
  }

  void _applyDraft(RegisterWizardDraft draft) {
    _step = draft.step.clamp(0, 2);
    _prenom.text = draft.prenom;
    _nom.text = draft.nom;
    _phone.text = draft.phone;
    _email.text = draft.email;
    _password.text = draft.password;
    _confirm.text = draft.confirmPassword;
    _adresse.text = draft.adresse;
    _salon.text = draft.salon;
    _nomAffiche.text = draft.nomAffiche;
    _codePostal.text = draft.codePostal;
    _description.text = draft.description;
    _ville.text = draft.ville;
    _bio.text = draft.bio;
    _phoneDialCode = draft.phoneDialCode;
    _roleChoice = draft.role;
    _signedUpViaOAuth = draft.signedUpViaOAuth;
    _phoneRequiredOnExtras = draft.phoneRequiredOnExtras;
    _pendingEmailVerification = draft.pendingEmailVerification;
  }

  void _attachAutosave() {
    void scheduleSave() {
      _saveDebounce?.cancel();
      _saveDebounce = Timer(const Duration(milliseconds: 400), _persistDraft);
    }

    for (final controller in [
      _prenom,
      _nom,
      _phone,
      _email,
      _password,
      _confirm,
      _adresse,
      _salon,
      _ville,
      _bio,
    ]) {
      controller.addListener(scheduleSave);
    }
  }

  bool _pendingEmailVerification = false;

  RegisterWizardDraft _currentDraft() => RegisterWizardDraft(
        step: _step,
        prenom: _prenom.text,
        nom: _nom.text,
        phone: _phone.text,
        phoneDialCode: _phoneDialCode,
        email: _email.text,
        password: _password.text,
        confirmPassword: _confirm.text,
        adresse: _adresse.text,
        salon: _salon.text,
        nomAffiche: _nomAffiche.text,
        codePostal: _codePostal.text,
        description: _description.text,
        ville: _ville.text,
        bio: _bio.text,
        signedUpViaOAuth: _signedUpViaOAuth,
        phoneRequiredOnExtras: _phoneRequiredOnExtras,
        pendingEmailVerification: _pendingEmailVerification,
        role: _roleChoice,
      );

  Future<void> _persistDraft({bool? pendingEmailVerification}) async {
    if (!_persistDraftOnDispose) return;
    if (pendingEmailVerification != null) {
      _pendingEmailVerification = pendingEmailVerification;
    }
    await RegisterWizardDraftStore.instance.save(_currentDraft());
  }

  User? _activeSessionUser(ProviderContainer container) {
    return container.read(authServiceProvider).currentSession?.user;
  }

  Future<void> _clearDraft() => RegisterWizardDraftStore.instance.clear();

  @override
  void dispose() {
    _saveDebounce?.cancel();
    if (_persistDraftOnDispose) {
      unawaited(_persistDraft());
    }
    _prenom.dispose();
    _nom.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _adresse.dispose();
    _salon.dispose();
    _nomAffiche.dispose();
    _codePostal.dispose();
    _description.dispose();
    _ville.dispose();
    _bio.dispose();
    super.dispose();
  }

  bool get _isPresta => _roleChoice == UserRole.prestataire;

  void _hydrateFromOAuthUser(User user) {
    final meta = user.userMetadata;
    final prenom = meta?['prenom'] as String? ?? '';
    final nom = meta?['nom'] as String? ?? '';
    final fullName = (meta?['full_name'] as String?)?.trim() ?? '';

    if (prenom.trim().isNotEmpty) {
      _prenom.text = prenom.trim();
    } else if (fullName.isNotEmpty) {
      final parts = fullName.split(RegExp(r'\s+'));
      _prenom.text = parts.first;
      if (parts.length > 1) {
        _nom.text = parts.sublist(1).join(' ');
      }
    }

    final metaNom = nom.trim();
    if (metaNom.isNotEmpty) {
      _nom.text = metaNom;
    }

    final phone = meta?['phone'] as String?;
    if (phone != null && phone.trim().isNotEmpty) {
      final parsed = PhoneNumberUtils.parseStored(phone);
      _phoneDialCode = parsed.dialCode;
      _phone.text = parsed.local;
    } else {
      _phoneRequiredOnExtras = true;
    }

    final email = user.email;
    if (email != null && email.isNotEmpty) {
      _email.text = email;
    }

    _signedUpViaOAuth = true;
  }

  Future<void> _googleSignIn() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);

    if (!await ensureOnline(context, ref)) return;

    if (!AppConfig.hasSupabase) {
      setState(() => _error = ShellStrings.supabaseMissingTitle);
      return;
    }

    _googleLaunched = true;
    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
      if (!mounted) return;
      AppSnackBar.info(context, AuthStrings.loginGoogleStarted);
    } on AppFailure catch (e) {
      if (mounted) {
        setState(() {
          _error = e.message;
          _googleLaunched = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _error = CoreStrings.errorUnexpected;
          _googleLaunched = false;
        });
      }
    }
  }

  /// Google ne remplace que l’étape Compte : préremplissage, pas de saut d’étape.
  Future<void> _onOAuthConnected(User user) async {
    _hydrateFromOAuthUser(user);
    await _persistDraft();
    if (!mounted) return;
    setState(() {
      _googleLaunched = false;
      _error = null;
      _clearFieldErrors();
    });
    AppSnackBar.success(context, AuthStrings.registerGoogleConnected);
  }

  Future<void> _showRegistrationSuccessDialog() => AuthSuccessDialog.show(
        context,
        title: AuthStrings.registerSuccessTitle,
        body: AuthStrings.registerSuccessBody,
        actionLabel: AuthStrings.registerSuccessCta,
      );

  void _clearFieldErrors() {
    _prenomError = null;
    _nomError = null;
    _phoneError = null;
    _emailError = null;
    _passwordError = null;
    _confirmError = null;
    _salonError = null;
    _villeError = null;
  }

  void _goToPreviousStep() {
    if (_step == 0) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _step -= 1;
      _error = null;
      _clearFieldErrors();
    });
    unawaited(_persistDraft());
  }

  bool _validateStep0() {
    final pErr = _prenom.text.trim().isEmpty
        ? AuthStrings.registerValidationPrenomEmpty
        : null;
    final nErr =
        _nom.text.trim().isEmpty ? AuthStrings.registerValidationNomEmpty : null;
    String? phErr;
    if (!_signedUpViaOAuth || !_phoneRequiredOnExtras) {
      phErr = RegisterValidators.phoneLocal(
        _phone.text,
        dialCode: _phoneDialCode,
      );
    }
    String? emailErr;
    String? pwErr;
    String? confirmErr;
    if (!_signedUpViaOAuth) {
      emailErr = RegisterValidators.email(_email.text.trim());
      pwErr = RegisterValidators.password(_password.text);
      confirmErr = _password.text != _confirm.text
          ? AuthStrings.registerValidationPasswordMismatch
          : null;
    }

    setState(() {
      _prenomError = pErr;
      _nomError = nErr;
      _phoneError = phErr;
      _emailError = emailErr;
      _passwordError = pwErr;
      _confirmError = confirmErr;
      _error = null;
    });

    return pErr == null &&
        nErr == null &&
        phErr == null &&
        emailErr == null &&
        pwErr == null &&
        confirmErr == null;
  }

  bool _isRoleSyncForbidden(Object error) {
    if (error is SupabaseServiceException) {
      return error.code == '42501' ||
          error.message == AuthStrings.roleChoiceSyncForbidden;
    }
    if (error is AppFailure) {
      return error.message == AuthStrings.roleChoiceSyncForbidden;
    }
    return false;
  }

  /// [container] : pour [ProviderContainer.invalidate] uniquement après la sync.
  ///
  /// Aucun `ref.read` ni `container.read(provider)` qui déclenche le graphe des
  /// providers d’auth ici : l’écran peut être démonté pendant les `await` et
  /// Riverpod ferait alors lever « ref while unmounted ».
  Future<void> _syncRoleBestEffort(
    UserRole role,
    ProviderContainer container,
  ) async {
    if (!AppConfig.hasSupabase) return;
    final rolesService = RoleService.fromEnv();
    try {
      await rolesService.ensureRole(role);
      final serverRoles = await rolesService.getMyRoles();
      await AuthRoleCache.persistServerRoles(serverRoles);
      container.invalidate(myRolesProvider);
    } catch (e) {
      if (!_isRoleSyncForbidden(e)) rethrow;
      // RLS/permission transitoire: on poursuit avec le rôle local choisi.
    }
  }

  void _next() {
    FocusScope.of(context).unfocus();

    if (_step == 0) {
      if (!_validateStep0()) return;
      setState(() {
        _step = 1;
        _error = null;
        _clearFieldErrors();
      });
      unawaited(_persistDraft());
      return;
    }

    if (_step == 1) {
      if (_roleChoice == null) {
        setState(() => _error = AuthStrings.registerValidationRoleEmpty);
        return;
      }
      setState(() {
        _step = 2;
        _error = null;
        _clearFieldErrors();
      });
      unawaited(_persistDraft());
    }
  }

  bool _validateExtrasStep() {
    String? phErr;
    if (_phoneRequiredOnExtras) {
      phErr = RegisterValidators.phoneLocal(
        _phone.text,
        dialCode: _phoneDialCode,
      );
    }

    String? salonErr;
    String? villeErr;
    if (_isPresta) {
      salonErr = _salon.text.trim().isEmpty
          ? AuthStrings.registerValidationSalonEmpty
          : null;
      villeErr = _ville.text.trim().isEmpty
          ? AuthStrings.registerValidationVilleEmpty
          : null;
    }

    setState(() {
      _phoneError = phErr;
      _salonError = salonErr;
      _villeError = villeErr;
      _error = null;
    });

    return phErr == null && salonErr == null && villeErr == null;
  }

  Future<void> _completeRegistrationAfterAuth({
    required User session,
    required String prenom,
    required String nom,
    required String phone,
    required ProviderContainer providerContainer,
  }) async {
    final uid = session.id;
    final post = PostSignupProfileService.fromEnv();
    final shellRole = _roleChoice == UserRole.prestataire
        ? 'prestataire'
        : 'client';

    // Avant sync serveur : évite que persistServerRoles ne force « client »
    // (rôle créé par le trigger auth) pendant ensureRole(prestataire).
    await LocalCacheService.instance.setSelectedRole(shellRole);
    await LocalCacheService.instance.setSignupShellRole(shellRole);

    await post.updateUserIdentity(
      userId: uid,
      prenom: prenom,
      nom: nom,
      phone: phone,
    );

    if (!mounted) return;

    if (_roleChoice == UserRole.prestataire) {
      await _syncRoleBestEffort(UserRole.prestataire, providerContainer);
      await post.updatePrestataireExtras(
        userId: uid,
        nomSalon: _salon.text.trim(),
        nomAffiche: _nomAffiche.text.trim().isEmpty
            ? _salon.text.trim()
            : _nomAffiche.text.trim(),
        ville: _ville.text.trim(),
        codePostal: _codePostal.text.trim().isEmpty
            ? null
            : _codePostal.text.trim(),
        description: _description.text.trim().isEmpty
            ? null
            : _description.text.trim(),
        bio: _bio.text.trim(),
        adresse: _adresse.text.trim().isEmpty ? null : _adresse.text.trim(),
      );
    } else {
      await _syncRoleBestEffort(UserRole.client, providerContainer);
      await post.updateClientExtras(
        userId: uid,
        adresse: _adresse.text.trim().isEmpty ? null : _adresse.text.trim(),
      );
    }

    await LocalCacheService.instance.setSelectedRole(shellRole);
    _persistDraftOnDispose = false;
    _saveDebounce?.cancel();
    await _clearDraft();

    if (!mounted) return;
    setState(() => _loading = false);

    await _showRegistrationSuccessDialog();
    if (!mounted) return;

    if (_roleChoice == UserRole.prestataire) {
      await BecomePrestataireDraftStore.instance.save(
        BecomePrestataireDraft(
          salon: _salon.text.trim(),
          ville: _ville.text.trim(),
          bio: _bio.text.trim(),
          step1Submitted: true,
          step2Started: true,
        ),
      );
      if (!mounted) return;
      await PrestataireNavigation.afterPrestaRegistration(
        context,
        providerContainer,
      );
    } else {
      context.goHome();
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);

    if (!await ensureOnline(context, ref)) return;

    if (!AppConfig.hasSupabase) {
      setState(() => _error = ShellStrings.supabaseMissingTitle);
      return;
    }

    if (!_validateExtrasStep()) return;

    setState(() => _loading = true);

    if (!mounted) return;
    final providerContainer = ProviderScope.containerOf(context);

    try {
      final prenom = _prenom.text.trim();
      final nom = _nom.text.trim();
      final email = _email.text.trim();
      final phone = PhoneNumberUtils.toStored(
        dialCode: _phoneDialCode,
        local: _phone.text,
      );

      var sessionUser = _activeSessionUser(providerContainer);

      if (!_signedUpViaOAuth) {
        final hasActiveSession = sessionUser != null &&
            sessionUser.email?.trim().toLowerCase() == email.toLowerCase();

        if (!hasActiveSession) {
          await providerContainer
              .read(authNotifierProvider.notifier)
              .signUpWithPassword(
                email: email,
                password: _password.text,
                displayName: '$prenom $nom'.trim(),
                prenom: prenom,
                nom: nom,
                phone: phone,
              );

          if (!mounted) return;

          final authState = providerContainer.read(authNotifierProvider);

          if (authState.hasError) {
            final err = authState.error;
            setState(() {
              _loading = false;
              _error = err is AppFailure
                  ? err.message
                  : CoreStrings.errorUnexpected;
            });
            return;
          }

          sessionUser = _activeSessionUser(providerContainer);
        }

        if (sessionUser == null) {
          await _persistDraft(pendingEmailVerification: true);
          if (!mounted) return;
          setState(() => _loading = false);
          await context.pushNamed(
            AppRouteNames.registerVerifyEmail,
            queryParameters: {'email': email},
          );
          return;
        }
      } else {
        sessionUser ??= _activeSessionUser(providerContainer);
        if (sessionUser == null) {
          setState(() {
            _loading = false;
            _error = AuthStrings.loginGoogleStarted;
          });
          return;
        }
      }

      await _completeRegistrationAfterAuth(
        session: sessionUser,
        prenom: prenom,
        nom: nom,
        phone: phone,
        providerContainer: providerContainer,
      );
    } on AppFailure catch (e) {
      debugPrint(
        '[RegisterWizard] submit AppFailure: ${e.message} cause=${e.cause}',
      );
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.message;
        });
      }
    } catch (e, st) {
      debugPrint('[RegisterWizard] submit unexpected: $e');
      debugPrintStack(stackTrace: st);
      if (mounted) {
        setState(() {
          _loading = false;
          _error = CoreStrings.errorUnexpected;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authNotifierProvider, (previous, next) {
      if (!_googleLaunched || _step != 0) return;
      final user = switch (next) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (user == null) return;
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted || !_googleLaunched || _step != 0) return;
        unawaited(_onOAuthConnected(user));
      });
    });

    final theme = Theme.of(context);
    final formEnabled = AppConfig.hasSupabase && !_loading;
    final onSurfaceVariant = theme.colorScheme.onSurfaceVariant;

    final stepTitle = switch (_step) {
      0 => AuthStrings.registerStepIdentityTitle,
      1 => AuthStrings.registerStepRoleTitle,
      _ => AuthStrings.registerStepExtrasTitle,
    };
    final stepSubtitle = switch (_step) {
      0 => AuthStrings.registerStepIdentitySubtitle,
      1 => AuthStrings.registerStepRoleSubtitle,
      _ when _isPresta => AuthStrings.registerStepExtrasPrestaSubtitle,
      _ => AuthStrings.registerStepExtrasClientSubtitle,
    };

    final stepLabel = switch (_step) {
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
        currentStep: _step,
        totalSteps: _totalSteps,
        stepLabel: stepLabel,
        compact: true,
      ),
      onBack: _loading
          ? () {}
          : () {
              if (_step == 0) {
                _persistDraftOnDispose = false;
                _saveDebounce?.cancel();
                unawaited(_clearDraft());
                if (context.canPop()) {
                  context.pop();
                } else {
                  context.goWelcome();
                }
              } else {
                _goToPreviousStep();
              }
            },
      isBackEnabled: !_loading,
      bottomBar: RegisterWizardBottomBar(
        showBack: _step > 0,
        isLoading: _loading,
        enabled: formEnabled,
        primaryLabel: _step < 2
            ? AuthStrings.registerWizardNext
            : AuthStrings.registerWizardSubmit,
        onBack: _goToPreviousStep,
        onPrimary: _loading
            ? null
            : () {
                if (_step < 2) {
                  _next();
                } else {
                  _submit();
                }
              },
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_restoredDraft) ...[
            _DraftRestoredBanner(
              onRestart: () async {
                _persistDraftOnDispose = true;
                _saveDebounce?.cancel();
                await _clearDraft();
                if (!mounted) return;
                setState(() {
                  _restoredDraft = false;
                  _step = 0;
                  _roleChoice = null;
                  _signedUpViaOAuth = false;
                  _phoneRequiredOnExtras = false;
                  _pendingEmailVerification = false;
                  _error = null;
                  _clearFieldErrors();
                  _prenom.clear();
                  _nom.clear();
                  _phone.clear();
                  _email.clear();
                  _password.clear();
                  _confirm.clear();
                  _adresse.clear();
                  _salon.clear();
                  _nomAffiche.clear();
                  _codePostal.clear();
                  _description.clear();
                  _ville.clear();
                  _bio.clear();
                  _phoneDialCode = '+33';
                });
              },
            ),
            const SizedBox(height: 10),
          ],
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeInCubic,
            transitionBuilder: (child, animation) {
              final offset = Tween<Offset>(
                begin: const Offset(0.03, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              ));
              return FadeTransition(
                opacity: animation,
                child: SlideTransition(position: offset, child: child),
              );
            },
            child: KeyedSubtree(
              key: ValueKey<int>(_step),
              child: switch (_step) {
                0 => _buildIdentityStep(
                    theme: theme,
                    formEnabled: formEnabled,
                    onSurfaceVariant: onSurfaceVariant,
                  ),
                1 => _buildRoleStep(
                    theme: theme,
                    formEnabled: formEnabled,
                    onSurfaceVariant: onSurfaceVariant,
                  ),
                _ => _buildExtrasStep(
                    theme: theme,
                    formEnabled: formEnabled,
                    onSurfaceVariant: onSurfaceVariant,
                  ),
              },
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 10),
            AuthErrorBanner(message: _error!),
          ],
        ],
      ),
    );
  }

  Widget _buildIdentityStep({
    required ThemeData theme,
    required bool formEnabled,
    required Color onSurfaceVariant,
  }) {
    final showPhoneHere = !_signedUpViaOAuth || !_phoneRequiredOnExtras;

    return AuthFormCard(
      compact: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (!_signedUpViaOAuth) ...[
            AuthStepSection(
              compact: true,
              title: AuthStrings.registerSectionQuick,
              subtitle: AuthStrings.registerSectionQuickHint,
              icon: Icons.bolt_outlined,
              child: AuthGoogleButton(
                label: AuthStrings.registerActionGoogle,
                enabled: formEnabled,
                onPressed: _googleSignIn,
              ),
            ),
            const SizedBox(height: _sectionGap),
            const AuthOrDivider(compact: true),
            const SizedBox(height: _sectionGap),
          ],
          AuthStepSection(
            compact: true,
            title: AuthStrings.registerSectionIdentity,
            icon: Icons.person_outline_rounded,
            child: RegisterFieldRow(
              left: AppTextField(
                dense: true,
                controller: _prenom,
                onChanged: (_) => setState(() => _prenomError = null),
                enabled: formEnabled,
                label: AuthStrings.registerFieldPrenom,
                errorText: _prenomError,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.givenName],
              ),
              right: AppTextField(
                dense: true,
                controller: _nom,
                onChanged: (_) => setState(() => _nomError = null),
                enabled: formEnabled,
                label: AuthStrings.registerFieldNom,
                errorText: _nomError,
                textInputAction: TextInputAction.next,
                autofillHints: const [AutofillHints.familyName],
              ),
            ),
          ),
          const SizedBox(height: _sectionGap),
          AuthStepSection(
            compact: true,
            title: AuthStrings.registerSectionContact,
            icon: Icons.contact_phone_outlined,
            child: Column(
              children: [
                if (showPhoneHere) ...[
                  PhoneNumberField(
                    dense: true,
                    enabled: formEnabled,
                    localController: _phone,
                    dialCode: _phoneDialCode,
                    errorText: _phoneError,
                    onDialCodeChanged: (code) {
                      setState(() => _phoneDialCode = code);
                      unawaited(_persistDraft());
                    },
                    onLocalChanged: () => setState(() => _phoneError = null),
                  ),
                  const SizedBox(height: _fieldGap),
                ],
                AppTextField(
                  dense: true,
                  controller: _email,
                  onChanged: (_) => setState(() => _emailError = null),
                  enabled: formEnabled && !_signedUpViaOAuth,
                  label: AuthStrings.loginFieldEmail,
                  errorText: _emailError,
                  keyboardType: TextInputType.emailAddress,
                  autocorrect: false,
                  textInputAction: TextInputAction.next,
                  autofillHints: const [
                    AutofillHints.email,
                    AutofillHints.username,
                  ],
                  prefixIcon: Icon(
                    Icons.mail_outline,
                    color: onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          if (_signedUpViaOAuth) ...[
            const SizedBox(height: _sectionGap),
            const _GoogleConnectedBanner(),
          ],
          if (!_signedUpViaOAuth) ...[
            const SizedBox(height: _sectionGap),
            AuthStepSection(
              compact: true,
              title: AuthStrings.registerSectionSecurity,
              icon: Icons.lock_outline_rounded,
              child: Column(
                children: [
                  AppTextField(
                    dense: true,
                    controller: _password,
                    onChanged: (_) => setState(() => _passwordError = null),
                    enabled: formEnabled,
                    label: AuthStrings.loginFieldPassword,
                    hint: AuthStrings.registerFieldPasswordHint,
                    errorText: _passwordError,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.next,
                    autofillHints: const [AutofillHints.newPassword],
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: onSurfaceVariant,
                    ),
                    suffixIcon: IconButton(
                      tooltip: _obscurePassword
                          ? AuthStrings.loginShowPassword
                          : AuthStrings.loginHidePassword,
                      onPressed: formEnabled
                          ? () => setState(
                                () => _obscurePassword = !_obscurePassword,
                              )
                          : null,
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ),
                  const SizedBox(height: _fieldGap),
                  AppTextField(
                    dense: true,
                    controller: _confirm,
                    onChanged: (_) => setState(() => _confirmError = null),
                    enabled: formEnabled,
                    label: AuthStrings.registerFieldConfirmPassword,
                    errorText: _confirmError,
                    obscureText: _obscureConfirmPassword,
                    textInputAction: TextInputAction.done,
                    autofillHints: const [AutofillHints.newPassword],
                    prefixIcon: Icon(
                      Icons.lock_outline,
                      color: onSurfaceVariant,
                    ),
                    suffixIcon: IconButton(
                      tooltip: _obscureConfirmPassword
                          ? AuthStrings.loginShowPassword
                          : AuthStrings.loginHidePassword,
                      onPressed: formEnabled
                          ? () => setState(
                                () => _obscureConfirmPassword =
                                    !_obscureConfirmPassword,
                              )
                          : null,
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        color: onSurfaceVariant,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleStep({
    required ThemeData theme,
    required bool formEnabled,
    required Color onSurfaceVariant,
  }) {
    return AuthFormCard(
      compact: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            AuthStrings.roleChoiceDescription,
            style: theme.textTheme.bodySmall?.copyWith(
              fontFamily: AppFonts.body,
              color: onSurfaceVariant,
              height: 1.35,
            ),
          ),
          const SizedBox(height: _sectionGap),
          AuthRoleCard(
            compact: true,
            selected: _roleChoice == UserRole.client,
            title: AuthStrings.registerChooseClient,
            subtitle: AuthStrings.registerChooseClientHint,
            icon: Icons.spa_outlined,
            onTap: formEnabled
                ? () {
                    setState(() {
                      _roleChoice = UserRole.client;
                      _error = null;
                    });
                    unawaited(_persistDraft());
                  }
                : null,
          ),
          const SizedBox(height: _fieldGap),
          AuthRoleCard(
            compact: true,
            selected: _roleChoice == UserRole.prestataire,
            title: AuthStrings.registerChoosePresta,
            subtitle: AuthStrings.registerChoosePrestaHint,
            icon: Icons.storefront_outlined,
            onTap: formEnabled
                ? () {
                    setState(() {
                      _roleChoice = UserRole.prestataire;
                      _error = null;
                    });
                    unawaited(_persistDraft());
                  }
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildExtrasStep({
    required ThemeData theme,
    required bool formEnabled,
    required Color onSurfaceVariant,
  }) {
    return AuthFormCard(
      compact: true,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_phoneRequiredOnExtras) ...[
            AuthStepSection(
              compact: true,
              title: AuthStrings.registerSectionContact,
              subtitle: AuthStrings.registerGooglePhoneHint,
              icon: Icons.phone_outlined,
              child: PhoneNumberField(
                dense: true,
                enabled: formEnabled,
                localController: _phone,
                dialCode: _phoneDialCode,
                errorText: _phoneError,
                onDialCodeChanged: (code) {
                  setState(() => _phoneDialCode = code);
                },
                onLocalChanged: () => setState(() {
                  _phoneError = null;
                  _error = null;
                }),
              ),
            ),
            const SizedBox(height: _sectionGap),
          ],
          if (!_isPresta)
            AppTextField(
              dense: true,
              controller: _adresse,
              enabled: formEnabled,
              label: AuthStrings.registerFieldAdresse,
              maxLines: 2,
              prefixIcon: Icon(
                Icons.location_on_outlined,
                color: onSurfaceVariant,
              ),
            )
          else ...[
            AuthStepSection(
              compact: true,
              title: AuthStrings.registerSectionActivity,
              subtitle: AuthStrings.registerSectionActivityHint,
              icon: Icons.storefront_outlined,
              child: AppTextField(
                dense: true,
                controller: _salon,
                onChanged: (_) => setState(() {
                  _salonError = null;
                  _error = null;
                }),
                enabled: formEnabled,
                label: AuthStrings.registerFieldSalon,
                errorText: _salonError,
                textInputAction: TextInputAction.next,
                prefixIcon: Icon(
                  Icons.storefront_outlined,
                  color: onSurfaceVariant,
                ),
              ),
            ),
            const SizedBox(height: _sectionGap),
            AuthStepSection(
              compact: true,
              title: AuthStrings.registerSectionLocation,
              icon: Icons.location_city_outlined,
              child: RegisterFieldRow(
                left: AppTextField(
                  dense: true,
                  controller: _ville,
                  onChanged: (_) => setState(() {
                    _villeError = null;
                    _error = null;
                  }),
                  enabled: formEnabled,
                  label: AuthStrings.registerFieldVille,
                  errorText: _villeError,
                  textInputAction: TextInputAction.next,
                  prefixIcon: Icon(
                    Icons.location_city_outlined,
                    color: onSurfaceVariant,
                  ),
                ),
                right: AppTextField(
                  dense: true,
                  controller: _codePostal,
                  enabled: formEnabled,
                  label: AuthStrings.registerFieldPostalCode,
                  keyboardType: TextInputType.number,
                  prefixIcon: Icon(
                    Icons.markunread_mailbox_outlined,
                    color: onSurfaceVariant,
                  ),
                ),
              ),
            ),
            const SizedBox(height: _sectionGap),
            RegisterOptionalPanel(
              children: [
                AppTextField(
                  dense: true,
                  controller: _nomAffiche,
                  enabled: formEnabled,
                  label: AuthStrings.registerFieldDisplayName,
                  prefixIcon: Icon(
                    Icons.badge_outlined,
                    color: onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: _fieldGap),
                AppTextField(
                  dense: true,
                  controller: _description,
                  enabled: formEnabled,
                  label: AuthStrings.registerFieldDescriptionPresta,
                  maxLines: 2,
                  prefixIcon: Icon(
                    Icons.short_text_outlined,
                    color: onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: _fieldGap),
                AppTextField(
                  dense: true,
                  controller: _adresse,
                  enabled: formEnabled,
                  label: AuthStrings.registerFieldSalonAdresse,
                  maxLines: 2,
                  prefixIcon: Icon(
                    Icons.location_on_outlined,
                    color: onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: _fieldGap),
                AppTextField(
                  dense: true,
                  controller: _bio,
                  enabled: formEnabled,
                  label: AuthStrings.registerFieldBioPresta,
                  maxLines: 2,
                  prefixIcon: Icon(
                    Icons.notes_outlined,
                    color: onSurfaceVariant,
                  ),
                ),
              ],
            ),
            const SizedBox(height: _sectionGap),
            _PrestaSubscriptionRegisterHint(
              onSurfaceVariant: onSurfaceVariant,
            ),
          ],
        ],
      ),
    );
  }
}

class _PrestaSubscriptionRegisterHint extends StatelessWidget {
  const _PrestaSubscriptionRegisterHint({required this.onSurfaceVariant});

  final Color onSurfaceVariant;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.35),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.card_membership_outlined,
            size: 22,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              DiscPrestaSub.registerHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _GoogleConnectedBanner extends StatelessWidget {
  const _GoogleConnectedBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.primaryContainer.withValues(alpha: 0.75),
        borderRadius: BorderRadius.circular(AuthFormStyles.bannerRadius),
        border: Border.all(
          color: theme.colorScheme.primary.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 20,
            color: theme.colorScheme.primary,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              AuthStrings.registerGoogleConnectedBanner,
              style: theme.textTheme.labelLarge?.copyWith(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w600,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _DraftRestoredBanner extends StatelessWidget {
  const _DraftRestoredBanner({required this.onRestart});

  final VoidCallback onRestart;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.9),
      borderRadius: BorderRadius.circular(AuthFormStyles.bannerRadius),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 8, 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.restore_rounded,
                size: 20,
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AuthStrings.registerDraftRestored,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: AppFonts.body,
                  color: theme.colorScheme.onPrimaryContainer,
                  height: 1.4,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: onRestart,
              child: Text(
                AuthStrings.registerDraftRestart,
                style: TextStyle(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
