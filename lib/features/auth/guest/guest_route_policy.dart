import '../../../router/app_router.dart';

/// Routes accessibles sans compte (mode invité).
abstract final class GuestRoutePolicy {
  GuestRoutePolicy._();

  static bool isClientShellPath(String location) =>
      location.startsWith('/client/');

  static bool isPrestataireSpacePath(String location) =>
      location.startsWith('/prestataire/') ||
      location == AppRoutes.becomePrestataire ||
      location == AppRoutes.role;

  static bool isBrowsableAsGuest(String location) {
    if (isClientShellPath(location)) return true;
    if (location.startsWith('${AppRoutes.prestataires}/')) return true;
    if (location == AppRoutes.booking) return true;
    return false;
  }

  static bool requiresAccount(String location) {
    if (location == AppRoutes.bookingConfirmation) return true;
    if (isPrestataireSpacePath(location)) return true;
    return false;
  }
}
