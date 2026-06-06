import 'package:intl/intl.dart';

/// Montants en euros — format français cohérent dans toute l'app.
abstract final class CurrencyFormat {
  CurrencyFormat._();

  static final NumberFormat _whole = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '€',
    decimalDigits: 0,
  );

  static final NumberFormat _decimals = NumberFormat.currency(
    locale: 'fr_FR',
    symbol: '€',
    decimalDigits: 2,
  );

  static String eur(double amount, {bool decimals = false}) {
    return (decimals ? _decimals : _whole).format(amount);
  }

  static String eurCents(int cents) => eur(cents / 100, decimals: true);
}
