import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_strings.dart';
import '../../core/models/domain/booking/reservation.dart';
import '../../core/models/domain/serialization/supabase_domain_codec.dart';
import 'stripe_payment_exception.dart';
import 'stripe_service.dart';

/// Paramètres renvoyés par l’Edge Function avant d’ouvrir la PaymentSheet.
class BookingPaymentSheetData {
  const BookingPaymentSheetData({
    required this.paymentIntentId,
    required this.paymentIntentClientSecret,
    required this.customerId,
    required this.ephemeralKey,
    required this.amountCents,
    this.currency = 'eur',
  });

  final String paymentIntentId;
  final String paymentIntentClientSecret;
  final String customerId;
  final String ephemeralKey;
  final int amountCents;
  final String currency;
}

/// Paiement réservation : PaymentIntent (Connect) + création réservation après succès.
class StripeBookingPaymentService {
  StripeBookingPaymentService(this._client);

  final SupabaseClient _client;

  static const _confirmMaxAttempts = 10;
  static const _confirmRetryDelay = Duration(milliseconds: 800);

  Future<BookingPaymentSheetData> createPaymentIntent({
    required String prestataireId,
    required String serviceId,
    required DateTime dateHeure,
    required double priceEur,
  }) async {
    if (kIsWeb) throw const StripePaymentGenericException(DiscPay.errWebUnsupported);
    if (!StripeService.isConfigured) {
      throw const StripePaymentNotConfiguredException();
    }

    final amountCents = (priceEur * 100).round();
    final response = await _invoke(
      'create_booking_payment_intent',
      body: {
        'prestataireId': prestataireId,
        'serviceId': serviceId,
        'dateHeure': _bookingInstantPayload(dateHeure),
        'amountCents': amountCents,
      },
    );

    final data = _expectMap(response.data, 'create_booking_payment_intent');
    final clientSecret = data['paymentIntentClientSecret'] as String?;
    final paymentIntentId = data['paymentIntentId'] as String?;
    final customerId = data['customerId'] as String?;
    final ephemeralKey = data['ephemeralKey'] as String?;
    if (clientSecret == null ||
        paymentIntentId == null ||
        customerId == null ||
        ephemeralKey == null) {
      throw const StripePaymentGenericException(
        'Réponse serveur incomplète (paiement)',
      );
    }

    return BookingPaymentSheetData(
      paymentIntentId: paymentIntentId,
      paymentIntentClientSecret: clientSecret,
      customerId: customerId,
      ephemeralKey: ephemeralKey,
      amountCents: data['amountCents'] as int? ?? amountCents,
      currency: data['currency'] as String? ?? 'eur',
    );
  }

  Future<void> presentPaymentSheet(BookingPaymentSheetData sheet) async {
    try {
      await Stripe.instance.initPaymentSheet(
        paymentSheetParameters: SetupPaymentSheetParameters(
          paymentIntentClientSecret: sheet.paymentIntentClientSecret,
          customerId: sheet.customerId,
          customerEphemeralKeySecret: sheet.ephemeralKey,
          merchantDisplayName: 'MadBeauty',
          style: ThemeMode.system,
          googlePay: const PaymentSheetGooglePay(
            merchantCountryCode: 'FR',
            testEnv: true,
          ),
        ),
      );
      await Stripe.instance.presentPaymentSheet();
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) {
        throw const StripePaymentCanceledException();
      }
      throw StripePaymentGenericException(
        e.error.localizedMessage ?? e.error.message,
      );
    } on PlatformException catch (e) {
      throw StripePaymentGenericException(
        e.message ?? e.code,
      );
    }
  }

  Future<Reservation> completeBookingAfterPayment({
    required String paymentIntentId,
    required String prestataireId,
    required String serviceId,
    required DateTime dateHeure,
    String? notesClient,
  }) async {
    final payload = {
      'paymentIntentId': paymentIntentId,
      'prestataireId': prestataireId,
      'serviceId': serviceId,
      'dateHeure': _bookingInstantPayload(dateHeure),
      if (notesClient != null && notesClient.trim().isNotEmpty)
        'notesClient': notesClient.trim(),
    };

    Object? lastErrorData;
    var lastStatus = 0;

    for (var attempt = 0; attempt < _confirmMaxAttempts; attempt++) {
      if (attempt > 0) {
        await Future<void>.delayed(_confirmRetryDelay);
      }

      try {
        final response = await _client.functions.invoke(
          'complete_booking_after_payment',
          body: payload,
        );
        return _parseReservationResponse(response.data);
      } on FunctionException catch (e) {
        lastStatus = e.status;
        lastErrorData = e.details;
        final map = _asMap(e.details);
        final code = map?['code'] as String?;
        if (e.status == 402 && code == 'payment_not_ready') {
          continue;
        }
        throw _mapFunctionError(e.status, e.details);
      }
    }

    throw _mapFunctionError(lastStatus, lastErrorData);
  }

  Future<void> capturePaymentForReservation(String reservationId) async {
    await _invoke(
      'capture_booking_payment',
      body: {'reservationId': reservationId},
    );
  }

  /// Supabase `invoke` lance [FunctionException] si status ∉ 2xx (pas de réponse).
  Future<FunctionResponse> _invoke(
    String name, {
    Object? body,
  }) async {
    try {
      return await _client.functions.invoke(name, body: body);
    } on FunctionException catch (e) {
      throw _mapFunctionError(e.status, e.details);
    }
  }

  Reservation _parseReservationResponse(Object? raw) {
    final data = _expectMap(raw, 'complete_booking_after_payment');
    final reservationRaw = data['reservation'];
    if (reservationRaw is! Map) {
      throw const StripePaymentGenericException(
        'Réponse serveur incomplète (réservation)',
      );
    }
    try {
      return SupabaseDomainCodec.reservation(
        Map<String, dynamic>.from(reservationRaw),
      );
    } catch (e) {
      debugPrint('Reservation parse error: $e');
      final detail = e is FormatException ? e.message : e.toString();
      throw StripePaymentGenericException(
        'Données réservation invalides : $detail',
      );
    }
  }

  /// Instant ISO UTC aligné create / complete (évite les écarts de métadonnées).
  static String _bookingInstantPayload(DateTime dateHeure) {
    final local = dateHeure.toLocal();
    final minuteLocal = DateTime(
      local.year,
      local.month,
      local.day,
      local.hour,
      local.minute,
    );
    return minuteLocal.toUtc().toIso8601String();
  }

  static Map<String, dynamic>? _asMapStatic(Object? raw) {
    if (raw is Map) {
      return Map<String, dynamic>.from(raw);
    }
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) {
          return Map<String, dynamic>.from(decoded);
        }
      } catch (_) {}
    }
    return null;
  }

  Map<String, dynamic>? _asMap(Object? raw) => _asMapStatic(raw);

  Map<String, dynamic> _expectMap(Object? raw, String operation) {
    final map = _asMap(raw);
    if (map != null) return map;
    throw StripePaymentGenericException(
      'Réponse invalide ($operation)',
    );
  }

  /// Convertit une erreur Edge Function (ou réseau) en exception métier.
  static StripePaymentException fromInvokeError(Object error) {
    if (error is StripePaymentException) return error;
    if (error is FunctionException) {
      return StripeBookingPaymentService._mapFunctionErrorStatic(
        error.status,
        error.details,
      );
    }
    return StripePaymentGenericException(error.toString());
  }

  StripePaymentException _mapFunctionError(int status, Object? raw) =>
      _mapFunctionErrorStatic(status, raw);

  static StripePaymentException _mapFunctionErrorStatic(
    int status,
    Object? raw,
  ) {
    final map = _asMapStatic(raw);
    final code = map?['code'] as String?;
    final error = map?['error'] as String? ??
        map?['message'] as String? ??
        (raw is String && raw.trim().isNotEmpty ? raw.trim() : null);

    switch (code) {
      case 'prestataire_not_payable':
        return const StripePaymentPrestaNotPayableException();
      case 'slot_taken':
        return const StripePaymentSlotTakenException();
      case 'payment_not_ready':
        return StripePaymentGenericException(
          error ?? DiscPay.errPaymentPending,
        );
    }

    if (status == 401 || status == 403) {
      return StripePaymentGenericException(
        error ?? DiscBk.errNeedLogin,
      );
    }

    if (error != null && error.trim().isNotEmpty) {
      return StripePaymentGenericException(error.trim());
    }

    return const StripePaymentGenericException();
  }
}
