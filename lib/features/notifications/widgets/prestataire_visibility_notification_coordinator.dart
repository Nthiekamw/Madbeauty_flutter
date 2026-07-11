import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/models/user_role.dart';
import '../../auth/providers/my_roles_provider.dart';
import '../../prestataire/logic/prestataire_visibility_nudge.dart';
import '../../prestataire/providers/profile/current_prestataire_provider.dart';
import '../../prestataire/providers/profile/prestataire_profile_form_provider.dart';
import '../../../services/notifications/in_app_notification.dart';
import '../../../services/notifications/in_app_notification_audience.dart';
import '../../../services/notifications/in_app_notifications_provider.dart';
import '../../../services/notifications/prestataire_catalog_visibility_reminders.dart';
import '../../../services/notifications/prestataire_visibility_notify_service.dart';
import '../../../services/supabase/prestataire/subscription/prestataire_subscription_providers.dart';

const _pushNudgePrefsPrefix = 'prestataire_visibility_push_nudge_at.v1';
const _pushNudgeCooldown = Duration(hours: 24);

/// Rappels push + in-app si le prestataire n’est pas visible (profil, carte, abo).
class PrestataireVisibilityNotificationCoordinator extends ConsumerStatefulWidget {
  const PrestataireVisibilityNotificationCoordinator({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  ConsumerState<PrestataireVisibilityNotificationCoordinator> createState() =>
      _PrestataireVisibilityNotificationCoordinatorState();
}

class _PrestataireVisibilityNotificationCoordinatorState
    extends ConsumerState<PrestataireVisibilityNotificationCoordinator> {
  bool _syncing = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _scheduleSync());
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(myRolesProvider, (_, __) => _scheduleSync());
    ref.listen(prestataireProfileFormProvider, (_, __) => _scheduleSync());
    ref.listen(prestataireSubscriptionStatusProvider, (_, __) => _scheduleSync());
    ref.listen(currentPrestataireProvider, (_, __) => _scheduleSync());
    return widget.child;
  }

  void _scheduleSync() {
    if (_syncing) return;
    unawaited(_sync());
  }

  Future<void> _sync() async {
    if (!AppConfig.hasSupabase || _syncing) return;
    _syncing = true;
    try {
      final roles = await ref.read(myRolesProvider.future);
      if (!roles.contains(UserRole.prestataire)) {
        await PrestataireCatalogVisibilityReminders.instance.cancelAll();
        return;
      }

      final form = ref.read(prestataireProfileFormProvider).value;
      final storedProfile = ref.read(currentPrestataireProvider).value;
      final subscription = ref.read(prestataireSubscriptionStatusProvider).value;
      final nudge = resolvePrestataireVisibilityNudge(
        form: form,
        storedProfile: storedProfile,
        subscription: subscription,
      );

      if (nudge == null) {
        await PrestataireCatalogVisibilityReminders.instance.cancelAll();
        return;
      }

      if (!kIsWeb) {
        await PrestataireCatalogVisibilityReminders.instance.scheduleNudges(
          title: nudge.title,
          body: nudge.body,
        );
      }

      _enqueueInApp(nudge);

      if (await _canSendPushNudge(nudge.kind)) {
        final sent = await PrestataireVisibilityNotifyService.fromEnv()
            .requestPushNudge(reason: nudge.kind.name);
        if (sent) await _markPushNudgeSent(nudge.kind);
      }
    } catch (_) {
      // Non bloquant.
    } finally {
      _syncing = false;
    }
  }

  void _enqueueInApp(PrestataireVisibilityNudge nudge) {
    final existing = ref.read(inAppNotificationsProvider);
    if (existing.any((n) => n.id == nudge.inAppId)) return;

    ref.read(inAppNotificationsProvider.notifier).enqueue(
          InAppNotification(
            id: nudge.inAppId,
            title: nudge.title,
            body: nudge.body,
            createdAt: DateTime.now(),
            read: false,
            actionType: nudge.pushType,
            audience: InAppNotificationAudience.prestataire.wire,
          ),
        );
  }

  Future<bool> _canSendPushNudge(PrestataireVisibilityNudgeKind kind) async {
    final prefs = await SharedPreferences.getInstance();
    final key = '$_pushNudgePrefsPrefix.${kind.name}';
    final raw = prefs.getString(key);
    if (raw == null || raw.isEmpty) return true;
    final last = DateTime.tryParse(raw);
    if (last == null) return true;
    return DateTime.now().difference(last) >= _pushNudgeCooldown;
  }

  Future<void> _markPushNudgeSent(PrestataireVisibilityNudgeKind kind) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      '$_pushNudgePrefsPrefix.${kind.name}',
      DateTime.now().toUtc().toIso8601String(),
    );
  }
}
