import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app_permissions_service.dart';

final appPermissionsServiceProvider = Provider<AppPermissionsService>(
  (ref) => AppPermissionsService(),
);

