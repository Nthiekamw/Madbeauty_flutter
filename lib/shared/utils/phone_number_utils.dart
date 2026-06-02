/// Indicatifs téléphone proposés dans les formulaires.
class PhoneDialOption {
  const PhoneDialOption({required this.flag, required this.dialCode});

  final String flag;
  final String dialCode;
}

abstract final class PhoneNumberUtils {
  PhoneNumberUtils._();

  static const dialOptions = <PhoneDialOption>[
    PhoneDialOption(flag: '🇫🇷', dialCode: '+33'),
    PhoneDialOption(flag: '🇧🇪', dialCode: '+32'),
    PhoneDialOption(flag: '🇨🇭', dialCode: '+41'),
    PhoneDialOption(flag: '🇩🇪', dialCode: '+49'),
    PhoneDialOption(flag: '🇬🇧', dialCode: '+44'),
  ];

  /// Retire le 0 initial (ex. 0612345678 → 612345678).
  static String stripLeadingZero(String input) {
    final digits = input.replaceAll(RegExp(r'\D'), '');
    if (digits.startsWith('0')) {
      return digits.substring(1);
    }
    return digits;
  }

  /// Numéro local affiché / saisi (sans indicatif).
  static String normalizeLocalInput(String input) => stripLeadingZero(input);

  /// Construit un numéro stocké type `+33 612345678`.
  static String toStored({required String dialCode, required String local}) {
    final normalized = normalizeLocalInput(local);
    if (normalized.isEmpty) return '';
    return '$dialCode $normalized';
  }

  /// Parse un numéro en base (indicatif + local sans 0).
  static ({String dialCode, String local}) parseStored(String? stored) {
    if (stored == null || stored.trim().isEmpty) {
      return (dialCode: '+33', local: '');
    }
    final compact = stored.replaceAll(RegExp(r'\s'), '');
    final dials = dialOptions.map((o) => o.dialCode).toList()
      ..sort((a, b) => b.length.compareTo(a.length));

    for (final dial in dials) {
      if (compact.startsWith(dial)) {
        var local = compact.substring(dial.length);
        local = stripLeadingZero(local);
        return (dialCode: dial, local: local);
      }
    }

    return (dialCode: '+33', local: stripLeadingZero(compact));
  }

  /// Affichage lisible dans le profil.
  static String formatForDisplay(String? stored) {
    if (stored == null || stored.trim().isEmpty) return '';
    final parsed = parseStored(stored);
    if (parsed.local.isEmpty) return parsed.dialCode;
    return '${parsed.dialCode} ${parsed.local}';
  }
}
