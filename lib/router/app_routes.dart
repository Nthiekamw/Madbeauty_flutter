/// Chemins et noms de routes GoRouter (source unique).
abstract final class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String welcome = '/welcome';
  static const String login = '/login';
  static const String register = '/register';
  static const String registerVerifyEmail = '/register/verify-email';
  static const String forgotPassword = '/forgot-password';
  static const String resetPassword = '/reset-password';
  static const String bannedAccountSupport = '/support/banned-account';
  static const String role = '/role';
  /// Fiche publique partageable : `/prestataire/:id` (UUID).
  static const String prestatairePublicProfile = '/prestataire';

  /// Ancien chemin listing — redirigé vers [prestatairePublicProfile].
  static const String prestatairesLegacy = '/prestataires';
  static const String booking = '/booking';
  static const String bookingConfirmation = '/booking/confirmation';
  static const String asyncStateTest = '/test/async-states';
  static const String becomePrestataire = '/become-prestataire';

  static const String clientHome = '/client/home';
  static const String clientSearch = '/client/search';
  static const String clientReservations = '/client/reservations';
  static const String clientReservationDetail = '/client/reservations/:id';
  static const String clientMessages = '/client/messages';
  static const String clientProfile = '/client/profile';
  static const String chat = '/chat';
  static const String editClientAccount = '/client/profile/edit';
  static const String clientPaymentMethods = '/client/payment-methods';
  static const String clientFavorites = '/client/favorites';
  static const String clientAllPrestataires = '/client/prestataires';
  static const String clientReviews = '/client/reviews';
  static const String clientHistory = '/client/history';
  static const String clientHelp = '/client/help';
  static const String clientReportBug = '/client/report-bug';
  static const String clientNewBugReport = '/client/report-bug/new';
  static const String clientMyBugReports = '/client/my-bug-reports';
  static const String bugReportChat = '/bug-report/:id/chat';
  static const String userSupportChat = '/support/chat';
  static const String clientReferral = '/client/referral';
  static const String adminHome = '/admin/home';
  static const String adminVerifications = '/admin/verifications';
  static const String adminReports = '/admin/reports';
  static const String adminBugReports = '/admin/bug-reports';
  static const String adminProfile = '/admin/profile';
  static const String adminUsers = '/admin/users';
  static const String adminReservations = '/admin/reservations';
  static const String adminAudit = '/admin/audit';
  static const String adminPush = '/admin/push';
  static const String adminSubscriptionTrial = '/admin/subscription-trial';
  static const String adminBookingPlatformFee = '/admin/booking-platform-fee';
  static const String adminRealisationPhotos = '/admin/realisation-photos';
  static const String adminUserSupport = '/admin/user-support';

  static const String prestataireDashboard = '/prestataire/dashboard';
  static const String prestataireAgenda = '/prestataire/agenda';
  static const String prestataireProfile = '/prestataire/profile';
  static const String prestataireClients = '/prestataire/clients';
  static const String prestataireMessages = '/prestataire/messages';
  static const String prestataireReservationDetail =
      '/prestataire/reservations/:id';
  static const String prestataireProfileEdit = '/prestataire/profile/edit';
  static const String prestataireHoraires = '/prestataire/horaires';
  static const String prestataireSubscription = '/prestataire/subscription';
  static const String prestatairePaymentMethods = '/prestataire/payment-methods';
  static const String prestataireReceivedReviews =
      '/prestataire/received-reviews';

  /// Anciennes routes — redirigées vers le shell client / prestataire.
  static const String home = '/';
  static const String listing = '/listing';
  static const String myReservations = '/reservations';
  static const String prestataire = '/prestataire';
}

abstract final class AppRouteNames {
  static const String splash = 'splash';
  static const String onboarding = 'onboarding';
  static const String welcome = 'welcome';
  static const String login = 'login';
  static const String register = 'register';
  static const String registerVerifyEmail = 'register-verify-email';
  static const String forgotPassword = 'forgot-password';
  static const String resetPassword = 'reset-password';
  static const String bannedAccountSupport = 'banned-account-support';
  static const String role = 'role';
  static const String prestataireDetail = 'prestataire-detail';
  static const String booking = 'booking';
  static const String bookingConfirmation = 'booking-confirmation';
  static const String asyncStateTest = 'async-state-test';
  static const String becomePrestataire = 'become-prestataire';

  static const String clientHome = 'client-home';
  static const String clientSearch = 'client-search';
  static const String clientReservations = 'client-reservations';
  static const String clientReservationDetail = 'client-reservation-detail';
  static const String clientMessages = 'client-messages';
  static const String clientProfile = 'client-profile';
  static const String chat = 'chat';
  static const String editClientAccount = 'edit-client-account';
  static const String clientPaymentMethods = 'client-payment-methods';
  static const String clientFavorites = 'client-favorites';
  static const String clientAllPrestataires = 'client-all-prestataires';
  static const String clientReviews = 'client-reviews';
  static const String clientHistory = 'client-history';
  static const String clientHelp = 'client-help';
  static const String clientReportBug = 'client-report-bug';
  static const String clientNewBugReport = 'client-new-bug-report';
  static const String clientMyBugReports = 'client-my-bug-reports';
  static const String bugReportChat = 'bug-report-chat';
  static const String userSupportChat = 'user-support-chat';
  static const String userSupportChatThread = 'user-support-chat-thread';
  static const String clientReferral = 'client-referral';
  static const String adminHome = 'admin-home';
  static const String adminVerifications = 'admin-verifications';
  static const String adminReports = 'admin-reports';
  static const String adminBugReports = 'admin-bug-reports';
  static const String adminProfile = 'admin-profile';
  static const String adminUsers = 'admin-users';
  static const String adminReservations = 'admin-reservations';
  static const String adminAudit = 'admin-audit';
  static const String adminPush = 'admin-push';
  static const String adminSubscriptionTrial = 'admin-subscription-trial';
  static const String adminBookingPlatformFee = 'admin-booking-platform-fee';
  static const String adminRealisationPhotos = 'admin-realisation-photos';
  static const String adminUserSupport = 'admin-user-support';

  static const String prestataireDashboard = 'prestataire-dashboard';
  static const String prestataireAgenda = 'prestataire-agenda';
  static const String prestataireProfile = 'prestataire-profile';
  static const String prestataireClients = 'prestataire-clients';
  static const String prestataireMessages = 'prestataire-messages';
  static const String prestataireReservationDetail =
      'prestataire-reservation-detail';
  static const String prestataireProfileEdit = 'prestataire-profile-edit';
  static const String prestataireHoraires = 'prestataire-horaires';
  static const String prestataireSubscription = 'prestataire-subscription';
  static const String prestatairePaymentMethods = 'prestataire-payment-methods';
  static const String prestataireReceivedReviews =
      'prestataire-received-reviews';
}
