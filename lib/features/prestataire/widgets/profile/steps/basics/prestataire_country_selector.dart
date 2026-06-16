import 'package:flutter/material.dart';

import '../../../../../../core/constants/app_strings.dart';
import '../../../../../../shared/utils/phone_number_utils.dart';

/// Sélecteur de pays (ISO) pour l’adresse du salon.
class PrestataireCountrySelector extends StatelessWidget {
  const PrestataireCountrySelector({
    super.key,
    required this.value,
    required this.onChanged,
    this.errorText,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selected = value.trim().toUpperCase();
    final effectiveValue = PhoneNumberUtils.dialOptions
            .any((option) => option.isoCode == selected)
        ? selected
        : PhoneNumberUtils.dialOptions.first.isoCode;

    return DropdownButtonFormField<String>(
      value: effectiveValue,
      decoration: InputDecoration(
        labelText: DiscPrestaForm.country,
        errorText: errorText,
        border: const OutlineInputBorder(),
      ),
      items: [
        for (final option in PhoneNumberUtils.dialOptions)
          DropdownMenuItem(
            value: option.isoCode,
            child: Row(
              children: [
                Text(option.flag, style: const TextStyle(fontSize: 18)),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    option.label,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
      ],
      onChanged: (next) {
        if (next != null) onChanged(next);
      },
      style: theme.textTheme.bodyMedium,
    );
  }
}
