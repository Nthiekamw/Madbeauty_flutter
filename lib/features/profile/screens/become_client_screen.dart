import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/models/user_role.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/storage/local_cache_service.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_button.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/discovery_form_scroll_view.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../auth/logic/auth_role_cache.dart';
import '../../auth/navigation/client_navigation.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../auth/providers/my_roles_provider.dart';

/// Active le rôle client pour un compte prestataire (opt-in).
class BecomeClientScreen extends ConsumerStatefulWidget {
  const BecomeClientScreen({super.key});

  @override
  ConsumerState<BecomeClientScreen> createState() => _BecomeClientScreenState();
}

class _BecomeClientScreenState extends ConsumerState<BecomeClientScreen> {
  bool _loading = false;
  String? _error;

  void _goBack() {
    if (context.canPop()) {
      context.pop();
      return;
    }
    context.goPrestataireProfile();
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_loading) return;

    if (!AppConfig.hasSupabase) {
      setState(() => _error = ShellStrings.supabaseMissingTitle);
      return;
    }

    setState(() {
      _loading = true;
      _error = null;
    });

    try {
      final rolesService = ref.read(roleServiceProvider);
      await rolesService.ensureRole(UserRole.client);
      ref.invalidate(myRolesProvider);
      final serverRoles = await ref.read(myRolesProvider.future);
      await AuthRoleCache.persistServerRoles(serverRoles);
      await LocalCacheService.instance.setSelectedRole('client');

      if (!mounted) return;
      setState(() => _loading = false);
      AppSnackBar.show(
        context,
        message: DiscProfile.becomeClientSuccess,
        kind: AppSnackKind.success,
      );
      await ClientNavigation.switchToClientSpace(context, ref);
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e.message;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = CoreStrings.errorUnexpected;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

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
            Text(
              DiscProfile.becomeClientScreenTitle,
              style: theme.textTheme.headlineSmall?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w900,
                letterSpacing: -0.4,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DiscProfile.becomeClientScreenBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 16),
            DiscoverySurfaceCard(
              padding: const EdgeInsets.all(18),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    DiscProfile.becomeClientCardTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 16),
                  const _BenefitRow(text: DiscProfile.becomeClientBenefit1),
                  const SizedBox(height: 8),
                  const _BenefitRow(text: DiscProfile.becomeClientBenefit2),
                  const SizedBox(height: 8),
                  const _BenefitRow(text: DiscProfile.becomeClientBenefit3),
                ],
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 12),
              Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 20),
            AppButton(
              onPressed: _loading ? null : _submit,
              child: Text(
                _loading
                    ? DiscPrestaForm.saving
                    : DiscProfile.becomeClientScreenSubmit,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _BenefitRow extends StatelessWidget {
  const _BenefitRow({required this.text});

  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(Icons.check_circle_rounded, size: 18, color: primary),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            text,
            style: theme.textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}
