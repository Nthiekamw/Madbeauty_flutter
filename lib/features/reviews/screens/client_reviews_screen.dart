import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/discovery/discovery_brand_scaffold.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_feature_header.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/guest/widgets/guest_account_prompt.dart';
import '../../booking/logic/booking_formatters.dart';
import '../models/client_review_list_item.dart';
import '../providers/review_provider.dart';
import '../widgets/edit_review_sheet.dart';
import '../widgets/review_photos_row.dart';

class ClientReviewsScreen extends ConsumerWidget {
  const ClientReviewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (ref.watch(isGuestBrowsingProvider)) {
      return DiscoveryBrandScaffold(
        body: Column(
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: IconButton(
                onPressed: () => context.pop(),
                icon: const Icon(Icons.arrow_back_rounded),
              ),
            ),
            const DiscoveryFeatureHeader(
              title: DiscReview.myReviewsTitle,
              subtitle: DiscReview.myReviewsSubtitle,
              icon: Icons.rate_review_outlined,
            ),
            Expanded(
              child: GuestAccountPrompt(
                icon: Icons.rate_review_outlined,
                title: AuthStrings.guestProfileTitle,
                message: AuthStrings.guestProfileBody,
              ),
            ),
          ],
        ),
      );
    }

    final reviewsAsync = ref.watch(clientReviewsForCurrentClientProvider);

    return DiscoveryBrandScaffold(
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Align(
            alignment: Alignment.centerLeft,
            child: IconButton(
              onPressed: () => context.pop(),
              icon: const Icon(Icons.arrow_back_rounded),
            ),
          ),
          const DiscoveryFeatureHeader(
            title: DiscReview.myReviewsTitle,
            subtitle: DiscReview.myReviewsSubtitle,
            icon: Icons.rate_review_outlined,
          ),
          Expanded(
            child: reviewsAsync.when(
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (_, __) => RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(clientReviewsForCurrentClientProvider);
                  await ref.read(clientReviewsForCurrentClientProvider.future);
                },
                child: ListView(
                  physics: const AlwaysScrollableScrollPhysics(),
                  children: [
                    DiscoveryEmptyState(
                      icon: Icons.cloud_off_outlined,
                      title: DiscBk.listErrTitle,
                      body: DiscBk.listErrBody,
                      iconColor: Theme.of(context).colorScheme.error,
                      actionLabel: DiscList.retry,
                      onAction: () =>
                          ref.invalidate(clientReviewsForCurrentClientProvider),
                    ),
                  ],
                ),
              ),
              data: (items) {
                if (items.isEmpty) {
                  return ListView(
                    children: const [
                      DiscoveryEmptyState(
                        icon: Icons.rate_review_outlined,
                        title: DiscReview.emptyTitle,
                        body: DiscReview.emptyBody,
                      ),
                    ],
                  );
                }

                return RefreshIndicator(
                  onRefresh: () async {
                    ref.invalidate(clientReviewsForCurrentClientProvider);
                    await ref.read(clientReviewsForCurrentClientProvider.future);
                  },
                  child: ListView.separated(
                    physics: const AlwaysScrollableScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
                    itemCount: items.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _ClientReviewCard(
                        item: items[index],
                        onTap: () async {
                          final updated = await showEditReviewSheet(
                            context,
                            item: items[index],
                          );
                          if (updated == true) {
                            ref.invalidate(clientReviewsForCurrentClientProvider);
                          }
                        },
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _ClientReviewCard extends StatelessWidget {
  const _ClientReviewCard({
    required this.item,
    required this.onTap,
  });

  final ClientReviewListItem item;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final prestataireLabel =
        item.prestataireName?.trim().isNotEmpty == true
            ? item.prestataireName!.trim()
            : DiscBk.unknownPresta;
    final serviceLabel = item.serviceName?.trim();
    final reservationDate = item.reservationDate;

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  prestataireLabel,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(5, (i) {
                  final filled = i < item.review.note;
                  return Icon(
                    filled ? Icons.star_rounded : Icons.star_outline_rounded,
                    size: 18,
                    color: filled
                        ? const Color(0xFFFFB800)
                        : theme.colorScheme.outline,
                  );
                }),
              ),
            ],
          ),
          if (serviceLabel != null && serviceLabel.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              serviceLabel,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (reservationDate != null) ...[
            const SizedBox(height: 4),
            Text(
              '${formatBookingDate(reservationDate)} · ${formatBookingTime(reservationDate)}',
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
          ],
          if (item.review.commentaire?.trim().isNotEmpty == true) ...[
            const SizedBox(height: 10),
            Text(
              item.review.commentaire!.trim(),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: theme.textTheme.bodyMedium,
            ),
          ],
          if (item.review.photoUrls.isNotEmpty) ...[
            const SizedBox(height: 10),
            ReviewPhotosRow(urls: item.review.photoUrls),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(
                item.canEdit ? Icons.edit_outlined : Icons.lock_outline,
                size: 16,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  item.canEdit
                      ? (item.daysLeftToEdit != null
                          ? DiscReview.daysLeftToEdit(item.daysLeftToEdit!)
                          : DiscReview.editDeadlineHint)
                      : DiscReview.editExpiredLabel,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.primary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right_rounded,
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ],
          ),
        ],
        ),
      ),
    );
  }
}
