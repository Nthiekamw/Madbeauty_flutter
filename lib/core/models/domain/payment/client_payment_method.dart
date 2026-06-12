/// Carte enregistrée côté Stripe Customer.
class ClientPaymentMethod {
  const ClientPaymentMethod({
    required this.id,
    required this.brand,
    required this.last4,
    required this.expMonth,
    required this.expYear,
    this.isDefault = false,
  });

  final String id;
  final String brand;
  final String last4;
  final int expMonth;
  final int expYear;
  final bool isDefault;

  factory ClientPaymentMethod.fromJson(Map<String, dynamic> json) {
    return ClientPaymentMethod(
      id: json['id'] as String,
      brand: (json['brand'] as String?)?.toLowerCase() ?? 'unknown',
      last4: json['last4'] as String? ?? '????',
      expMonth: (json['expMonth'] as num?)?.toInt() ?? 0,
      expYear: (json['expYear'] as num?)?.toInt() ?? 0,
      isDefault: json['isDefault'] == true,
    );
  }

  String get brandLabel {
    return switch (brand) {
      'visa' => 'Visa',
      'mastercard' => 'Mastercard',
      'amex' => 'American Express',
      'cartes_bancaires' => 'Carte Bancaire',
      _ => brand.isNotEmpty ? brand : 'Carte',
    };
  }

  String get expiryLabel {
    final m = expMonth.toString().padLeft(2, '0');
    final y = (expYear % 100).toString().padLeft(2, '0');
    return '$m/$y';
  }
}

class ClientCustomerSheetData {
  const ClientCustomerSheetData({
    required this.customerId,
    required this.ephemeralKey,
    required this.setupIntentClientSecret,
  });

  final String customerId;
  final String ephemeralKey;
  final String setupIntentClientSecret;

  factory ClientCustomerSheetData.fromJson(Map<String, dynamic> json) {
    final customerId = json['customerId'] as String?;
    final ephemeralKey = json['ephemeralKey'] as String?;
    final setupIntentClientSecret = json['setupIntentClientSecret'] as String?;
    if (customerId == null ||
        ephemeralKey == null ||
        setupIntentClientSecret == null) {
      throw const FormatException('Réponse Customer Sheet incomplète');
    }
    return ClientCustomerSheetData(
      customerId: customerId,
      ephemeralKey: ephemeralKey,
      setupIntentClientSecret: setupIntentClientSecret,
    );
  }
}
