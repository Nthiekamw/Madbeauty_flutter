import 'package:flutter/material.dart';

import '../../../../shared/theme/app_fonts.dart';
import '../../logic/chat_message_templates.dart';

/// Puces de réponses rapides au-dessus du champ de saisie.
class ChatQuickRepliesStrip extends StatelessWidget {
  const ChatQuickRepliesStrip({
    super.key,
    required this.templates,
    required this.onPick,
  });

  final List<ChatMessageTemplate> templates;
  final ValueChanged<String> onPick;

  @override
  Widget build(BuildContext context) {
    if (templates.isEmpty) return const SizedBox.shrink();

    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return SizedBox(
      height: 44,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.fromLTRB(14, 6, 14, 2),
        itemCount: templates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final t = templates[index];
          return Material(
            color: primary.withValues(alpha: 0.08),
            borderRadius: BorderRadius.circular(999),
            child: InkWell(
              onTap: () => onPick(t.text),
              borderRadius: BorderRadius.circular(999),
              child: Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  border: Border.all(
                    color: primary.withValues(alpha: 0.18),
                  ),
                ),
                child: Text(
                  t.label,
                  style: theme.textTheme.labelMedium?.copyWith(
                    fontFamily: AppFonts.body,
                    fontWeight: FontWeight.w600,
                    color: primary,
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
