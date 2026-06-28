import 'package:flutter/material.dart';

import '../../core/constants/app_strings.dart';
import '../../shared/layout/shell_nav_destination.dart';

abstract final class PrestataireShellDestinations {
  PrestataireShellDestinations._();

  static const _labels = [
    ShellStrings.navPrestataireDashboard,
    ShellStrings.navPrestataireAgenda,
    ShellStrings.navPrestataireClients,
    ShellStrings.navPrestataireMessages,
    ShellStrings.navPrestataireProfile,
  ];
  static const _outlined = [
    Icons.dashboard_outlined,
    Icons.calendar_month_outlined,
    Icons.groups_outlined,
    Icons.chat_bubble_outline_rounded,
    Icons.person_outline,
  ];
  static const _filled = [
    Icons.dashboard,
    Icons.calendar_month,
    Icons.groups,
    Icons.chat_bubble_rounded,
    Icons.person,
  ];

  static List<ShellNavDestination> build({int messagesBadge = 0}) {
    return List.generate(_labels.length, (index) {
      return ShellNavDestination(
        label: _labels[index],
        outlinedIcon: _outlined[index],
        filledIcon: _filled[index],
        badgeCount: index == 3 ? messagesBadge : 0,
      );
    });
  }
}
