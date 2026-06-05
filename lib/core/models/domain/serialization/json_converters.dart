import 'package:json_annotation/json_annotation.dart';

/// Parse les dates renvoyées par Supabase / Postgres (chaîne ISO ou epoch ms).
class IsoDateTimeConverter implements JsonConverter<DateTime, Object?> {
  const IsoDateTimeConverter();

  @override
  DateTime fromJson(Object? json) {
    if (json is String) {
      return DateTime.parse(json);
    }
    if (json is int) {
      return DateTime.fromMillisecondsSinceEpoch(json, isUtc: true);
    }
    throw FormatException('Valeur de date invalide: $json');
  }

  @override
  Object toJson(DateTime object) => object.toIso8601String();
}

class NullableIsoDateTimeConverter
    implements JsonConverter<DateTime?, Object?> {
  const NullableIsoDateTimeConverter();

  @override
  DateTime? fromJson(Object? json) {
    if (json == null) return null;
    return const IsoDateTimeConverter().fromJson(json);
  }

  @override
  Object? toJson(DateTime? object) => object?.toIso8601String();
}

/// `numeric` / `decimal` Postgres : num, String ou null côté JSON.
class DecimalConverter implements JsonConverter<double, Object?> {
  const DecimalConverter();

  @override
  double fromJson(Object? json) {
    if (json == null) {
      throw FormatException('Nombre attendu, reçu null');
    }
    if (json is num) return json.toDouble();
    if (json is String) return double.parse(json);
    throw FormatException('Nombre invalide: $json');
  }

  @override
  Object toJson(double object) => object;
}

class NullableDecimalConverter implements JsonConverter<double?, Object?> {
  const NullableDecimalConverter();

  @override
  double? fromJson(Object? json) {
    if (json == null) return null;
    return const DecimalConverter().fromJson(json);
  }

  @override
  Object? toJson(double? object) => object;
}

