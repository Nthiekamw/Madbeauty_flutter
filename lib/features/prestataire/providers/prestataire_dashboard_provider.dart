import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/booking/booking_service_providers.dart';
import '../logic/prestataire_dashboard_split.dart';
import '../models/prestataire_dashboard_data.dart';

final prestataireDashboardProvider =
    FutureProvider.autoDispose<PrestataireDashboardData>((ref) async {
      final service = ref.watch(bookingServiceProvider);
      if (service == null) {
        return const PrestataireDashboardData(
          pending: [],
          todayConfirmed: [],
          weekConfirmed: [],
        );
      }
      final items = await service.listForCurrentPrestataire();
      return splitPrestataireReservations(items);
    });
