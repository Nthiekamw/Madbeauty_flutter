import '../../../core/constants/app_strings.dart';
import '../../../shared/utils/phone_number_utils.dart';

/// Libellé affiché pour un code pays ISO (ex. FR → France).
String adminCountryLabel(String countryCode) {
  final upper = countryCode.toUpperCase();
  if (upper == 'XX') return DiscProfile.adminCountryUnknown;
  for (final option in PhoneNumberUtils.dialOptions) {
    if (option.isoCode == upper) return option.label;
  }
  return upper;
}

/// Drapeau emoji ou icône neutre pour pays inconnu.
String adminCountryFlag(String countryCode) {
  final upper = countryCode.toUpperCase();
  if (upper == 'XX') return '🌍';
  final flag = PhoneNumberUtils.countryFlag(upper);
  return flag.isEmpty ? '🌍' : flag;
}
