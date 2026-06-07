import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/layout/discovery_responsive.dart';
import '../../../shared/theme/app_fonts.dart';
import '../models/client_home_section_id.dart';
import '../providers/client_home_layout_provider.dart';
import 'client_home_explore_row.dart';
import 'client_home_feed_prestataires_section.dart';
import 'client_home_layout_sheet.dart';
import 'client_home_nearby_prestataires_section.dart';
import 'client_home_next_appointment_section.dart';
import 'client_home_top_rated_prestataires_section.dart';

/// Sections accueil client dans l'ordre personnalisé.
class ClientHomeReorderableSections extends ConsumerWidget {
  const ClientHomeReorderableSections({
    super.key,
    this.footer,
  });

  final Widget? footer;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final pad = DiscoveryResponsive.of(context).horizontalPadding;
    final layout = ref.watch(clientHomeLayoutProvider);
    final isLoggedIn = clientHomeIsLoggedIn(ref);
    final hasSupabase = AppConfig.hasSupabase;
    final hasFeedSelection = clientHomeHasFeedSelection(ref);

    final visible = visibleClientHomeSections(
      layout: layout,
      isLoggedIn: isLoggedIn,
      hasSupabase: hasSupabase,
      hasFeedSelection: hasFeedSelection,
    );

    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: ListView(
        padding: EdgeInsets.fromLTRB(pad, 4, pad, 32),
        children: [
        Align(
          alignment: Alignment.centerRight,
          child: TextButton.icon(
            onPressed: () => showClientHomeLayoutSheet(context, ref),
            icon: const Icon(Icons.tune_rounded, size: 18),
            label: Text(DiscHome.layoutOrganizeAction),
            style: TextButton.styleFrom(
              visualDensity: VisualDensity.compact,
              padding: const EdgeInsets.symmetric(horizontal: 8),
            ),
          ),
        ),
        const SizedBox(height: 4),
        for (var i = 0; i < visible.length; i++) ...[
          _sectionFor(visible[i]),
          if (i < visible.length - 1) const SizedBox(height: 28),
        ],
        if (!hasSupabase) ...[
          const SizedBox(height: 28),
          _SupabaseConfigCard(theme: Theme.of(context)),
        ],
        if (footer != null) ...[
          const SizedBox(height: 20),
          footer!,
        ],
        ],
      ),
    );
  }

  Widget _sectionFor(ClientHomeSectionId id) {
    return switch (id) {
      ClientHomeSectionId.nextAppointment =>
        const ClientHomeNextAppointmentSection(),
      ClientHomeSectionId.inspiration => const ClientHomeExploreRow(),
      ClientHomeSectionId.feed => const ClientHomeFeedPrestatairesSection(),
      ClientHomeSectionId.nearby =>
        const ClientHomeNearbyPrestatairesSection(),
      ClientHomeSectionId.topRated =>
        const ClientHomeTopRatedPrestatairesSection(),
    };
  }
}

class _SupabaseConfigCard extends StatelessWidget {
  const _SupabaseConfigCard({required this.theme});

  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(18),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              ShellStrings.supabaseMissingTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              ShellStrings.supabaseMissingBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.4,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
