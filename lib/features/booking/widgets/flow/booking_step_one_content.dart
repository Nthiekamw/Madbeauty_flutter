import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../core/models/domain/catalog/service_beaute.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/widgets/discovery/content/discovery_shimmer.dart';
import '../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../logic/booking_formatters.dart';
import '../../models/booking_availability_rules.dart';
import '../../models/booking_selection_state.dart';
import '../../models/booking_slot.dart';
import 'availability_calendar.dart';
import 'booking_continue_button.dart';
import '../shared/booking_section_title.dart';
import 'selected_service_header.dart';
import 'service_choice_card.dart';
import 'booking_waitlist_card.dart';
import '../../../../shared/layout/web_flow_panel.dart';
import 'slot_choice_wrap.dart';

class BookingStepOneContent extends StatelessWidget {
  const BookingStepOneContent({
    super.key,
    required this.services,
    required this.selectedService,
    required this.selection,
    required this.availabilityRules,
    required this.daySlots,
    required this.daySlotsLoading,
    required this.bookedSlots,
    required this.bookedSlotsLoading,
    required this.canConfirm,
    required this.onServiceSelected,
    required this.onDaySelected,
    required this.onPageChanged,
    required this.onSlotSelected,
    required this.onContinue,
    this.prestataireId,
    this.hideServicePicker = false,
    this.packHeaderTitle,
    this.packHeaderLabel,
  });

  final List<ServiceBeaute> services;
  final ServiceBeaute selectedService;
  final BookingSelectionState selection;
  final BookingAvailabilityRules availabilityRules;
  final List<BookingSlot> daySlots;
  final bool daySlotsLoading;
  final Set<BookingSlot> bookedSlots;
  final bool bookedSlotsLoading;
  final bool canConfirm;
  final ValueChanged<String> onServiceSelected;
  final void Function(DateTime selectedDay, DateTime focusedDay) onDaySelected;
  final ValueChanged<DateTime> onPageChanged;
  final ValueChanged<BookingSlot> onSlotSelected;
  final VoidCallback onContinue;
  final String? prestataireId;
  final bool hideServicePicker;
  final String? packHeaderTitle;
  final String? packHeaderLabel;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    final useWeb = layout.useWebSiteLayout;
    final pad = layout.pageHorizontalPadding(flow: true);
    final innerPad = useWeb ? 20.0 : pad;
    final slots = daySlots;

    final listView = ListView(
      padding: EdgeInsets.fromLTRB(innerPad, 12, innerPad, 24),
      children: [
        SelectedServiceHeader(
          service: selectedService,
          overrideLabel: packHeaderLabel,
          overrideTitle: packHeaderTitle,
        ),
        if (!hideServicePicker) ...[
          const SizedBox(height: 16),
          BookingSectionTitle(
            icon: Icons.content_cut_rounded,
            title: DiscBk.stepService,
            subtitle: DiscBk.svcCountLabel(services.length),
          ),
          const SizedBox(height: 8),
          DiscoverySurfaceCard(
            includeHorizontalMargin: false,
            padding: const EdgeInsets.all(10),
            child: Column(
              children: [
                for (var i = 0; i < services.length; i++) ...[
                  if (i > 0) const SizedBox(height: 8),
                  ServiceChoiceCard(
                    service: services[i],
                    selected: services[i].id == selectedService.id,
                    onTap: () => onServiceSelected(services[i].id),
                  ),
                ],
              ],
            ),
          ),
        ],
        const SizedBox(height: 16),
        const BookingSectionTitle(
          icon: Icons.calendar_month_rounded,
          title: DiscBk.stepDate,
          subtitle: DiscBk.stepDateSub,
        ),
        const SizedBox(height: 8),
        DiscoverySurfaceCard(
          includeHorizontalMargin: false,
          padding: const EdgeInsets.all(12),
          child: AvailabilityCalendar(
            rules: availabilityRules,
            focusedDay: selection.focusedDay,
            selectedDay: selection.selectedDay,
            onDaySelected: (selectedDay, focusedDay) {
              if (!availabilityRules.isAvailableDay(selectedDay)) return;
              onDaySelected(selectedDay, focusedDay);
            },
            onPageChanged: onPageChanged,
          ),
        ),
        const SizedBox(height: 16),
        BookingSectionTitle(
          icon: Icons.schedule_rounded,
          title: DiscBk.stepSlots,
          subtitle: formatBookingDate(selection.selectedDay),
        ),
        const SizedBox(height: 8),
        DiscoverySurfaceCard(
          includeHorizontalMargin: false,
          padding: const EdgeInsets.all(12),
          child: _SlotsBody(
            daySlotsLoading: daySlotsLoading,
            slots: slots,
            bookedSlots: bookedSlots,
            bookedSlotsLoading: bookedSlotsLoading,
            selection: selection,
            prestataireId: prestataireId,
            selectedService: selectedService,
            selectedDay: selection.selectedDay,
            onSlotSelected: onSlotSelected,
          ),
        ),
        const SizedBox(height: 20),
        BookingContinueButton(
          enabled: canConfirm,
          selectedSlot: selection.selectedSlot,
          onPressed: onContinue,
        ),
      ],
    );

    return WebFlowPanel(child: listView);
  }
}

class _SlotsBody extends StatelessWidget {
  const _SlotsBody({
    required this.daySlotsLoading,
    required this.slots,
    required this.bookedSlots,
    required this.bookedSlotsLoading,
    required this.selection,
    required this.prestataireId,
    required this.selectedService,
    required this.selectedDay,
    required this.onSlotSelected,
  });

  final bool daySlotsLoading;
  final List<BookingSlot> slots;
  final Set<BookingSlot> bookedSlots;
  final bool bookedSlotsLoading;
  final BookingSelectionState selection;
  final String? prestataireId;
  final ServiceBeaute selectedService;
  final DateTime selectedDay;
  final ValueChanged<BookingSlot> onSlotSelected;

  @override
  Widget build(BuildContext context) {
    if (daySlotsLoading) {
      return DiscoveryShimmer.wrap(
        context: context,
        child: Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(
            8,
            (_) => Container(
              width: 72,
              height: 40,
              decoration: BoxDecoration(
                color: Theme.of(context).colorScheme.surfaceContainerHigh,
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      );
    }

    if (slots.isEmpty) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            DiscBk.noSlotsDay,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  fontSize: 13,
                ),
          ),
          if (prestataireId != null && prestataireId!.trim().isNotEmpty) ...[
            const SizedBox(height: 12),
            BookingWaitlistCard(
              prestataireId: prestataireId!,
              serviceId: selectedService.id,
              day: selectedDay,
            ),
          ],
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        SlotChoiceWrap(
          slots: slots,
          bookedSlots: bookedSlots,
          selectedSlot: selection.selectedSlot,
          onSelected: onSlotSelected,
        ),
        if (bookedSlotsLoading) ...[
          const SizedBox(height: 10),
          const LinearProgressIndicator(),
        ],
      ],
    );
  }
}
