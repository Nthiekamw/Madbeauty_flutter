import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/models/user_role.dart';
import '../../../services/auth/post_signup_profile_service.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../auth/logic/auth_role_cache.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../auth/providers/my_roles_provider.dart';
import '../../prestataire/navigation/prestataire_navigation.dart';
import '../../prestataire/providers/prestataire_profile_form_provider.dart';

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

  @override
  void dispose() {
    _salon.dispose();
    _ville.dispose();
    _bio.dispose();
    super.dispose();
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
      ref.invalidate(myRolesProvider);
      ref.invalidate(prestataireProfileFormProvider);

      if (!mounted) return;
      setState(() => _loading = false);
      await PrestataireNavigation.afterBecomePrestataire(context, ref);
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
    return Scaffold(
      appBar: AppBar(
        title: const Text(AuthStrings.profileBecomePresta),
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: _loading ? null : () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(24),
          children: [
            Text(
              AuthStrings.becomePrestaStep1Title,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              AuthStrings.becomePrestaStep1Body,
              style: theme.textTheme.bodyLarge,
            ),
            const SizedBox(height: 24),
            TextField(
              controller: _salon,
              decoration: const InputDecoration(
                labelText: AuthStrings.registerFieldSalon,
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _ville,
              decoration: const InputDecoration(
                labelText: AuthStrings.registerFieldVille,
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: _bio,
              decoration: const InputDecoration(
                labelText: AuthStrings.registerFieldBioPresta,
              ),
              maxLines: 3,
            ),
            if (_error != null) ...[
              const SizedBox(height: 16),
              Text(
                _error!,
                style: TextStyle(color: theme.colorScheme.error),
              ),
            ],
            const SizedBox(height: 32),
            FilledButton(
              onPressed: _loading ? null : _submit,
              child: _loading
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(AuthStrings.becomePrestaStep1Submit),
            ),
          ],
        ),
      ),
    );
  }
}
