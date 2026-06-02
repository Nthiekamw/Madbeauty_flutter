import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/booking/slot_waitlist_service.dart';
import '../../../services/supabase/profile/client_profile_providers.dart';
import '../../../core/config/app_config.dart';
import '../../../services/supabase/supabase_service.dart';

final slotWaitlistServiceProvider = Provider<SlotWaitlistService?>((ref) {
  if (!AppConfig.hasSupabase) return null;
  return SlotWaitlistService(SupabaseService.client);
});

typedef SlotWaitlistQuery = ({
  String prestataireId,
  String serviceId,
  DateTime day,
});

final slotWaitlistActiveProvider = FutureProvider.autoDispose
    .family<bool, SlotWaitlistQuery>((ref, query) async {
      final service = ref.watch(slotWaitlistServiceProvider);
      final client = await ref.watch(currentClientProfileProvider.future);
      if (service == null || client == null) return false;
      return service.isOnWaitlist(
        clientId: client.id,
        prestataireId: query.prestataireId,
        serviceId: query.serviceId,
        day: query.day,
      );
    });
