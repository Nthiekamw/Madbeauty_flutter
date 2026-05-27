import 'package:madbeauty/core/models/domain/booking/favori.dart';
import 'package:madbeauty/core/models/domain/booking/reservation.dart';
import 'package:madbeauty/core/models/domain/catalog/categorie_service.dart';
import 'package:madbeauty/core/models/domain/catalog/photo_realisation.dart';
import 'package:madbeauty/core/models/domain/catalog/prestataire_specialite.dart';
import 'package:madbeauty/core/models/domain/catalog/service_beaute.dart';
import 'package:madbeauty/core/models/domain/messaging/conversation.dart';
import 'package:madbeauty/core/models/domain/messaging/message.dart';
import 'package:madbeauty/core/models/domain/reviews/avis.dart';
import 'package:madbeauty/core/models/domain/reviews/review.dart';
import 'package:madbeauty/core/models/domain/user/app_user.dart';
import 'package:madbeauty/core/models/domain/user/client_profile.dart';
import 'package:madbeauty/core/models/domain/user/prestataire_profile.dart';
import 'package:madbeauty/core/models/domain/user/user_profile.dart';

/// Sérialisation des lignes PostgREST / [Map] passés à Supabase `.insert()` / `.update()`.
///
/// - [SupabaseDomainCodec.row] : copie défensive (réponse API ou map mutable).
/// - [SupabaseDomainCodec.decode*] : `fromJson` explicite pour une ligne Supabase.
/// - [toSupabaseMap] (extensions) : `toJson` + option d’omettre les clés `null` (upserts partiels).
abstract final class SupabaseDomainCodec {
  const SupabaseDomainCodec._();

  /// Copie plate pour éviter les mutations accidentelles du [Map] source.
  static Map<String, dynamic> row(Map<String, dynamic> source) =>
      Map<String, dynamic>.from(source);

  /// Prépare un [Map] pour `.insert()` / `.update()` à partir du JSON du modèle.
  static Map<String, dynamic> toMap(
    Map<String, dynamic> json, {
    bool omitNullKeys = false,
  }) {
    final m = Map<String, dynamic>.from(json);
    if (omitNullKeys) {
      m.removeWhere((_, value) => value == null);
    }
    return m;
  }

  static AppUser appUser(Map<String, dynamic> r) => AppUser.fromJson(row(r));

  static UserProfile userProfile(Map<String, dynamic> r) =>
      UserProfile.fromJson(row(r));

  static ClientProfile clientProfile(Map<String, dynamic> r) =>
      ClientProfile.fromJson(row(r));

  static PrestataireProfile prestataireProfile(Map<String, dynamic> r) =>
      PrestataireProfile.fromJson(row(r));

  static CategorieService categorieService(Map<String, dynamic> r) =>
      CategorieService.fromJson(row(r));

  static PrestataireSpecialite prestataireSpecialite(Map<String, dynamic> r) =>
      PrestataireSpecialite.fromJson(row(r));

  static ServiceBeaute serviceBeaute(Map<String, dynamic> r) =>
      ServiceBeaute.fromJson(row(r));

  static Reservation reservation(Map<String, dynamic> r) =>
      Reservation.fromJson(row(r));

  static Avis avis(Map<String, dynamic> r) => Avis.fromJson(row(r));

  static Review review(Map<String, dynamic> r) => Review.fromJson(row(r));

  static PhotoRealisation photoRealisation(Map<String, dynamic> r) =>
      PhotoRealisation.fromJson(row(r));

  static Favori favori(Map<String, dynamic> r) => Favori.fromJson(row(r));

  static Conversation conversation(Map<String, dynamic> r) =>
      Conversation.fromJson(row(r));

  static Message message(Map<String, dynamic> r) {
    final m = row(r);
    if (m['content'] == null && m['contenu'] != null) {
      m['content'] = m['contenu'];
    }
    return Message.fromJson(m);
  }
}

extension AppUserSupabaseMap on AppUser {
  Map<String, dynamic> toSupabaseMap({bool omitNullKeys = false}) =>
      SupabaseDomainCodec.toMap(toJson(), omitNullKeys: omitNullKeys);
}

extension UserProfileSupabaseMap on UserProfile {
  Map<String, dynamic> toSupabaseMap({bool omitNullKeys = false}) =>
      SupabaseDomainCodec.toMap(toJson(), omitNullKeys: omitNullKeys);
}

extension ClientProfileSupabaseMap on ClientProfile {
  Map<String, dynamic> toSupabaseMap({bool omitNullKeys = false}) =>
      SupabaseDomainCodec.toMap(toJson(), omitNullKeys: omitNullKeys);
}

extension PrestataireProfileSupabaseMap on PrestataireProfile {
  Map<String, dynamic> toSupabaseMap({bool omitNullKeys = false}) =>
      SupabaseDomainCodec.toMap(toJson(), omitNullKeys: omitNullKeys);
}

extension CategorieServiceSupabaseMap on CategorieService {
  Map<String, dynamic> toSupabaseMap({bool omitNullKeys = false}) =>
      SupabaseDomainCodec.toMap(toJson(), omitNullKeys: omitNullKeys);
}

extension PrestataireSpecialiteSupabaseMap on PrestataireSpecialite {
  Map<String, dynamic> toSupabaseMap({bool omitNullKeys = false}) =>
      SupabaseDomainCodec.toMap(toJson(), omitNullKeys: omitNullKeys);
}

extension ServiceBeauteSupabaseMap on ServiceBeaute {
  Map<String, dynamic> toSupabaseMap({bool omitNullKeys = false}) =>
      SupabaseDomainCodec.toMap(toJson(), omitNullKeys: omitNullKeys);
}

extension ReservationSupabaseMap on Reservation {
  Map<String, dynamic> toSupabaseMap({bool omitNullKeys = false}) =>
      SupabaseDomainCodec.toMap(toJson(), omitNullKeys: omitNullKeys);
}

extension AvisSupabaseMap on Avis {
  Map<String, dynamic> toSupabaseMap({bool omitNullKeys = false}) =>
      SupabaseDomainCodec.toMap(toJson(), omitNullKeys: omitNullKeys);
}

extension ReviewSupabaseMap on Review {
  Map<String, dynamic> toSupabaseMap({bool omitNullKeys = false}) =>
      SupabaseDomainCodec.toMap(toJson(), omitNullKeys: omitNullKeys);
}

extension PhotoRealisationSupabaseMap on PhotoRealisation {
  Map<String, dynamic> toSupabaseMap({bool omitNullKeys = false}) =>
      SupabaseDomainCodec.toMap(toJson(), omitNullKeys: omitNullKeys);
}

extension FavoriSupabaseMap on Favori {
  Map<String, dynamic> toSupabaseMap({bool omitNullKeys = false}) =>
      SupabaseDomainCodec.toMap(toJson(), omitNullKeys: omitNullKeys);
}

extension ConversationSupabaseMap on Conversation {
  Map<String, dynamic> toSupabaseMap({bool omitNullKeys = false}) =>
      SupabaseDomainCodec.toMap(toJson(), omitNullKeys: omitNullKeys);
}

extension MessageSupabaseMap on Message {
  Map<String, dynamic> toSupabaseMap({bool omitNullKeys = false}) =>
      SupabaseDomainCodec.toMap(toJson(), omitNullKeys: omitNullKeys);
}
