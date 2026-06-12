import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import 'in_app_notification.dart';

/// Navigation depuis une notification push ou la liste in-app.
void handlePushMessageNavigation(BuildContext context, RemoteMessage message) {
  navigateFromPushData(context, message.data);
}

void handlePushMessageNavigationWithRouter(
  GoRouter router,
  RemoteMessage message,
) {
  navigateFromPushDataWithRouter(router, message.data);
}

void handleInAppNotificationNavigation(
  BuildContext context,
  InAppNotification notification,
) {
  navigateFromPushData(context, _dataFromInApp(notification));
}

void navigateFromPushData(
  BuildContext context,
  Map<String, dynamic> data,
) {
  if (!context.mounted) return;
  navigateFromPushDataWithRouter(GoRouter.of(context), data);
}

void navigateFromPushDataWithRouter(
  GoRouter router,
  Map<String, dynamic> data,
) {
  final type = _str(data, 'type');
  final reservationId =
      _str(data, 'reservation_id') ?? _str(data, 'reservationId');
  final bookingId = _str(data, 'booking_id') ?? _str(data, 'bookingId');
  final role = _str(data, 'role');
  final nav = _str(data, 'nav');

  switch (type) {
    case 'slot_waitlist':
      _openBookingWithRouter(router, data);
      return;
    case 'prestataire_catalog_visibility':
      router.pushNamed(AppRouteNames.prestataireSubscription);
      return;
    case 'booking_created':
    case 'booking_status':
      if (reservationId != null) {
        _openReservationDetail(router, reservationId, role: role);
      }
      return;
    case 'message':
      if (bookingId != null) {
        router.pushNamed(
          AppRouteNames.chat,
          pathParameters: {'bookingId': bookingId},
        );
      }
      return;
    case 'prestataire_like':
      router.goNamed(AppRouteNames.prestataireDashboard);
      return;
    case 'prestataire_review':
      router.pushNamed(AppRouteNames.prestataireReceivedReviews);
      return;
    case 'prestataire_verification_approved':
    case 'prestataire_verification_revoked':
      router.pushNamed(AppRouteNames.prestataireProfileEdit);
      return;
    case 'bug_report':
      router.pushNamed(AppRouteNames.adminBugReports);
      return;
    case 'bug_report_status':
      router.pushNamed(AppRouteNames.clientMyBugReports);
      return;
    case 'bug_report_message':
      final bugReportId = _str(data, 'bug_report_id');
      if (bugReportId != null) {
        router.pushNamed(
          AppRouteNames.bugReportChat,
          pathParameters: {'id': bugReportId},
        );
      }
      return;
    case 'admin_broadcast':
      _openAdminNavTarget(router, nav, data);
      return;
  }

  // Webhook Stripe legacy : reservationId sans type.
  if (reservationId != null) {
    _openReservationDetail(router, reservationId, role: 'prestataire');
  }
}

Map<String, dynamic> _dataFromInApp(InAppNotification notification) {
  return {
    if (notification.actionType != null) 'type': notification.actionType!,
    if (notification.prestataireId != null)
      'prestataire_id': notification.prestataireId!,
    if (notification.serviceId != null) 'service_id': notification.serviceId!,
    if (notification.dateJour != null) 'date_jour': notification.dateJour!,
    if (notification.reservationId != null)
      'reservation_id': notification.reservationId!,
    if (notification.bookingId != null) 'booking_id': notification.bookingId!,
    if (notification.role != null) 'role': notification.role!,
    if (notification.nav != null) 'nav': notification.nav!,
    if (notification.bugReportId != null)
      'bug_report_id': notification.bugReportId!,
  };
}

void _openAdminNavTarget(
  GoRouter router,
  String? nav,
  Map<String, dynamic> data,
) {
  switch (nav) {
    case 'client_home':
      router.goNamed(AppRouteNames.clientHome);
    case 'client_reservations':
      router.goNamed(AppRouteNames.clientReservations);
    case 'client_search':
      router.goNamed(AppRouteNames.clientSearch);
    case 'client_messages':
      router.goNamed(AppRouteNames.clientMessages);
    case 'prestataire_dashboard':
      router.goNamed(AppRouteNames.prestataireDashboard);
    case 'prestataire_subscription':
      router.pushNamed(AppRouteNames.prestataireSubscription);
    case 'prestataire_profile_edit':
      router.pushNamed(AppRouteNames.prestataireProfileEdit);
    case 'booking':
      _openBookingWithRouter(router, data);
    case 'admin_bug_reports':
      router.pushNamed(AppRouteNames.adminBugReports);
    case 'my_bug_reports':
      router.pushNamed(AppRouteNames.clientMyBugReports);
    case 'bug_report_chat':
      final chatId = _str(data, 'bug_report_id');
      if (chatId != null) {
        router.pushNamed(
          AppRouteNames.bugReportChat,
          pathParameters: {'id': chatId},
        );
      }
    case 'none':
    case null:
    case '':
      break;
  }
}

void _openReservationDetail(
  GoRouter router,
  String reservationId, {
  String? role,
}) {
  if (role == 'prestataire') {
    router.pushNamed(
      AppRouteNames.prestataireReservationDetail,
      pathParameters: {'id': reservationId},
    );
    return;
  }
  router.pushNamed(
    AppRouteNames.clientReservationDetail,
    pathParameters: {'id': reservationId},
  );
}

void _openBookingWithRouter(GoRouter router, Map<String, dynamic> data) {
  final params = _bookingQueryParams(data);
  if (params == null) return;
  router.pushNamed(AppRouteNames.booking, queryParameters: params);
}

Map<String, String>? _bookingQueryParams(Map<String, dynamic> data) {
  final prestataireId = _str(data, 'prestataire_id');
  if (prestataireId == null || prestataireId.isEmpty) return null;

  final serviceId = _str(data, 'service_id');
  final dateJour = _str(data, 'date_jour');

  return {
    'prestataireId': prestataireId,
    if (serviceId != null && serviceId.isNotEmpty) 'serviceId': serviceId,
    if (dateJour != null && dateJour.length >= 10) 'date': dateJour,
  };
}

String? _str(Map<String, dynamic> data, String key) {
  final raw = data[key];
  if (raw == null) return null;
  final value = raw.toString().trim();
  return value.isEmpty ? null : value;
}
