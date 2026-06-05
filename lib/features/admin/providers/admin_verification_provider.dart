import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/admin/admin_verification_service.dart';
import '../models/admin_verification_request.dart';

enum AdminVerificationFilter { all, pending }

final adminVerificationServiceProvider = Provider<AdminVerificationService?>((ref) {
  return AdminVerificationService.fromEnv();
});

final adminVerificationRequestsProvider = FutureProvider.autoDispose
    .family<List<AdminVerificationRequest>, AdminVerificationFilter>((
      ref,
      filter,
    ) async {
      final service = ref.watch(adminVerificationServiceProvider);
      if (service == null) return const [];
      return service.listRequests(
        onlyPending: filter == AdminVerificationFilter.pending,
      );
    });

