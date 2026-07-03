import 'package:flutter/material.dart';

import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/auth_form_styles.dart';

/// Bouton Sign in with Apple (iOS / macOS).
class AuthAppleButton extends StatelessWidget {
  const AuthAppleButton({
    super.key,
    required this.label,
    required this.onPressed,
    this.enabled = true,
    this.isLoading = false,
  });

  final String label;
  final VoidCallback? onPressed;
  final bool enabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final active = enabled && !isLoading;
    final isDark = theme.brightness == Brightness.dark;

    return OutlinedButton(
      onPressed: active ? onPressed : null,
      style: OutlinedButton.styleFrom(
        minimumSize: const Size.fromHeight(52),
        shape: RoundedRectangleBorder(
          borderRadius: AuthFormStyles.buttonBorderRadius,
        ),
        side: BorderSide(
          color: isDark
              ? Colors.white.withValues(alpha: 0.35)
              : Colors.black.withValues(alpha: 0.85),
          width: 1.2,
        ),
        backgroundColor: isDark
            ? Colors.white.withValues(alpha: active ? 0.12 : 0.06)
            : Colors.black.withValues(alpha: active ? 0.92 : 0.45),
        foregroundColor: isDark ? Colors.white : Colors.white,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (isLoading)
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.2,
                color: isDark ? Colors.white : Colors.white,
              ),
            )
          else
            Icon(
              Icons.apple,
              size: 24,
              color: isDark
                  ? Colors.white.withValues(alpha: active ? 1 : 0.45)
                  : Colors.white.withValues(alpha: active ? 1 : 0.7),
            ),
          const SizedBox(width: 12),
          Text(
            label,
            style: TextStyle(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w600,
              fontSize: 15,
              color: isDark
                  ? Colors.white.withValues(alpha: active ? 1 : 0.45)
                  : Colors.white.withValues(alpha: active ? 1 : 0.7),
            ),
          ),
        ],
      ),
    );
  }
}
