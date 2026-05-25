import 'package:flutter/material.dart';

import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../theme/home_styles.dart';

/// En-tête accueil client : carte hero premium, salutation, avatar.
class ClientHomeHeader extends StatelessWidget {
  const ClientHomeHeader({
    super.key,
    required this.greetingLine,
    required this.subtitle,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.trailing,
    this.onAvatarTap,
  });

  final String greetingLine;
  final String subtitle;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final Widget? trailing;
  final VoidCallback? onAvatarTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final tertiary = theme.colorScheme.tertiary;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: HomeStyles.heroBorderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          stops: const [0.0, 0.55, 1.0],
          colors: [
            primary.withValues(alpha: isDark ? 0.45 : 0.72),
            theme.colorScheme.primaryContainer.withValues(
              alpha: isDark ? 0.6 : 0.88,
            ),
            tertiary.withValues(alpha: isDark ? 0.25 : 0.35),
          ],
        ),
        border: Border.all(
          color: primary.withValues(alpha: isDark ? 0.3 : 0.18),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: primary.withValues(alpha: isDark ? 0.18 : 0.12),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 22, 16, 20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: primary.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: primary.withValues(alpha: 0.25),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.auto_awesome_rounded,
                                  size: 13,
                                  color: primary,
                                ),
                                const SizedBox(width: 5),
                                Text(
                                  'MadBeauty',
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    fontFamily: AppFonts.display,
                                    fontWeight: FontWeight.w700,
                                    color: primary,
                                    letterSpacing: 0.3,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        greetingLine,
                        style: theme.textTheme.headlineMedium?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w900,
                          letterSpacing: -0.8,
                          height: 1.05,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subtitle,
                        style: theme.textTheme.bodyMedium?.copyWith(
                          fontFamily: AppFonts.body,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                if (trailing != null)
                  trailing!
                else
                  _AvatarButton(
                    onTap: onAvatarTap,
                    child: AppAvatar(
                      imageUrl: avatarUrl,
                      radius: 30,
                      displayName: displayName.isEmpty ? null : displayName,
                      email: email.isEmpty ? null : email,
                    ),
                  ),
              ],
            ),
            const SizedBox(height: 18),
            _QuickStatRow(theme: theme, primary: primary),
          ],
        ),
      ),
    );
  }
}

class _QuickStatRow extends StatelessWidget {
  const _QuickStatRow({required this.theme, required this.primary});

  final ThemeData theme;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _StatBadge(
          icon: Icons.storefront_rounded,
          label: 'Salons proches',
          theme: theme,
          primary: primary,
        ),
        const SizedBox(width: 8),
        _StatBadge(
          icon: Icons.star_rounded,
          label: 'Top notés',
          theme: theme,
          primary: primary,
        ),
        const SizedBox(width: 8),
        _StatBadge(
          icon: Icons.verified_rounded,
          label: 'Certifiés',
          theme: theme,
          primary: primary,
        ),
      ],
    );
  }
}

class _StatBadge extends StatelessWidget {
  const _StatBadge({
    required this.icon,
    required this.label,
    required this.theme,
    required this.primary,
  });

  final IconData icon;
  final String label;
  final ThemeData theme;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface.withValues(
            alpha: theme.brightness == Brightness.dark ? 0.25 : 0.55,
          ),
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: primary.withValues(alpha: 0.12),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, size: 18, color: primary),
            const SizedBox(height: 4),
            Text(
              label,
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelSmall?.copyWith(
                fontFamily: AppFonts.body,
                fontWeight: FontWeight.w600,
                fontSize: 9.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AvatarButton extends StatelessWidget {
  const _AvatarButton({required this.child, this.onTap});

  final Widget child;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ring = theme.colorScheme.primary.withValues(alpha: 0.3);

    final avatar = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );

    if (onTap == null) return avatar;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatar,
      ),
    );
  }
}
