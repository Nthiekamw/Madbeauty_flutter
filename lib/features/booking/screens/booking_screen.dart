import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/catalog/service_beaute.dart';
import '../../../router/navigation_extensions.dart';
import '../models/booked_slots_query.dart';
import '../models/booking_slot.dart';
import '../providers/booking_availability_provider.dart';
import '../providers/booking_selection_provider.dart';
import '../providers/booking_services_provider.dart';
import '../providers/booked_slots_provider.dart';
import '../widgets/booking_message.dart';
import '../providers/is_own_prestataire_profile_provider.dart';
import '../widgets/booking_step_one_content.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({super.key, this.prestataireId, this.serviceId});

  final String? prestataireId;
  final String? serviceId;

  @override
  ConsumerState<BookingScreen> createState() => _BookingScreenState();
}

class _BookingScreenState extends ConsumerState<BookingScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      ref
          .read(bookingSelectionProvider.notifier)
          .initialize(serviceId: widget.serviceId);
    });
  }

  @override
  Widget build(BuildContext context) {
    final prestataireId = widget.prestataireId?.trim();
    final selection = ref.watch(bookingSelectionProvider);
    final availabilityRules = ref.watch(bookingAvailabilityRulesProvider);
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
              AsyncLoading() => const Center(
                child: CircularProgressIndicator(),
              ),
              AsyncData(:final value) when value => const BookingMessage(
                icon: Icons.person_outline,
                title: DiscBk.cannotBookOwnTitle,
                message: DiscBk.cannotBookOwnBody,
              ),
              _ => ref
                .watch(bookingActiveServicesProvider(prestataireId))
                .when(
                  loading: () =>
                      const Center(child: CircularProgressIndicator()),
                  error: (_, __) => const BookingMessage(
                    icon: Icons.cloud_off_outlined,
                    title: DiscBk.svcLoadFailTitle,
                    message: DiscBk.svcLoadFailBody,
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

                    return BookingStepOneContent(
                      services: services,
                      selectedService: selectedService,
                      selection: selection,
                      availabilityRules: availabilityRules,
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
