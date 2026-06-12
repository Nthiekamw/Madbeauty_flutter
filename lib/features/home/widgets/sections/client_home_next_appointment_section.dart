import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../services/supabase/booking/booking_service_providers.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../../../../shared/widgets/discovery/content/discovery_shimmer.dart';
import '../catalog/prestataire_catalog_section_empty.dart';
import '../shared/client_home_section_header.dart';
import '../../../booking/logic/booking_formatters.dart';
import '../../../booking/logic/client_reservation_lists.dart';

/// Prochains rendez-vous client sur l'accueil.
class ClientHomeNextAppointmentSection extends ConsumerWidget {
  const ClientHomeNextAppointmentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final reservationsAsync = ref.watch(clientReservationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClientHomeSectionHeader(
          title: DiscHome.nextAppointmentTitle,
          compact: true,
          actionLabel: DiscHome.nextAppointmentSeeAll,
          onAction: () => context.goMyReservations(),
        ),
        const SizedBox(height: 8),
        reservationsAsync.when(
          loading: () => DiscoveryShimmer.wrap(
            context: context,
            child: Container(
              height: 64,
              decoration: BoxDecoration(
                color: theme.colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(14),
              ),
            ),
          ),
          error: (_, __) => DiscoverySectionError(
            message: DiscBk.listErrBody,
            onRetry: () => ref.invalidate(clientReservationsProvider),
          ),
          data: (all) {
            final upcoming = clientUpcomingReservations(all);
            if (upcoming.isEmpty) {
              return PrestataireCatalogSectionEmpty(
                compact: true,
                icon: Icons.event_available_outlined,
                title: DiscHome.nextAppointmentEmptyTitle,
                body: DiscHome.nextAppointmentEmptyBody,
                actionLabel: DiscHome.nextAppointmentCta,
                onAction: () => context.goClientSearch(),
              );
            }

            final next = upcoming.first;
            final dateLabel = _capitalize(formatBookingDate(next.dateHeure));
            final timeLabel = formatBookingTime(next.dateHeure);
            final salon = next.prestataireName ?? DiscBk.unknownPresta;

            return Material(
              color: AppColors.cardSurfaceFor(theme.brightness),
              elevation: 0,
              borderRadius: BorderRadius.circular(14),
              child: InkWell(
                borderRadius: BorderRadius.circular(14),
                onTap: () => context.pushClientReservationDetail(next.id),
                child: Ink(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(
                      color: theme.colorScheme.outline.withValues(
                        alpha: isDark ? 0.28 : 0.1,
                      ),
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        Container(
                          width: 38,
                          height: 38,
                          decoration: BoxDecoration(
                            color: isDark
                                ? AppColors.clientAppointmentIconBgDark
                                : AppColors.clientAppointmentIconBg,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Icon(
                            Icons.calendar_month_outlined,
                            color: theme.colorScheme.primary,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '$dateLabel · $timeLabel',
                                style: theme.textTheme.labelLarge?.copyWith(
                                  fontFamily: AppFonts.display,
                                  fontWeight: FontWeight.w800,
                                  fontSize: 12,
                                  color: theme.colorScheme.onSurface,
                                ),
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 2),
                              Text(
                                'chez $salon',
                                style: theme.textTheme.bodySmall?.copyWith(
                                  fontSize: 11,
                                  color: theme.colorScheme.onSurfaceVariant,
                                  height: 1.2,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 6),
                        TextButton(
                          onPressed: () =>
                              context.pushClientReservationDetail(next.id),
                          style: TextButton.styleFrom(
                            foregroundColor: theme.colorScheme.primary,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            minimumSize: Size.zero,
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                            textStyle: theme.textTheme.labelSmall?.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 11,
                            ),
                          ),
                          child: Text(DiscHome.nextAppointmentDetails),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  String _capitalize(String value) {
    if (value.isEmpty) return value;
    return '${value[0].toUpperCase()}${value.substring(1)}';
  }
}
