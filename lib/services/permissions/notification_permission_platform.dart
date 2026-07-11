export 'notification_permission_platform_stub.dart'
    if (dart.library.html) 'notification_permission_platform_web.dart'
    if (dart.library.io) 'notification_permission_platform_io.dart';
