import '../../core/constants/app_strings.dart';
import '../../shared/layout/shell_nav_destination.dart';
import '../../shared/theme/app_icons.dart';

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
    AppIcons.dashboard,
    AppIcons.agenda,
    AppIcons.clients,
    AppIcons.messages,
    AppIcons.profile,
  ];
  static const _filled = [
    AppIcons.dashboardFilled,
    AppIcons.agendaFilled,
    AppIcons.clientsFilled,
    AppIcons.messagesFilled,
    AppIcons.profileFilled,
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
