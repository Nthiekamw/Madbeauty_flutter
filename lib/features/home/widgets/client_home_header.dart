import 'package:flutter/material.dart';

import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/prototype_layout.dart';
import '../../../shared/theme/prototype_palette.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/prototype/prototype_icon_circle_button.dart';

/// En-tête accueil client : paramètres | avatar | cloche (style Madbeauty_flutter).
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
    final layout = PrototypeLayout(context);
    final rem = layout.rem;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDark) {
      return _DarkHeader(
        greetingLine: greetingLine,
        subtitle: subtitle,
        displayName: displayName,
        email: email,
        avatarUrl: avatarUrl,
        trailing: trailing,
        onAvatarTap: onAvatarTap,
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: EdgeInsets.fromLTRB(rem * 4, rem * 3, rem * 4, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              PrototypeIconCircleButton(
                icon: Icons.settings_outlined,
                size: rem * 10,
                onTap: () => context.goClientProfile(),
              ),
              if (trailing != null)
                trailing!
              else
                _CenterAvatar(
                  rem: rem,
                  displayName: displayName,
                  email: email,
                  avatarUrl: avatarUrl,
                  onTap: onAvatarTap,
                ),
              PrototypeIconCircleButton(
                icon: Icons.notifications_outlined,
                size: rem * 10,
                showNotificationDot: true,
                onTap: () {},
              ),
            ],
          ),
        ),
        SizedBox(height: rem * 2.5),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rem * 4),
          child: Text(
            greetingLine,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: rem * 5.2,
              fontWeight: FontWeight.w900,
              color: PrototypePalette.textDark,
              height: 1.25,
              letterSpacing: -0.3,
            ),
          ),
        ),
        SizedBox(height: rem * 1.5),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: rem * 4),
          child: Text(
            subtitle,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: rem * 3.4,
              color: PrototypePalette.textGrey,
              height: 1.35,
            ),
          ),
        ),
      ],
    );
  }
}

class _CenterAvatar extends StatelessWidget {
  const _CenterAvatar({
    required this.rem,
    required this.displayName,
    required this.email,
    this.avatarUrl,
    this.onTap,
  });

  final double rem;
  final String displayName;
  final String email;
  final String? avatarUrl;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final avatar = Container(
      width: rem * 13,
      height: rem * 13,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(color: PrototypePalette.gold, width: 2.5),
        boxShadow: [
          BoxShadow(
            color: PrototypePalette.gold.withValues(alpha: 0.3),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: AppAvatar(
        imageUrl: avatarUrl,
        radius: rem * 6.2,
        displayName: displayName.isEmpty ? null : displayName,
        email: email.isEmpty ? null : email,
      ),
    );

    if (onTap == null) return avatar;

    return GestureDetector(onTap: onTap, child: avatar);
  }
}

/// Variante dark : conserve l’ancienne carte hero.
class _DarkHeader extends StatelessWidget {
  const _DarkHeader({
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
    final primary = theme.colorScheme.primary;

    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primaryContainer.withValues(alpha: 0.55),
            theme.colorScheme.surface.withValues(alpha: 0.35),
          ],
        ),
        border: Border.all(color: primary.withValues(alpha: 0.12)),
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
                      fontWeight: FontWeight.w800,
                      height: 1.1,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    subtitle,
                    style: theme.textTheme.bodyMedium?.copyWith(
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
              GestureDetector(
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
