import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/layout/shell_nav_destination.dart';

/// Onglets shell client (partagés barre bas + rail web).
abstract final class ClientShellDestinations {
  ClientShellDestinations._();

  static const _labels = [
    ShellStrings.navClientHome,
    ShellStrings.navClientSearch,
    ShellStrings.navClientReservations,
    ShellStrings.navClientMessages,
    ShellStrings.navClientProfile,
  ];
  static const _outlined = [
    Icons.home_outlined,
    Icons.search_outlined,
    Icons.event_outlined,
    Icons.chat_bubble_outline_rounded,
    Icons.person_outline_rounded,
  ];
  static const _filled = [
    Icons.home_rounded,
    Icons.search_rounded,
    Icons.event_rounded,
    Icons.chat_bubble_rounded,
    Icons.person_rounded,
  ];

  static List<ShellNavDestination> build({
    int reservationsBadge = 0,
    int messagesBadge = 0,
  }) {
    return List.generate(_labels.length, (index) {
      final badge = switch (index) {
        2 => reservationsBadge,
        3 => messagesBadge,
        _ => 0,
      };
      return ShellNavDestination(
        label: _labels[index],
        outlinedIcon: _outlined[index],
        filledIcon: _filled[index],
        badgeCount: badge,
      );
    });
  }
}
