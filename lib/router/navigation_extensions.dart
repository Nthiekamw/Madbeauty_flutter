import 'dart:async';

import 'package:flutter/scheduler.dart';
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
  void pushPrestataireReceivedReviews() =>
      pushNamed(AppRouteNames.prestataireReceivedReviews);
  void goClientProfile() => goNamed(AppRouteNames.clientProfile);
  void goBecomePrestataire() => goNamed(AppRouteNames.becomePrestataire);
  void pushBecomePrestataire() => pushNamed(AppRouteNames.becomePrestataire);
  void pushBecomeClient() => pushNamed(AppRouteNames.becomeClient);
  void pushEditClientAccount() => pushNamed(AppRouteNames.editClientAccount);
  void pushClientFavorites() => pushNamed(AppRouteNames.clientFavorites);
  void pushAllPrestataires() => pushNamed(AppRouteNames.clientAllPrestataires);
  void pushClientReviews() => pushNamed(AppRouteNames.clientReviews);
  void pushClientHistory() => pushNamed(AppRouteNames.clientHistory);
  void pushClientHelp() => pushNamed(AppRouteNames.clientHelp);
  void pushReportBug() => pushNamed(AppRouteNames.clientReportBug);
  void pushNewBugReport() => pushNamed(AppRouteNames.clientNewBugReport);
  void pushMyBugReports() => pushNamed(AppRouteNames.clientReportBug);
  void pushBugReportChat(String bugReportId) => pushNamed(
        AppRouteNames.bugReportChat,
        pathParameters: {'id': bugReportId},
      );
  void pushUserSupportChat() => push(AppRoutes.userSupportChat);
  void pushUserSupportChatThread(String threadId) =>
      push('${AppRoutes.userSupportChat}/$threadId');
  void pushBannedAccountSupport({String? reason}) {
    final trimmed = reason?.trim();
    if (trimmed != null && trimmed.isNotEmpty) {
      pushNamed(
        AppRouteNames.bannedAccountSupport,
        queryParameters: {'reason': trimmed},
      );
    } else {
      pushNamed(AppRouteNames.bannedAccountSupport);
    }
  }
  void pushClientReferral() => pushNamed(AppRouteNames.clientReferral);
  void goAdminHome() => goNamed(AppRouteNames.adminHome);
  void goAdminModeration() => goNamed(AppRouteNames.adminModeration);
  void goAdminSupport() => goNamed(AppRouteNames.adminSupport);
  void goAdminManagement() => goNamed(AppRouteNames.adminManagement);
  void goAdminVerifications() => goNamed(AppRouteNames.adminVerifications);
  void goAdminReports() => goNamed(AppRouteNames.adminReports);
  void goAdminProfile() => goNamed(AppRouteNames.adminProfile);
  void pushAdminVerifications() => pushNamed(AppRouteNames.adminVerifications);
  void pushAdminReports() => pushNamed(AppRouteNames.adminReports);
  void pushAdminBugReports() => pushNamed(AppRouteNames.adminBugReports);
  void pushAdminUserSupport() => pushNamed(AppRouteNames.adminUserSupport);
  void pushAdminUsers() => pushNamed(AppRouteNames.adminUsers);
  void pushAdminReservations() => pushNamed(AppRouteNames.adminReservations);
  void pushAdminAudit() => pushNamed(AppRouteNames.adminAudit);
  void pushAdminPush() => pushNamed(AppRouteNames.adminPush);
  void pushAdminSubscriptionTrial() =>
      pushNamed(AppRouteNames.adminSubscriptionTrial);
  void pushAdminBookingPlatformFee() =>
      pushNamed(AppRouteNames.adminBookingPlatformFee);
  void pushAdminRealisationPhotos() =>
      pushNamed(AppRouteNames.adminRealisationPhotos);
  void goClientMessages() => goNamed(AppRouteNames.clientMessages);
  void goPrestataireMessages() => goNamed(AppRouteNames.prestataireMessages);
  Future<T?> pushChat<T extends Object?>(
    String conversationId, {
    String? as,
  }) =>
      pushNamed<T>(
        AppRouteNames.chat,
        pathParameters: {'conversationId': conversationId},
        queryParameters:
            as != null && as.isNotEmpty ? {'as': as} : const {},
      );

  Future<T?> pushChatForBooking<T extends Object?>(
    String bookingId, {
    String? as,
  }) =>
      pushNamed<T>(
        AppRouteNames.chatFromBooking,
        pathParameters: {'bookingId': bookingId},
        queryParameters:
            as != null && as.isNotEmpty ? {'as': as} : const {},
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

/// Navigation différée : évite les clés de page dupliquées avec [GoRouter.redirect].
extension GoRouterDeferredNavigation on GoRouter {
  Future<void> goDeferred(String location) {
    final normalized = location.trim();
    if (normalized.isEmpty) return Future.value();
    if (state.matchedLocation == normalized) return Future.value();

    final completer = Completer<void>();
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          if (state.matchedLocation != normalized) {
            go(normalized);
          }
        } finally {
          if (!completer.isCompleted) completer.complete();
        }
      });
    });
    return completer.future;
  }

  Future<void> goNamedDeferred(
    String name, {
    Map<String, String> pathParameters = const {},
    Map<String, String> queryParameters = const {},
  }) {
    final completer = Completer<void>();
    SchedulerBinding.instance.scheduleFrameCallback((_) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        try {
          goNamed(
            name,
            pathParameters: pathParameters,
            queryParameters: queryParameters,
          );
        } finally {
          if (!completer.isCompleted) completer.complete();
        }
      });
    });
    return completer.future;
  }
}
