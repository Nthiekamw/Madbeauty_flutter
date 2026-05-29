import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/constants/app_strings.dart';
import '../../core/providers/offline_providers.dart';
import '../../shared/widgets/app/app_snack_bar.dart';

/// Bloque une action nécessitant le réseau et affiche un message.
Future<bool> ensureOnline(BuildContext context, WidgetRef ref) async {
  if (ref.read(isOnlineProvider)) return true;
  if (!context.mounted) return false;
  AppSnackBar.warning(context, ShellStrings.offlineActionBlocked);
  return false;
}
