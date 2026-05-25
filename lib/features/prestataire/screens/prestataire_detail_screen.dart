import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/photo_realisation.dart';
import '../../../core/models/domain/catalog/service_beaute.dart';
import '../../../core/models/domain/user/prestataire_profile.dart';
import '../../../router/navigation_extensions.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../booking/providers/is_own_prestataire_profile_provider.dart';
import '../providers/prestataire_detail_provider.dart';

/// Fiche publique d’un prestataire (catalogue client).
class PrestataireDetailScreen extends ConsumerWidget {
  const PrestataireDetailScreen({super.key, required this.prestataireId});

  final String prestataireId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(prestataireDetailProvider(prestataireId));
    final isOwnAsync = ref.watch(isOwnPrestataireProfileProvider(prestataireId));
    final isOwnProfile = isOwnAsync.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(DiscPrestaDetail.screenTitle),
      ),
      body: async.when(
        data: (data) {
          if (data == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  DiscPrestaDetail.missing,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            );
          }
          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              _PrestataireHero(
                profile: data.profile,
                avatarUrl: data.avatarUrl,
                servicesCount: data.services.length,
              ),
              const SizedBox(height: 18),
              _TrustHighlights(isVerified: data.profile.isVerified),
              if (isOwnProfile) ...[
                const SizedBox(height: 16),
                const _OwnProfileBookingBanner(),
              ],
              const SizedBox(height: 16),
              _PrimaryActions(
                canBook: !isOwnProfile,
                onBook: () =>
                    context.pushBooking(prestataireId: data.profile.id),
              ),
              if (data.profile.bio != null &&
                  data.profile.bio!.trim().isNotEmpty) ...[
                const SizedBox(height: 24),
                const _SectionTitle(DiscPrestaDetail.bioTitle),
                const SizedBox(height: 8),
                Text(
                  data.profile.bio!.trim(),
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                ),
              ],
              if (data.specialtyNames.isNotEmpty) ...[
                const SizedBox(height: 24),
                const _SectionTitle(
                  DiscPrestaDetail.specialtiesTitle,
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    for (final name in data.specialtyNames)
                      Chip(label: Text(name)),
                  ],
                ),
              ],
              const SizedBox(height: 24),
              const _SectionTitle(
                DiscPrestaDetail.galleryTitle,
              ),
              const SizedBox(height: 10),
              if (data.photos.isEmpty)
                const _EmptyPhotosCard()
              else
                _RealisationGrid(photos: data.photos),
              const SizedBox(height: 24),
              const _SectionTitle(
                DiscPrestaDetail.svcTitle,
              ),
              const SizedBox(height: 10),
              if (data.services.isEmpty)
                const _EmptyServicesCard()
              else ...[
                for (final service in data.services)
                  _ServiceCard(
                    service: service,
                    canBook: !isOwnProfile,
                    onBook: () => context.pushBooking(
                      prestataireId: data.profile.id,
                      serviceId: service.id,
                    ),
                  ),
                if (!isOwnProfile) ...[
                  const SizedBox(height: 8),
                  FilledButton.icon(
                    onPressed: () =>
                        context.pushBooking(prestataireId: data.profile.id),
                    icon: const Icon(Icons.calendar_month_outlined),
                    label: const Text(DiscPrestaDetail.actionBook),
                  ),
                ],
              ],
              const SizedBox(height: 24),
              const _SectionTitle(
                DiscPrestaDetail.reviewsTitle,
              ),
              const SizedBox(height: 10),
              const _EmptyReviewsCard(),
            ],
          );
        },
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              DiscPrestaDetail.loadErr,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}

class _PrestataireHero extends StatelessWidget {
  const _PrestataireHero({
    required this.profile,
    required this.avatarUrl,
    required this.servicesCount,
  });

  final PrestataireProfile profile;
  final String? avatarUrl;
  final int servicesCount;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final display = profile.nomAffiche?.trim();
    final salon = profile.nomSalon?.trim();
    final title = display != null && display.isNotEmpty
        ? display
        : salon != null && salon.isNotEmpty
        ? salon
        : 'Salon';
    final ville = profile.ville?.trim();
    final cp = profile.codePostal?.trim();
    final adresse = profile.adresse?.trim();
    final locationLine = [
      if (adresse != null && adresse.isNotEmpty) adresse,
      if (cp != null && cp.isNotEmpty) cp,
      if (ville != null && ville.isNotEmpty) ville,
    ].join(', ');

    return Card(
      elevation: 0,
      color: theme.colorScheme.primaryContainer.withValues(alpha: 0.45),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppAvatar(imageUrl: avatarUrl, displayName: title, radius: 48),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: theme.textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w800,
                          color: theme.colorScheme.onPrimaryContainer,
                        ),
                      ),
                      const SizedBox(height: 8),
                      if (locationLine.isNotEmpty)
                        _MetaLine(
                          icon: Icons.place_outlined,
                          text: locationLine,
                        ),
                      const SizedBox(height: 10),
                      Wrap(
                        spacing: 8,
                        runSpacing: 8,
                        children: [
                          _RatingPill(note: profile.noteMoyenne),
                          if (profile.isVerified) const _VerifiedBadge(),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 18),
            Text(
              '$servicesCount service${servicesCount > 1 ? 's' : ''} disponible${servicesCount > 1 ? 's' : ''}',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onPrimaryContainer,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _MetaLine extends StatelessWidget {
  const _MetaLine({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: theme.colorScheme.onPrimaryContainer),
        const SizedBox(width: 6),
        Flexible(
          child: Text(
            text,
            style: theme.textTheme.bodyLarge?.copyWith(
              color: theme.colorScheme.onPrimaryContainer,
            ),
          ),
        ),
      ],
    );
  }
}

class _RatingPill extends StatelessWidget {
  const _RatingPill({required this.note});

  final double? note;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final label = note == null
        ? DiscPrestaDetail.badgeNewTalent
        : note!.toStringAsFixed(1);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(999),
      ),
      child: FittedBox(
        fit: BoxFit.scaleDown,
        alignment: Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (var i = 0; i < 5; i++)
              Icon(
                i < (note ?? 0).round() ? Icons.star : Icons.star_border,
                size: 16,
                color: theme.colorScheme.primary,
              ),
            const SizedBox(width: 6),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _VerifiedBadge extends StatelessWidget {
  const _VerifiedBadge();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Chip(
      avatar: Icon(Icons.verified, size: 18, color: theme.colorScheme.primary),
      label: const Text(DiscPrestaDetail.badgeVerified),
      side: BorderSide(
        color: theme.colorScheme.primary.withValues(alpha: 0.35),
      ),
      backgroundColor: theme.colorScheme.surface,
    );
  }
}

class _TrustHighlights extends StatelessWidget {
  const _TrustHighlights({required this.isVerified});

  final bool isVerified;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: [
        if (isVerified)
          const _TrustChip(
            icon: Icons.verified_user_outlined,
            label: DiscPrestaDetail.trustId,
          ),
        const _TrustChip(
          icon: Icons.sell_outlined,
          label: DiscPrestaDetail.trustPrices,
        ),
        const _TrustChip(
          icon: Icons.calendar_month_outlined,
          label: DiscPrestaDetail.trustBook,
        ),
      ],
    );
  }
}

class _TrustChip extends StatelessWidget {
  const _TrustChip({required this.icon, required this.label});

  final IconData icon;
  final String label;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: theme.colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(14),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 18, color: theme.colorScheme.primary),
          const SizedBox(width: 8),
          Text(label, style: theme.textTheme.labelMedium),
        ],
      ),
    );
  }
}

class _OwnProfileBookingBanner extends StatelessWidget {
  const _OwnProfileBookingBanner();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      color: theme.colorScheme.secondaryContainer.withValues(alpha: 0.55),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.info_outline,
              color: theme.colorScheme.onSecondaryContainer,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                DiscPrestaDetail.ownProfileBookHint,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PrimaryActions extends StatelessWidget {
  const _PrimaryActions({required this.onBook, required this.canBook});

  final VoidCallback onBook;
  final bool canBook;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: FilledButton.icon(
            onPressed: canBook ? onBook : null,
            icon: const Icon(Icons.calendar_month_outlined),
            label: const Text(DiscPrestaDetail.actionBook),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: null,
            icon: const Icon(Icons.chat_bubble_outline),
            label: const Text(DiscPrestaDetail.contact),
          ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: Theme.of(
        context,
      ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

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
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    service.nom,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    '${service.dureeMinutes} min',
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(
                  '${service.prix.toStringAsFixed(2)} €',
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 8),
                FilledButton.tonal(
                  onPressed: canBook ? onBook : null,
                  child: const Text(
                    DiscPrestaDetail.actionBookSvc,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _RealisationGrid extends StatelessWidget {
  const _RealisationGrid({required this.photos});

  final List<PhotoRealisation> photos;

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: photos.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (context, index) {
        final photo = photos[index];
        return ClipRRect(
          borderRadius: BorderRadius.circular(12),
          child: Image.network(
            photo.url,
            fit: BoxFit.cover,
            errorBuilder: (context, error, stackTrace) {
              return ColoredBox(
                color: Theme.of(context).colorScheme.surfaceContainerHighest,
                child: Icon(
                  Icons.broken_image_outlined,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              );
            },
          ),
        );
      },
    );
  }
}

class _EmptyPhotosCard extends StatelessWidget {
  const _EmptyPhotosCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.photo_library_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DiscPrestaDetail.noPhotosTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DiscPrestaDetail.noPhotosBody,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyServicesCard extends StatelessWidget {
  const _EmptyServicesCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DiscPrestaDetail.noSvcsTitle,
              style: theme.textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DiscPrestaDetail.noSvcsBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyReviewsCard extends StatelessWidget {
  const _EmptyReviewsCard();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.rate_review_outlined,
              color: theme.colorScheme.onSurfaceVariant,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DiscPrestaDetail.noReviewsTitle,
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    DiscPrestaDetail.noReviewsBody,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
