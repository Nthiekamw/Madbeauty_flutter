import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';

class ProfileFooterActions extends StatelessWidget {
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
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final error = theme.colorScheme.error;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        OutlinedButton.icon(
          onPressed: onSupportUser,
          icon: const Icon(Icons.support_agent_rounded, size: 20),
          label: const Text(DiscProfile.supportUser),
          style: OutlinedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 14),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          DiscProfile.supportUserHint,
          textAlign: TextAlign.center,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontFamily: AppFonts.body,
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
