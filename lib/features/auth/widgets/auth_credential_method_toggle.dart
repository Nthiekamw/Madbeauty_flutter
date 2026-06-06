import 'package:flutter/material.dart';

import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/auth_form_styles.dart';

/// Bascule e-mail / téléphone pour connexion ou inscription.
class AuthCredentialMethodToggle extends StatelessWidget {
  const AuthCredentialMethodToggle({
    super.key,
    required this.emailLabel,
    required this.phoneLabel,
    required this.isPhoneSelected,
    required this.onChanged,
    this.enabled = true,
    this.compact = false,
  });

  final String emailLabel;
  final String phoneLabel;
  final bool isPhoneSelected;
  final ValueChanged<bool> onChanged;
  final bool enabled;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      children: [
        Expanded(
          child: _MethodOption(
            theme: theme,
            icon: Icons.mail_outline_rounded,
            label: emailLabel,
            selected: !isPhoneSelected,
            enabled: enabled,
            compact: compact,
            onTap: () => onChanged(false),
          ),
        ),
        SizedBox(width: compact ? 8 : 10),
        Expanded(
          child: _MethodOption(
            theme: theme,
            icon: Icons.phone_android_outlined,
            label: phoneLabel,
            selected: isPhoneSelected,
            enabled: enabled,
            compact: compact,
            onTap: () => onChanged(true),
          ),
        ),
      ],
    );
  }
}

class _MethodOption extends StatelessWidget {
  const _MethodOption({
    required this.theme,
    required this.icon,
    required this.label,
    required this.selected,
    required this.enabled,
    required this.compact,
    required this.onTap,
  });

  final ThemeData theme;
  final IconData icon;
  final String label;
  final bool selected;
  final bool enabled;
  final bool compact;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final primary = theme.colorScheme.primary;
    final onPrimary = theme.colorScheme.onPrimary;
    final outline = theme.colorScheme.outlineVariant;

    return Material(
      color: selected ? primary : theme.colorScheme.surface,
      elevation: selected ? 1 : 0,
      shadowColor: primary.withValues(alpha: 0.35),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AuthFormStyles.fieldRadius),
        side: BorderSide(
          color: selected ? primary : outline,
          width: selected ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: enabled ? onTap : null,
        borderRadius: BorderRadius.circular(AuthFormStyles.fieldRadius),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: compact ? 8 : 10,
            vertical: compact ? 10 : 14,
          ),
          child: compact
              ? Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 18,
                      color: selected
                          ? onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        color: selected ? onPrimary : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                )
              : Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      icon,
                      size: 22,
                      color: selected
                          ? onPrimary
                          : theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(height: 6),
                    Text(
                      label,
                      textAlign: TextAlign.center,
                      style: theme.textTheme.labelLarge?.copyWith(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        color: selected ? onPrimary : theme.colorScheme.onSurface,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }
}
