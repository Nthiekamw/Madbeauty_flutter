import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../features/auth/providers/auth_notifier.dart';
import '../../router/navigation_extensions.dart';
import '../../services/supabase/messaging/messaging_providers.dart';
import '../../services/supabase/profile/client_profile_providers.dart';
import '../../shared/widgets/app_snack_bar.dart';

/// Ouvre le fil de discussion lié à une réservation (crée la conversation si besoin).
Future<void> openChatForReservation(
  BuildContext context,
  WidgetRef ref,
  String reservationId,
) async {
  final messageService = ref.read(messageServiceProvider);
  if (messageService == null) {
    if (context.mounted) {
      AppSnackBar.show(context, message: DiscChat.loadError);
    }
    return;
  }

  try {
    await messageService.ensureThreadForBooking(reservationId);
    if (!context.mounted) return;
    context.pushChat(reservationId);
  } catch (_) {
    if (context.mounted) {
      AppSnackBar.show(context, message: DiscChat.loadError);
    }
  }
}

/// Depuis la fiche prestataire : ouvre le chat du dernier RDV avec ce pro (crée le fil si besoin).
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
      message:
          user == null ? DiscChat.loginRequired : DiscChat.loadError,
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

    final bookingId =
        await messagingService.findLatestBookingIdForClientPrestaPair(
      clientProfileId: client.id,
      prestataireId: prestataireId,
    );

    if (bookingId == null) {
      if (!context.mounted) return;
      AppSnackBar.show(context, message: DiscChat.contactRequiresBooking);
      context.pushBooking(prestataireId: prestataireId);
      return;
    }

    await messageService.ensureThreadForBooking(bookingId);
    if (!context.mounted) return;
    await context.pushChat(bookingId);
  } catch (_) {
    if (context.mounted) {
      AppSnackBar.show(context, message: DiscChat.loadError);
    }
  }
}
