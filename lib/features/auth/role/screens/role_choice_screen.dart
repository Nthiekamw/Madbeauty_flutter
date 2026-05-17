import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/models/user_role.dart';
import '../../logic/auth_role_cache.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/my_roles_provider.dart';
import '../../../../services/storage/local_cache_service.dart';
import '../../../prestataire/navigation/prestataire_navigation.dart';
import '../../../../router/navigation_extensions.dart';

class RoleChoiceScreen extends ConsumerWidget {
  const RoleChoiceScreen({super.key});

  Future<void> _selectRole(
    BuildContext context,
    WidgetRef ref,
    UserRole role,
  ) async {
    try {
      if (ref.read(authSupabaseEnabledProvider)) {
        await ref.read(roleServiceProvider).ensureRole(role);
      }
      ref.invalidate(myRolesProvider);
      final roles = await ref.read(myRolesProvider.future);
      await AuthRoleCache.persistServerRoles(roles);
      await LocalCacheService.instance.setSelectedRole(role.value);
      if (!context.mounted) return;

      if (role == UserRole.prestataire) {
        await PrestataireNavigation.switchToPrestataireSpace(context, ref);
      } else {
        context.goHome();
      }
    } on AppFailure catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(e.message)),
      );
    } catch (_) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text(CoreStrings.errorUnexpected)),
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(AuthStrings.roleChoiceTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AuthStrings.roleChoiceDescription,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _selectRole(context, ref, UserRole.client),
                icon: const Icon(Icons.person_outline),
                label: const Text(AuthStrings.roleChoiceClient),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () =>
                    _selectRole(context, ref, UserRole.prestataire),
                icon: const Icon(Icons.storefront_outlined),
                label: const Text(AuthStrings.roleChoicePrestataire),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
