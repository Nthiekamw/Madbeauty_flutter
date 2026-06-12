import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/guest/widgets/guest_account_prompt.dart';
import '../../../core/models/domain/catalog/service_beaute.dart';
import '../../../router/navigation_extensions.dart';
import '../models/booked_slots_query.dart';
import '../models/booking_slot.dart';
import '../../prestataire/providers/agenda/disponibilite_provider.dart';
import '../providers/booking_availability_provider.dart';
import '../providers/booking_selection_provider.dart';
import '../providers/booking_services_provider.dart';
import '../providers/booked_slots_provider.dart';
import '../widgets/shared/booking_message.dart';
import '../providers/is_own_prestataire_profile_provider.dart';
import '../../../shared/widgets/discovery/content/discovery_detail_skeleton.dart';
import '../widgets/flow/booking_step_one_content.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({
    super.key,
    this.prestataireId,
    this.serviceId,
    this.initialDay,
  });

  final String? prestataireId;
  final String? serviceId;
  /// `YYYY-MM-DD` depuis deep link / notification.
  final String? initialDay;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      final notifier = ref.read(bookingSelectionProvider.notifier);
      notifier.initialize(serviceId: widget.serviceId);
      final day = _parseInitialDay(widget.initialDay);
      if (day != null) {
        notifier.selectDay(day, day);
      }
    });
  }

  DateTime? _parseInitialDay(String? raw) {
    final text = raw?.trim();
    if (text == null || text.length < 10) return null;
    final parts = text.split('-');
    if (parts.length != 3) return null;
    final y = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    final d = int.tryParse(parts[2]);
    if (y == null || m == null || d == null) return null;
    return DateTime(y, m, d);
  }

  @override
  Widget build(BuildContext context) {
    if (ref.watch(isGuestBrowsingProvider)) {
      return Scaffold(
        appBar: AppBar(title: const Text(DiscNav.bookingFlowTitle)),
        body: const GuestAccountPrompt(
          icon: Icons.event_available_outlined,
          title: AuthStrings.guestBookingTitle,
          message: AuthStrings.guestBookingBody,
        ),
      );
    }

    final prestataireId = widget.prestataireId?.trim();
    final selection = ref.watch(bookingSelectionProvider);
    final availabilityAsync = prestataireId == null || prestataireId.isEmpty
        ? null
        : ref.watch(bookingAvailabilityForPrestaProvider(prestataireId));
    final isOwnAsync = prestataireId == null || prestataireId.isEmpty
        ? null
        : ref.watch(isOwnPrestataireProfileProvider(prestataireId));

    return Scaffold(
      appBar: AppBar(title: const Text(DiscNav.bookingFlowTitle)),
      body: prestataireId == null || prestataireId.isEmpty
          ? const BookingMessage(
              icon: Icons.storefront_outlined,
              title: DiscBk.missingPrestaTitle,
              message: DiscBk.missingPrestaBody,
            )
          : switch (isOwnAsync) {
              AsyncLoading() => const DiscoveryDetailSkeleton(),
              AsyncData(:final value) when value => const BookingMessage(
                icon: Icons.person_outline,
                title: DiscBk.cannotBookOwnTitle,
                message: DiscBk.cannotBookOwnBody,
              ),
              _ => ref
                .watch(bookingActiveServicesProvider(prestataireId))
                .when(
                  loading: () => const DiscoveryDetailSkeleton(),
                  error: (_, __) => BookingMessage(
                    icon: Icons.cloud_off_outlined,
                    title: DiscBk.svcLoadFailTitle,
                    message: DiscBk.svcLoadFailBody,
                    actionLabel: DiscList.retry,
                    onAction: () => ref.invalidate(
                      bookingActiveServicesProvider(prestataireId),
                    ),
                  ),
                  data: (services) {
                    if (services.isEmpty) return const _NoServicesMessage();

                    final selectedService = _selectedService(
                      services,
                      selection.selectedServiceId,
                    );
                    _ensureServiceSelected(selectedService);

                    final bookedSlotsAsync = ref.watch(
                      bookedSlotsProvider(
                        BookedSlotsQuery(
                          prestataireId: prestataireId,
                          serviceId: selectedService.id,
                          day: selection.selectedDay,
                        ),
                      ),
                    );
                    final Set<BookingSlot> bookedSlots =
                        switch (bookedSlotsAsync) {
                          AsyncData(:final value) => value,
                          _ => const <BookingSlot>{},
                        };
                    _clearSlotIfBooked(bookedSlots);

                    final rules = switch (availabilityAsync) {
                      AsyncData(:final value) => value,
                      _ => ref.read(bookingAvailabilityRulesProvider),
                    };

                    final creneauxAsync = ref.watch(
                      creneauxDisponiblesProvider((
                        prestataireId: prestataireId,
                        date: selection.selectedDay,
                      )),
                    );
                    final daySlots = switch (creneauxAsync) {
                      AsyncData(:final value) => value
                          .map(
                            (s) => BookingSlot(hour: s.hour, minute: s.minute),
                          )
                          .toList(),
                      _ => const <BookingSlot>[],
                    };

                    return BookingStepOneContent(
                      services: services,
                      selectedService: selectedService,
                      selection: selection,
                      availabilityRules: rules,
                      daySlots: daySlots,
                      daySlotsLoading: creneauxAsync.isLoading,
                      bookedSlots: bookedSlots,
                      bookedSlotsLoading: bookedSlotsAsync.isLoading,
                      canConfirm:
                          selection.selectedServiceId != null &&
                          selection.selectedSlot != null &&
                          !bookedSlotsAsync.isLoading &&
                          !bookedSlots.contains(selection.selectedSlot),
                      onServiceSelected: ref
                          .read(bookingSelectionProvider.notifier)
                          .selectService,
                      onDaySelected: ref
                          .read(bookingSelectionProvider.notifier)
                          .selectDay,
                      onPageChanged: ref
                          .read(bookingSelectionProvider.notifier)
                          .setFocusedDay,
                      onSlotSelected: ref
                          .read(bookingSelectionProvider.notifier)
                          .selectSlot,
                      onContinue: () => _confirmSelection(selectedService),
                      prestataireId: prestataireId,
                    );
                  },
                ),
            },
    );
  }

  ServiceBeaute _selectedService(
    List<ServiceBeaute> services,
    String? selectedServiceId,
  ) {
    final id = selectedServiceId?.trim();
    if (id != null && id.isNotEmpty) {
      for (final service in services) {
        if (service.id == id) return service;
      }
    }
    return services.first;
  }

  void _confirmSelection(ServiceBeaute service) {
    final selection = ref.read(bookingSelectionProvider);
    final slot = selection.selectedSlot;
    if (selection.selectedServiceId == null || slot == null) return;

    final prestataireId = widget.prestataireId?.trim();
    if (prestataireId == null || prestataireId.isEmpty) return;

    context.pushBookingConfirmation(
      prestataireId: prestataireId,
      serviceId: service.id,
      serviceName: service.nom,
      price: service.prix,
      durationMinutes: service.dureeMinutes,
      dateTime: slot.onDay(selection.selectedDay),
    );
  }

  void _ensureServiceSelected(ServiceBeaute service) {
    if (ref.read(bookingSelectionProvider).selectedServiceId != null) return;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref.read(bookingSelectionProvider.notifier).selectService(service.id);
    });
  }

  void _clearSlotIfBooked(Set<BookingSlot> bookedSlots) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(bookingSelectionProvider.notifier)
          .clearSlotIfBooked(bookedSlots);
    });
  }
}

class _NoServicesMessage extends StatelessWidget {
  const _NoServicesMessage();

  @override
  Widget build(BuildContext context) {
    return const BookingMessage(
      icon: Icons.event_busy_outlined,
      title: DiscBk.noSvcsTitle,
      message: DiscBk.noSvcsBody,
    );
  }
}

