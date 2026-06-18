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
    this.compact = false,
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
  final bool compact;

  String _secondaryLine(String presenceLabel) {
    final parts = <String>[presenceLabel];
    final sub = subtitle?.trim();
    if (sub != null && sub.isNotEmpty) parts.add(sub);
    return parts.join(' · ');
  }

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
    final avatarRadius = compact ? 16.0 : 21.0;

    return Row(
      children: [
        Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              padding: EdgeInsets.all(compact ? 2 : 2.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: onLightGradient
                    ? AppColors.onPrimarySurface22
                    : primary.withValues(alpha: 0.1),
                border: Border.all(
                  color: onLightGradient
                      ? AppColors.onPrimarySurface55
                      : primary.withValues(alpha: 0.25),
                  width: compact ? 1.5 : 2,
                ),
              ),
              child: AppAvatar(
                imageUrl: avatarUrl,
                displayName: singleLineTitle,
                radius: avatarRadius,
              ),
            ),
            if (isOnline)
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: compact ? 9 : 11,
                  height: compact ? 9 : 11,
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
        SizedBox(width: compact ? 10 : 12),
        Expanded(
          child: compact
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
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
                        fontSize: 15,
                        height: 1.05,
                        color: titleColor,
                      ),
                    ),
                    const SizedBox(height: 1),
                    Text(
                      _secondaryLine(presenceLabel),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.labelSmall?.copyWith(
                        fontFamily: AppFonts.body,
                        fontWeight: isOnline ? FontWeight.w700 : FontWeight.w500,
                        fontSize: 11,
                        height: 1.05,
                        color: isOnline ? presenceColor : subtitleColor,
                      ),
                    ),
                  ],
                )
              : Column(
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
