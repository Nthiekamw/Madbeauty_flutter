import 'package:flutter/material.dart';

import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/utils/text_normalizer.dart';
import '../../../../shared/utils/user_presence_formatter.dart';
import '../../../../shared/widgets/app/app_avatar.dart';
import '../../../../shared/theme/app_colors.dart';

/// En-tête chat : avatar + nom (+ présence + sous-titre réservation).
class ChatPeerHeader extends StatelessWidget {
  const ChatPeerHeader({
    super.key,
    required this.displayName,
    this.peerPrenom,
    this.peerNom,
    this.avatarUrl,
    this.subtitle,
    this.peerLastSeenAt,
    this.titleColor,
    this.subtitleColor,
    this.onLightGradient = false,
    this.useSalonName = false,
  });

  final String displayName;
  final String? peerPrenom;
  final String? peerNom;
  final String? avatarUrl;
  final String? subtitle;
  final DateTime? peerLastSeenAt;
  final Color? titleColor;
  final Color? subtitleColor;
  final bool onLightGradient;
  final bool useSalonName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedName = normalizeSingleLineText(displayName);
    final title = normalizedName.isEmpty ? displayName : normalizedName;
    final singleLineTitle = (!useSalonName &&
            peerPrenom?.trim().isNotEmpty == true &&
            peerNom?.trim().isNotEmpty == true)
        ? normalizeSingleLineText('${peerPrenom!.trim()} ${peerNom!.trim()}')
        : title;
    final primary = theme.colorScheme.primary;
    final isOnline = UserPresenceFormatter.isOnline(peerLastSeenAt);
    final presenceLabel = UserPresenceFormatter.label(peerLastSeenAt);
    final presenceColor = isOnline
        ? (onLightGradient ? const Color(0xFF86EFAC) : const Color(0xFF16A34A))
        : (subtitleColor ?? theme.colorScheme.onSurfaceVariant);

    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
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
                displayName: singleLineTitle,
                radius: 21,
              ),
            ),
            if (isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 11,
                  height: 11,
                  decoration: BoxDecoration(
                    color: const Color(0xFF22C55E),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: onLightGradient
                          ? primary
                          : theme.colorScheme.surface,
                      width: 2,
                    ),
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                singleLineTitle,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: titleColor,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                presenceLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.labelSmall?.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: isOnline ? FontWeight.w700 : FontWeight.w500,
                  color: presenceColor,
                  height: 1.1,
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
