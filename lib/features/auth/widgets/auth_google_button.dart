import 'package:flutter/material.dart';

import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/auth_form_styles.dart';
import '../../../shared/widgets/google_logo.dart';

/// Bouton OAuth Google cohérent avec la charte MadBeauty.
class AuthGoogleButton extends StatelessWidget {
  const AuthGoogleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return OutlinedButton(
      onPressed: enabled ? onPressed : null,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: AuthFormStyles.buttonBorderRadius,
        ),
        side: BorderSide(
          color: theme.colorScheme.outline.withValues(alpha: 0.45),
          width: 1.2,
        ),
        backgroundColor: theme.colorScheme.surface.withValues(
          alpha: theme.brightness == Brightness.dark ? 0.5 : 0.85,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Opacity(
            opacity: enabled ? 1 : 0.45,
            child: const GoogleLogo(size: 22),
          ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: theme.colorScheme.onSurface.withValues(
                alpha: enabled ? 1 : 0.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
