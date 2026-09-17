import '../../core/constants/app_strings.dart';
import '../../shared/layout/shell_nav_destination.dart';
import '../../shared/theme/app_icons.dart';

/// Onglets shell client (partagés barre bas + rail web).
abstract final class ClientShellDestinations {
  ClientShellDestinations._();

  static const _labels = [
    ShellStrings.navClientHome,
    ShellStrings.navClientSearch,
    ShellStrings.navClientReel,
    ShellStrings.navClientMessages,
    ShellStrings.navClientProfile,
  ];
  static const _outlined = [
    AppIcons.home,
    AppIcons.search,
    AppIcons.reels,
    AppIcons.messages,
    AppIcons.profile,
  ];
  static const _filled = [
    AppIcons.homeFilled,
    AppIcons.searchFilled,
    AppIcons.reelsFilled,
    AppIcons.messagesFilled,
    AppIcons.profileFilled,
  ];

  static List<ShellNavDestination> build({
    int profileBadge = 0,
    int messagesBadge = 0,
  }) {
    return List.generate(_labels.length, (index) {
      final badge = switch (index) {
        3 => messagesBadge,
        4 => profileBadge,
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
