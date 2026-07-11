/// Indicatifs téléphone proposés dans les formulaires.
class PhoneDialOption {
  const PhoneDialOption({
    required this.isoCode,
    required this.dialCode,
    required this.label,
  });

  /// Code pays ISO 3166-1 alpha-2 (ex. FR).
  final String isoCode;
  final String dialCode;

  /// Libellé lisible (ex. France).
  final String label;

  /// Drapeau régional généré depuis [isoCode] (évite les soucis d'encodage fichier).
  String get flag => PhoneNumberUtils.countryFlag(isoCode);
}

abstract final class PhoneNumberUtils {
  PhoneNumberUtils._();

  static const dialOptions = <PhoneDialOption>[
    PhoneDialOption(isoCode: 'FR', dialCode: '+33', label: 'France'),
    PhoneDialOption(isoCode: 'BE', dialCode: '+32', label: 'Belgique'),
    PhoneDialOption(isoCode: 'CA', dialCode: '+1', label: 'Canada'),
    PhoneDialOption(isoCode: 'CH', dialCode: '+41', label: 'Suisse'),
    PhoneDialOption(isoCode: 'DE', dialCode: '+49', label: 'Allemagne'),
    PhoneDialOption(isoCode: 'GB', dialCode: '+44', label: 'Royaume-Uni'),
  ];

  /// Construit l'emoji drapeau à partir d'un code pays à 2 lettres (FR → 🇫🇷).
  static String countryFlag(String iso3166Alpha2) {
    final upper = iso3166Alpha2.toUpperCase();
    if (upper.length != 2) return '';
    final a = upper.codeUnitAt(0);
    final b = upper.codeUnitAt(1);
    if (a < 65 || a > 90 || b < 65 || b > 90) return '';
    return String.fromCharCodes([
      0x1F1E6 + (a - 65),
      0x1F1E6 + (b - 65),
    ]);
  }

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

  /// Format E.164 sans espace (ex. `+33612345678`) pour OTP SMS / Firebase.
  static String toE164({required String dialCode, required String local}) {
    final normalized = normalizeLocalInput(local);
    if (normalized.isEmpty) return '';
    return '$dialCode$normalized';
  }

  /// E.164 depuis un numéro stocké (`+33 612…` ou `+33612…`).
  static String storedToE164(String? stored) {
    if (stored == null || stored.trim().isEmpty) return '';
    return stored.replaceAll(RegExp(r'\s'), '');
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
