import 'package:flutter/material.dart';

import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/utils/text_normalizer.dart';
import '../../../../shared/widgets/app/app_avatar.dart';
import '../../../../shared/theme/app_colors.dart';

/// En-tête chat : avatar + nom (+ sous-titre réservation).
class ChatPeerHeader extends StatelessWidget {
  const ChatPeerHeader({
    super.key,
    required this.displayName,
    this.peerPrenom,
    this.peerNom,
    this.avatarUrl,
    this.subtitle,
    this.titleColor,
    this.subtitleColor,
    this.onLightGradient = false,
  });

  final String displayName;
  final String? peerPrenom;
  final String? peerNom;
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
    final hasSplitName = peerPrenom?.trim().isNotEmpty == true &&
        peerNom?.trim().isNotEmpty == true;
    final primary = theme.colorScheme.primary;

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: onLightGradient
                ? AppColors.onPrimarySurface22
                : primary.withValues(alpha: 0.1),
            border: Border.all(
              color: onLightGradient
                  ? AppColors.onPrimarySurface55
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
              if (hasSplitName) ...[
                Text(
                  peerPrenom!.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                    height: 1.1,
                    color: titleColor,
                  ),
                ),
                Text(
                  peerNom!.trim(),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelLarge?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
                    height: 1.1,
                    color: titleColor?.withValues(alpha: 0.92) ?? titleColor,
                  ),
                ),
              ] else
                Text(
                  title,
                  maxLines: 2,
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

