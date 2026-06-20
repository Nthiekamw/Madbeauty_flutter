import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/domain/user/user_profile.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../services/notifications/in_app_notification_audience.dart';
import '../../../../services/notifications/in_app_notifications_provider.dart';
import '../../../notifications/widgets/in_app_notifications_sheet.dart'
    show showInAppNotificationsSheet;
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/app/app_avatar.dart';
import '../../../auth/guest/guest_mode_provider.dart';
import '../../../auth/providers/auth_notifier.dart';
import '../../../profile/providers/current_user_profile_provider.dart';
import '../../models/home_feed_selection.dart';
import '../../providers/home_feed_provider.dart';
import '../../providers/home_profile_provider.dart';
import '../layout/client_home_settings_sheet.dart';
import '../shared/client_home_search_card.dart';

/// En-tête accueil : avatar, salutation, notifications, recherche + filtres.
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
      if (next == null) return;
      final shouldClearSearch = next == HomeFeedSelection.defaultInspiration ||
          next.source != HomeFeedSource.search;
      if (!shouldClearSearch || _searchController.text.isEmpty) return;
      _searchController.removeListener(_onSearchChanged);
      _searchController.clear();
      _searchController.addListener(_onSearchChanged);
    });

    final theme = Theme.of(context);
    final isGuest = ref.watch(isGuestBrowsingProvider);
    final userProfile = ref.watch(currentUserProfileProvider).asData?.value;
    final authUser = ref.watch(authNotifierProvider).asData?.value;
    final profileSnapshot =
        ref.watch(homeProfileSnapshotProvider).asData?.value;
    final unreadNotif = ref.watch(
      scopedUnreadInAppNotificationsCountProvider(
        InAppNotificationAudience.client,
      ),
    );

    final greetingName = _greetingName(
      isGuest: isGuest,
      userProfile: userProfile,
      authMetadataPrenom: authUser?.userMetadata?['prenom'] as String?,
      profileDisplayName: profileSnapshot?.displayName,
      authFullName: authUser?.userMetadata?['full_name'] as String?,
    );
    final greetingLine = DiscHome.clientHomeGreeting(greetingName);
    const avatarRadius = 22.0;
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
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _HomeProfileAvatar(
                radius: avatarRadius,
                imageUrl: avatarUrl,
                displayName: avatarDisplayName,
                email: authUser?.email,
                isGuest: isGuest,
                onTap: isGuest ? null : () => context.goClientProfile(),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      greetingLine,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleSmall?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                        color: theme.colorScheme.onSurface,
                        height: 1.2,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DiscHome.greetingSubtitle,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodySmall?.copyWith(
                        fontSize: 11,
                        color: theme.colorScheme.onSurfaceVariant,
                        height: 1.25,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 4),
              _HomeHeaderIconButton(
                icon: Icons.settings_rounded,
                tooltip: DiscHome.settingsTooltip,
                onPressed: () => showClientHomeSettingsSheet(context, ref),
              ),
              const SizedBox(width: 4),
              _HomeHeaderIconButton(
                icon: Icons.notifications_outlined,
                tooltip: DiscHome.notificationsTooltip,
                badgeCount: unreadNotif,
                onPressed: () => showInAppNotificationsSheet(
                  context,
                  ref,
                  audience: InAppNotificationAudience.client,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClientHomeSearchCard(
            controller: _searchController,
            hint: DiscHome.hintSearch,
            searchTooltip: DiscHome.actionSearch,
            onSubmit: _submitSearch,
            onFilter: () => context.goClientSearch(
              query: _searchController.text.trim().isEmpty
                  ? null
                  : _searchController.text.trim(),
            ),
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

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    const size = 36.0;
    const iconSize = 20.0;
    final iconWidget = Icon(icon, size: iconSize);

    return SizedBox(
      width: size,
      height: size,
      child: IconButton(
        tooltip: tooltip,
        onPressed: onPressed,
        style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.surface.withValues(alpha: 0.85),
          foregroundColor: theme.colorScheme.onSurface,
          shape: const CircleBorder(),
          minimumSize: const Size(size, size),
          maximumSize: const Size(size, size),
          padding: EdgeInsets.zero,
        ),
        icon: badgeCount > 0
            ? Badge(
                isLabelVisible: true,
                label: Text(
                  badgeCount > 99 ? '99+' : '$badgeCount',
                  style: const TextStyle(
                    fontSize: 9,
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
      elevation: 1,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.12),
      shape: const CircleBorder(),
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
