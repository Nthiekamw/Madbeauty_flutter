import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../features/auth/providers/auth_notifier.dart';
import '../../router/navigation_extensions.dart';
import '../../services/notifications/live_refresh.dart';
import '../../services/supabase/messaging/messaging_providers.dart';
import '../../services/supabase/profile/client_profile_providers.dart';
import '../../shared/widgets/app/app_snack_bar.dart';
import 'models/client_presta_chat_access.dart';
import 'models/messaging_inbox_role.dart';

/// Ouvre le fil de discussion lié à une réservation (crée la conversation si besoin).
Future<void> openChatForReservation(
  BuildContext context,
  WidgetRef ref,
  String reservationId, {
  required MessagingInboxRole viewerRole,
}) async {
  final messageService = ref.read(messageServiceProvider);
  final messagingService = ref.read(messagingServiceProvider);
  if (messageService == null || messagingService == null) {
    if (context.mounted) {
      AppSnackBar.show(context, message: DiscChat.loadError);
    }
    return;
  }

  try {
    final allowed = await messagingService.isChatOpenForBooking(reservationId);
    if (!allowed) {
      if (context.mounted) {
        AppSnackBar.show(context, message: DiscChat.contactNotConfirmed);
      }
      return;
    }

    final conv = await messageService.ensureThreadForBooking(reservationId);
    refreshMessagingInbox(ref, role: viewerRole);

    if (!context.mounted) return;

    await context.pushChat(
      conv.id,
      as: viewerRole == MessagingInboxRole.client ? 'client' : 'prestataire',
    );

    if (!context.mounted) return;
    refreshMessagingInbox(ref, role: viewerRole);
  } catch (_) {
    if (context.mounted) {
      AppSnackBar.show(context, message: DiscChat.loadError);
    }
  }
}

/// Depuis la fiche prestataire : ouvre le chat si la réservation est confirmée.
Future<void> openChatWithPrestataire(
  BuildContext context,
  WidgetRef ref,
  String prestataireId,
) async {
  final messageService = ref.read(messageServiceProvider);
  final messagingService = ref.read(messagingServiceProvider);

  final user = switch (ref.read(authNotifierProvider)) {
    AsyncData(:final value) => value,
    _ => null,
  };

  if (messageService == null ||
      messagingService == null ||
      user == null) {
    if (!context.mounted) return;
    AppSnackBar.show(
      context,
      message: user == null ? DiscChat.loginRequired : DiscChat.loadError,
    );
    return;
  }

  try {
    final client = await ref.read(currentClientProfileProvider.future);
    if (client == null) {
      if (context.mounted) {
        AppSnackBar.show(context, message: DiscChat.loginRequired);
      }
      return;
    }

    final access = await messagingService.resolveClientChatAccess(
      clientProfileId: client.id,
      prestataireId: prestataireId,
    );

    if (!context.mounted) return;

    switch (access.kind) {
      case ClientPrestaChatAccessKind.noBooking:
        AppSnackBar.show(context, message: DiscChat.contactRequiresBooking);
        context.pushBooking(prestataireId: prestataireId);
      case ClientPrestaChatAccessKind.awaitingPrestaResponse:
        AppSnackBar.show(context, message: DiscChat.contactAwaitingPresta);
        context.goMyReservations();
      case ClientPrestaChatAccessKind.ready:
        final bookingId = access.bookingId;
        if (bookingId == null) {
          AppSnackBar.show(context, message: DiscChat.loadError);
          return;
        }
        final conv = await messageService.ensureThreadForBooking(bookingId);
        refreshMessagingInbox(ref, role: MessagingInboxRole.client);
        if (!context.mounted) return;
        await context.pushChat(conv.id, as: 'client');
        if (!context.mounted) return;
        refreshMessagingInbox(ref, role: MessagingInboxRole.client);
    }
  } catch (_) {
    if (context.mounted) {
      AppSnackBar.show(context, message: DiscChat.loadError);
    }
  }
}
