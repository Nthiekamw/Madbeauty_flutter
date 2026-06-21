import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../features/booking/providers/booking_session_providers.dart';
import '../../features/messaging/models/chat_inbox_key.dart';
import '../../features/messaging/providers/message_provider.dart';
import '../../features/messaging/providers/messaging_inbox_providers.dart';
import '../../features/messaging/providers/messaging_refresh_signal_provider.dart';
import '../../features/prestataire/providers/agenda/prestataire_agenda_provider.dart';
import '../../features/prestataire/providers/analytics/prestataire_analytics_provider.dart';
import '../../features/prestataire/providers/analytics/stats_provider.dart';
import '../../features/prestataire/providers/dashboard/prestataire_dashboard_provider.dart';
import '../../features/prestataire/providers/profile/current_prestataire_provider.dart';
import '../../services/supabase/support/user_support_providers.dart';
import '../../services/notifications/in_app_notifications_provider.dart';

/// Rafraîchit badges messages, inbox et fil chat après un événement live.
void refreshMessagingLiveState(
  WidgetRef ref, {
  String? conversationId,
  String? bookingId,
}) {
  bumpMessagingRefreshFromWidgetRef(ref);
  if (conversationId != null && conversationId.isNotEmpty) {
    ref.invalidate(messagesProvider(conversationId));
  }
  if (bookingId != null && bookingId.isNotEmpty) {
    ref.invalidate(
      chatConversationIdProvider(ChatRouteKey(bookingId: bookingId)),
    );
  }
  ref.invalidate(conversationsInboxProvider(MessagingInboxRole.client));
  ref.invalidate(conversationsInboxProvider(MessagingInboxRole.prestataire));
  ref.invalidate(messagingUnreadCountProvider(MessagingInboxRole.client));
  ref.invalidate(messagingUnreadCountProvider(MessagingInboxRole.prestataire));
  refreshInAppNotificationsSync(ref);
}

/// Rafraîchit badges réservations et listes après un événement live.
void refreshReservationsLiveState(WidgetRef ref) {
  ref.read(reservationsRefreshSignalProvider.notifier).increment();
  ref.invalidate(clientReservationsProvider);
  ref.invalidate(clientPendingReservationsCountProvider);
  ref.invalidate(bookingsClientProvider);
  ref.invalidate(bookingsPrestataireProvider);
  ref.invalidate(prestataireAgendaProvider);
  ref.invalidate(prestataireDashboardProvider);
  ref.invalidate(prestataireAnalyticsProvider);
  ref.invalidate(bookingsPrestataireProvider);
  final presta = switch (ref.read(currentPrestataireProvider)) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (presta != null) {
    ref.invalidate(statsProvider(presta.id));
  }
  refreshInAppNotificationsSync(ref);
}

void refreshInAppNotificationsSync(WidgetRef ref) {
  ref.invalidate(inAppNotificationsSyncProvider);
  unawaited(ref.read(inAppNotificationsSyncProvider.future));
}

void refreshUserSupportLiveState(WidgetRef ref) {
  ref.invalidate(myUserSupportThreadIdProvider);
  refreshInAppNotificationsSync(ref);
}
