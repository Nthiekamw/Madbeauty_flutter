import 'package:flutter/material.dart';

import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/auth_form_styles.dart';

/// Carte sélectionnable Client / Prestataire (inscription ou choix d’espace).
class AuthRoleCard extends StatelessWidget {
  const AuthRoleCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.onTap,
    this.selected = false,
    this.enabled = true,
    this.isLoading = false,
  });

  final String title;
  final String subtitle;
  final IconData icon;
  final VoidCallback? onTap;
  final bool selected;
  final bool enabled;
  final bool isLoading;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final interactive = enabled && !isLoading && onTap != null;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOutCubic,
      decoration: BoxDecoration(
        color: selected
            ? theme.colorScheme.primaryContainer.withValues(alpha: 0.65)
            : theme.colorScheme.surfaceContainerHighest.withValues(
                alpha: theme.brightness == Brightness.dark ? 0.5 : 0.9,
              ),
        borderRadius: BorderRadius.circular(AuthFormStyles.chipRadius),
        border: Border.all(
          color: selected
              ? primary
              : theme.colorScheme.outline.withValues(alpha: 0.22),
          width: selected ? 2 : 1,
        ),
        boxShadow: selected && theme.brightness == Brightness.light
            ? [
                BoxShadow(
                  color: primary.withValues(alpha: 0.08),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: interactive ? onTap : null,
          borderRadius: BorderRadius.circular(AuthFormStyles.chipRadius),
          child: Padding(
            padding: const EdgeInsets.all(18),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: selected ? 0.18 : 0.1),
                    borderRadius:
                        BorderRadius.circular(AuthFormStyles.fieldRadius),
                  ),
                  child: Icon(icon, color: primary, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w700,
                          letterSpacing: -0.2,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: AppFonts.body,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.35,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 8),
                if (isLoading)
                  SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2.5,
                      color: primary,
                    ),
                  )
                else
                  Icon(
                    selected
                        ? Icons.check_circle_rounded
                        : Icons.arrow_forward_ios_rounded,
                    size: selected ? 26 : 18,
                    color: selected
                        ? primary
                        : theme.colorScheme.onSurfaceVariant.withValues(
                            alpha: 0.55,
                          ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
