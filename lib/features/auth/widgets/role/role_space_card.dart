import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/discovery_styles.dart';
import '../../../../shared/theme/app_colors.dart';

/// Carte sélectionnable pour basculer client / prestataire.
class RoleSpaceCard extends StatelessWidget {
  const RoleSpaceCard({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.isActive,
    required this.onTap,
    this.compact = false,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final bool isActive;
  final VoidCallback? onTap;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final pad = compact ? 10.0 : 14.0;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: DiscoveryStyles.cardBorderRadius,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          curve: Curves.easeOutCubic,
          height: compact ? 92 : null,
          padding: EdgeInsets.all(pad),
          decoration: BoxDecoration(
            borderRadius: DiscoveryStyles.cardBorderRadius,
            gradient: isActive
                ? LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primary.withValues(alpha: isDark ? 0.5 : 0.78),
                      theme.colorScheme.primaryContainer.withValues(
                        alpha: isDark ? 0.55 : 0.9,
                      ),
                    ],
                  )
                : null,
            color: isActive
                ? null
                : theme.colorScheme.surfaceContainerHighest.withValues(
                    alpha: isDark ? 0.45 : 0.85,
                  ),
            border: Border.all(
              color: isActive
                  ? primary
                  : theme.colorScheme.outline.withValues(alpha: 0.18),
              width: isActive ? 2 : 1,
            ),
            boxShadow: isActive
                ? [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.18),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    icon,
                    size: compact ? 18 : 22,
                    color: isActive
                        ? theme.colorScheme.onPrimary
                        : primary,
                  ),
                  const Spacer(),
                  if (isActive)
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: compact ? 6 : 8,
                        vertical: 2,
                      ),
                      decoration: BoxDecoration(
                        color: theme.colorScheme.onPrimary.withValues(
                          alpha: 0.2,
                        ),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        DiscProfile.roleActiveBadge,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w800,
                          fontSize: 9,
                          color: theme.colorScheme.onPrimary,
                        ),
                      ),
                    ),
                ],
              ),
              SizedBox(height: compact ? 6 : 10),
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  fontSize: compact ? 13 : null,
                  color: isActive ? theme.colorScheme.onPrimary : null,
                ),
              ),
              const SizedBox(height: 2),
              Expanded(
                child: Text(
                  subtitle,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: AppFonts.body,
                    fontSize: compact ? 11 : null,
                    color: isActive
                        ? theme.colorScheme.onPrimary.withValues(alpha: 0.88)
                        : theme.colorScheme.onSurfaceVariant,
                    height: 1.2,
                  ),
                ),
              ),
              if (!isActive && onTap != null)
                Row(
                  children: [
                    Text(
                      DiscProfile.roleSwitchAction,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontFamily: AppFonts.body,
                        fontWeight: FontWeight.w700,
                        fontSize: compact ? 10 : null,
                        color: primary,
                      ),
                    ),
                    Icon(Icons.arrow_forward_rounded, size: 12, color: primary),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
