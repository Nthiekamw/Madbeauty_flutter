import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/admin/admin_push_service.dart';

final adminPushServiceProvider = Provider<AdminPushService?>((ref) {
  return AdminPushService.fromEnv();
});
