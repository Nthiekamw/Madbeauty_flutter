import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

/// Motif obligatoire avant de retirer la vérification d'un prestataire.
Future<String?> showAdminRevokeVerificationDialog(BuildContext context) {
  return showDialog<String>(
    context: context,
    builder: (ctx) => const _AdminRevokeVerificationDialog(),
  );
}

class _AdminRevokeVerificationDialog extends StatefulWidget {
  const _AdminRevokeVerificationDialog();

  @override
  State<_AdminRevokeVerificationDialog> createState() =>
      _AdminRevokeVerificationDialogState();
}

class _AdminRevokeVerificationDialogState
    extends State<_AdminRevokeVerificationDialog> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _submit() {
    final text = _controller.text.trim();
    if (text.length < 3) {
      setState(() => _error = DiscProfile.adminVerificationRevokeNoteTooShort);
      return;
    }
    Navigator.of(context).pop(text);
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(DiscProfile.adminVerificationRevokeTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(DiscProfile.adminVerificationRevokeBody),
          const SizedBox(height: 12),
          TextField(
            controller: _controller,
            maxLines: 4,
            decoration: InputDecoration(
              labelText: DiscProfile.adminVerificationRevokeNoteLabel,
              hintText: DiscProfile.adminVerificationRevokeNoteHint,
              errorText: _error,
            ),
            onChanged: (_) {
              if (_error != null) setState(() => _error = null);
            },
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text(CoreStrings.actionCancel),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text(DiscProfile.adminVerificationRevokeConfirm),
        ),
      ],
    );
  }
}
