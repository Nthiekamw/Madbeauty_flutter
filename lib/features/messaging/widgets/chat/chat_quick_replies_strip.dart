import 'package:flutter/material.dart';

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

    return SizedBox(
      height: 40,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: templates.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final t = templates[index];
          return ActionChip(
            label: Text(t.label),
            onPressed: () => onPick(t.text),
          );
        },
      ),
    );
  }
}

