import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_assets.dart';
import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/user/user_profile.dart';
import '../../../services/notifications/in_app_notifications_provider.dart';
import '../../../services/notifications/in_app_notifications_sheet.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../profile/providers/current_user_profile_provider.dart';
import '../models/home_feed_selection.dart';
import '../providers/home_feed_provider.dart';
import '../providers/home_profile_provider.dart';
import 'client_home_search_card.dart';
import 'client_home_settings_sheet.dart';

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
    const topActionSize = 40.0;

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 6, 16, 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: topActionSize,
            child: Row(
              children: [
                SizedBox(
                  width: topActionSize,
                  height: topActionSize,
                  child: IconButton(
                    tooltip: DiscHome.settingsTooltip,
                    onPressed: () =>
                        showClientHomeSettingsSheet(context, ref),
                    icon: const Icon(Icons.settings_rounded, size: 22),
                    style: IconButton.styleFrom(
                      backgroundColor: theme.colorScheme.surfaceContainerHighest
                          .withValues(alpha: 0.65),
                      foregroundColor: theme.colorScheme.onSurface,
                    ),
                  ),
                ),
                Expanded(
                  child: Center(
                    child: Image.asset(
                      AppAssets.logo,
                      height: 18,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                      errorBuilder: (_, __, ___) => Text(
                        CoreStrings.appName,
                        style: theme.textTheme.labelMedium?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w800,
                          color: AppColors.brandBrown,
                        ),
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: topActionSize,
                  height: topActionSize,
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: NotificationBellButton(
                      compact: true,
                      unreadCount: unreadNotif,
                      onPressed: () => showInAppNotificationsSheet(context, ref),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
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
