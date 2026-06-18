import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../core/constants/app_strings.dart';
import '../core/models/user_role.dart';
import '../features/auth/providers/auth_notifier.dart';
import '../features/auth/providers/auth_redirect_providers.dart';
import '../features/auth/register/logic/register_wizard_submit_handler.dart';
import '../features/auth/register/storage/register_wizard_draft_store.dart';
import '../features/auth/providers/password_recovery_provider.dart';
import '../features/profile/storage/become_prestataire_draft_store.dart';
import '../services/auth/auth_deep_link_handler.dart';
import '../services/storage/local_cache_service.dart';
import '../features/prestataire/logic/prestataire_subscription_refresh.dart';
import '../shared/widgets/app/app_snack_bar.dart';
import 'app_deep_links.dart';
import 'app_router.dart';

/// Ouvre les liens partagés (`/prestataire/:id`) dans [GoRouter].
class DeepLinkListener extends ConsumerStatefulWidget {
  const DeepLinkListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<DeepLinkListener> createState() => _DeepLinkListenerState();
}

class _DeepLinkListenerState extends ConsumerState<DeepLinkListener> {
  StreamSubscription<Uri>? _subscription;
  final _appLinks = AppLinks();
  String? _lastAuthLinkKey;
  DateTime? _lastAuthLinkAt;

  bool _shouldSkipDuplicateAuthLink(Uri uri) {
    final params = AuthDeepLinkHandler.normalizedQueryParameters(uri);
    final key = params['code'] ??
        params['token_hash'] ??
        params['access_token'] ??
        uri.toString();
    final now = DateTime.now();
    if (_lastAuthLinkKey == key &&
        _lastAuthLinkAt != null &&
        now.difference(_lastAuthLinkAt!) < const Duration(seconds: 8)) {
      return true;
    }
    _lastAuthLinkKey = key;
    _lastAuthLinkAt = now;
    return false;
  }

  @override
  void initState() {
    super.initState();
    if (kIsWeb) return;
    _listenIncomingLinks();
    _handleInitialLink();
  }

  Future<void> _handleInitialLink() async {
    try {
      final uri = await _appLinks.getInitialLink();
      if (uri == null) return;
      if (AuthDeepLinkHandler.isAuthCallbackUri(uri)) {
        await _handleAuthCallback(uri);
        return;
      }
      _navigateFromUri(uri);
    } catch (e, st) {
      debugPrint('DeepLinkListener initial: $e\n$st');
    }
  }

  void _listenIncomingLinks() {
    _subscription = _appLinks.uriLinkStream.listen(
      _navigateFromUri,
      onError: (Object e, StackTrace st) {
        debugPrint('DeepLinkListener stream: $e\n$st');
      },
    );
  }

  void _navigateFromUri(Uri uri) {
    if (AppDeepLinks.isAuthCallbackUri(uri)) {
      unawaited(_handleAuthCallback(uri));
      return;
    }

    final subscriptionPath = AppDeepLinks.subscriptionReturnPath(uri);
    if (subscriptionPath != null) {
      _goSubscriptionReturn(subscriptionPath, uri);
      return;
    }

    final clientPaymentPath = AppDeepLinks.clientPaymentReturnPath(uri);
    if (clientPaymentPath != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        ref.read(goRouterProvider).go(clientPaymentPath);
      });
      return;
    }

    final path = AppDeepLinks.routePathFromUri(uri);
    if (path == null) return;

    final code = uri.queryParameters['code'] ??
        (uri.host == 'invite' && uri.pathSegments.isNotEmpty
            ? uri.pathSegments.first
            : null);
    if (code != null && code.trim().isNotEmpty) {
      unawaited(
        LocalCacheService.instance.setPendingReferralCode(code.trim()),
      );
    }

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final router = ref.read(goRouterProvider);
      final base = path.split('?').first;
      if (router.state.matchedLocation == base) return;
      router.go(path);
    });
  }

  Future<void> _handleAuthCallback(Uri uri) async {
    if (_shouldSkipDuplicateAuthLink(uri)) return;

    final result = await AuthDeepLinkHandler.handle(uri);
    if (!mounted) return;

    if (!result.handled) {
      final params = AuthDeepLinkHandler.normalizedQueryParameters(uri);
      final authError = params['error_description'] ?? params['error'];
      if (result.linkExpired) {
        AppSnackBar.show(
          context,
          message: AuthStrings.authEmailLinkExpired,
          kind: AppSnackKind.info,
          duration: const Duration(seconds: 6),
        );
      } else if (authError != null && authError.trim().isNotEmpty) {
        AppSnackBar.show(
          context,
          message: authError.trim(),
          kind: AppSnackKind.error,
        );
      }
      return;
    }

    if (!result.passwordRecovery) {
      final draft = RegisterWizardDraftStore.instance.read();
      if (draft != null && draft.isActive) {
        final user = ref.read(authServiceProvider).currentSession?.user;
        if (user != null) {
          final isPrestaSignup = draft.role == UserRole.prestataire;
          final finalized = await RegisterWizardSubmitHandler()
              .finalizePendingRegistrationFromDraft(
            context: context,
            mounted: () => mounted,
            ref: ref,
            session: user,
          );
          if (finalized) {
            if (isPrestaSignup || BecomePrestataireDraftStore.instance.hasDraft) {
              ref
                  .read(splashRedirectTargetProvider.notifier)
                  .setTarget(AppRoutes.prestataireProfileEdit);
            }
            return;
          }
        }
      }
    }

    if (!result.passwordRecovery) return;

    ref.read(passwordRecoveryPendingProvider.notifier).activate();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final router = ref.read(goRouterProvider);
      if (router.state.matchedLocation != AppRoutes.resetPassword) {
        router.go(AppRoutes.resetPassword);
      }
    });
  }

  void _goSubscriptionReturn(String path, Uri uri) {
    final result = uri.queryParameters['result'];
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!mounted) return;
      final router = ref.read(goRouterProvider);
      router.go(path);
      if (result == 'success') {
        await refreshPrestataireSubscription(ref);
      }
      if (!mounted) return;
      final message = result == 'success'
          ? DiscPrestaSub.returnSuccess
          : (result == 'cancel' ? DiscPrestaSub.returnCancel : null);
      if (message != null) {
        AppSnackBar.show(
          context,
          message: message,
          kind: result == 'success'
              ? AppSnackKind.success
              : AppSnackKind.info,
          duration: Duration(seconds: result == 'success' ? 6 : 3),
        );
      }
    });
  }

  @override
  void dispose() {
    unawaited(_subscription?.cancel());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.child;
}
