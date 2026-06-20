import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/user_role.dart';
import '../../../features/prestataire/providers/subscription/prestataire_subscription_gate_provider.dart';
import '../../../services/notifications/in_app_notification.dart';
import '../../../services/notifications/in_app_notification_audience.dart';
import '../../../services/notifications/in_app_notifications_provider.dart';
import '../../../services/notifications/prestataire_catalog_visibility_reminders.dart';
import '../../../services/notifications/prestataire_visibility_notify_service.dart';
import '../../../services/stripe/stripe_subscription_providers.dart';
import '../../auth/providers/my_roles_provider.dart';
import '../../prestataire/providers/profile/prestataire_profile_form_provider.dart';

const _pushNudgePrefsKey = 'prestataire_visibility_push_nudge_at.v1';
const _pushNudgeCooldown = Duration(hours: 24);

/// Rappels + push si le prestataire n’est pas visible dans le catalogue.
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

      final needsSub = ref.read(prestataireNeedsSubscriptionForCatalogProvider);
      if (!needsSub) {
        await PrestataireCatalogVisibilityReminders.instance.cancelAll();
        return;
      }

      await PrestataireCatalogVisibilityReminders.instance.scheduleNudges(
        title: DiscPrestaSub.notVisibleReminderTitle,
        body: DiscPrestaSub.notVisibleReminderBody,
      );

      _enqueueInAppOnce();

      if (await _canSendPushNudge()) {
        final sent = await PrestataireVisibilityNotifyService.fromEnv()
            .requestPushNudge();
        if (sent) await _markPushNudgeSent();
      }
    } catch (_) {
      // Non bloquant.
    } finally {
      _syncing = false;
    }
  }

  void _enqueueInAppOnce() {
    final existing = ref.read(inAppNotificationsProvider);
    const markerId = 'prestataire_catalog_visibility_nudge';
    if (existing.any((n) => n.id == markerId)) return;

    ref.read(inAppNotificationsProvider.notifier).enqueue(
          InAppNotification(
            id: markerId,
            title: DiscPrestaSub.notVisibleReminderTitle,
            body: DiscPrestaSub.notVisibleReminderBody,
            createdAt: DateTime.now(),
            read: false,
            actionType: 'prestataire_catalog_visibility',
            audience: InAppNotificationAudience.prestataire.wire,
          ),
        );
  }

  Future<bool> _canSendPushNudge() async {
    final prefs = await SharedPreferences.getInstance();
    final raw = prefs.getString(_pushNudgePrefsKey);
    if (raw == null || raw.isEmpty) return true;
    final last = DateTime.tryParse(raw);
    if (last == null) return true;
    return DateTime.now().difference(last) >= _pushNudgeCooldown;
  }

  Future<void> _markPushNudgeSent() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(
      _pushNudgePrefsKey,
      DateTime.now().toUtc().toIso8601String(),
    );
  }
}
