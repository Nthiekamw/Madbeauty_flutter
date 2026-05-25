import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/models/user_role.dart';
import '../../../../router/navigation_extensions.dart';
import '../../logic/auth_role_cache.dart';
import '../../../prestataire/navigation/prestataire_navigation.dart';
import '../../../../services/auth/post_signup_profile_service.dart';
import '../../../../services/offline/offline_actions.dart';
import '../../../../services/storage/local_cache_service.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/auth_form_styles.dart';
import '../../../../shared/widgets/app_snack_bar.dart';
import '../../../../shared/widgets/app_button.dart';
import '../../../../shared/widgets/app_text_field.dart';
import '../../guest/guest_mode_provider.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/my_roles_provider.dart';
import '../../widgets/auth_error_banner.dart';
import '../../widgets/auth_form_card.dart';
import '../../widgets/auth_form_scaffold.dart';
import '../../widgets/auth_google_button.dart';
import '../../widgets/auth_or_divider.dart';
import '../../widgets/auth_role_card.dart';
import '../../widgets/auth_step_header.dart';
import '../logic/register_validators.dart';
import '../logic/register_wizard_draft.dart';
import '../storage/register_wizard_draft_store.dart';

/// Inscription en 3 étapes : identité → rôle → infos complémentaires.
class RegisterWizardScreen extends ConsumerStatefulWidget {
  const RegisterWizardScreen({super.key});

  @override
  ConsumerState<RegisterWizardScreen> createState() =>
      _RegisterWizardScreenState();
}

class _RegisterWizardScreenState extends ConsumerState<RegisterWizardScreen> {
  late final PageController _pageController;
  int _step = 0;
  Timer? _saveDebounce;
  bool _restoredDraft = false;

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
  String? _error;
  bool _loading = false;
  bool _signedUpViaOAuth = false;
  bool _googleLaunched = false;
  bool _phoneRequiredOnExtras = false;

  @override
  void initState() {
    super.initState();
    final draft = RegisterWizardDraftStore.instance.read();
    if (draft != null) {
      _applyDraft(draft);
      _restoredDraft = true;
    }
    _pageController = PageController(initialPage: _step);
    _attachAutosave();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      exitGuestMode(ref);
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
    _ville.text = draft.ville;
    _bio.text = draft.bio;
    _roleChoice = draft.role;
    _signedUpViaOAuth = draft.signedUpViaOAuth;
    _phoneRequiredOnExtras = draft.phoneRequiredOnExtras;
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

  RegisterWizardDraft _currentDraft() => RegisterWizardDraft(
        step: _step,
        prenom: _prenom.text,
        nom: _nom.text,
        phone: _phone.text,
        email: _email.text,
        password: _password.text,
        confirmPassword: _confirm.text,
        adresse: _adresse.text,
        salon: _salon.text,
        ville: _ville.text,
        bio: _bio.text,
        signedUpViaOAuth: _signedUpViaOAuth,
        phoneRequiredOnExtras: _phoneRequiredOnExtras,
        role: _roleChoice,
      );

  Future<void> _persistDraft() async {
    await RegisterWizardDraftStore.instance.save(_currentDraft());
  }

  Future<void> _clearDraft() => RegisterWizardDraftStore.instance.clear();

  @override
  void dispose() {
    _saveDebounce?.cancel();
    unawaited(_persistDraft());
    _pageController.dispose();
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
      _phone.text = phone.trim();
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

  void _advanceAfterOAuth(User user) {
    _hydrateFromOAuthUser(user);
    _pageController.nextPage(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
    setState(() {
      _step = 1;
      _googleLaunched = false;
    });
    unawaited(_persistDraft());
  }

  void _next() {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);

    if (_step == 0) {
      final pErr = _prenom.text.trim().isEmpty
          ? AuthStrings.registerValidationPrenomEmpty
          : null;
      final nErr =
          _nom.text.trim().isEmpty ? AuthStrings.registerValidationNomEmpty : null;
      String? phErr;
      if (!_signedUpViaOAuth) {
        phErr = _phone.text.trim().isEmpty
            ? AuthStrings.registerValidationPhoneEmpty
            : null;
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

      if (pErr != null ||
          nErr != null ||
          phErr != null ||
          emailErr != null ||
          pwErr != null ||
          confirmErr != null) {
        setState(
          () => _error = emailErr ?? pErr ?? nErr ?? phErr ?? pwErr ?? confirmErr,
        );
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() => _step = 1);
      unawaited(_persistDraft());
      return;
    }

    if (_step == 1) {
      if (_roleChoice == null) {
        setState(() => _error = 'Choisis un profil.');
        return;
      }
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
      setState(() => _step = 2);
      unawaited(_persistDraft());
      return;
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

    if (_phoneRequiredOnExtras && _phone.text.trim().isEmpty) {
      setState(() => _error = AuthStrings.registerValidationPhoneEmpty);
      return;
    }

    if (_isPresta) {
      if (_salon.text.trim().isEmpty || _ville.text.trim().isEmpty) {
        setState(() =>
            _error = 'Renseigne au moins le nom du salon et la ville.');
        return;
      }
    }

    setState(() => _loading = true);

    try {
      final prenom = _prenom.text.trim();
      final nom = _nom.text.trim();
      final email = _email.text.trim();
      final phone = _phone.text.trim();

      User? session = switch (ref.read(authNotifierProvider)) {
        AsyncData(:final value) => value,
        _ => null,
      };

      if (!_signedUpViaOAuth) {
        await ref.read(authNotifierProvider.notifier).signUpWithPassword(
              email: email,
              password: _password.text,
              displayName: '$prenom $nom'.trim(),
              prenom: prenom,
              nom: nom,
              phone: phone,
            );

        if (!mounted) return;

        final authState = ref.read(authNotifierProvider);

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

        session = switch (authState) {
          AsyncData(:final value) => value,
          _ => null,
        };

        session =
            ref.read(authServiceProvider).currentSession?.user ?? session;
        if (session == null) {
          setState(() {
            _loading = false;
            _error = AuthStrings.authEmailNotConfirmed;
          });
          return;
        }
      } else if (session == null) {
        setState(() {
          _loading = false;
          _error = AuthStrings.loginGoogleStarted;
        });
        return;
      }

      final uid = session.id;
      final roles = ref.read(roleServiceProvider);
      final post = PostSignupProfileService.fromEnv();

      await post.updateUserIdentity(
        userId: uid,
        prenom: prenom,
        nom: nom,
        phone: phone,
      );

      if (_roleChoice == UserRole.prestataire) {
        await roles.ensureRole(UserRole.prestataire);
        ref.invalidate(myRolesProvider);
        final serverRoles = await ref.read(myRolesProvider.future);
        await AuthRoleCache.persistServerRoles(serverRoles);
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
        await roles.ensureRole(UserRole.client);
        await post.updateClientExtras(
          userId: uid,
          adresse: _adresse.text.trim().isEmpty ? null : _adresse.text.trim(),
        );
        ref.invalidate(myRolesProvider);
        final serverRoles = await ref.read(myRolesProvider.future);
        await AuthRoleCache.persistServerRoles(serverRoles);
      }

      final shellRole = _roleChoice == UserRole.prestataire
          ? 'prestataire'
          : 'client';
      await LocalCacheService.instance.setSelectedRole(shellRole);
      await _clearDraft();

      if (!mounted) return;
      setState(() => _loading = false);
      if (_roleChoice == UserRole.prestataire) {
        await PrestataireNavigation.afterPrestaRegistration(context, ref);
      } else {
        context.goHome();
      }
    } on AppFailure catch (e) {
      if (mounted) {
        setState(() {
          _loading = false;
          _error = e.message;
        });
      }
    } catch (_) {
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
        _advanceAfterOAuth(user);
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

    return AuthFormScaffold(
      title: stepTitle,
      subtitle: stepSubtitle,
      showLogo: _step == 0,
      scrollable: false,
      onBack: _loading
          ? () {}
          : () {
              if (_step == 0) {
                unawaited(_clearDraft());
                context.pop();
              } else {
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeOut,
                );
                setState(() => _step -= 1);
                unawaited(_persistDraft());
              }
            },
      isBackEnabled: !_loading,
      bottomBar: AppButton(
        isLoading: _loading,
        enabled: formEnabled,
        onPressed: _loading
            ? null
            : () {
                if (_step < 2) {
                  _next();
                } else {
                  _submit();
                }
              },
        child: Text(
          _step < 2
              ? AuthStrings.registerWizardNext
              : AuthStrings.registerWizardSubmit,
          style: const TextStyle(
            fontFamily: AppFonts.body,
            fontWeight: FontWeight.w600,
            fontSize: 16,
          ),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_restoredDraft) ...[
            _DraftRestoredBanner(
              onRestart: () async {
                await _clearDraft();
                if (!mounted) return;
                setState(() {
                  _restoredDraft = false;
                  _step = 0;
                  _roleChoice = null;
                  _signedUpViaOAuth = false;
                  _phoneRequiredOnExtras = false;
                  _prenom.clear();
                  _nom.clear();
                  _phone.clear();
                  _email.clear();
                  _password.clear();
                  _confirm.clear();
                  _adresse.clear();
                  _salon.clear();
                  _ville.clear();
                  _bio.clear();
                });
                _pageController.jumpToPage(0);
              },
            ),
            const SizedBox(height: 16),
          ],
          AuthStepHeader(
            currentStep: _step,
            labels: const [
              AuthStrings.registerStepLabelIdentity,
              AuthStrings.registerStepLabelRole,
              AuthStrings.registerStepLabelExtras,
            ],
          ),
          const SizedBox(height: 20),
          Expanded(
            child: PageView(
              controller: _pageController,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    AuthFormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          AppTextField(
                            controller: _prenom,
                            enabled: formEnabled,
                            label: AuthStrings.registerFieldPrenom,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icon(
                              Icons.badge_outlined,
                              color: onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _nom,
                            enabled: formEnabled,
                            label: AuthStrings.registerFieldNom,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icon(
                              Icons.person_outline,
                              color: onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _phone,
                            enabled: formEnabled,
                            label: AuthStrings.registerFieldPhone,
                            keyboardType: TextInputType.phone,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icon(
                              Icons.phone_outlined,
                              color: onSurfaceVariant,
                            ),
                          ),
                          const SizedBox(height: 14),
                          AppTextField(
                            controller: _email,
                            enabled: formEnabled && !_signedUpViaOAuth,
                            label: AuthStrings.loginFieldEmail,
                            keyboardType: TextInputType.emailAddress,
                            autocorrect: false,
                            textInputAction: TextInputAction.next,
                            prefixIcon: Icon(
                              Icons.mail_outline,
                              color: onSurfaceVariant,
                            ),
                          ),
                          if (!_signedUpViaOAuth) ...[
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _password,
                              enabled: formEnabled,
                              label: AuthStrings.loginFieldPassword,
                              obscureText: true,
                              textInputAction: TextInputAction.next,
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _confirm,
                              enabled: formEnabled,
                              label: AuthStrings.registerFieldConfirmPassword,
                              obscureText: true,
                              textInputAction: TextInputAction.done,
                              prefixIcon: Icon(
                                Icons.lock_outline,
                                color: onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (!_signedUpViaOAuth) ...[
                      const AuthOrDivider(),
                      AuthGoogleButton(
                        label: AuthStrings.registerActionGoogle,
                        enabled: formEnabled,
                        onPressed: _googleSignIn,
                      ),
                    ],
                  ],
                ),
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    AuthFormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Text(
                            AuthStrings.roleChoiceDescription,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              fontFamily: AppFonts.body,
                              color: onSurfaceVariant,
                              height: 1.4,
                            ),
                          ),
                          const SizedBox(height: 20),
                          AuthRoleCard(
                            selected: _roleChoice == UserRole.client,
                            title: AuthStrings.registerChooseClient,
                            subtitle: AuthStrings.registerChooseClientHint,
                            icon: Icons.spa_outlined,
                            onTap: () {
                              setState(() => _roleChoice = UserRole.client);
                              unawaited(_persistDraft());
                            },
                          ),
                          const SizedBox(height: 12),
                          AuthRoleCard(
                            selected: _roleChoice == UserRole.prestataire,
                            title: AuthStrings.registerChoosePresta,
                            subtitle: AuthStrings.registerChoosePrestaHint,
                            icon: Icons.storefront_outlined,
                            onTap: () {
                              setState(
                                () => _roleChoice = UserRole.prestataire,
                              );
                              unawaited(_persistDraft());
                            },
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ListView(
                  padding: EdgeInsets.zero,
                  children: [
                    AuthFormCard(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          if (_phoneRequiredOnExtras) ...[
                            Text(
                              AuthStrings.registerGooglePhoneHint,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: AppFonts.body,
                                color: onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                            const SizedBox(height: 16),
                            AppTextField(
                              controller: _phone,
                              enabled: formEnabled,
                              label: AuthStrings.registerFieldPhone,
                              keyboardType: TextInputType.phone,
                              onChanged: (_) => setState(() => _error = null),
                              prefixIcon: Icon(
                                Icons.phone_outlined,
                                color: onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 20),
                          ],
                          if (!_isPresta) ...[
                            AppTextField(
                              controller: _adresse,
                              enabled: formEnabled,
                              label: AuthStrings.registerFieldAdresse,
                              maxLines: 2,
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: onSurfaceVariant,
                              ),
                            ),
                          ] else ...[
                            AppTextField(
                              controller: _salon,
                              enabled: formEnabled,
                              label: AuthStrings.registerFieldSalon,
                              prefixIcon: Icon(
                                Icons.storefront_outlined,
                                color: onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _nomAffiche,
                              enabled: formEnabled,
                              label: AuthStrings.registerFieldDisplayName,
                              prefixIcon: Icon(
                                Icons.badge_outlined,
                                color: onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _description,
                              enabled: formEnabled,
                              label: AuthStrings.registerFieldDescriptionPresta,
                              maxLines: 2,
                              prefixIcon: Icon(
                                Icons.short_text_outlined,
                                color: onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _ville,
                              enabled: formEnabled,
                              label: AuthStrings.registerFieldVille,
                              prefixIcon: Icon(
                                Icons.location_city_outlined,
                                color: onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _codePostal,
                              enabled: formEnabled,
                              label: AuthStrings.registerFieldPostalCode,
                              keyboardType: TextInputType.number,
                              prefixIcon: Icon(
                                Icons.markunread_mailbox_outlined,
                                color: onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _adresse,
                              enabled: formEnabled,
                              label: AuthStrings.registerFieldSalonAdresse,
                              maxLines: 2,
                              prefixIcon: Icon(
                                Icons.location_on_outlined,
                                color: onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 14),
                            AppTextField(
                              controller: _bio,
                              enabled: formEnabled,
                              label: AuthStrings.registerFieldBioPresta,
                              maxLines: 3,
                              prefixIcon: Icon(
                                Icons.notes_outlined,
                                color: onSurfaceVariant,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            AuthErrorBanner(message: _error!),
          ],
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
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.85),
      borderRadius: BorderRadius.circular(AuthFormStyles.bannerRadius),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.restore_outlined,
              color: theme.colorScheme.onPrimaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                AuthStrings.registerDraftRestored,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontFamily: AppFonts.body,
                  color: theme.colorScheme.onPrimaryContainer,
                  height: 1.35,
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
