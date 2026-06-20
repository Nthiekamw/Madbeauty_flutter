import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../services/supabase/support/user_support_providers.dart';
import '../../../../shared/theme/app_fonts.dart';

class ProfileFooterActions extends ConsumerWidget {
  const ProfileFooterActions({
    super.key,
    required this.onSupportUser,
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  final VoidCallback onSupportUser;
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final error = theme.colorScheme.error;
    final supportUnread = ref.watch(userSupportUnreadCountProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: onSupportUser,
          icon: Badge(
            isLabelVisible: supportUnread > 0,
            label: Text(
              supportUnread > 99 ? '99+' : '$supportUnread',
              style: const TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w700,
              ),
            ),
            child: const Icon(Icons.support_agent_rounded, size: 20),
          ),
          label: const Text(DiscProfile.supportUser),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          supportUnread > 0
              ? DiscProfile.supportUserUnreadHint(supportUnread)
              : DiscProfile.supportUserHint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: supportUnread > 0
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            fontFamily: AppFonts.body,
            fontWeight:
                supportUnread > 0 ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton.icon(
          onPressed: onSignOut,
          icon: const Icon(Icons.logout_rounded, size: 20),
          label: const Text(DiscProfile.signOut),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
            foregroundColor: error,
            side: BorderSide(
              color: error.withValues(alpha: 0.55),
            ),
          ),
        ),
        const SizedBox(height: 10),
        TextButton(
          onPressed: onDeleteAccount,
          style: TextButton.styleFrom(
            foregroundColor: error,
            padding: const EdgeInsets.symmetric(vertical: 12),
          ),
          child: Text(
            DiscProfile.deleteAccount,
            style: theme.textTheme.labelLarge?.copyWith(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w700,
              color: error,
            ),
          ),
        ),
      ],
    );
  }
}
