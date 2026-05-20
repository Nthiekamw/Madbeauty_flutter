import 'package:flutter/material.dart';

import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../theme/home_styles.dart';

/// En-tête accueil client : carte hero, salutation, avatar.
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

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: HomeStyles.heroBorderRadius,
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withValues(
              alpha: isDark ? 0.55 : 0.85,
            ),
            theme.colorScheme.surface.withValues(
              alpha: isDark ? 0.35 : 0.7,
            ),
          ],
        ),
        border: Border.all(
          color: primary.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 16, 20),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    greetingLine,
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                      letterSpacing: -0.5,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      fontFamily: AppFonts.body,
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            if (trailing != null)
              trailing!
            else
              _AvatarButton(
                onTap: onAvatarTap,
                child: AppAvatar(
                  imageUrl: avatarUrl,
                  radius: 28,
                  displayName: displayName.isEmpty ? null : displayName,
                  email: email.isEmpty ? null : email,
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
    final ring = Theme.of(context).colorScheme.primary.withValues(alpha: 0.25);

    final avatar = DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: ring, width: 2.5),
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
