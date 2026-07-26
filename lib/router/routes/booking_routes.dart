import 'package:go_router/go_router.dart';

import '../../features/booking/screens/booking_confirmation_screen.dart';
import '../../features/booking/screens/booking_screen.dart';
import '../../features/dev/screens/async_state_test_screen.dart';
import '../app_routes.dart';

List<RouteBase> buildBookingRoutes() => [
      GoRoute(
        name: AppRouteNames.booking,
        path: AppRoutes.booking,
        builder: (context, state) => BookingScreen(
          prestataireId: state.uri.queryParameters['prestataireId'],
          serviceId: state.uri.queryParameters['serviceId'],
          packId: state.uri.queryParameters['packId'],
          initialDay: state.uri.queryParameters['date'],
        ),
      ),
      GoRoute(
        name: AppRouteNames.bookingConfirmation,
        path: AppRoutes.bookingConfirmation,
        builder: (context, state) {
          final params = state.uri.queryParameters;
          final dateTime =
              DateTime.tryParse(params['dateTime'] ?? '') ?? DateTime.now();
          return BookingConfirmationScreen(
            prestataireId: params['prestataireId'] ?? '',
            serviceId: params['serviceId'] ?? '',
            serviceName: params['serviceName'] ?? '',
            price: double.tryParse(params['price'] ?? '') ?? 0,
            durationMinutes: int.tryParse(params['durationMinutes'] ?? '') ?? 0,
            dateTime: dateTime,
            packId: params['packId'],
          );
        },
      ),
      GoRoute(
        name: AppRouteNames.asyncStateTest,
        path: AppRoutes.asyncStateTest,
        builder: (context, state) => const AsyncStateTestScreen(),
      ),
    ];
