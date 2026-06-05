import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/models/user_role.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/auth/post_signup_profile_service.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/widgets/app/app_button.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery/discovery_form_scroll_view.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../auth/logic/auth_role_cache.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../auth/providers/my_roles_provider.dart';
import '../../prestataire/navigation/prestataire_navigation.dart';
import '../../prestataire/providers/prestataire_profile_form_provider.dart';
import '../logic/become_prestataire_draft.dart';
import '../storage/become_prestataire_draft_store.dart';
import '../widgets/become_prestataire_form_card.dart';

/// Ajoute le rôle prestataire et les infos de base puis ouvre l’espace pro.
class BecomePrestataireScreen extends ConsumerStatefulWidget {
  const BecomePrestataireScreen({super.key});

  @override
  ConsumerState<BecomePrestataireScreen> createState() =>
      _BecomePrestataireScreenState();
}

class _BecomePrestataireScreenState
    extends ConsumerState<BecomePrestataireScreen> {
  final _salon = TextEditingController();
  final _ville = TextEditingController();
  final _bio = TextEditingController();

  String? _error;
  bool _loading = false;
  bool _step1Submitted = false;
  bool _draftLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadDraft();
    _salon.addListener(_persistDraft);
    _ville.addListener(_persistDraft);
    _bio.addListener(_persistDraft);
  }

  @override
  void dispose() {
    _salon.removeListener(_persistDraft);
    _ville.removeListener(_persistDraft);
    _bio.removeListener(_persistDraft);
    _salon.dispose();
    _ville.dispose();
    _bio.dispose();
    super.dispose();
  }

  void _loadDraft() {
    final draft = BecomePrestataireDraftStore.instance.read();
    if (draft == null) return;
    _salon.text = draft.salon;
    _ville.text = draft.ville;
    _bio.text = draft.bio;
    _step1Submitted = draft.step1Submitted;
    _draftLoaded = true;
  }

  Future<void> _persistDraft() async {
    await BecomePrestataireDraftStore.instance.save(
      BecomePrestataireDraft(
        salon: _salon.text,
        ville: _ville.text,
        bio: _bio.text,
        step1Submitted: _step1Submitted,
      ),
    );
  }

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.goClientProfile();
  }

  Future<void> _continueToStep2() async {
    await LocalCacheService.instance.setSelectedRole('prestataire');
    await LocalCacheService.instance.setSignupShellRole('prestataire');
    if (!mounted) return;
    await PrestataireNavigation.afterBecomePrestataire(context, ref);
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    setState(() => _error = null);

    if (!AppConfig.hasSupabase) {
      setState(() => _error = ShellStrings.supabaseMissingTitle);
      return;
    }

    if (_salon.text.trim().isEmpty || _ville.text.trim().isEmpty) {
      setState(
        () => _error =
            'Renseigne au moins le nom du salon ou de l’activité et la ville.',
      );
      return;
    }

    if (_step1Submitted) {
      await _continueToStep2();
      return;
    }

    setState(() => _loading = true);

    try {
      final authSnapshot = ref.read(authNotifierProvider);
      final user = switch (authSnapshot) {
        AsyncData(:final value) => value,
        _ => null,
      };
      if (user == null) {
        setState(() {
          _loading = false;
          _error = CoreStrings.errorUnexpected;
        });
        return;
      }

      final roles = ref.read(roleServiceProvider);
      final post = PostSignupProfileService.fromEnv();

      await roles.ensureRole(UserRole.prestataire);
      ref.invalidate(myRolesProvider);
      final serverRoles = await ref.read(myRolesProvider.future);
      await AuthRoleCache.persistServerRoles(serverRoles);
      await post.updatePrestataireExtras(
        userId: user.id,
        nomSalon: _salon.text.trim(),
        ville: _ville.text.trim(),
        bio: _bio.text.trim(),
      );

      await LocalCacheService.instance.setSelectedRole('prestataire');
      await LocalCacheService.instance.setSignupShellRole('prestataire');
      ref.invalidate(myRolesProvider);
      ref.invalidate(prestataireProfileFormProvider);

      _step1Submitted = true;
      await _persistDraft();

      if (!mounted) return;
      setState(() => _loading = false);
      await _continueToStep2();
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
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final isDark = theme.brightness == Brightness.dark;

    if (!_draftLoaded) {
      final draft = BecomePrestataireDraftStore.instance.read();
      if (draft != null) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (!mounted || _draftLoaded) return;
          setState(() {
            _salon.text = draft.salon;
            _ville.text = draft.ville;
            _bio.text = draft.bio;
            _step1Submitted = draft.step1Submitted;
            _draftLoaded = true;
          });
        });
      } else {
        _draftLoaded = true;
      }
    }

    return PopScope(
      canPop: !_loading && context.canPop(),
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop && !_loading) _goBack();
      },
      child: DiscoveryBrandScaffold(
        body: DiscoveryFormScrollView(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: _loading ? null : _goBack,
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: primary.withValues(alpha: 0.2)),
              ),
              child: Text(
                DiscProfile.becomePrestaScreenStep,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w800,
                  color: primary,
                ),
              ),
            ),
            if (_step1Submitted) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.primaryContainer.withValues(
                    alpha: isDark ? 0.35 : 0.55,
                  ),
                  borderRadius: DiscoveryStyles.chipBorderRadius,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.check_circle_rounded,
                        size: 20,
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          DiscProfile.becomePrestaStep1SavedBanner,
                          style: theme.textTheme.bodySmall?.copyWith(
                            height: 1.35,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            const SizedBox(height: 16),
            Center(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [
                      primary.withValues(alpha: isDark ? 0.45 : 0.7),
                      theme.colorScheme.secondary.withValues(alpha: 0.35),
                    ],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.2),
                      blurRadius: 20,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(22),
                  child: Icon(
                    Icons.storefront_rounded,
                    size: 40,
                    color: theme.colorScheme.onPrimary,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 18),
            Text(
              DiscProfile.becomePrestaScreenTitle,
              textAlign: TextAlign.center,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DiscProfile.becomePrestaScreenBody,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 24),
            LayoutBuilder(
              builder: (context, constraints) {
                final horizontal = constraints.maxWidth >= 920;
                final form = BecomePrestataireFormCard(
                  salonController: _salon,
                  villeController: _ville,
                  bioController: _bio,
                  errorText: _error,
                );
                if (!horizontal) return form;
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(flex: 3, child: form),
                    const SizedBox(width: 12),
                    Expanded(
                      flex: 2,
                      child: DiscoverySurfaceCard(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              DiscProfile.becomePrestaScreenStep,
                              style: theme.textTheme.titleSmall?.copyWith(
                                fontFamily: AppFonts.display,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              DiscProfile.becomePrestaScreenBody,
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.4,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                );
              },
            ),
            const SizedBox(height: 24),
            AppButton(
              onPressed: _loading ? null : _submit,
              isLoading: _loading,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    _step1Submitted
                        ? DiscProfile.becomePrestaContinueStep2
                        : DiscProfile.becomePrestaScreenSubmit,
                  ),
                  if (!_loading) ...[
                    const SizedBox(width: 6),
                    Icon(
                      Icons.arrow_forward_rounded,
                      size: 18,
                      color: theme.colorScheme.onPrimary,
                    ),
                  ],
                ],
              ),
            ),
            const SizedBox(height: 12),
            ClipRRect(
              borderRadius: DiscoveryStyles.chipBorderRadius,
              child: LinearProgressIndicator(
                value: _step1Submitted ? 0.33 : 0.33,
                minHeight: 4,
                backgroundColor: primary.withValues(alpha: 0.1),
                color: primary,
              ),
          ),
        ],
        ),
      ),
    );
  }
}

