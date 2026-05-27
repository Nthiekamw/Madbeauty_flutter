import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../router/navigation_extensions.dart';
import '../../services/supabase/messaging/messaging_providers.dart';
import '../../shared/widgets/app_snack_bar.dart';
import '../../core/constants/app_strings.dart';

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
