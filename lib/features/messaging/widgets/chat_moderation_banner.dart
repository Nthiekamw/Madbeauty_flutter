import 'package:flutter/material.dart';

import '../../../shared/theme/app_fonts.dart';
import '../logic/chat_message_moderator.dart';

/// Bandeau d’avertissement sous le champ de saisie (style Leboncoin).
class ChatModerationBanner extends StatelessWidget {
  const ChatModerationBanner({
    super.key,
    required this.moderation,
  });

  final ChatMessageModerationResult moderation;

  @override
  Widget build(BuildContext context) {
    if (!moderation.isBlocked) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final error = theme.colorScheme.error;

    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 8),
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: error.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: error.withValues(alpha: 0.35)),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(Icons.shield_outlined, size: 20, color: error),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  moderation.bannerMessage,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: AppFonts.body,
                    color: theme.colorScheme.onSurface,
                    height: 1.35,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
