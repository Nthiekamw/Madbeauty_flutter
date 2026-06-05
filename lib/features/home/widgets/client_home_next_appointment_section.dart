import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/booking/booking_service_providers.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_avatar.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../booking/logic/booking_formatters.dart';
import '../../booking/logic/client_reservation_lists.dart';
import '../../booking/logic/client_reservation_ui_status.dart';
import 'client_home_section_header.dart';

/// Prochain rendez-vous client sur l'accueil.
class ClientHomeNextAppointmentSection extends ConsumerWidget {
  const ClientHomeNextAppointmentSection({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final reservationsAsync = ref.watch(clientReservationsProvider);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ClientHomeSectionHeader(
          title: DiscHome.nextAppointmentTitle,
          subtitle: DiscHome.nextAppointmentSub,
          actionLabel: DiscHome.nextAppointmentSeeAll,
          onAction: () => context.goMyReservations(),
        ),
        const SizedBox(height: 12),
        reservationsAsync.when(
          loading: () => const Center(
            child: Padding(
              padding: EdgeInsets.all(20),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (_, __) => DiscoveryEmptyState(
            icon: Icons.event_busy_outlined,
            title: DiscHome.nextAppointmentEmptyTitle,
            body: DiscBk.listErrBody,
            actionLabel: DiscList.retry,
            onAction: () => ref.invalidate(clientReservationsProvider),
          ),
          data: (all) {
            final upcoming = clientUpcomingReservations(all);
            if (upcoming.isEmpty) {
              return DiscoverySurfaceCard(
                child: DiscoveryEmptyState(
                  icon: Icons.event_available_outlined,
                  title: DiscHome.nextAppointmentEmptyTitle,
                  body: DiscHome.nextAppointmentEmptyBody,
                  actionLabel: DiscHome.nextAppointmentCta,
                  onAction: () => context.goClientSearch(),
                ),
              );
            }

            final next = upcoming.first;
            final ui = clientReservationUiStatusFromStatut(next.statut);
            final chip = chipColorsForReservationStatus(theme.colorScheme, ui);

            return DiscoverySurfaceCard(
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(14),
                  onTap: () => context.pushClientReservationDetail(next.id),
                  child: Padding(
                    padding: const EdgeInsets.all(14),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppAvatar(
                          imageUrl: next.prestataireAvatarUrl,
                          displayName: next.prestataireName ?? '?',
                          radius: 24,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                next.prestataireName ?? DiscBk.unknownPresta,
                                style: theme.textTheme.titleSmall?.copyWith(
                                  fontFamily: AppFonts.display,
                                  fontWeight: FontWeight.w800,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 4),
                              Text(
                                next.serviceName ?? DiscBk.unknownSvc,
                                style: theme.textTheme.bodySmall?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Icon(
                                    Icons.calendar_today_rounded,
                                    size: 14,
                                    color: theme.colorScheme.primary,
                                  ),
                                  const SizedBox(width: 4),
                                  Expanded(
                                    child: Text(
                                      '${formatBookingDate(next.dateHeure)} · ${formatBookingTime(next.dateHeure)}',
                                      style: theme.textTheme.labelMedium
                                          ?.copyWith(
                                        fontWeight: FontWeight.w600,
                                      ),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 6),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: chip.backgroundColor,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  clientReservationStatusLabel(ui),
                                  style: theme.textTheme.labelSmall?.copyWith(
                                    color: chip.foregroundColor,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Icon(
                          Icons.chevron_right_rounded,
                          color: theme.colorScheme.onSurfaceVariant,
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
}
