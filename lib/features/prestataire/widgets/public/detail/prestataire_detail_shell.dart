import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../core/models/domain/user/prestataire_profile.dart';
import '../../../../../shared/theme/app_colors.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/theme/discovery_styles.dart';
import '../../../../../shared/utils/text_normalizer.dart';
import '../../../../../shared/widgets/app/app_avatar.dart';
import '../../../../../shared/widgets/prestataire/prestataire_favorite_button.dart';
import '../../agenda/prestataire_availability_badge.dart';
import '../prestataire_realisation_carousel_scope.dart';
import '../../../providers/prestataire_response_time_provider.dart';
import '../../../../reviews/providers/prestataire_note_moyenne_provider.dart';

enum PrestataireDetailSection {
  services,
  gallery,
  about,
  reviews,
}

/// Hero photo + actions (partager, signaler, favori).
class PrestataireDetailHero extends StatelessWidget {
  const PrestataireDetailHero({
    super.key,
    required this.prestataireId,
    required this.displayTitle,
    this.avatarUrl,
    required this.isOwnProfile,
    required this.onShare,
    this.onReport,
  });

  final String prestataireId;
  final String displayTitle;
  final String? avatarUrl;
  final bool isOwnProfile;
  final VoidCallback onShare;
  final VoidCallback? onReport;

  static const double expandedHeight = 280;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SliverAppBar(
      expandedHeight: expandedHeight,
      pinned: true,
      stretch: true,
      backgroundColor: theme.colorScheme.surface,
      surfaceTintColor: AppColors.transparent,
      actions: [
        if (onReport != null)
          IconButton(
            icon: const Icon(Icons.flag_outlined),
            tooltip: DiscReport.action,
            onPressed: onReport,
          ),
        IconButton(
          icon: const Icon(Icons.share_outlined),
          tooltip: DiscPrestaDetail.shareTooltip,
          onPressed: onShare,
        ),
        if (!isOwnProfile)
          Padding(
            padding: const EdgeInsets.only(right: 8),
            child: PrestataireFavoriteButton(
              prestataireId: prestataireId,
              style: PrestataireFavoriteButtonStyle.hero,
            ),
          ),
      ],
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground],
        background: Stack(
          fit: StackFit.expand,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                return PrestataireRealisationCarouselScope(
                  prestataireId: prestataireId,
                  height: constraints.maxHeight,
                  fallbackDisplayName: displayTitle,
                  fallbackAvatarUrl: avatarUrl,
                );
              },
            ),
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: const [0.0, 0.45, 1.0],
                  colors: [
                    AppColors.scrimDark25,
                    AppColors.transparent,
                    theme.colorScheme.surface.withValues(alpha: 0.92),
                  ],
                ),
              ),
            ),
            Positioned(
              left: 16,
              bottom: 16,
              child: PrestataireAvailabilityBadge(
                prestataireId: prestataireId,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Carte identité chevauchant le hero : nom, stats, actions rapides.
class PrestataireDetailIdentityCard extends ConsumerWidget {
  const PrestataireDetailIdentityCard({
    super.key,
    required this.profile,
    required this.avatarUrl,
    required this.displayTitle,
    required this.servicesCount,
    required this.isOwnProfile,
    required this.onBook,
    this.onMessage,
  });

  final PrestataireProfile profile;
  final String? avatarUrl;
  final String displayTitle;
  final int servicesCount;
  final bool isOwnProfile;
  final VoidCallback onBook;
  final VoidCallback? onMessage;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    final salon = normalizeSingleLineText(profile.nomSalon);
    final showSalon = salon.isNotEmpty && salon != displayTitle;
    final ville = profile.ville?.trim() ?? '';
    final cp = profile.codePostal?.trim() ?? '';
    final location = [
      if (ville.isNotEmpty) ville,
      if (cp.isNotEmpty) cp,
    ].join(' · ');

    final liveNote = switch (ref.watch(
      prestataireNoteMoyenneProvider(profile.id),
    )) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final rating = liveNote ?? profile.noteMoyenne;
    final respondsQuickly = ref
        .watch(prestataireRespondsQuicklyProvider(profile.id))
        .maybeWhen(data: (v) => v, orElse: () => false);

    return Transform.translate(
      offset: const Offset(0, -20),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: DecoratedBox(
          decoration: BoxDecoration(
            borderRadius: DiscoveryStyles.cardBorderRadius,
            boxShadow: isDark
                ? null
                : [
                    BoxShadow(
                      color: primary.withValues(alpha: 0.1),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
          ),
          child: Material(
            color: theme.colorScheme.surface,
            elevation: isDark ? 2 : 0,
            surfaceTintColor: AppColors.transparent,
            shape: RoundedRectangleBorder(
              borderRadius: DiscoveryStyles.cardBorderRadius,
              side: BorderSide(
                color: theme.colorScheme.outline.withValues(
                  alpha: isDark ? 0.16 : 0.1,
                ),
              ),
            ),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppAvatar(
                        imageUrl: avatarUrl,
                        displayName: displayTitle,
                        radius: 32,
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    displayTitle,
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: theme.textTheme.titleLarge?.copyWith(
                                      fontFamily: AppFonts.display,
                                      fontWeight: FontWeight.w900,
                                      letterSpacing: -0.3,
                                      height: 1.15,
                                    ),
                                  ),
                                ),
                                if (profile.isVerified)
                                  Padding(
                                    padding: const EdgeInsets.only(left: 6),
                                    child: Icon(
                                      Icons.verified_rounded,
                                      size: 20,
                                      color: primary,
                                    ),
                                  ),
                              ],
                            ),
                            if (showSalon) ...[
                              const SizedBox(height: 4),
                              Text(
                                salon,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                            if (location.isNotEmpty) ...[
                              const SizedBox(height: 6),
                              Row(
                                children: [
                                  Icon(
                                    Icons.location_on_rounded,
                                    size: 15,
                                    color: theme.colorScheme.onSurfaceVariant,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      location,
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: theme.textTheme.bodySmall?.copyWith(
                                        color: theme.colorScheme.onSurfaceVariant,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 14),
                  Row(
                    children: [
                      _InlineStat(
                        icon: Icons.star_rounded,
                        iconColor: AppColors.starRating,
                        value: rating != null
                            ? rating.toStringAsFixed(1)
                            : '—',
                        label: DiscPrestaDetail.statRating,
                      ),
                      _divider(theme),
                      _InlineStat(
                        icon: Icons.content_cut_rounded,
                        iconColor: primary,
                        value: '$servicesCount',
                        label: DiscPrestaDetail.statServices,
                      ),
                      if (respondsQuickly) ...[
                        _divider(theme),
                        _InlineStat(
                          icon: Icons.bolt_rounded,
                          iconColor: AppColors.purpleAccent,
                          value: '<2h',
                          label: DiscPrestaDetail.statResponse,
                        ),
                      ],
                    ],
                  ),
                  if (profile.isVerified || respondsQuickly) ...[
                    const SizedBox(height: 12),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: [
                        if (profile.isVerified)
                          _TrustPill(
                            icon: Icons.verified_user_outlined,
                            label: DiscPrestaDetail.badgeVerified,
                            color: primary,
                          ),
                        if (respondsQuickly)
                          _TrustPill(
                            icon: Icons.chat_bubble_outline_rounded,
                            label: DiscPrestaDetail.trustFastResponse,
                            color: AppColors.purpleAccent,
                          ),
                      ],
                    ),
                  ],
                  if (!isOwnProfile) ...[
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: FilledButton.icon(
                            onPressed: onBook,
                            icon: const Icon(
                              Icons.calendar_month_rounded,
                              size: 20,
                            ),
                            label: Text(DiscPrestaDetail.actionBook),
                          ),
                        ),
                        if (onMessage != null) ...[
                          const SizedBox(width: 10),
                          Expanded(
                            flex: 2,
                            child: OutlinedButton.icon(
                              onPressed: onMessage,
                              icon: const Icon(
                                Icons.chat_bubble_outline_rounded,
                                size: 18,
                              ),
                              label: Text(DiscPrestaDetail.contact),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _divider(ThemeData theme) {
    return Container(
      width: 1,
      height: 36,
      margin: const EdgeInsets.symmetric(horizontal: 10),
      color: theme.colorScheme.outline.withValues(alpha: 0.15),
    );
  }
}

class _InlineStat extends StatelessWidget {
  const _InlineStat({
    required this.icon,
    required this.iconColor,
    required this.value,
    required this.label,
  });

  final IconData icon;
  final Color iconColor;
  final String value;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Expanded(
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: iconColor),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _TrustPill extends StatelessWidget {
  const _TrustPill({
    required this.icon,
    required this.label,
    required this.color,
  });

  final IconData icon;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.22)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 14, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

/// Navigation rapide entre sections (épinglée au scroll).
class PrestataireDetailSectionNav extends StatelessWidget {
  const PrestataireDetailSectionNav({
    super.key,
    required this.selected,
    required this.onSelected,
  });

  final PrestataireDetailSection selected;
  final ValueChanged<PrestataireDetailSection> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: theme.colorScheme.surface,
      elevation: 1,
      shadowColor: theme.colorScheme.shadow.withValues(alpha: 0.08),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            _NavChip(
              label: DiscPrestaDetail.navServices,
              icon: Icons.content_cut_rounded,
              selected: selected == PrestataireDetailSection.services,
              onTap: () => onSelected(PrestataireDetailSection.services),
            ),
            const SizedBox(width: 8),
            _NavChip(
              label: DiscPrestaDetail.navGallery,
              icon: Icons.photo_library_outlined,
              selected: selected == PrestataireDetailSection.gallery,
              onTap: () => onSelected(PrestataireDetailSection.gallery),
            ),
            const SizedBox(width: 8),
            _NavChip(
              label: DiscPrestaDetail.navAbout,
              icon: Icons.info_outline_rounded,
              selected: selected == PrestataireDetailSection.about,
              onTap: () => onSelected(PrestataireDetailSection.about),
            ),
            const SizedBox(width: 8),
            _NavChip(
              label: DiscPrestaDetail.navReviews,
              icon: Icons.star_outline_rounded,
              selected: selected == PrestataireDetailSection.reviews,
              onTap: () => onSelected(PrestataireDetailSection.reviews),
            ),
          ],
        ),
      ),
    );
  }
}

class PrestataireDetailSectionNavDelegate extends SliverPersistentHeaderDelegate {
  PrestataireDetailSectionNavDelegate({
    required this.selected,
    required this.onSelected,
  });

  final PrestataireDetailSection selected;
  final ValueChanged<PrestataireDetailSection> onSelected;

  static const double height = 52;

  @override
  double get minExtent => height;

  @override
  double get maxExtent => height;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return PrestataireDetailSectionNav(
      selected: selected,
      onSelected: onSelected,
    );
  }

  @override
  bool shouldRebuild(covariant PrestataireDetailSectionNavDelegate oldDelegate) {
    return oldDelegate.selected != selected;
  }
}

class _NavChip extends StatelessWidget {
  const _NavChip({
    required this.label,
    required this.icon,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Material(
      color: selected
          ? primary.withValues(alpha: 0.12)
          : theme.colorScheme.surfaceContainerHighest.withValues(alpha: 0.65),
      borderRadius: DiscoveryStyles.chipBorderRadius,
      child: InkWell(
        onTap: onTap,
        borderRadius: DiscoveryStyles.chipBorderRadius,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon,
                size: 16,
                color: selected ? primary : theme.colorScheme.onSurfaceVariant,
              ),
              const SizedBox(width: 6),
              Text(
                label,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: selected ? primary : theme.colorScheme.onSurface,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Barre d'action fixe en bas de l'écran.
class PrestataireDetailBottomBar extends StatelessWidget {
  const PrestataireDetailBottomBar({
    super.key,
    required this.minPrice,
    required this.onBook,
  });

  final double? minPrice;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final bottom = MediaQuery.paddingOf(context).bottom;

    return DecoratedBox(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(
            color: theme.colorScheme.outline.withValues(
              alpha: isDark ? 0.2 : 0.12,
            ),
          ),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: theme.colorScheme.shadow.withValues(alpha: 0.06),
                  blurRadius: 16,
                  offset: const Offset(0, -4),
                ),
              ],
      ),
      child: Padding(
        padding: EdgeInsets.fromLTRB(16, 12, 16, 12 + bottom),
        child: Row(
          children: [
            if (minPrice != null) ...[
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    DiscPrestaDetail.fromPrice,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  Text(
                    '${minPrice!.toStringAsFixed(0)} €',
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w900,
                      color: theme.colorScheme.primary,
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 16),
            ],
            Expanded(
              child: FilledButton.icon(
                onPressed: onBook,
                icon: const Icon(Icons.calendar_month_rounded, size: 20),
                label: Text(DiscPrestaDetail.actionBook),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 14),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
