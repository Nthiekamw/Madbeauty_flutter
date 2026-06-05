import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import 'experience_item_codec.dart';

/// Condition de service proposée (preset ou personnalisée).
class ServiceConditionOption {
  const ServiceConditionOption({
    required this.id,
    required this.label,
    this.icon = Icons.check_circle_outline_rounded,
  });

  final String id;
  final String label;
  final IconData icon;

  static const List<ServiceConditionOption> presets = [
    ServiceConditionOption(
      id: 'cancel_24h',
      label: DiscPrestaComfort.condCancel24h,
      icon: Icons.event_busy_rounded,
    ),
    ServiceConditionOption(
      id: 'cancel_48h',
      label: DiscPrestaComfort.condCancel48h,
      icon: Icons.event_busy_outlined,
    ),
    ServiceConditionOption(
      id: 'late_15',
      label: DiscPrestaComfort.condLate15,
      icon: Icons.schedule_rounded,
    ),
    ServiceConditionOption(
      id: 'deposit_none',
      label: DiscPrestaComfort.condNoDeposit,
      icon: Icons.money_off_csred_rounded,
    ),
    ServiceConditionOption(
      id: 'deposit_30',
      label: DiscPrestaComfort.condDeposit30,
      icon: Icons.account_balance_wallet_outlined,
    ),
    ServiceConditionOption(
      id: 'hygiene',
      label: DiscPrestaComfort.condHygiene,
      icon: Icons.clean_hands_rounded,
    ),
    ServiceConditionOption(
      id: 'arrive_early',
      label: DiscPrestaComfort.condArriveEarly,
      icon: Icons.alarm_rounded,
    ),
    ServiceConditionOption(
      id: 'minor_guardian',
      label: DiscPrestaComfort.condMinorGuardian,
      icon: Icons.family_restroom_rounded,
    ),
  ];

  static ServiceConditionOption? presetById(String id) {
    for (final option in presets) {
      if (option.id == id) return option;
    }
    return null;
  }

  /// Presets + libellés `custom:…` conservés dans [rawIds].
  static List<ServiceConditionOption> resolve(Iterable<String> rawIds) {
    final result = <ServiceConditionOption>[];
    for (final id in rawIds) {
      if (ExperienceItemCodec.isCustom(id)) {
        final label = ExperienceItemCodec.decodeCustomLabel(id);
        if (label.isEmpty) continue;
        result.add(
          ServiceConditionOption(
            id: id,
            label: label,
            icon: Icons.edit_note_rounded,
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
