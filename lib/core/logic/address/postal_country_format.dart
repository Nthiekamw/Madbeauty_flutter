import '../../../shared/utils/phone_number_utils.dart';
import 'postal_address.dart';

/// Libellé pays affiché dans [PostalAddressForm] depuis un code ISO.
String postalCountryLabelForIso(String? iso) {
  final code = iso?.trim().toUpperCase();
  if (code == null || code.isEmpty) return PostalAddress.defaultCountry;
  for (final option in PhoneNumberUtils.dialOptions) {
    if (option.isoCode == code) return option.label;
  }
  return PostalAddress.defaultCountry;
}

/// Code ISO2 pour la base à partir du libellé ou code saisi.
String postalCountryIso2(String? raw) {
  final value = raw?.trim();
  if (value == null || value.isEmpty) return 'FR';
  if (value.length == 2) return value.toUpperCase();
  final upper = value.toUpperCase();
  for (final option in PhoneNumberUtils.dialOptions) {
    if (option.isoCode == upper || option.label.toUpperCase() == upper) {
      return option.isoCode;
    }
  }
  return switch (upper) {
    'FRANCE' => 'FR',
    'BELGIQUE' => 'BE',
    'BELGIUM' => 'BE',
    'LUXEMBOURG' => 'LU',
    'SUISSE' => 'CH',
    'SWITZERLAND' => 'CH',
    'ALLEMAGNE' => 'DE',
    'GERMANY' => 'DE',
    'ROYAUME-UNI' => 'GB',
    'UNITED KINGDOM' => 'GB',
    _ => 'FR',
  };
}
