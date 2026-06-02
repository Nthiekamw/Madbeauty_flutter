import 'package:flutter/material.dart';

import '../../../shared/theme/app_fonts.dart';
import '../../../shared/utils/text_normalizer.dart';
import '../../../shared/widgets/app/app_avatar.dart';

/// En-tête chat : avatar + nom (+ sous-titre réservation).
class ChatPeerHeader extends StatelessWidget {
  const ChatPeerHeader({
    super.key,
    required this.displayName,
    this.avatarUrl,
    this.subtitle,
    this.titleColor,
    this.subtitleColor,
    this.onLightGradient = false,
  });

  final String displayName;
  final String? avatarUrl;
  final String? subtitle;
  final Color? titleColor;
  final Color? subtitleColor;
  final bool onLightGradient;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedName = normalizeSingleLineText(displayName);
    final title = normalizedName.isEmpty ? displayName : normalizedName;
    final primary = theme.colorScheme.primary;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onLightGradient
                ? Colors.white.withValues(alpha: 0.22)
                : primary.withValues(alpha: 0.1),
            border: Border.all(
              color: onLightGradient
                  ? Colors.white.withValues(alpha: 0.55)
                  : primary.withValues(alpha: 0.25),
              width: 2,
            ),
          ),
          child: AppAvatar(
            imageUrl: avatarUrl,
            displayName: title,
            radius: 21,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                title,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: titleColor,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.event_available_rounded,
                      size: 13,
                      color: subtitleColor ??
                          theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 4),
                    Expanded(
                      child: Text(
                        subtitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontFamily: AppFonts.body,
                          fontWeight: FontWeight.w500,
                          color: subtitleColor ??
                              theme.colorScheme.onSurfaceVariant,
                          height: 1.1,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
