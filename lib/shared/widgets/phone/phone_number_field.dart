import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../core/constants/app_strings.dart';
import '../../theme/auth_form_styles.dart';
import '../../utils/phone_number_utils.dart';
import '../app/app_text_field.dart';

/// Champ téléphone : indicatif (+33…) + numéro local sans 0 initial.
class PhoneNumberField extends StatelessWidget {
  const PhoneNumberField({
    super.key,
    required this.localController,
    required this.dialCode,
    required this.onDialCodeChanged,
    this.onLocalChanged,
    this.errorText,
    this.enabled = true,
    this.dense = true,
  });

  final TextEditingController localController;
  final String dialCode;
  final ValueChanged<String> onDialCodeChanged;
  final VoidCallback? onLocalChanged;
  final String? errorText;
  final bool enabled;
  final bool dense;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          width: dense ? 96 : 120,
          child: DropdownButtonFormField<String>(
            value: dialCode,
            isExpanded: true,
            decoration: InputDecoration(
              labelText: '+',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AuthFormStyles.fieldRadius),
              ),
              isDense: dense,
              contentPadding: EdgeInsets.symmetric(
                horizontal: dense ? 6 : 8,
                vertical: dense ? 12 : 14,
              ),
            ),
            style: theme.textTheme.labelLarge?.copyWith(
              fontWeight: FontWeight.w600,
              fontSize: dense ? 13 : null,
            ),
            selectedItemBuilder: (context) => PhoneNumberUtils.dialOptions
                .map(
                  (o) => Align(
                    alignment: AlignmentDirectional.centerStart,
                    child: Text(
                      dense ? o.dialCode : '${o.flag} ${o.dialCode}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                )
                .toList(),
            items: PhoneNumberUtils.dialOptions
                .map(
                  (o) => DropdownMenuItem<String>(
                    value: o.dialCode,
                    child: Text('${o.flag} ${o.dialCode}'),
                  ),
                )
                .toList(),
            onChanged: enabled
                ? (value) {
                    if (value != null) onDialCodeChanged(value);
                  }
                : null,
          ),
        ),
        SizedBox(width: dense ? 6 : 8),
        Expanded(
          child: AppTextField(
            dense: dense,
            controller: localController,
            enabled: enabled,
            label: AuthStrings.registerFieldPhone,
            hint: AuthStrings.registerFieldPhoneHint,
            errorText: errorText,
            keyboardType: TextInputType.phone,
            textInputAction: TextInputAction.next,
            autofillHints: const [AutofillHints.telephoneNumber],
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9\s]')),
            ],
            onChanged: (value) {
              final normalized = PhoneNumberUtils.normalizeLocalInput(value);
              if (normalized != value.replaceAll(RegExp(r'\s'), '')) {
                localController.value = TextEditingValue(
                  text: normalized,
                  selection: TextSelection.collapsed(
                    offset: normalized.length,
                  ),
                );
              }
              onLocalChanged?.call();
            },
            prefixIcon: Icon(
              Icons.phone_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ),
      ],
    );
  }
}
