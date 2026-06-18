import 'dart:convert';

import '../../../core/constants/app_strings.dart';

/// Une expérience professionnelle avec sa durée.
class ProfessionalExperienceEntry {
  const ProfessionalExperienceEntry({
    required this.role,
    required this.years,
  });

  final String role;
  final String years;

  ProfessionalExperienceEntry copyWith({String? role, String? years}) {
    return ProfessionalExperienceEntry(
      role: role ?? this.role,
      years: years ?? this.years,
    );
  }

  Map<String, String> toJson() => {'r': role, 'y': years};

  static ProfessionalExperienceEntry? fromJson(Map<String, dynamic> json) {
    final role = (json['r'] as String?)?.trim() ?? '';
    final years = (json['y'] as String?)?.trim() ?? '';
    if (role.isEmpty) return null;
    return ProfessionalExperienceEntry(role: role, years: years);
  }
}

/// Encodage multi-expériences dans [experience_professionnelle] (rétrocompatible).
abstract final class ProfessionalExperienceCodec {
  ProfessionalExperienceCodec._();

  static const maxEntries = 5;
  static const _prefix = 'mb_exp:v1:';

  static ({String professional, String yearsSummary}) encode(
    List<ProfessionalExperienceEntry> entries,
  ) {
    final cleaned = entries
        .where((e) => e.role.trim().isNotEmpty)
        .map((e) => e.copyWith(role: e.role.trim(), years: e.years.trim()))
        .toList();
    if (cleaned.isEmpty) {
      return (professional: '', yearsSummary: '');
    }
    if (cleaned.length == 1 && cleaned.first.years.isEmpty) {
      return (
        professional: cleaned.first.role,
        yearsSummary: '',
      );
    }
    final payload = jsonEncode(cleaned.map((e) => e.toJson()).toList());
    final yearsSummary = cleaned
        .map((e) => e.years)
        .where((y) => y.isNotEmpty)
        .join(' · ');
    return (professional: '$_prefix$payload', yearsSummary: yearsSummary);
  }

  static List<ProfessionalExperienceEntry> decode(
    String? professionalRaw,
    String? yearsRaw,
  ) {
    final professional = professionalRaw?.trim() ?? '';
    if (professional.startsWith(_prefix)) {
      try {
        final list = jsonDecode(professional.substring(_prefix.length));
        if (list is List) {
          return [
            for (final item in list)
              if (item is Map)
                ProfessionalExperienceEntry.fromJson(
                  Map<String, dynamic>.from(item),
                ),
          ].whereType<ProfessionalExperienceEntry>().toList();
        }
      } catch (_) {
        return const [];
      }
    }

    if (professional.isEmpty) return const [];
    return [
      ProfessionalExperienceEntry(
        role: professional,
        years: yearsRaw?.trim() ?? '',
      ),
    ];
  }

  static String? validationError(List<ProfessionalExperienceEntry> entries) {
    if (entries.isEmpty) {
      return DiscPrestaForm.reqExperiencePro;
    }
    if (entries.length > maxEntries) {
      return DiscPrestaForm.experienceProTooMany;
    }
    for (final entry in entries) {
      if (entry.role.trim().isEmpty || entry.years.trim().isEmpty) {
        return DiscPrestaForm.experienceProIncomplete;
      }
    }
    final encoded = encode(entries).professional;
    if (encoded.length > 2000) {
      return DiscPrestaForm.experienceProEncodedTooLong;
    }
    return null;
  }
}
