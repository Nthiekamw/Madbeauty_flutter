import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';

/// Retourne le motif de refus saisi, ou `null` si annulé.
Future<String?> showRejectReservationDialog(BuildContext context) {
  return showDialog<String?>(
    context: context,
    builder: (ctx) => const _RejectReservationDialog(),
  );
}

class _RejectReservationDialog extends StatefulWidget {
  const _RejectReservationDialog();

  @override
  State<_RejectReservationDialog> createState() =>
      _RejectReservationDialogState();
}

class _RejectReservationDialogState extends State<_RejectReservationDialog> {
  final _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(DiscPrestaDash.rejectConfirmTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(DiscPrestaDash.rejectConfirmBody),
          const SizedBox(height: 16),
          TextField(
            controller: _controller,
            maxLines: 3,
            decoration: const InputDecoration(
              labelText: DiscPrestaAgenda.rejectReasonLabel,
              hintText: DiscPrestaAgenda.rejectReasonHint,
              border: OutlineInputBorder(),
            ),
          ),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: () => Navigator.of(context).pop(_controller.text),
          child: const Text(DiscPrestaDash.reject),
        ),
      ],
    );
  }
}
