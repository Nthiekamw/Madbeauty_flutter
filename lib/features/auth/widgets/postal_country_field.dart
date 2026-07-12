import 'package:flutter/material.dart';

import '../../../core/config/market_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/logic/address/postal_country_format.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/utils/phone_number_utils.dart';

/// Sélecteur de pays pour [PostalAddressForm] (marchés MadBeauty).
class PostalCountryField extends StatelessWidget {
  const PostalCountryField({
    super.key,
    required this.value,
    required this.onChanged,
    this.dense = true,
    this.enabled = true,
    this.iconColor,
  });

  final String value;
  final ValueChanged<String> onChanged;
  final bool dense;
  final bool enabled;
  final Color? iconColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final selectedIso = postalFormCountryIso2(value);

    return DropdownButtonFormField<String>(
      value: selectedIso,
      isExpanded: true,
      decoration: InputDecoration(
        labelText: AuthStrings.registerFieldCountry,
        filled: true,
        isDense: dense,
        prefixIcon: Icon(Icons.public_outlined, color: iconColor),
      ),
      items: [
        for (final iso in postalFormCountryIsoCodes)
          DropdownMenuItem(
            value: iso,
            child: Row(
              children: [
                Text(
                  PhoneNumberUtils.countryFlag(iso),
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(MarketConfig.definitionFor(iso).labelFr),
                ),
              ],
            ),
          ),
      ],
      onChanged: enabled
          ? (iso) {
              if (iso == null) return;
              onChanged(postalCountryLabelForIso(iso));
            }
          : null,
      selectedItemBuilder: (context) {
        return [
          for (final iso in postalFormCountryIsoCodes)
            Align(
              alignment: AlignmentDirectional.centerStart,
              child: Text(
                MarketConfig.definitionFor(iso).labelFr,
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontFamily: AppFonts.body,
                ),
              ),
            ),
        ];
      },
      style: theme.textTheme.bodyMedium?.copyWith(fontFamily: AppFonts.body),
    );
  }
}
