import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart' show ThemeMode;
import 'package:flutter/services.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/constants/app_strings.dart';
import '../../core/models/domain/payment/client_payment_method.dart';
import 'stripe_service.dart';

class StripeClientPaymentException implements Exception {
  const StripeClientPaymentException(this.message, {this.code});

  final String message;
  final String? code;

  @override
  String toString() => message;
}

/// Cartes clientes : liste + Customer Sheet (dans l’app).
class StripeClientPaymentService {
  StripeClientPaymentService(this._client);

  final SupabaseClient _client;

  Future<List<ClientPaymentMethod>> listPaymentMethods() async {
    final response = await _invoke('list_client_payment_methods');
    final data = _expectMap(response.data);
    final raw = data['paymentMethods'];
    if (raw is! List) return const [];
    return raw
        .map(
          (e) => ClientPaymentMethod.fromJson(
            Map<String, dynamic>.from(e as Map),
          ),
        )
        .toList();
  }

  Future<ClientCustomerSheetData> prepareCustomerSheet() async {
    if (kIsWeb) {
      throw const StripeClientPaymentException(DiscPay.errWebUnsupported);
    }
    if (!StripeService.isConfigured) {
      throw const StripeClientPaymentException(DiscPaymentMethods.unavailable);
    }

    final response = await _invoke('prepare_client_customer_sheet');
    final data = _expectMap(response.data);
    return ClientCustomerSheetData.fromJson(data);
  }

  Future<void> presentCustomerSheet() async {
    if (kIsWeb) {
      throw const StripeClientPaymentException(DiscPay.errWebUnsupported);
    }

    final sheet = await prepareCustomerSheet();

    try {
      await Stripe.instance.initCustomerSheet(
        customerSheetInitParams: CustomerSheetInitParams.adapter(
          customerId: sheet.customerId,
          customerEphemeralKeySecret: sheet.ephemeralKey,
          setupIntentClientSecret: sheet.setupIntentClientSecret,
          merchantDisplayName: 'MadBeauty',
          style: ThemeMode.system,
          headerTextForSelectionScreen: DiscPaymentMethods.customerSheetTitle,
          googlePayEnabled: false,
          applePayEnabled: false,
        ),
      );
      await Stripe.instance.presentCustomerSheet();
    } on StripeException catch (e) {
      if (e.error.code == FailureCode.Canceled) return;
      throw StripeClientPaymentException(
        e.error.localizedMessage ??
            e.error.message ??
            DiscPaymentMethods.sheetErr,
      );
    } on PlatformException catch (e) {
      throw StripeClientPaymentException(e.message ?? e.code);
    }
  }

  /// Portail web (secours si Customer Sheet indisponible).
  Future<String> createBillingPortalUrl() async {
    final response = await _invoke('create_client_billing_portal');
    final data = _expectMap(response.data);
    final url = data['url'] as String?;
    if (url == null || url.isEmpty) {
      throw const StripeClientPaymentException(
        'Portail de paiement indisponible',
      );
    }
    return url;
  }

  Future<FunctionResponse> _invoke(String name) async {
    try {
      return await _client.functions.invoke(name);
    } on FunctionException catch (e) {
      throw _mapError(e.status, e.details);
    }
  }

  Map<String, dynamic> _expectMap(Object? raw) {
    final map = _asMap(raw);
    if (map != null) return map;
    throw const StripeClientPaymentException('Réponse serveur invalide');
  }

  static Map<String, dynamic>? _asMap(Object? raw) {
    if (raw is Map) return Map<String, dynamic>.from(raw);
    if (raw is String && raw.trim().isNotEmpty) {
      try {
        final decoded = jsonDecode(raw);
        if (decoded is Map) return Map<String, dynamic>.from(decoded);
      } catch (_) {}
    }
    return null;
  }

  static StripeClientPaymentException _mapError(int status, Object? raw) {
    final map = _asMap(raw);
    final code = map?['code'] as String?;
    final error = map?['error'] as String? ?? map?['message'] as String?;

    if (error != null && error.trim().isNotEmpty) {
      return StripeClientPaymentException(error.trim(), code: code);
    }
    if (status == 401 || status == 403) {
      return const StripeClientPaymentException('Session expirée');
    }
    return const StripeClientPaymentException(
      DiscPaymentMethods.portalErr,
    );
  }
}
