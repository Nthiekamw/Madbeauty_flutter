import 'in_app_notification.dart';

/// Espace cible d'une notification in-app (cloche client vs prestataire).
enum InAppNotificationAudience {
  client,
  prestataire,
  admin,
}

extension InAppNotificationAudienceX on InAppNotificationAudience {
  String get wire => name;

  static InAppNotificationAudience? parse(String? raw) {
    return switch (raw?.trim().toLowerCase()) {
      'client' => InAppNotificationAudience.client,
      'prestataire' => InAppNotificationAudience.prestataire,
      'admin' => InAppNotificationAudience.admin,
      _ => null,
    };
  }
}

InAppNotificationAudience resolveInAppNotificationAudience(
  InAppNotification notification,
) {
  final explicit = InAppNotificationAudienceX.parse(notification.audience);
  if (explicit != null) return explicit;

  return switch (notification.actionType) {
    'client_booking_pending' ||
    'client_booking_confirmed' ||
    'client_booking_cancelled' ||
    'client_booking_done' ||
    'slot_waitlist' ||
    'bug_report_status' =>
      InAppNotificationAudience.client,
    'booking_pending' ||
    'booking_confirmed' ||
    'booking_cancelled' ||
    'booking_done' ||
    'prestataire_like' ||
    'prestataire_review' ||
    'prestataire_verification_approved' ||
    'prestataire_verification_revoked' ||
    'prestataire_catalog_visibility' ||
    'prestataire_profile_incomplete' ||
    'prestataire_map_missing' ||
    'moderation_photo_removed' ||
    'moderation_photo_flagged' ||
    'moderation_account_warned' =>
      InAppNotificationAudience.prestataire,
    'bug_report' => InAppNotificationAudience.admin,
    'user_support_message' =>
      InAppNotificationAudienceX.parse(notification.role) ??
          InAppNotificationAudience.client,
    'booking_created' ||
    'booking_status' ||
    'message' =>
      _audienceFromNavRole(notification.role),
    _ => InAppNotificationAudience.client,
  };
}

InAppNotificationAudience _audienceFromNavRole(String? role) {
  return switch (role?.trim().toLowerCase()) {
    'prestataire' => InAppNotificationAudience.prestataire,
    'admin' => InAppNotificationAudience.admin,
    _ => InAppNotificationAudience.client,
  };
}

bool inAppNotificationMatchesAudience(
  InAppNotification notification,
  InAppNotificationAudience audience,
) {
  return resolveInAppNotificationAudience(notification) == audience;
}

List<InAppNotification> filterInAppNotificationsForAudience(
  List<InAppNotification> items,
  InAppNotificationAudience audience,
) {
  return [
    for (final item in items)
      if (inAppNotificationMatchesAudience(item, audience)) item,
  ];
}
