import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/domain/user/user_profile.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../services/notifications/in_app_notifications_provider.dart';
import '../../../notifications/widgets/in_app_notifications_sheet.dart' show showInAppNotificationsSheet;
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_avatar.dart';
import '../../../auth/guest/guest_mode_provider.dart';
import '../../../auth/providers/auth_notifier.dart';
import '../../../profile/providers/current_user_profile_provider.dart';
import '../../models/home_feed_selection.dart';
import '../../providers/home_feed_provider.dart';
import '../../providers/home_profile_provider.dart';
import '../shared/client_home_search_card.dart';
import '../layout/client_home_settings_sheet.dart';

/// En-tête accueil : paramètres, logo, notifications, salutation, recherche.
class ClientHomeHeroHeader extends ConsumerStatefulWidget {
  const ClientHomeHeroHeader({super.key});

  @override
  ConsumerState<ClientHomeHeroHeader> createState() =>
      _ClientHomeHeroHeaderState();
}

class _ClientHomeHeroHeaderState extends ConsumerState<ClientHomeHeroHeader> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    ref.read(homeFeedSelectionProvider.notifier).setSearch(
          _searchController.text,
        );
    setState(() {});
  }

  void _submitSearch() {
    ref.read(homeFeedSelectionProvider.notifier).setSearch(
          _searchController.text,
        );
    FocusScope.of(context).unfocus();
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<HomeFeedSelection?>(homeFeedSelectionProvider, (_, next) {
      if (next == null || next.source == HomeFeedSource.search) return;
      if (_searchController.text.isEmpty) return;
      _searchController.removeListener(_onSearchChanged);
      _searchController.clear();
      _searchController.addListener(_onSearchChanged);
    });

    final theme = Theme.of(context);
    final isGuest = ref.watch(isGuestBrowsingProvider);
    final userProfile = ref.watch(currentUserProfileProvider).asData?.value;
    final authUser = ref.watch(authNotifierProvider).asData?.value;
    final profileSnapshot = ref.watch(homeProfileSnapshotProvider).asData?.value;
    final unreadNotif = ref.watch(unreadInAppNotificationsCountProvider);

    final greetingName = _greetingName(
      isGuest: isGuest,
      userProfile: userProfile,
      authMetadataPrenom: authUser?.userMetadata?['prenom'] as String?,
      profileDisplayName: profileSnapshot?.displayName,
      authFullName: authUser?.userMetadata?['full_name'] as String?,
    );
    final greetingLine = DiscHome.clientHomeGreeting(greetingName);
    final responsive = DiscoveryResponsive.of(context);
    final avatarRadius = responsive.isCompact
        ? 40.0
        : (responsive.isTablet ? 48.0 : 44.0);
    final headerBandHeight = avatarRadius * 2 + 12;
    final avatarUrl = userProfile?.avatarUrl ??
        (authUser?.userMetadata?['avatar_url'] as String?);
    final avatarDisplayName = _avatarDisplayName(
      isGuest: isGuest,
      userProfile: userProfile,
      greetingName: greetingName,
      profileDisplayName: profileSnapshot?.displayName,
      email: authUser?.email,
    );

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: headerBandHeight,
            child: Stack(
              clipBehavior: Clip.none,
              alignment: Alignment.center,
              children: [
                Align(
                  alignment: Alignment.centerLeft,
                  child: _HomeHeaderIconButton(
                    icon: Icons.settings_rounded,
                    tooltip: DiscHome.settingsTooltip,
                    onPressed: () => showClientHomeSettingsSheet(context, ref),
                  ),
                ),
                Align(
                  alignment: Alignment.centerRight,
                  child: _HomeHeaderIconButton(
                    icon: Icons.notifications_outlined,
                    tooltip: DiscHome.notificationsTooltip,
                    badgeCount: unreadNotif,
                    onPressed: () => showInAppNotificationsSheet(context, ref),
                  ),
                ),
                _HomeProfileAvatar(
                  radius: avatarRadius,
                  imageUrl: avatarUrl,
                  displayName: avatarDisplayName,
                  email: authUser?.email,
                  isGuest: isGuest,
                  onTap: isGuest ? null : () => context.goClientProfile(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            greetingLine,
            textAlign: TextAlign.center,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
              color: theme.colorScheme.onSurface,
              height: 1.25,
              letterSpacing: -0.2,
            ),
          ),
          const SizedBox(height: 12),
          ClientHomeSearchCard(
            controller: _searchController,
            hint: DiscHome.hintSearch,
            searchTooltip: DiscHome.actionSearch,
            onSubmit: _submitSearch,
          ),
        ],
      ),
    );
  }
}

String _greetingName({
  required bool isGuest,
  required UserProfile? userProfile,
  required String? authMetadataPrenom,
  required String? profileDisplayName,
  required String? authFullName,
}) {
  if (isGuest) return '';

  final prenom = userProfile?.prenom?.trim() ?? '';
  if (prenom.isNotEmpty) return prenom;

  final metaPrenom = authMetadataPrenom?.trim() ?? '';
  if (metaPrenom.isNotEmpty) return metaPrenom;

  final nom = userProfile?.nom?.trim() ?? '';
  if (nom.isNotEmpty) return nom.split(RegExp(r'\s+')).first;

  final display = profileDisplayName?.trim() ?? '';
  if (display.isNotEmpty) return display.split(RegExp(r'\s+')).first;

  final full = authFullName?.trim() ?? '';
  if (full.isNotEmpty) return full.split(RegExp(r'\s+')).first;

  return '';
}

String _avatarDisplayName({
  required bool isGuest,
  required UserProfile? userProfile,
  required String greetingName,
  required String? profileDisplayName,
  required String? email,
}) {
  if (isGuest) return '';

  final prenom = userProfile?.prenom?.trim() ?? '';
  final nom = userProfile?.nom?.trim() ?? '';
  if (prenom.isNotEmpty && nom.isNotEmpty) return '$prenom $nom';
  if (prenom.isNotEmpty) return prenom;
  if (nom.isNotEmpty) return nom;

  final display = profileDisplayName?.trim() ?? '';
  if (display.isNotEmpty) return display;

  if (greetingName.isNotEmpty) return greetingName;

  final mail = email?.trim() ?? '';
  if (mail.isNotEmpty) return mail;

  return CoreStrings.appName;
}

class _HomeHeaderIconButton extends StatelessWidget {
  const _HomeHeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
    this.badgeCount = 0,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;
  final int badgeCount;

  static const _size = 40.0;
  static const _iconSize = 22.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final iconWidget = Icon(icon, size: _iconSize);

    return SizedBox(
      width: _size,
      height: _size,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.surfaceContainerHighest
              .withValues(alpha: 0.65),
          foregroundColor: theme.colorScheme.onSurface,
          shape: const CircleBorder(),
          minimumSize: const Size(_size, _size),
          maximumSize: const Size(_size, _size),
          padding: EdgeInsets.zero,
        ),
        icon: badgeCount > 0
            ? Badge(
                isLabelVisible: true,
                label: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                child: iconWidget,
              )
            : iconWidget,
      ),
    );
  }
}

class _HomeProfileAvatar extends StatelessWidget {
  const _HomeProfileAvatar({
    required this.radius,
    required this.imageUrl,
    required this.displayName,
    required this.email,
    required this.isGuest,
    this.onTap,
  });

  final double radius;
  final String? imageUrl;
  final String displayName;
  final String? email;
  final bool isGuest;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final ring = theme.colorScheme.primary.withValues(alpha: 0.35);
    final hasPhoto = imageUrl != null && imageUrl!.trim().isNotEmpty;

    final Widget face = hasPhoto || !isGuest
        ? AppAvatar(
            imageUrl: imageUrl,
            displayName: displayName.isEmpty ? null : displayName,
            email: email,
            radius: radius,
          )
        : CircleAvatar(
            radius: radius,
            backgroundColor: theme.colorScheme.primaryContainer,
            foregroundColor: theme.colorScheme.onPrimaryContainer,
            child: Icon(Icons.person_outline_rounded, size: radius * 0.9),
          );

    final avatar = Material(
      color: theme.colorScheme.surface,
      elevation: 2,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.18),
      shape: CircleBorder(
        side: BorderSide(color: ring, width: 2.5),
      ),
      clipBehavior: Clip.antiAlias,
      child: face,
    );

    if (onTap == null) return avatar;

    return Material(
      color: AppColors.transparent,
      child: InkWell(
        onTap: onTap,
        customBorder: const CircleBorder(),
        child: avatar,
      ),
    );
  }
}
