import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../../auth/guest/widgets/guest_account_prompt.dart';
import '../../../core/logic/catalog/pack_booking_duration.dart';
import '../../../core/models/domain/catalog/pack_item_type.dart';
import '../../../core/models/domain/catalog/pack_offre_detail.dart';
import '../../../core/models/domain/catalog/service_beaute.dart';
import '../../../core/models/domain/availability/time_slot.dart';
import '../../../router/navigation_extensions.dart';
import '../logic/pending_booking_intent.dart';
import '../models/booked_slots_query.dart';
import '../models/booking_selection_state.dart';
import '../models/booking_slot.dart';
import '../../prestataire/providers/agenda/disponibilite_provider.dart';
import '../../prestataire/providers/boutique/boutique_providers.dart';
import '../providers/booking_availability_provider.dart';
import '../providers/booking_selection_provider.dart';
import '../providers/booking_services_provider.dart';
import '../providers/booked_slots_provider.dart';
import '../widgets/shared/booking_message.dart';
import '../providers/is_own_prestataire_profile_provider.dart';
import '../../../shared/widgets/discovery/content/discovery_detail_skeleton.dart';
import '../../../shared/layout/web_flow_scaffold.dart';
import '../widgets/flow/booking_step_one_content.dart';

class BookingScreen extends ConsumerStatefulWidget {
  const BookingScreen({
    super.key,
    this.prestataireId,
    this.serviceId,
    this.packId,
    this.initialDay,
  });

  final String? prestataireId;
  final String? serviceId;
  final String? packId;
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
      _syncPendingBookingIntent();
      final notifier = ref.read(bookingSelectionProvider.notifier);
      notifier.initialize(serviceId: widget.serviceId);
      final day = _parseInitialDay(widget.initialDay);
      if (day != null) {
        notifier.selectDay(day, day);
      }
    });
  }

  void _syncPendingBookingIntent() {
    final prestataireId = widget.prestataireId?.trim();
    if (prestataireId == null || prestataireId.isEmpty) {
      unawaited(PendingBookingIntent.clear());
      return;
    }
    if (ref.read(isGuestBrowsingProvider)) {
      unawaited(
        PendingBookingIntent.remember(
          prestataireId: prestataireId,
          serviceId: widget.serviceId,
          packId: widget.packId,
          initialDay: widget.initialDay,
        ),
      );
      return;
    }
    unawaited(PendingBookingIntent.clear());
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

    return WebFlowScaffold(
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
              _ => _buildBookingBody(
                context,
                prestataireId: prestataireId,
                selection: selection,
                availabilityAsync: availabilityAsync,
              ),
            },
    );
  }

  Widget _buildBookingBody(
    BuildContext context, {
    required String prestataireId,
    required BookingSelectionState selection,
    required AsyncValue? availabilityAsync,
  }) {
    final packId = widget.packId?.trim();
    final isPack = packId != null && packId.isNotEmpty;

    if (isPack) {
      final packsAsync = ref.watch(publicPacksOffreDetailProvider(prestataireId));
      return packsAsync.when(
        loading: () => const DiscoveryDetailSkeleton(),
        error: (_, __) => BookingMessage(
          icon: Icons.cloud_off_outlined,
          title: DiscBoutique.packsLoadErr,
          message: DiscBoutique.packsLoadErr,
          actionLabel: DiscList.retry,
          onAction: () =>
              ref.invalidate(publicPacksOffreDetailProvider(prestataireId)),
        ),
        data: (packs) {
          PackOffreDetail? detail;
          for (final p in packs) {
            if (p.pack.id == packId) {
              detail = p;
              break;
            }
          }
          if (detail == null) {
            return const BookingMessage(
              icon: Icons.local_offer_outlined,
              title: DiscBoutique.packBookingUnavailableTitle,
              message: DiscBoutique.packBookingUnavailableBody,
            );
          }
          final servicesById = <String, ServiceBeaute>{};
          // Services hydratés via bookingActiveServices pour le 1er service.
          return ref.watch(bookingActiveServicesProvider(prestataireId)).when(
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
                  for (final s in services) {
                    servicesById[s.id] = s;
                  }
                  final duration = computePackDurationMinutes(
                    items: detail!.items,
                    servicesById: servicesById,
                  );
                  if (duration < 1) {
                    return const BookingMessage(
                      icon: Icons.event_busy_outlined,
                      title: DiscBoutique.packBookingNoServiceTitle,
                      message: DiscBoutique.packBookingNoServiceBody,
                    );
                  }
                  String? firstServiceId;
                  for (final i in detail.items) {
                    if (i.itemType == PackItemType.service &&
                        i.serviceId != null) {
                      firstServiceId = i.serviceId;
                      break;
                    }
                  }
                  ServiceBeaute? anchor;
                  if (firstServiceId != null) {
                    anchor = servicesById[firstServiceId];
                  }
                  anchor ??= services.isNotEmpty
                      ? services.first
                      : ServiceBeaute(
                          id: firstServiceId ?? 'pack',
                          prestataireId: prestataireId,
                          nom: detail.pack.titre,
                          dureeMinutes: duration,
                          prix: detail.pack.prixPack,
                        );
                  final displayService = ServiceBeaute(
                    id: anchor.id,
                    prestataireId: prestataireId,
                    nom: detail.pack.titre,
                    dureeMinutes: duration,
                    prix: detail.pack.prixPack,
                    description: detail.pack.description,
                    isActif: true,
                  );
                  _ensureServiceSelected(displayService);
                  return _buildStepContent(
                    prestataireId: prestataireId,
                    selection: selection,
                    availabilityAsync: availabilityAsync,
                    services: [displayService],
                    selectedService: displayService,
                    durationMinutes: duration,
                    hideServicePicker: true,
                    packHeaderTitle: detail.pack.titre,
                    packHeaderLabel: DiscBoutique.packBookingHeaderLabel,
                    onContinue: () {
                      final sel = ref.read(bookingSelectionProvider);
                      final slot = sel.selectedSlot;
                      if (slot == null) return;
                      context.pushBookingConfirmation(
                        prestataireId: prestataireId,
                        serviceId: displayService.id,
                        serviceName: detail!.pack.titre,
                        price: detail.pack.prixPack,
                        durationMinutes: duration,
                        dateTime: slot.onDay(sel.selectedDay),
                        packId: packId,
                      );
                    },
                  );
                },
              );
        },
      );
    }

    return ref.watch(bookingActiveServicesProvider(prestataireId)).when(
          loading: () => const DiscoveryDetailSkeleton(),
          error: (_, __) => BookingMessage(
            icon: Icons.cloud_off_outlined,
            title: DiscBk.svcLoadFailTitle,
            message: DiscBk.svcLoadFailBody,
            actionLabel: DiscList.retry,
            onAction: () =>
                ref.invalidate(bookingActiveServicesProvider(prestataireId)),
          ),
          data: (services) {
            if (services.isEmpty) return const _NoServicesMessage();
            final selectedService = _selectedService(
              services,
              selection.selectedServiceId,
            );
            _ensureServiceSelected(selectedService);
            return _buildStepContent(
              prestataireId: prestataireId,
              selection: selection,
              availabilityAsync: availabilityAsync,
              services: services,
              selectedService: selectedService,
              durationMinutes: selectedService.dureeMinutes,
              hideServicePicker: false,
              onContinue: () => _confirmSelection(selectedService),
            );
          },
        );
  }

  Widget _buildStepContent({
    required String prestataireId,
    required BookingSelectionState selection,
    required AsyncValue? availabilityAsync,
    required List<ServiceBeaute> services,
    required ServiceBeaute selectedService,
    required int durationMinutes,
    required bool hideServicePicker,
    required VoidCallback onContinue,
    String? packHeaderTitle,
    String? packHeaderLabel,
  }) {
    final bookedSlotsAsync = ref.watch(
      bookedSlotsProvider(
        BookedSlotsQuery(
          prestataireId: prestataireId,
          serviceId: selectedService.id,
          day: selection.selectedDay,
        ),
      ),
    );
    final Set<BookingSlot> bookedSlots = switch (bookedSlotsAsync) {
      AsyncData(:final value) => value,
      _ => const <BookingSlot>{},
    };
    _clearSlotIfBooked(bookedSlots);

    final rules = switch (availabilityAsync) {
      AsyncData(:final value) => value,
      _ => ref.read(bookingAvailabilityRulesProvider),
    };

    final creneauxAsync = ref.watch(
      creneauxAffichageProvider((
        prestataireId: prestataireId,
        date: selection.selectedDay,
        durationMinutes: durationMinutes > 0 ? durationMinutes : null,
      )),
    );
    final daySlots = _mergeDaySlots(
      creneauxAsync: creneauxAsync,
      bookedSlots: bookedSlots,
      day: selection.selectedDay,
    );

    return BookingStepOneContent(
      services: services,
      selectedService: selectedService,
      selection: selection,
      availabilityRules: rules,
      daySlots: daySlots,
      daySlotsLoading: creneauxAsync.isLoading,
      bookedSlots: bookedSlots,
      bookedSlotsLoading: bookedSlotsAsync.isLoading,
      canConfirm: selection.selectedSlot != null &&
          !bookedSlotsAsync.isLoading &&
          !bookedSlots.contains(selection.selectedSlot),
      onServiceSelected: ref.read(bookingSelectionProvider.notifier).selectService,
      onDaySelected: ref.read(bookingSelectionProvider.notifier).selectDay,
      onPageChanged: ref.read(bookingSelectionProvider.notifier).setFocusedDay,
      onSlotSelected: ref.read(bookingSelectionProvider.notifier).selectSlot,
      onContinue: onContinue,
      prestataireId: prestataireId,
      hideServicePicker: hideServicePicker,
      packHeaderTitle: packHeaderTitle,
      packHeaderLabel: packHeaderLabel,
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

  List<BookingSlot> _mergeDaySlots({
    required AsyncValue<List<TimeSlot>> creneauxAsync,
    required Set<BookingSlot> bookedSlots,
    required DateTime day,
  }) {
    final fromPlanning = switch (creneauxAsync) {
      AsyncData(:final value) => value
          .map((s) => BookingSlot(hour: s.hour, minute: s.minute))
          .toList(),
      _ => const <BookingSlot>[],
    };
    final now = DateTime.now();
    final visibleBooked = bookedSlots.where((slot) {
      final at = slot.onDay(day);
      final dayOnly = DateTime(day.year, day.month, day.day);
      final todayOnly = DateTime(now.year, now.month, now.day);
      if (dayOnly.isBefore(todayOnly)) return false;
      if (dayOnly.isAfter(todayOnly)) return true;
      return !at.isBefore(now);
    });
    final merged = <BookingSlot>{...fromPlanning, ...visibleBooked}.toList()
      ..sort((a, b) {
        final h = a.hour.compareTo(b.hour);
        return h != 0 ? h : a.minute.compareTo(b.minute);
      });
    return merged;
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

