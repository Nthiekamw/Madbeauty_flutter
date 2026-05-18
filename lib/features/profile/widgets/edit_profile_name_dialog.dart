import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

/// Dialogue de modification du prénom et du nom.
Future<({String prenom, String nom})?> showEditProfileNameDialog({
  required BuildContext context,
  required String initialPrenom,
  required String initialNom,
}) {
  return showDialog<({String prenom, String nom})>(
    context: context,
    builder: (ctx) => _EditProfileNameDialog(
      initialPrenom: initialPrenom,
      initialNom: initialNom,
    ),
  );
}

class _EditProfileNameDialog extends StatefulWidget {
  const _EditProfileNameDialog({
    required this.initialPrenom,
    required this.initialNom,
  });

  final String initialPrenom;
  final String initialNom;

  @override
  State<_EditProfileNameDialog> createState() => _EditProfileNameDialogState();
}

class _EditProfileNameDialogState extends State<_EditProfileNameDialog> {
  late final TextEditingController _prenomController;
  late final TextEditingController _nomController;
  String? _error;

  @override
  void initState() {
    super.initState();
    _prenomController = TextEditingController(text: widget.initialPrenom);
    _nomController = TextEditingController(text: widget.initialNom);
  }

  @override
  void dispose() {
    _prenomController.dispose();
    _nomController.dispose();
    super.dispose();
  }

  void _submit() {
    final prenom = _prenomController.text.trim();
    final nom = _nomController.text.trim();
    if (prenom.isEmpty && nom.isEmpty) {
      setState(() => _error = ShellStrings.profileNameRequired);
      return;
    }
    Navigator.of(context).pop((prenom: prenom, nom: nom));
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text(ShellStrings.profileEditNameTitle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextField(
            controller: _prenomController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: ShellStrings.profileFieldPrenom,
            ),
            onSubmitted: (_) => _submit(),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nomController,
            textCapitalization: TextCapitalization.words,
            decoration: const InputDecoration(
              labelText: ShellStrings.profileFieldNom,
            ),
            onSubmitted: (_) => _submit(),
          ),
          if (_error != null) ...[
            const SizedBox(height: 12),
            Text(
              _error!,
              style: TextStyle(color: Theme.of(context).colorScheme.error),
            ),
          ],
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: const Text('Annuler'),
        ),
        FilledButton(
          onPressed: _submit,
          child: const Text(ShellStrings.profileSave),
        ),
      ],
    );
  }
}
