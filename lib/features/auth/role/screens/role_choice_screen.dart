import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/user_role.dart';
import '../../../../router/app_router.dart';
import '../../providers/auth_notifier.dart';
import '../../../../services/storage/local_cache_service.dart';

class RoleChoiceScreen extends ConsumerWidget {
  const RoleChoiceScreen({super.key});

  Future<void> _selectRole(
    BuildContext context,
    WidgetRef ref,
    UserRole role,
    String targetRouteName,
  ) async {
    if (ref.read(authSupabaseEnabledProvider)) {
      await ref.read(roleServiceProvider).ensureRole(role);
    }
    await LocalCacheService.instance.setSelectedRole(role.value);
    if (context.mounted) {
      context.goNamed(targetRouteName);
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(title: const Text(AppStrings.roleChoiceTitle)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                AppStrings.roleChoiceDescription,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => _selectRole(
                  context,
                  ref,
                  UserRole.client,
                  AppRouteNames.home,
                ),
                icon: const Icon(Icons.person_outline),
                label: const Text(AppStrings.roleChoiceClient),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _selectRole(
                  context,
                  ref,
                  UserRole.prestataire,
                  AppRouteNames.prestataire,
                ),
                icon: const Icon(Icons.storefront_outlined),
                label: const Text(AppStrings.roleChoicePrestataire),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
