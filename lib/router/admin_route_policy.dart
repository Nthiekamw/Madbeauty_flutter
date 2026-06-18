import 'app_router.dart';

/// Chemins autorisés / interdits pour les comptes administrateur.
abstract final class AdminRoutePolicy {
  AdminRoutePolicy._();

  static bool isAdminShellPath(String location) =>
      location.startsWith('/admin/');

  /// Chat support et signalements techniques (hors shell admin).
  static bool isBugReportPath(String location) =>
      location.startsWith('/bug-report/') ||
      location == AppRoutes.clientReportBug ||
      location == AppRoutes.clientNewBugReport ||
      location == AppRoutes.clientMyBugReports ||
      location == AppRoutes.bannedAccountSupport ||
      location == AppRoutes.userSupportChat ||
      location.startsWith('${AppRoutes.userSupportChat}/') ||
      location == AppRoutes.adminUserSupport;

  static bool isClientWorkspacePath(String location) =>
      location.startsWith('/client');

  static bool isPrestataireWorkspacePath(String location) {
    const prefixes = <String>[
      AppRoutes.prestataireDashboard,
      AppRoutes.prestataireAgenda,
      AppRoutes.prestataireClients,
      AppRoutes.prestataireMessages,
      AppRoutes.prestataireProfile,
      AppRoutes.prestataireHoraires,
      AppRoutes.prestataireSubscription,
      AppRoutes.prestatairePaymentMethods,
      AppRoutes.prestataireReceivedReviews,
      AppRoutes.prestataireProfileEdit,
      '/prestataire/reservations/',
    ];
    return prefixes.any((p) => location.startsWith(p));
  }

  static bool shouldRedirectAdminAway(String location) {
    if (isClientWorkspacePath(location)) return true;
    if (isPrestataireWorkspacePath(location)) return true;
    if (location == AppRoutes.role) return true;
    if (location == AppRoutes.becomePrestataire) return true;
    if (location.startsWith(AppRoutes.booking)) return true;
    if (location.startsWith(AppRoutes.chat)) return true;
    return false;
  }
}
