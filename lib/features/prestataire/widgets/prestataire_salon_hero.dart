import 'package:flutter/material.dart';

import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/widgets/app_avatar.dart';

/// En-tête salon (dashboard / profil prestataire).
class PrestataireSalonHero extends StatelessWidget {
  const PrestataireSalonHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.avatarUrl,
    this.trailing,
  });

  final String title;
  final String subtitle;
  final String? avatarUrl;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
      child: DecoratedBox(
        decoration: BoxDecoration(
          borderRadius: DiscoveryStyles.heroBorderRadius,
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primaryContainer.withValues(
                alpha: isDark ? 0.55 : 0.85,
              ),
              theme.colorScheme.surface.withValues(
                alpha: isDark ? 0.35 : 0.75,
              ),
            ],
          ),
          border: Border.all(color: primary.withValues(alpha: 0.12)),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              DecoratedBox(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: primary.withValues(alpha: 0.25),
                    width: 2.5,
                  ),
                ),
                child: AppAvatar(
                  imageUrl: avatarUrl,
                  displayName: title,
                  radius: 32,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: theme.textTheme.headlineSmall?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.4,
                        height: 1.1,
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      subtitle,
                      style: theme.textTheme.bodyMedium?.copyWith(
                        fontFamily: AppFonts.body,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.35,
                      ),
                    ),
                    if (trailing != null) ...[
                      const SizedBox(height: 10),
                      trailing!,
                    ],
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
