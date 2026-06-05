import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import 'experience_item_codec.dart';

/// Option de confort affichée sur la fiche prestataire.
class ClientComfortOption {
  const ClientComfortOption({
    required this.id,
    required this.label,
    required this.icon,
  });

  final String id;
  final String label;
  final IconData icon;

  static const List<ClientComfortOption> presets = [
    ClientComfortOption(
      id: 'wifi',
      label: DiscPrestaComfort.wifi,
      icon: Icons.wifi_rounded,
    ),
    ClientComfortOption(
      id: 'parking',
      label: DiscPrestaComfort.parking,
      icon: Icons.local_parking_rounded,
    ),
    ClientComfortOption(
      id: 'pmr',
      label: DiscPrestaComfort.pmr,
      icon: Icons.accessible_rounded,
    ),
    ClientComfortOption(
      id: 'refreshments',
      label: DiscPrestaComfort.refreshments,
      icon: Icons.local_cafe_rounded,
    ),
    ClientComfortOption(
      id: 'climate',
      label: DiscPrestaComfort.climate,
      icon: Icons.ac_unit_rounded,
    ),
    ClientComfortOption(
      id: 'kids',
      label: DiscPrestaComfort.kids,
      icon: Icons.child_care_rounded,
    ),
    ClientComfortOption(
      id: 'vegan',
      label: DiscPrestaComfort.vegan,
      icon: Icons.spa_rounded,
    ),
    ClientComfortOption(
      id: 'consultation',
      label: DiscPrestaComfort.consultation,
      icon: Icons.chat_bubble_outline_rounded,
    ),
    ClientComfortOption(
      id: 'flex_payment',
      label: DiscPrestaComfort.flexPayment,
      icon: Icons.payments_outlined,
    ),
  ];

  static ClientComfortOption? presetById(String id) {
    for (final option in presets) {
      if (option.id == id) return option;
    }
    return null;
  }

  /// Presets + entrées `custom:…`.
  static List<ClientComfortOption> resolve(Iterable<String> rawIds) {
    final result = <ClientComfortOption>[];
    for (final id in rawIds) {
      if (ExperienceItemCodec.isCustom(id)) {
        final label = ExperienceItemCodec.decodeCustomLabel(id);
        if (label.isEmpty) continue;
        result.add(
          ClientComfortOption(
            id: id,
            label: label,
            icon: Icons.star_outline_rounded,
          ),
        );
        continue;
      }
      final preset = presetById(id);
      if (preset != null) result.add(preset);
    }
    return result;
  }
}

