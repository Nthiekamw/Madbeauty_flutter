import 'package:flutter/material.dart';

import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/utils/text_normalizer.dart';
import '../../../shared/widgets/app_avatar.dart';

/// En-tête salon (dashboard / profil prestataire).
class PrestataireSalonHero extends StatelessWidget {
  const PrestataireSalonHero({
    super.key,
    required this.title,
    required this.subtitle,
    this.avatarUrl,
    this.trailing,
    this.footer,
  });

  final String title;
  final String subtitle;
  final String? avatarUrl;
  final Widget? trailing;
  final Widget? footer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final normalizedTitle = normalizeSingleLineText(title);

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
                alpha: isDark ? 0.55 : 0.88,
              ),
              theme.colorScheme.surface.withValues(
                alpha: isDark ? 0.4 : 0.82,
              ),
            ],
          ),
          border: Border.all(color: primary.withValues(alpha: 0.14)),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: primary.withValues(alpha: 0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 18, 16, 18),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primary.withValues(alpha: 0.3),
                        width: 2.5,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: primary.withValues(alpha: 0.15),
                          blurRadius: 12,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: AppAvatar(
                      imageUrl: avatarUrl,
                      displayName: title,
                      radius: 34,
                    ),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: LayoutBuilder(
                      builder: (context, constraints) {
                        final compact = constraints.maxWidth < 235;
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Expanded(
                                  child: Text(
                                    normalizedTitle.isEmpty ? title : normalizedTitle,
                                    maxLines: 1,
                                    softWrap: false,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.headlineSmall?.copyWith(
                                      fontFamily: AppFonts.display,
                                      fontWeight: FontWeight.w800,
                                      letterSpacing: -0.4,
                                      height: 1.1,
                                    ),
                                  ),
                                ),
                                if (trailing != null && !compact) ...[
                                  const SizedBox(width: 8),
                                  trailing!,
                                ],
                              ],
                            ),
                            if (trailing != null && compact) ...[
                              const SizedBox(height: 8),
                              Align(
                                alignment: Alignment.centerLeft,
                                child: trailing!,
                              ),
                            ],
                            const SizedBox(height: 6),
                            Text(
                              subtitle,
                              style: theme.textTheme.bodyMedium?.copyWith(
                                fontFamily: AppFonts.body,
                                color: theme.colorScheme.onSurfaceVariant,
                                height: 1.35,
                              ),
                            ),
                          ],
                        );
                      },
                    ),
                  ),
                ],
              ),
              if (footer != null) ...[
                const SizedBox(height: 14),
                footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
