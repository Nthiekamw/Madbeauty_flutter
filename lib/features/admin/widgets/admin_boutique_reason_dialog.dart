import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

/// Motif obligatoire pour une action admin boutique (support / litige).
Future<String?> showAdminBoutiqueReasonDialog(
  BuildContext context, {
  required String title,
  String? hint,
}) async {
  final controller = TextEditingController();
  final result = await showDialog<String>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: Text(title),
        content: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(
            labelText: DiscProfile.adminBoutiqueReasonLabel,
            hintText: hint ?? DiscProfile.adminBoutiqueReasonHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text(DiscProfile.adminUsersBanCancel),
          ),
          FilledButton(
            onPressed: () {
              final reason = controller.text.trim();
              if (reason.length < 3) return;
              Navigator.of(context).pop(reason);
            },
            child: const Text(DiscProfile.adminBoutiqueReasonConfirm),
          ),
        ],
      );
    },
  );
  controller.dispose();
  return result;
}
