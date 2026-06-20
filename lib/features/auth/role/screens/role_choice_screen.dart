import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/errors/app_failure.dart';
import '../../../../core/models/user_role.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../services/storage/local_cache_service.dart';
import '../../../prestataire/navigation/prestataire_navigation.dart';
import '../../logic/auth_role_cache.dart';
import '../../providers/auth_notifier.dart';
import '../../providers/my_roles_provider.dart';
import '../../widgets/auth_error_banner.dart';
import '../../widgets/auth_form_card.dart';
import '../../widgets/auth_form_scaffold.dart';
import '../../widgets/auth_role_card.dart';

class RoleChoiceScreen extends ConsumerStatefulWidget {
  const RoleChoiceScreen({super.key});

  @override
  ConsumerState<RoleChoiceScreen> createState() => _RoleChoiceScreenState();
}

class _RoleChoiceScreenState extends ConsumerState<RoleChoiceScreen> {
  UserRole? _pendingRole;
  String? _error;
  bool _redirectingAdmin = false;

  bool get _isBusy => _pendingRole != null || _redirectingAdmin;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_redirectAdminIfNeeded());
    });
  }

  Future<void> _redirectAdminIfNeeded() async {
    if (!mounted || _redirectingAdmin) return;
    if (AuthRoleCache.hasAdminAmong(
      LocalCacheService.instance.cachedServerRoles,
    )) {
      _redirectingAdmin = true;
      context.goAdminHome();
      return;
    }
    if (!ref.read(authSupabaseEnabledProvider)) return;
    _redirectingAdmin = true;
    try {
      final roles = await ref.read(myRolesProvider.future);
      await AuthRoleCache.persistServerRoles(roles);
      if (!mounted) return;
      if (roles.contains(UserRole.admin)) {
        await LocalCacheService.instance.setSelectedRole('admin');
        context.goAdminHome();
      }
    } finally {
      if (mounted) setState(() => _redirectingAdmin = false);
    }
  }

  Future<void> _selectRole(UserRole role) async {
    if (_isBusy) return;
    setState(() {
      _pendingRole = role;
      _error = null;
    });

    try {
      if (ref.read(authSupabaseEnabledProvider)) {
        final rolesService = ref.read(roleServiceProvider);
        if (role == UserRole.prestataire) {
          await rolesService.removeRole(UserRole.client);
        }
        await rolesService.ensureRole(role);
      }
      ref.invalidate(myRolesProvider);
      final roles = await ref.read(myRolesProvider.future);
      await AuthRoleCache.persistServerRoles(roles);
      await LocalCacheService.instance.setSelectedRole(role.value);
      await LocalCacheService.instance.setSignupShellRole(role.value);
      if (!mounted) return;

      if (role == UserRole.prestataire) {
        await PrestataireNavigation.switchToPrestataireSpace(context, ref);
      } else {
        context.goHome();
      }
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _pendingRole = null;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _pendingRole = null;
        _error = CoreStrings.errorUnexpected;
      });
    }
  }

  void _onBack() {
    if (context.canPop()) {
      context.pop();
    } else {
      context.goWelcome();
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AuthFormScaffold(
      title: AuthStrings.roleChoiceTitle,
      subtitle: AuthStrings.roleChoiceSubtitle,
      onBack: _onBack,
      isBackEnabled: !_isBusy,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (_error != null) AuthErrorBanner(message: _error!),
          AuthFormCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  AuthStrings.roleChoiceDescription,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),
                AuthRoleCard(
                  title: AuthStrings.roleChoiceClient,
                  subtitle: AuthStrings.roleChoiceClientHint,
                  icon: Icons.spa_outlined,
                  selected: _pendingRole == UserRole.client,
                  isLoading: _pendingRole == UserRole.client,
                  enabled: !_isBusy,
                  onTap: () => _selectRole(UserRole.client),
                ),
                const SizedBox(height: 12),
                AuthRoleCard(
                  title: AuthStrings.roleChoicePrestataire,
                  subtitle: AuthStrings.roleChoicePrestataireHint,
                  icon: Icons.storefront_outlined,
                  selected: _pendingRole == UserRole.prestataire,
                  isLoading: _pendingRole == UserRole.prestataire,
                  enabled: !_isBusy,
                  onTap: () => _selectRole(UserRole.prestataire),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

