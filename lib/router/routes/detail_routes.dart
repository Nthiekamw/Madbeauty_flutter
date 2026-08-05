import 'package:go_router/go_router.dart';

import '../../features/booking/screens/client_reservation_detail_screen.dart';
import '../../features/disputes/screens/dispute_detail_screen.dart';
import '../../features/messaging/providers/messaging_inbox_providers.dart';
import '../../features/messaging/screens/chat_screen.dart';
import '../../features/prestataire/models/prestataire_profile_edit_section.dart';
import '../../features/prestataire/screens/prestataire_account_hub_screen.dart';
import '../../features/prestataire/screens/prestataire_boutique_hub_screen.dart';
import '../../features/prestataire/screens/prestataire_boutique_orders_screen.dart';
import '../../features/prestataire/screens/prestataire_boutique_screen.dart';
import '../../features/prestataire/screens/prestataire_detail_screen.dart';
import '../../features/prestataire/screens/prestataire_horaires_screen.dart';
import '../../features/prestataire/screens/prestataire_hub_screen.dart';
import '../../features/prestataire/screens/prestataire_packs_screen.dart';
import '../../features/prestataire/screens/prestataire_payment_methods_screen.dart';
import '../../features/prestataire/screens/prestataire_received_reviews_screen.dart';
import '../../features/prestataire/screens/prestataire_reservation_detail_screen.dart';
import '../../features/prestataire/screens/prestataire_salon_hub_screen.dart';
import '../../features/prestataire/screens/prestataire_subscription_screen.dart';
import '../../features/reel/screens/prestataire_reel_manage_screen.dart';
import '../../features/support/screens/user_support_chat_screen.dart';
import '../../services/supabase/disputes/dispute_service.dart';
import '../../core/models/domain/user/prestataire_public_slug.dart';
import '../app_routes.dart';
import '../prestataire_public_route.dart';

List<RouteBase> buildDetailRoutes() => [
      GoRoute(
        name: AppRouteNames.prestataireDetailByHandle,
        path: '/@:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug']?.trim() ?? '';
          return PrestataireDetailScreen(prestataireId: slug);
        },
      ),
      GoRoute(
        name: AppRouteNames.prestataireDetailBySlug,
        path: '${AppRoutes.prestatairePublicSlugAlias}/:slug',
        builder: (context, state) {
          final slug = state.pathParameters['slug']?.trim() ?? '';
          return PrestataireDetailScreen(prestataireId: slug);
        },
      ),
      GoRoute(
        name: AppRouteNames.chatFromBooking,
        path: '${AppRoutes.chat}/booking/:bookingId',
        builder: (context, state) {
          final id = state.pathParameters['bookingId']!;
          final as = state.uri.queryParameters['as'];
          final viewerRole = switch (as) {
            'client' => MessagingInboxRole.client,
            'prestataire' => MessagingInboxRole.prestataire,
            _ => null,
          };
          return ChatScreen(bookingId: id, viewerRole: viewerRole);
        },
      ),
      GoRoute(
        name: AppRouteNames.chat,
        path: '${AppRoutes.chat}/:conversationId',
        builder: (context, state) {
          final id = state.pathParameters['conversationId']!;
          final as = state.uri.queryParameters['as'];
          final viewerRole = switch (as) {
            'client' => MessagingInboxRole.client,
            'prestataire' => MessagingInboxRole.prestataire,
            _ => null,
          };
          return ChatScreen(conversationId: id, viewerRole: viewerRole);
        },
      ),
      GoRoute(
        name: AppRouteNames.userSupportChatThread,
        path: '${AppRoutes.userSupportChat}/:threadId',
        builder: (context, state) => UserSupportChatScreen(
          threadId: state.pathParameters['threadId'],
        ),
      ),
      GoRoute(
        name: AppRouteNames.userSupportChat,
        path: AppRoutes.userSupportChat,
        builder: (context, state) => const UserSupportChatScreen(),
      ),
      GoRoute(
        name: AppRouteNames.clientReservationDetail,
        path: AppRoutes.clientReservationDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return ClientReservationDetailScreen(reservationId: id);
        },
      ),
      GoRoute(
        name: AppRouteNames.clientDisputeDetail,
        path: AppRoutes.clientDisputeDetail,
        builder: (context, state) => DisputeDetailScreen(
          disputeId: state.pathParameters['id']!,
          viewerRole: DisputeSenderRole.client,
        ),
      ),
      GoRoute(
        name: AppRouteNames.prestataireReservationDetail,
        path: AppRoutes.prestataireReservationDetail,
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PrestataireReservationDetailScreen(reservationId: id);
        },
      ),
      GoRoute(
        name: AppRouteNames.prestataireDisputeDetail,
        path: AppRoutes.prestataireDisputeDetail,
        builder: (context, state) => DisputeDetailScreen(
          disputeId: state.pathParameters['id']!,
          viewerRole: DisputeSenderRole.prestataire,
        ),
      ),
      GoRoute(
        name: AppRouteNames.prestataireHoraires,
        path: AppRoutes.prestataireHoraires,
        builder: (context, state) => const PrestataireHorairesScreen(),
      ),
      GoRoute(
        name: AppRouteNames.prestataireSubscription,
        path: AppRoutes.prestataireSubscription,
        builder: (context, state) => const PrestataireSubscriptionScreen(),
      ),
      GoRoute(
        name: AppRouteNames.prestatairePaymentMethods,
        path: AppRoutes.prestatairePaymentMethods,
        builder: (context, state) => const PrestatairePaymentMethodsScreen(),
      ),
      GoRoute(
        name: AppRouteNames.prestataireReceivedReviews,
        path: AppRoutes.prestataireReceivedReviews,
        builder: (context, state) => const PrestataireReceivedReviewsScreen(),
      ),
      GoRoute(
        name: AppRouteNames.prestataireBoutique,
        path: AppRoutes.prestataireBoutique,
        builder: (context, state) => const PrestataireBoutiqueScreen(),
      ),
      GoRoute(
        name: AppRouteNames.prestatairePacks,
        path: AppRoutes.prestatairePacks,
        builder: (context, state) => const PrestatairePacksScreen(),
      ),
      GoRoute(
        name: AppRouteNames.prestataireBoutiqueOrders,
        path: AppRoutes.prestataireBoutiqueOrders,
        builder: (context, state) => const PrestataireBoutiqueOrdersScreen(),
      ),
      GoRoute(
        name: AppRouteNames.prestataireReel,
        path: AppRoutes.prestataireReel,
        builder: (context, state) => const PrestataireReelManageScreen(),
      ),
      GoRoute(
        name: AppRouteNames.prestataireProfileSalon,
        path: AppRoutes.prestataireProfileSalon,
        builder: (context, state) => const PrestataireSalonHubScreen(),
      ),
      GoRoute(
        name: AppRouteNames.prestataireProfileBoutique,
        path: AppRoutes.prestataireProfileBoutique,
        builder: (context, state) => const PrestataireBoutiqueHubScreen(),
      ),
      GoRoute(
        name: AppRouteNames.prestataireProfileAccount,
        path: AppRoutes.prestataireProfileAccount,
        builder: (context, state) => const PrestataireAccountHubScreen(),
      ),
      GoRoute(
        name: AppRouteNames.prestataireProfileEdit,
        path: AppRoutes.prestataireProfileEdit,
        builder: (context, state) {
          final section = PrestataireProfileEditSection.fromQuery(
            state.uri.queryParameters['section'],
          );
          final stepRaw = state.uri.queryParameters['step'];
          final initialStep = stepRaw != null ? int.tryParse(stepRaw) : null;
          return PrestataireHubScreen(
            focusedSection: section,
            initialStep: initialStep,
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.prestataireDetail,
        path: '${AppRoutes.prestatairePublicProfile}/:id',
        redirect: (context, state) {
          final id = state.pathParameters['id']?.trim() ?? '';
          if (isPublicPrestataireId(id)) return null;
          if (PrestatairePublicSlug.normalize(id) != null) return null;
          return switch (id) {
            'subscription' => AppRoutes.prestataireSubscription,
            'payment-methods' => AppRoutes.prestatairePaymentMethods,
            'horaires' => AppRoutes.prestataireHoraires,
            'boutique' => AppRoutes.prestataireBoutique,
            'packs' => AppRoutes.prestatairePacks,
            'boutique-orders' => AppRoutes.prestataireBoutiqueOrders,
            'reel' => AppRoutes.prestataireReel,
            'salon' => AppRoutes.prestataireProfileSalon,
            'profile-boutique' => AppRoutes.prestataireProfileBoutique,
            'profile-account' => AppRoutes.prestataireProfileAccount,
            _ => AppRoutes.clientSearch,
          };
        },
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return PrestataireDetailScreen(prestataireId: id);
        },
      ),
    ];
