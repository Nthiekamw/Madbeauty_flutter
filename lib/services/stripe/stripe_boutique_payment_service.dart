import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/stripe_platform_policy.dart';
import '../../core/constants/app_strings.dart';
import '../../features/cart/models/boutique_cart_state.dart';
import 'stripe_booking_payment_service.dart';
import 'stripe_payment_exception.dart';
import 'stripe_service.dart';

/// Paiement commande boutique (PaymentIntent Connect, capture auto).
class StripeBoutiquePaymentService {
  StripeBoutiquePaymentService(this._client);

  final SupabaseClient _client;

  Future<BookingPaymentSheetData> createPaymentIntent({
    required BoutiqueCartState cart,
  }) async {
    if (!StripePlatformPolicy.isEnabled) {
      throw const StripePaymentGenericException(DiscPay.errWebUnsupported);
    }
    if (!StripeService.isConfigured) {
      throw const StripePaymentNotConfiguredException();
    }
    final prestaId = cart.prestataireId?.trim();
    if (prestaId == null || prestaId.isEmpty || cart.isEmpty) {
      throw const StripePaymentGenericException('Panier invalide');
    }

    final response = await _client.functions.invoke(
      'create_boutique_order_payment_intent',
      body: {
        'prestataireId': prestaId,
        'lines': [
          for (final line in cart.lines)
            {
              'produitId': line.produitId,
              'quantite': line.quantite,
            },
        ],
      },
    );

    if (response.status >= 400) {
      final data = response.data;
      final message = data is Map && data['error'] is String
          ? data['error'] as String
          : DiscBoutique.cartCheckoutErr;
      throw StripePaymentGenericException(message);
    }

    final data = response.data;
    if (data is! Map) {
      throw const StripePaymentGenericException(
        'Réponse serveur incomplète (paiement boutique)',
      );
    }
    final map = Map<String, dynamic>.from(data);
    final clientSecret = map['paymentIntentClientSecret'] as String?;
    final paymentIntentId = map['paymentIntentId'] as String?;
    final customerId = map['customerId'] as String?;
    final ephemeralKey = map['ephemeralKey'] as String?;
    if (clientSecret == null ||
        paymentIntentId == null ||
        customerId == null ||
        ephemeralKey == null) {
      throw const StripePaymentGenericException(
        'Réponse serveur incomplète (paiement boutique)',
      );
    }

    return BookingPaymentSheetData(
      paymentIntentId: paymentIntentId,
      paymentIntentClientSecret: clientSecret,
      customerId: customerId,
      ephemeralKey: ephemeralKey,
      amountCents: map['amountCents'] as int? ?? 0,
      currency: map['currency'] as String? ?? 'eur',
    );
  }

  /// Marque la commande payée côté app (le webhook reste la source de vérité).
  Future<void> markCommandePaidByIntent(String paymentIntentId) async {
    await _client
        .from('boutique_commandes')
        .update({
          'statut': 'paid',
          'payment_status': 'paid',
          'paid_at': DateTime.now().toUtc().toIso8601String(),
        })
        .eq('stripe_payment_intent_id', paymentIntentId);
  }
}
