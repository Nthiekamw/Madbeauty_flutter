import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../../router/app_router.dart';
import 'in_app_notification.dart';

/// Navigation depuis une notification push ou la liste in-app.
void handlePushMessageNavigation(BuildContext context, RemoteMessage message) {
  final type = message.data['type'] as String?;
  if (type == 'slot_waitlist') {
    _openBookingFromData(context, message.data);
  }
}

void handlePushMessageNavigationWithRouter(
  GoRouter router,
  RemoteMessage message,
) {
  final type = message.data['type'] as String?;
  if (type == 'slot_waitlist') {
    _openBookingWithRouter(router, message.data);
  }
}

void handleInAppNotificationNavigation(
  BuildContext context,
  InAppNotification notification,
) {
  if (notification.actionType == 'slot_waitlist') {
    _openBookingFromData(context, {
      if (notification.prestataireId != null)
        'prestataire_id': notification.prestataireId!,
      if (notification.serviceId != null) 'service_id': notification.serviceId!,
      if (notification.dateJour != null) 'date_jour': notification.dateJour!,
    });
  }
}

void _openBookingFromData(BuildContext context, Map<String, dynamic> data) {
  final params = _bookingQueryParams(data);
  if (params == null) return;
  if (!context.mounted) return;
  context.pushNamed(AppRouteNames.booking, queryParameters: params);
}

void _openBookingWithRouter(GoRouter router, Map<String, dynamic> data) {
  final params = _bookingQueryParams(data);
  if (params == null) return;
  router.pushNamed(AppRouteNames.booking, queryParameters: params);
}

Map<String, String>? _bookingQueryParams(Map<String, dynamic> data) {
  final prestataireId = (data['prestataire_id'] as String?)?.trim();
  if (prestataireId == null || prestataireId.isEmpty) return null;

  final serviceId = (data['service_id'] as String?)?.trim();
  final dateJour = (data['date_jour'] as String?)?.trim();

  return {
    'prestataireId': prestataireId,
    if (serviceId != null && serviceId.isNotEmpty) 'serviceId': serviceId,
    if (dateJour != null && dateJour.length >= 10) 'date': dateJour,
  };
}

