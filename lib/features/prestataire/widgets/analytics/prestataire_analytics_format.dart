import 'package:intl/intl.dart';

/// Format monétaire partagé pour les blocs analytiques prestataire.
final prestataireAnalyticsCurrency = NumberFormat.currency(
  locale: 'fr_FR',
  symbol: '€',
  decimalDigits: 0,
);
