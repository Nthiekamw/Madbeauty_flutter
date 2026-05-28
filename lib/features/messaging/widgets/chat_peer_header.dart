import 'package:flutter/material.dart';

import '../../../shared/theme/app_fonts.dart';
import '../../../shared/utils/text_normalizer.dart';
import '../../../shared/widgets/app_avatar.dart';
/// En-tête chat : avatar + nom de l'interlocuteur (+ sous-titre réservation).
class ChatPeerHeader extends StatelessWidget {
  const ChatPeerHeader({
    super.key,
    required this.displayName,
    this.avatarUrl,
    this.subtitle,
    this.titleColor,
    this.subtitleColor,
  });

  final String displayName;
  final String? avatarUrl;
  final String? subtitle;
  final Color? titleColor;
  final Color? subtitleColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final normalizedName = normalizeSingleLineText(displayName);

    return Row(
      children: [
        Container(
          padding: const EdgeInsets.all(2.5),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFFFFF), Color(0x99FFFFFF)],
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.white.withValues(alpha: 0.35),
                blurRadius: 14,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: AppAvatar(
            imageUrl: avatarUrl,
            displayName: normalizedName.isEmpty ? displayName : normalizedName,
            radius: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                normalizedName.isEmpty ? displayName : normalizedName,
                maxLines: 1,
                softWrap: false,
                overflow: TextOverflow.ellipsis,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  height: 1.15,
                  color: titleColor,
                ),
              ),
              if (subtitle != null && subtitle!.isNotEmpty) ...[
                const SizedBox(height: 2),
                Text(
                  subtitle!,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: subtitleColor ?? theme.colorScheme.onSurfaceVariant,
                    height: 1.1,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
