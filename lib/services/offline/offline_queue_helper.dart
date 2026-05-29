import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/providers/offline_providers.dart';
import '../../core/providers/offline_queue_providers.dart';
import '../../services/supabase/booking/booking_service_providers.dart';
import '../../shared/widgets/app/app_snack_bar.dart';
import 'pending_offline_action.dart';

/// Met une action en file si hors ligne ; retourne `true` si mise en file.
Future<bool> enqueueIfOffline({
  required WidgetRef ref,
  required BuildContext context,
  required PendingOfflineAction action,
}) async {
  if (ref.read(isOnlineProvider)) return false;

  await ref.read(offlineActionQueueProvider.notifier).enqueue(action);
  invalidateClientReservations(ref);

  if (!context.mounted) return true;
  AppSnackBar.info(context, ShellStrings.offlineActionQueued);
  return true;
}
