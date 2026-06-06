import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'admin_content_reports_provider.dart';
import 'admin_verification_provider.dart';

final adminPendingVerificationsCountProvider =
    FutureProvider.autoDispose<int>((ref) async {
      final service = ref.watch(adminVerificationServiceProvider);
      if (service == null) return 0;
      final items = await service.listRequests(onlyPending: true);
      return items.length;
    });

final adminPendingReportsCountProvider = FutureProvider.autoDispose<int>((
  ref,
) async {
  final service = ref.watch(adminContentReportsServiceProvider);
  if (service == null) return 0;
  final items = await service.listReports(onlyPending: true);
  return items.length;
});
