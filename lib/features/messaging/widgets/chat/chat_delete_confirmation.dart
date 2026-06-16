import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

/// Dialogue de confirmation avant suppression d’un message ou d’une conversation.
Future<bool> confirmChatDeletion(
  BuildContext context, {
  required String title,
  required String body,
  String confirmLabel = DiscChat.deleteConfirm,
  String cancelLabel = DiscChat.deleteCancel,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      icon: Icon(
        Icons.delete_outline_rounded,
        color: Theme.of(ctx).colorScheme.error,
        size: 28,
      ),
      title: Text(title),
      content: Text(body),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(ctx).pop(false),
          child: Text(cancelLabel),
        ),
        FilledButton(
          onPressed: () => Navigator.of(ctx).pop(true),
          style: FilledButton.styleFrom(
            backgroundColor: Theme.of(ctx).colorScheme.error,
            foregroundColor: Theme.of(ctx).colorScheme.onError,
          ),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}
