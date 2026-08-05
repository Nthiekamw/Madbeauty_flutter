import '../../../router/app_router.dart';
import '../../../router/prestataire_public_route.dart';

/// Routes accessibles sans compte (mode invité).
abstract final class GuestRoutePolicy {
  GuestRoutePolicy._();

  static bool isClientShellPath(String location) =>
      location.startsWith('/client/');

  static bool isPrestataireSpacePath(String location) {
    if (isPublicPrestataireProfilePath(location)) return false;
    return location.startsWith('/prestataire/') ||
        location == AppRoutes.becomePrestataire ||
        location == AppRoutes.becomeClient ||
        location == AppRoutes.role;
  }

  static bool isBrowsableAsGuest(String location) {
    if (isClientShellPath(location)) return true;
    if (isPublicPrestataireProfilePath(location)) return true;
    if (location.startsWith('${AppRoutes.prestatairesLegacy}/')) return true;
    if (location == AppRoutes.booking) return true;
    return false;
  }

  static bool requiresAccount(String location) {
    if (location == AppRoutes.bookingConfirmation) return true;
    if (location == AppRoutes.editClientAccount) return true;
    if (location == AppRoutes.clientFavorites) return true;
    if (location == AppRoutes.clientReelFavorites) return true;
    if (location == AppRoutes.clientWishlist) return true;
    if (isPrestataireSpacePath(location)) return true;
    return false;
  }
}

