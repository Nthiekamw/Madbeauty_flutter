import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';

/// Lien « Mot de passe oublié ? » sous le champ mot de passe (connexion).
class AuthForgotPasswordLink extends StatelessWidget {
  const AuthForgotPasswordLink({
    super.key,
    required this.onPressed,
    this.enabled = true,
  });

  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: enabled ? onPressed : null,
        style: TextButton.styleFrom(
          padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
          minimumSize: Size.zero,
          tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          foregroundColor: primary,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.help_outline_rounded, size: 16, color: primary),
            const SizedBox(width: 6),
            Text(
              AuthStrings.loginActionForgotPassword,
              style: theme.textTheme.labelLarge?.copyWith(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w600,
                color: primary,
                decoration: TextDecoration.underline,
                decorationColor: primary.withValues(alpha: 0.55),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

