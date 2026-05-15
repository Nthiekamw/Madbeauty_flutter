import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import 'app_router.dart';

extension AppNavigationX on BuildContext {
  void goSplash() => goNamed(AppRouteNames.splash);
  void goHome() => goNamed(AppRouteNames.clientHome);
  void goClientSearch({String? query}) {
    final q = query?.trim();
    if (q != null && q.isNotEmpty) {
      goNamed(AppRouteNames.clientSearch, queryParameters: {'q': q});
    } else {
      goNamed(AppRouteNames.clientSearch);
    }
  }

  void pushClientSearch({String? query}) {
    final q = query?.trim();
    if (q != null && q.isNotEmpty) {
      pushNamed(AppRouteNames.clientSearch, queryParameters: {'q': q});
    } else {
      pushNamed(AppRouteNames.clientSearch);
    }
  }

  void goListing({String? query}) => goClientSearch(query: query);
  void pushListing({String? query}) => pushClientSearch(query: query);

  void goLogin() => goNamed(AppRouteNames.login);
  void goRegister() => goNamed(AppRouteNames.register);
  void goRoleChoice() => goNamed(AppRouteNames.role);
  void goPrestataire() => goNamed(AppRouteNames.prestataireProfile);
  void goPrestataireDashboard() =>
      goNamed(AppRouteNames.prestataireDashboard);
  void goPrestataireAgenda() => goNamed(AppRouteNames.prestataireAgenda);
  void goPrestataireProfile() => goNamed(AppRouteNames.prestataireProfile);
  void goClientProfile() => goNamed(AppRouteNames.clientProfile);
  void goMyReservations() => goNamed(AppRouteNames.clientReservations);

  void goBooking({String? prestataireId, String? serviceId}) {
    final id = prestataireId?.trim();
    final service = serviceId?.trim();
    if (id != null && id.isNotEmpty) {
      goNamed(
        AppRouteNames.booking,
        queryParameters: {
          'prestataireId': id,
          if (service != null && service.isNotEmpty) 'serviceId': service,
        },
      );
    } else {
      goNamed(AppRouteNames.booking);
    }
  }

  void goAsyncStateTest() => goNamed(AppRouteNames.asyncStateTest);

  void pushLogin() => pushNamed(AppRouteNames.login);
  void pushRegister() => pushNamed(AppRouteNames.register);
  void pushForgotPassword() => pushNamed(AppRouteNames.forgotPassword);
  void pushPrestataireDetail(String id) =>
      pushNamed(AppRouteNames.prestataireDetail, pathParameters: {'id': id});
  void pushPrestataire() => pushNamed(AppRouteNames.prestataireProfile);
  void pushBooking({String? prestataireId, String? serviceId}) {
    final id = prestataireId?.trim();
    final service = serviceId?.trim();
    if (id != null && id.isNotEmpty) {
      pushNamed(
        AppRouteNames.booking,
        queryParameters: {
          'prestataireId': id,
          if (service != null && service.isNotEmpty) 'serviceId': service,
        },
      );
    } else {
      pushNamed(AppRouteNames.booking);
    }
  }

  void pushBookingConfirmation({
    required String prestataireId,
    required String serviceId,
    required String serviceName,
    required double price,
    required int durationMinutes,
    required DateTime dateTime,
  }) {
    pushNamed(
      AppRouteNames.bookingConfirmation,
      queryParameters: {
        'prestataireId': prestataireId,
        'serviceId': serviceId,
        'serviceName': serviceName,
        'price': price.toString(),
        'durationMinutes': durationMinutes.toString(),
        'dateTime': dateTime.toIso8601String(),
      },
    );
  }

  void pushAsyncStateTest() => pushNamed(AppRouteNames.asyncStateTest);
}
