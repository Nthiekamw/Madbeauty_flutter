import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../core/models/domain/catalog/service_beaute.dart';
import '../../../core/models/domain/user/prestataire_profile.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../booking/providers/is_own_prestataire_profile_provider.dart';
import '../providers/prestataire_detail_provider.dart';
import '../widgets/prestataire_client_experience_section.dart';

class PrestataireDetailScreen extends ConsumerWidget {
  const PrestataireDetailScreen({super.key, required this.prestataireId});

  final String prestataireId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(prestataireDetailProvider(prestataireId));
    final isOwnAsync = ref.watch(isOwnPrestataireProfileProvider(prestataireId));
    final isOwnProfile = isOwnAsync.maybeWhen(data: (v) => v, orElse: () => false);
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.surface,
      body: async.when(
        data: (data) {
          if (data == null) {
            return Scaffold(
              appBar: AppBar(title: Text(DiscPrestaDetail.screenTitle)),
              body: Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(DiscPrestaDetail.missing, textAlign: TextAlign.center),
                ),
              ),
            );
          }

          return CustomScrollView(
            slivers: [
              _DetailSliverAppBar(
                profile: data.profile,
                avatarUrl: data.avatarUrl,
                isOwnProfile: isOwnProfile,
                onBook: () => context.pushBooking(prestataireId: data.profile.id),
              ),
              SliverToBoxAdapter(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Stats rapides
                    _QuickStatsRow(
                      profile: data.profile,
                      servicesCount: data.services.length,
                    ),
                    // Badges confiance
                    _TrustBar(isVerified: data.profile.isVerified),
                    // Bannière profil propre
                    if (isOwnProfile)
                      _OwnProfileBanner(),
                    // Bio
                    if (data.profile.bio?.trim().isNotEmpty == true)
                      _Section(
                        icon: Icons.person_outline_rounded,
                        title: DiscPrestaDetail.bioTitle,
                        child: Text(
                          data.profile.bio!.trim(),
                          style: theme.textTheme.bodyLarge?.copyWith(height: 1.55),
                        ),
                      ),
                    // Confort & conditions
                    PrestataireClientExperienceSection(
                      comfortIds: data.profile.confortClient,
                      conditionIds: data.profile.conditionsService,
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                    ),
                    if (data.profile.confortClient.isNotEmpty ||
                        data.profile.conditionsService.isNotEmpty)
                      const SizedBox(height: 8),
                    // Spécialités
                    if (data.specialtyNames.isNotEmpty)
                      _Section(
                        icon: Icons.auto_awesome_rounded,
                        title: DiscPrestaDetail.specialtiesTitle,
                        child: Wrap(
                          spacing: 8,
                          runSpacing: 8,
                          children: [
                            for (final name in data.specialtyNames)
                              _SpecialtyTag(name: name),
                          ],
                        ),
                      ),
                    // Galerie
                    _Section(
                      icon: Icons.photo_library_outlined,
                      title: DiscPrestaDetail.galleryTitle,
                      child: data.photos.isEmpty
                          ? _EmptyCard(
                              icon: Icons.photo_library_outlined,
                              title: DiscPrestaDetail.noPhotosTitle,
                              body: DiscPrestaDetail.noPhotosBody,
                            )
                          : _RealisationGrid(photos: data.photos),
                    ),
                    // Services
                    _Section(
                      icon: Icons.content_cut_rounded,
                      title: DiscPrestaDetail.svcTitle,
                      child: data.services.isEmpty
                          ? _EmptyCard(
                              icon: Icons.event_busy_outlined,
                              title: DiscPrestaDetail.noSvcsTitle,
                              body: DiscPrestaDetail.noSvcsBody,
                            )
                          : Column(
                              children: [
                                for (final service in data.services)
                                  _ServiceCard(
                                    service: service,
                                    canBook: !isOwnProfile,
                                    onBook: () => context.pushBooking(
                                      prestataireId: data.profile.id,
                                      serviceId: service.id,
                                    ),
                                  ),
                              ],
                            ),
                    ),
                    // Avis
                    _Section(
                      icon: Icons.star_outline_rounded,
                      title: DiscPrestaDetail.reviewsTitle,
                      child: _EmptyCard(
                        icon: Icons.rate_review_outlined,
                        title: DiscPrestaDetail.noReviewsTitle,
                        body: DiscPrestaDetail.noReviewsBody,
                      ),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ],
          );
        },
        error: (_, __) => Scaffold(
          appBar: AppBar(title: Text(DiscPrestaDetail.screenTitle)),
          body: Center(
            child: Text(
              DiscPrestaDetail.loadErr,
              style: theme.textTheme.bodyLarge?.copyWith(color: theme.colorScheme.error),
            ),
          ),
        ),
        loading: () => Scaffold(
          appBar: AppBar(title: Text(DiscPrestaDetail.screenTitle)),
          body: const Center(child: CircularProgressIndicator()),
        ),
      ),
    );
  }
}

// ─── SliverAppBar hero ────────────────────────────────────────────────────────

class _DetailSliverAppBar extends StatelessWidget {
  const _DetailSliverAppBar({
    required this.profile,
    required this.avatarUrl,
    required this.isOwnProfile,
    required this.onBook,
  });

  final PrestataireProfile profile;
  final String? avatarUrl;
  final bool isOwnProfile;
  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;
    final tertiary = theme.colorScheme.tertiary;

    final display = profile.nomAffiche?.trim();
    final salon = profile.nomSalon?.trim();
    final title = (display?.isNotEmpty == true)
        ? display!
        : (salon?.isNotEmpty == true)
            ? salon!
            : 'Salon';
    final ville = profile.ville?.trim() ?? '';
    final cp = profile.codePostal?.trim() ?? '';
    final adresse = profile.adresse?.trim() ?? '';
    final locationParts = [
      if (adresse.isNotEmpty) adresse,
      if (cp.isNotEmpty) cp,
      if (ville.isNotEmpty) ville,
    ];
    final locationLine = locationParts.join(', ');

    return SliverAppBar(
      expandedHeight: 260,
      pinned: true,
      stretch: true,
      backgroundColor: theme.colorScheme.surface,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
        background: Stack(
          fit: StackFit.expand,
          children: [
            // Fond dégradé
            DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  stops: const [0.0, 0.5, 1.0],
                  colors: [
                    primary.withValues(alpha: isDark ? 0.55 : 0.75),
                    theme.colorScheme.primaryContainer.withValues(
                      alpha: isDark ? 0.65 : 0.9,
                    ),
                    tertiary.withValues(alpha: isDark ? 0.3 : 0.4),
                  ],
                ),
              ),
            ),
            // Contenu
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 56, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        // Avatar avec ring
                        Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.white.withValues(alpha: 0.35),
                              width: 3,
                            ),
                            boxShadow: [
                              BoxShadow(
                                color: primary.withValues(alpha: 0.3),
                                blurRadius: 18,
                                offset: const Offset(0, 6),
                              ),
                            ],
                          ),
                          child: AppAvatar(
                            imageUrl: avatarUrl,
                            displayName: title,
                            radius: 44,
                          ),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              if (profile.isVerified)
                                Container(
                                  margin: const EdgeInsets.only(bottom: 6),
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 3,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white.withValues(alpha: 0.2),
                                    borderRadius: BorderRadius.circular(20),
                                    border: Border.all(
                                      color: Colors.white.withValues(alpha: 0.35),
                                    ),
                                  ),
                                  child: Row(
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      const Icon(Icons.verified_rounded,
                                          size: 12, color: Colors.white),
                                      const SizedBox(width: 4),
                                      Text(
                                        DiscPrestaDetail.badgeVerified,
                                        style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w700,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              Text(
                                title,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: theme.textTheme.headlineSmall?.copyWith(
                                  fontFamily: AppFonts.display,
                                  fontWeight: FontWeight.w900,
                                  color: Colors.white,
                                  letterSpacing: -0.5,
                                  height: 1.1,
                                  shadows: [
                                    Shadow(
                                      color: Colors.black.withValues(alpha: 0.25),
                                      blurRadius: 8,
                                    ),
                                  ],
                                ),
                              ),
                              if (locationLine.isNotEmpty) ...[
                                const SizedBox(height: 6),
                                Row(
                                  children: [
                                    const Icon(Icons.location_on_rounded,
                                        size: 14, color: Colors.white70),
                                    const SizedBox(width: 4),
                                    Flexible(
                                      child: Text(
                                        locationLine,
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                        style: const TextStyle(
                                          color: Colors.white70,
                                          fontSize: 13,
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
                    const SizedBox(height: 18),
                    // Boutons CTA dans le hero
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: _HeroCta(
                            label: DiscPrestaDetail.actionBook,
                            icon: Icons.calendar_month_rounded,
                            filled: true,
                            onPressed: isOwnProfile ? null : onBook,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          flex: 2,
                          child: _HeroCta(
                            label: DiscPrestaDetail.contact,
                            icon: Icons.chat_bubble_outline_rounded,
                            filled: false,
                            onPressed: null,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HeroCta extends StatelessWidget {
  const _HeroCta({
    required this.label,
    required this.icon,
    required this.filled,
    required this.onPressed,
  });

  final String label;
  final IconData icon;
  final bool filled;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    if (filled) {
      return FilledButton.icon(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          backgroundColor: Colors.white,
          foregroundColor: theme.colorScheme.primary,
          padding: const EdgeInsets.symmetric(vertical: 12),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
        icon: Icon(icon, size: 18),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.w700),
        ),
      );
    }

    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.white,
        side: BorderSide(color: Colors.white.withValues(alpha: 0.6)),
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
      ),
      icon: Icon(icon, size: 18),
      label: Text(
        label,
        style: const TextStyle(fontWeight: FontWeight.w600),
      ),
    );
  }
}

// ─── Stats rapides ────────────────────────────────────────────────────────────

class _QuickStatsRow extends StatelessWidget {
  const _QuickStatsRow({required this.profile, required this.servicesCount});

  final PrestataireProfile profile;
  final int servicesCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final rating = profile.noteMoyenne;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Row(
        children: [
          _StatBox(
            value: rating != null ? rating.toStringAsFixed(1) : '—',
            label: 'Note',
            icon: Icons.star_rounded,
            iconColor: const Color(0xFFF59E0B),
            theme: theme,
          ),
          const SizedBox(width: 10),
          _StatBox(
            value: '$servicesCount',
            label: 'Services',
            icon: Icons.content_cut_rounded,
            iconColor: theme.colorScheme.primary,
            theme: theme,
          ),
          const SizedBox(width: 10),
          _StatBox(
            value: profile.isVerified ? 'Oui' : 'Non',
            label: 'Vérifié',
            icon: Icons.verified_rounded,
            iconColor: profile.isVerified
                ? theme.colorScheme.primary
                : theme.colorScheme.onSurfaceVariant,
            theme: theme,
          ),
        ],
      ),
    );
  }
}

class _StatBox extends StatelessWidget {
  const _StatBox({
    required this.value,
    required this.label,
    required this.icon,
    required this.iconColor,
    required this.theme,
  });

  final String value;
  final String label;
  final IconData icon;
  final Color iconColor;
  final ThemeData theme;

  @override
  Widget build(BuildContext context) {
    final isDark = theme.brightness == Brightness.dark;
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.14 : 0.1),
          ),
          boxShadow: isDark
              ? null
              : [
                  BoxShadow(
                    color: iconColor.withValues(alpha: 0.07),
                    blurRadius: 8,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Column(
          children: [
            Icon(icon, size: 20, color: iconColor),
            const SizedBox(height: 6),
            Text(
              value,
              style: theme.textTheme.titleMedium?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w800,
              ),
            ),
            Text(
              label,
              style: theme.textTheme.labelSmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Trust bar ────────────────────────────────────────────────────────────────

class _TrustBar extends StatelessWidget {
  const _TrustBar({required this.isVerified});
  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: [
          if (isVerified)
            _TrustChip(
              icon: Icons.verified_user_outlined,
              label: DiscPrestaDetail.trustId,
              color: Theme.of(context).colorScheme.primary,
            ),
          _TrustChip(
            icon: Icons.sell_outlined,
            label: DiscPrestaDetail.trustPrices,
            color: const Color(0xFF10B981),
          ),
          _TrustChip(
            icon: Icons.calendar_month_outlined,
            label: DiscPrestaDetail.trustBook,
            color: const Color(0xFF0EA5E9),
          ),
        ],
      ),
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({
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
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 15, color: color),
          const SizedBox(width: 6),
          Text(
            label,
            style: Theme.of(context).textTheme.labelMedium?.copyWith(
              fontFamily: AppFonts.body,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Bannière profil propre ───────────────────────────────────────────────────

class _OwnProfileBanner extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: theme.colorScheme.secondary.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: [
            Icon(Icons.info_rounded,
                color: theme.colorScheme.secondary, size: 20),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DiscPrestaDetail.ownProfileBookHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                  height: 1.4,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Section générique ────────────────────────────────────────────────────────

class _Section extends StatelessWidget {
  const _Section({
    required this.icon,
    required this.title,
    required this.child,
  });

  final IconData icon;
  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: primary.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(icon, size: 17, color: primary),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.2,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          child,
        ],
      ),
    );
  }
}

// ─── Spécialités ─────────────────────────────────────────────────────────────

class _SpecialtyTag extends StatelessWidget {
  const _SpecialtyTag({required this.name});
  final String name;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Text(
        name,
        style: theme.textTheme.labelMedium?.copyWith(
          fontFamily: AppFonts.body,
          fontWeight: FontWeight.w600,
          color: primary,
        ),
      ),
    );
  }
}

// ─── Service card ─────────────────────────────────────────────────────────────

class _ServiceCard extends StatelessWidget {
  const _ServiceCard({
    required this.service,
    required this.onBook,
    required this.canBook,
  });

  final ServiceBeaute service;
  final VoidCallback onBook;
  final bool canBook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final primary = theme.colorScheme.primary;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: primary.withValues(alpha: isDark ? 0.12 : 0.09),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: primary.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(16),
        child: InkWell(
          onTap: canBook ? onBook : null,
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: primary.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(Icons.content_cut_rounded,
                      size: 20, color: primary),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.nom,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontFamily: AppFonts.display,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(Icons.schedule_rounded,
                              size: 13,
                              color: theme.colorScheme.onSurfaceVariant),
                          const SizedBox(width: 4),
                          Text(
                            '${service.dureeMinutes} min',
                            style: theme.textTheme.bodySmall?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      '${service.prix.toStringAsFixed(0)} €',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontFamily: AppFonts.display,
                        fontWeight: FontWeight.w900,
                        color: primary,
                      ),
                    ),
                    const SizedBox(height: 6),
                    if (canBook)
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 5),
                        decoration: BoxDecoration(
                          color: primary,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          DiscPrestaDetail.actionBookSvc,
                          style: TextStyle(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                            fontSize: 12,
                            color: theme.colorScheme.onPrimary,
                          ),
                        ),
                      ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Galerie ──────────────────────────────────────────────────────────────────

class _RealisationGrid extends StatelessWidget {
  const _RealisationGrid({required this.photos});
  final List<PhotoRealisation> photos;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        const spacing = 6.0;
        final itemW = (constraints.maxWidth - spacing * 2) / 3;
        return Wrap(
          spacing: spacing,
          runSpacing: spacing,
          children: photos.map((photo) {
            return ClipRRect(
              borderRadius: BorderRadius.circular(12),
              child: SizedBox(
                width: itemW,
                height: itemW,
                child: Image.network(
                  photo.url,
                  fit: BoxFit.cover,
                  errorBuilder: (_, __, ___) => ColoredBox(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    child: Icon(
                      Icons.broken_image_outlined,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        );
      },
    );
  }
}

// ─── Empty states ─────────────────────────────────────────────────────────────

class _EmptyCard extends StatelessWidget {
  const _EmptyCard({
    required this.icon,
    required this.title,
    required this.body,
  });

  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerLowest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.1),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHighest,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(icon,
                size: 22, color: theme.colorScheme.onSurfaceVariant),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  body,
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
