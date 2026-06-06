import 'package:flutter/widgets.dart';
import 'package:go_router/go_router.dart';

import '../features/prestataire/models/prestataire_profile_edit_section.dart';
import 'app_router.dart';

extension AppNavigationX on BuildContext {
  void goSplash() => goNamed(AppRouteNames.splash);
  void goOnboarding() => goNamed(AppRouteNames.onboarding);
  void goWelcome() => goNamed(AppRouteNames.welcome);
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
  void goRegisterResume() =>
      goNamed(AppRouteNames.register, queryParameters: {'resume': '1'});
  void goRegisterVerifyEmail(String email) => goNamed(
        AppRouteNames.registerVerifyEmail,
        queryParameters: {'email': email.trim()},
      );
  void pushVerifyPhone({
    required String flow,
    required String phone,
  }) =>
      pushNamed(
        AppRouteNames.verifyPhone,
        queryParameters: {
          'flow': flow,
          'phone': phone.trim(),
        },
      );
  void goRegisterPhoneVerified() => goNamed(
        AppRouteNames.register,
        queryParameters: {'phoneVerified': '1'},
      );
  void goRoleChoice() => goNamed(AppRouteNames.role);
  void goPrestataire() => goNamed(AppRouteNames.prestataireProfile);
  void goPrestataireDashboard() =>
      goNamed(AppRouteNames.prestataireDashboard);
  void goPrestataireAgenda() => goNamed(AppRouteNames.prestataireAgenda);
  void goPrestataireProfile() => goNamed(AppRouteNames.prestataireProfile);
  void goPrestataireClients() => goNamed(AppRouteNames.prestataireClients);
  void pushPrestataireReservationDetail(String reservationId) =>
      pushNamed(
        AppRouteNames.prestataireReservationDetail,
        pathParameters: {'id': reservationId},
      );
  void pushPrestataireProfileEdit() =>
      pushNamed(AppRouteNames.prestataireProfileEdit);

  void pushPrestataireProfileEditSection(
    PrestataireProfileEditSection section,
  ) =>
      pushNamed(
        AppRouteNames.prestataireProfileEdit,
        queryParameters: {'section': section.queryValue},
      );
  void pushPrestataireProfileEditAtStep(int step) => pushNamed(
        AppRouteNames.prestataireProfileEdit,
        queryParameters: {'step': '$step'},
      );

  void pushPrestataireHoraires() => pushNamed(AppRouteNames.prestataireHoraires);
  void pushPrestataireSubscription() =>
      pushNamed(AppRouteNames.prestataireSubscription);
  void pushPrestatairePaymentMethods() =>
      pushNamed(AppRouteNames.prestatairePaymentMethods);
  void goClientProfile() => goNamed(AppRouteNames.clientProfile);
  void goBecomePrestataire() => goNamed(AppRouteNames.becomePrestataire);
  void pushBecomePrestataire() => pushNamed(AppRouteNames.becomePrestataire);
  void pushEditClientAccount() => pushNamed(AppRouteNames.editClientAccount);
  void pushClientPaymentMethods() =>
      pushNamed(AppRouteNames.clientPaymentMethods);
  void pushClientFavorites() => pushNamed(AppRouteNames.clientFavorites);
  void pushClientReviews() => pushNamed(AppRouteNames.clientReviews);
  void pushClientHistory() => pushNamed(AppRouteNames.clientHistory);
  void pushClientHelp() => pushNamed(AppRouteNames.clientHelp);
  void pushClientReferral() => pushNamed(AppRouteNames.clientReferral);
  void goAdminHome() => goNamed(AppRouteNames.adminHome);
  void goAdminVerifications() => goNamed(AppRouteNames.adminVerifications);
  void goAdminReports() => goNamed(AppRouteNames.adminReports);
  void goAdminProfile() => goNamed(AppRouteNames.adminProfile);
  void pushAdminVerifications() => pushNamed(AppRouteNames.adminVerifications);
  void pushAdminReports() => pushNamed(AppRouteNames.adminReports);
  void pushAdminUsers() => pushNamed(AppRouteNames.adminUsers);
  void pushAdminReservations() => pushNamed(AppRouteNames.adminReservations);
  void pushAdminAudit() => pushNamed(AppRouteNames.adminAudit);
  void goClientMessages() => goNamed(AppRouteNames.clientMessages);
  void goPrestataireMessages() => goNamed(AppRouteNames.prestataireMessages);
  Future<T?> pushChat<T extends Object?>(String bookingId) => pushNamed<T>(
        AppRouteNames.chat,
        pathParameters: {'bookingId': bookingId},
      );
  void goMyReservations() => goNamed(AppRouteNames.clientReservations);
  void pushClientReservationDetail(String reservationId) => pushNamed(
        AppRouteNames.clientReservationDetail,
        pathParameters: {'id': reservationId},
      );

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
  void pushBooking({String? prestataireId, String? serviceId, DateTime? day}) {
    final id = prestataireId?.trim();
    final service = serviceId?.trim();
    if (id != null && id.isNotEmpty) {
      pushNamed(
        AppRouteNames.booking,
        queryParameters: {
          'prestataireId': id,
          if (service != null && service.isNotEmpty) 'serviceId': service,
          if (day != null)
            'date': '${day.year.toString().padLeft(4, '0')}-'
                '${day.month.toString().padLeft(2, '0')}-'
                '${day.day.toString().padLeft(2, '0')}',
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
