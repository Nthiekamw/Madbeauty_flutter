import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/config/app_config.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/models/user_role.dart';
import '../../logic/auth_role_cache.dart';
import '../../navigation/post_auth_navigation.dart';
import '../../../prestataire/navigation/prestataire_navigation.dart';
import '../../../../services/auth/post_signup_profile_service.dart';
import '../../../../services/storage/local_cache_service.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/my_roles_provider.dart';
import '../logic/register_validators.dart';

/// Inscription en 3 étapes : identité → rôle → infos complémentaires.
class RegisterWizardScreen extends ConsumerStatefulWidget {
  const RegisterWizardScreen({super.key});

  @override
  ConsumerState<RegisterWizardScreen> createState() =>
      _RegisterWizardScreenState();
}

class _RegisterWizardScreenState extends ConsumerState<RegisterWizardScreen> {
  final _pageController = PageController();
  int _step = 0;

  final _prenom = TextEditingController();
  final _nom = TextEditingController();
  final _phone = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  final _adresse = TextEditingController();
  final _salon = TextEditingController();
  final _ville = TextEditingController();
  final _bio = TextEditingController();

  UserRole? _roleChoice;
  String? _error;
  bool _loading = false;
  bool _signedUpViaOAuth = false;
  bool _googleLaunched = false;
  bool _phoneRequiredOnExtras = false;

  @override
  void dispose() {
    _pageController.dispose();
    _prenom.dispose();
    _nom.dispose();
    _phone.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    _adresse.dispose();
    _salon.dispose();
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

    if (!AppConfig.hasSupabase) {
      setState(() => _error = ShellStrings.supabaseMissingTitle);
      return;
    }

    _googleLaunched = true;
    try {
      await ref.read(authNotifierProvider.notifier).signInWithGoogle();
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(AuthStrings.loginGoogleStarted)),
      );
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
      return;
    }
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);

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
          ville: _ville.text.trim(),
          bio: _bio.text.trim(),
        );
      } else {
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

      if (!mounted) return;
      setState(() => _loading = false);
      if (_roleChoice == UserRole.prestataire) {
        await PrestataireNavigation.afterPrestaRegistration(context, ref);
      } else {
        await PostAuthNavigation.navigate(context, ref);
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
    return Scaffold(
      appBar: AppBar(
        title: Text(
          switch (_step) {
            0 => AuthStrings.registerStepIdentityTitle,
            1 => AuthStrings.registerStepRoleTitle,
            _ => AuthStrings.registerStepExtrasTitle,
          },
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _loading
              ? null
              : () {
                  if (_step == 0) {
                    context.pop();
                  } else {
                    _pageController.previousPage(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeOut,
                    );
                    setState(() => _step -= 1);
                  }
                },
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            LinearProgressIndicator(value: (_step + 1) / 3),
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                children: [
                  ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      TextField(
                        controller: _prenom,
                        decoration: InputDecoration(
                          labelText: AuthStrings.registerFieldPrenom,
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _nom,
                        decoration: InputDecoration(
                          labelText: AuthStrings.registerFieldNom,
                        ),
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _phone,
                        decoration: InputDecoration(
                          labelText: AuthStrings.registerFieldPhone,
                        ),
                        keyboardType: TextInputType.phone,
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _email,
                        decoration: InputDecoration(
                          labelText: AuthStrings.loginFieldEmail,
                        ),
                        keyboardType: TextInputType.emailAddress,
                        autocorrect: false,
                        readOnly: _signedUpViaOAuth,
                      ),
                      if (!_signedUpViaOAuth) ...[
                        const SizedBox(height: 12),
                        TextField(
                          controller: _password,
                          decoration: InputDecoration(
                            labelText: AuthStrings.loginFieldPassword,
                          ),
                          obscureText: true,
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _confirm,
                          decoration: InputDecoration(
                            labelText:
                                AuthStrings.registerFieldConfirmPassword,
                          ),
                          obscureText: true,
                        ),
                      ],
                      if (!_signedUpViaOAuth) ...[
                        const SizedBox(height: 20),
                        Row(
                          children: [
                            const Expanded(child: Divider()),
                            Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 12),
                              child: Text(
                                AuthStrings.registerOrDivider,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ),
                            const Expanded(child: Divider()),
                          ],
                        ),
                        const SizedBox(height: 16),
                        OutlinedButton.icon(
                          onPressed: formEnabled ? _googleSignIn : null,
                          icon: const Icon(Icons.g_mobiledata, size: 28),
                          label: const Text(AuthStrings.registerActionGoogle),
                        ),
                      ],
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      Text(
                        AuthStrings.roleChoiceDescription,
                        style: theme.textTheme.bodyLarge,
                      ),
                      const SizedBox(height: 20),
                      _RoleCard(
                        selected: _roleChoice == UserRole.client,
                        title: AuthStrings.registerChooseClient,
                        icon: Icons.person_outline,
                        onTap: () =>
                            setState(() => _roleChoice = UserRole.client),
                      ),
                      const SizedBox(height: 12),
                      _RoleCard(
                        selected: _roleChoice == UserRole.prestataire,
                        title: AuthStrings.registerChoosePresta,
                        icon: Icons.storefront_outlined,
                        onTap: () =>
                            setState(() => _roleChoice = UserRole.prestataire),
                      ),
                    ],
                  ),
                  ListView(
                    padding: const EdgeInsets.all(24),
                    children: [
                      if (_phoneRequiredOnExtras) ...[
                        Text(
                          AuthStrings.registerGooglePhoneHint,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                        const SizedBox(height: 16),
                        TextField(
                          controller: _phone,
                          decoration: InputDecoration(
                            labelText: AuthStrings.registerFieldPhone,
                          ),
                          keyboardType: TextInputType.phone,
                          onChanged: (_) => setState(() => _error = null),
                        ),
                        const SizedBox(height: 20),
                      ],
                      if (!_isPresta) ...[
                        TextField(
                          controller: _adresse,
                          decoration: InputDecoration(
                            labelText: AuthStrings.registerFieldAdresse,
                          ),
                          maxLines: 2,
                        ),
                      ] else ...[
                        TextField(
                          controller: _salon,
                          decoration: InputDecoration(
                            labelText: AuthStrings.registerFieldSalon,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _ville,
                          decoration: InputDecoration(
                            labelText: AuthStrings.registerFieldVille,
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: _bio,
                          decoration: InputDecoration(
                            labelText: AuthStrings.registerFieldBioPresta,
                          ),
                          maxLines: 3,
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
            if (_error != null)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  _error!,
                  style: TextStyle(color: theme.colorScheme.error),
                ),
              ),
            Padding(
              padding: const EdgeInsets.all(24),
              child: FilledButton(
                onPressed: _loading
                    ? null
                    : () {
                        if (_step < 2) {
                          _next();
                        } else {
                          _submit();
                        }
                      },
                child: _loading
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(
                        _step < 2
                            ? AuthStrings.registerWizardNext
                            : AuthStrings.registerWizardSubmit,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RoleCard extends StatelessWidget {
  const _RoleCard({
    required this.selected,
    required this.title,
    required this.icon,
    required this.onTap,
  });

  final bool selected;
  final String title;
  final IconData icon;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Material(
      color: selected
          ? theme.colorScheme.primaryContainer
          : theme.colorScheme.surfaceContainerHighest,
      borderRadius: BorderRadius.circular(16),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(icon, color: theme.colorScheme.primary),
              const SizedBox(width: 16),
              Expanded(
                child: Text(
                  title,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              if (selected) Icon(Icons.check_circle, color: theme.colorScheme.primary),
            ],
          ),
        ),
      ),
    );
  }
}
