import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../services/supabase/profile/client_profile_providers.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../providers/slot_waitlist_provider.dart';

class BookingWaitlistCard extends ConsumerWidget {
  const BookingWaitlistCard({
    super.key,
    required this.prestataireId,
    required this.serviceId,
    required this.day,
  });

  final String prestataireId;
  final String serviceId;
  final DateTime day;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final query = (
      prestataireId: prestataireId,
      serviceId: serviceId,
      day: day,
    );
    final activeAsync = ref.watch(slotWaitlistActiveProvider(query));

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.all(14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Icon(
                Icons.notifications_active_outlined,
                color: theme.colorScheme.primary,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  DiscWaitlist.title,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight: FontWeight.w800,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            DiscWaitlist.body,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          activeAsync.when(
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (_, __) => Text(
              DiscWaitlist.err,
              style: TextStyle(color: theme.colorScheme.error),
            ),
            data: (active) => OutlinedButton.icon(
              onPressed: () => _toggle(context, ref, active),
              icon: Icon(active ? Icons.check_circle_outline : Icons.add_alert),
              label: Text(
                active ? DiscWaitlist.ctaActive : DiscWaitlist.cta,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _toggle(
    BuildContext context,
    WidgetRef ref,
    bool active,
  ) async {
    final service = ref.read(slotWaitlistServiceProvider);
    final client = await ref.read(currentClientProfileProvider.future);
    if (service == null || client == null) {
      if (context.mounted) AppSnackBar.error(context, DiscWaitlist.err);
      return;
    }

    try {
      if (active) {
        await service.leave(
          clientId: client.id,
          prestataireId: prestataireId,
          serviceId: serviceId,
          day: day,
        );
        if (context.mounted) {
          AppSnackBar.success(context, DiscWaitlist.removed);
        }
      } else {
        await service.join(
          clientId: client.id,
          prestataireId: prestataireId,
          serviceId: serviceId,
          day: day,
        );
        if (context.mounted) {
          AppSnackBar.success(context, DiscWaitlist.ok);
        }
      }
      ref.invalidate(
        slotWaitlistActiveProvider((
          prestataireId: prestataireId,
          serviceId: serviceId,
          day: day,
        )),
      );
    } catch (_) {
      if (context.mounted) AppSnackBar.error(context, DiscWaitlist.err);
    }
  }
}
