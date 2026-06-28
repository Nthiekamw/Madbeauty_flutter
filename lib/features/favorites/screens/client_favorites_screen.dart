import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/layout/profile_flow_scaffold.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/guest/widgets/guest_account_prompt.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../listing/widgets/catalog/prestataire_catalog_list_card.dart';
import '../providers/client_favorite_catalog_provider.dart';
import '../providers/client_favorite_prestataire_ids_provider.dart';

class ClientFavoritesScreen extends ConsumerWidget {
  const ClientFavoritesScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final user = switch (ref.watch(authNotifierProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final isGuest = ref.watch(isGuestBrowsingProvider);
    final useWeb = DiscoveryResponsive.of(context).useWebSiteLayout;
    final listPadding = useWeb
        ? const EdgeInsets.fromLTRB(20, 16, 20, 28)
        : const EdgeInsets.fromLTRB(16, 4, 16, 28);

    if (user == null || isGuest) {
      return ProfileFlowScaffold(
        title: DiscFavori.screenTitle,
        icon: Icons.bookmark_border_rounded,
        wrapPanel: false,
        body: GuestAccountPrompt(
          icon: Icons.bookmark_border_rounded,
          title: DiscFavori.screenTitle,
          message: DiscFavori.loginRequired,
        ),
      );
    }

    ref.listen(clientFavoritePrestataireIdsProvider, (previous, next) {
      final prevIds = previous?.asData?.value;
      final nextIds = next.asData?.value;
      if (prevIds != nextIds) {
        ref.invalidate(clientFavoriteCatalogProvider);
      }
    });

    final catalogAsync = ref.watch(clientFavoriteCatalogProvider);

    return ProfileFlowScaffold(
      title: DiscFavori.screenTitle,
      icon: Icons.bookmark_border_rounded,
      body: catalogAsync.when(
        loading: () => const DiscoveryListSkeleton(rowCount: 5),
        error: (_, __) => Center(
          child: DiscoveryEmptyState(
            icon: Icons.cloud_off_outlined,
            title: DiscFavori.loadErrorTitle,
            body: DiscFavori.loadErrorBody,
            iconColor: theme.colorScheme.error,
            actionLabel: DiscList.retry,
            onAction: () => ref.invalidate(clientFavoriteCatalogProvider),
          ),
        ),
        data: (entries) {
          if (entries.isEmpty) {
            return Center(
              child: DiscoveryEmptyState(
                icon: Icons.bookmark_border_rounded,
                title: DiscFavori.emptyTitle,
                body: DiscFavori.emptyBody,
                iconColor: theme.colorScheme.primary,
                actionLabel: DiscBk.browsePresta,
                onAction: () => context.goClientSearch(),
              ),
            );
          }

          return ListView.separated(
            padding: listPadding,
            itemCount: entries.length,
            separatorBuilder: (_, __) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              return PrestataireCatalogListCard(entry: entries[index]);
            },
          );
        },
      ),
    );
  }
}

