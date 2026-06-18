import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../features/auth/providers/auth_notifier.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/support/user_support_providers.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';

/// Ouvre le chat support avec l’admin (crée le fil si besoin).
Future<void> openUserSupportChat(
  BuildContext context,
  WidgetRef ref,
) async {
  final user = switch (ref.read(authNotifierProvider)) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (user == null) {
    if (context.mounted) {
      AppSnackBar.show(context, message: DiscSupport.loginRequired);
    }
    return;
  }

  final service = ref.read(userSupportServiceProvider);
  if (service == null) {
    if (context.mounted) {
      AppSnackBar.error(context, DiscSupport.loadErr);
    }
    return;
  }

  if (!context.mounted) return;
  context.pushUserSupportChat();
}
