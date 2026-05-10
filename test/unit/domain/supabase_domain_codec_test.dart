import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/models/domain/domain.dart';

/// Données mock style PostgREST (snake_case, timestamps ISO, numeric en nombre ou chaîne).
void main() {
  group('SupabaseDomainCodec + toSupabaseMap', () {
    test('AppUser roundtrip + omitNullKeys', () {
      final row = <String, dynamic>{
        'id': '11111111-1111-1111-1111-111111111111',
        'email': 'client@example.com',
        'password_hash': null,
        'created_at': '2026-05-10T12:00:00.000Z',
      };
      final m = SupabaseDomainCodec.appUser(row);
      expect(m.email, 'client@example.com');
      final full = m.toSupabaseMap();
      expect(full['password_hash'], isNull);
      final sparse = m.toSupabaseMap(omitNullKeys: true);
      expect(sparse.containsKey('password_hash'), isFalse);
      final again = AppUser.fromJson(full);
      expect(again, m);
    });

    test('UserProfile', () {
      final row = <String, dynamic>{
        'id': '22222222-2222-2222-2222-222222222222',
        'user_id': '11111111-1111-1111-1111-111111111111',
        'nom': 'Dupont',
        'prenom': 'Amina',
        'avatar_url': 'https://cdn.example/a.png',
        'telephone': '+33600000000',
        'updated_at': '2026-05-10T14:30:00.000Z',
      };
      final m = SupabaseDomainCodec.userProfile(row);
      final map = m.toSupabaseMap();
      expect(SupabaseDomainCodec.userProfile(map), m);
    });

    test('ClientProfile', () {
      final row = <String, dynamic>{
        'id': '33333333-3333-3333-3333-333333333333',
        'user_id': '11111111-1111-1111-1111-111111111111',
        'adresse': '10 rue de Paris',
        'created_at': '2026-05-01T08:00:00.000Z',
      };
      final m = SupabaseDomainCodec.clientProfile(row);
      expect(SupabaseDomainCodec.clientProfile(m.toSupabaseMap()), m);
    });

    test('PrestataireProfile (numeric note, bool)', () {
      final row = <String, dynamic>{
        'id': '44444444-4444-4444-4444-444444444444',
        'user_id': '55555555-5555-5555-5555-555555555555',
        'nom_salon': 'Studio Afro',
        'bio': 'Spécialiste tresses',
        'ville': 'Lyon',
        'latitude': 45.764043,
        'longitude': 4.835659,
        'note_moyenne': 4.7,
        'is_verified': true,
        'created_at': '2026-04-20T10:00:00.000Z',
      };
      final m = SupabaseDomainCodec.prestataireProfile(row);
      expect(m.noteMoyenne, 4.7);
      expect(SupabaseDomainCodec.prestataireProfile(m.toSupabaseMap()), m);
    });

    test('CategorieService', () {
      final row = <String, dynamic>{
        'id': '66666666-6666-6666-6666-666666666666',
        'nom': 'Coiffure afro',
        'icone': 'hair',
      };
      final m = SupabaseDomainCodec.categorieService(row);
      expect(SupabaseDomainCodec.categorieService(m.toSupabaseMap()), m);
    });

    test('PrestataireSpecialite', () {
      final row = <String, dynamic>{
        'prestataire_id': '44444444-4444-4444-4444-444444444444',
        'categorie_id': '66666666-6666-6666-6666-666666666666',
      };
      final m = SupabaseDomainCodec.prestataireSpecialite(row);
      expect(SupabaseDomainCodec.prestataireSpecialite(m.toSupabaseMap()), m);
    });

    test('ServiceBeaute (prix num puis string)', () {
      final rowNum = <String, dynamic>{
        'id': '77777777-7777-7777-7777-777777777777',
        'prestataire_id': '44444444-4444-4444-4444-444444444444',
        'nom': 'Vanilles',
        'duree_minutes': 120,
        'prix': 45.5,
        'is_actif': true,
      };
      final fromNum = SupabaseDomainCodec.serviceBeaute(rowNum);
      expect(fromNum.prix, 45.5);

      final rowStr = Map<String, dynamic>.from(rowNum)..['prix'] = '55.00';
      final fromStr = SupabaseDomainCodec.serviceBeaute(rowStr);
      expect(fromStr.prix, 55.0);
    });

    test('Reservation', () {
      final row = <String, dynamic>{
        'id': '88888888-8888-8888-8888-888888888888',
        'client_id': '33333333-3333-3333-3333-333333333333',
        'prestataire_id': '44444444-4444-4444-4444-444444444444',
        'service_id': '77777777-7777-7777-7777-777777777777',
        'date_heure': '2026-06-15T15:00:00.000Z',
        'statut': 'confirmee',
        'notes_client': 'Sans ammoniaque',
        'created_at': '2026-05-10T09:00:00.000Z',
      };
      final m = SupabaseDomainCodec.reservation(row);
      expect(SupabaseDomainCodec.reservation(m.toSupabaseMap()), m);
    });

    test('Avis', () {
      final row = <String, dynamic>{
        'id': '99999999-9999-9999-9999-999999999999',
        'client_id': '33333333-3333-3333-3333-333333333333',
        'prestataire_id': '44444444-4444-4444-4444-444444444444',
        'reservation_id': '88888888-8888-8888-8888-888888888888',
        'note': 5,
        'commentaire': 'Parfait',
        'created_at': '2026-05-11T18:00:00.000Z',
      };
      final m = SupabaseDomainCodec.avis(row);
      expect(SupabaseDomainCodec.avis(m.toSupabaseMap()), m);
    });

    test('PhotoRealisation', () {
      final row = <String, dynamic>{
        'id': 'aaaaaaaa-aaaa-aaaa-aaaa-aaaaaaaaaaaa',
        'prestataire_id': '44444444-4444-4444-4444-444444444444',
        'url': 'https://cdn.example/p.jpg',
        'caption': 'Nattes',
        'categorie_id': '66666666-6666-6666-6666-666666666666',
        'created_at': '2026-05-09T12:00:00.000Z',
      };
      final m = SupabaseDomainCodec.photoRealisation(row);
      expect(SupabaseDomainCodec.photoRealisation(m.toSupabaseMap()), m);
    });

    test('Favori', () {
      final row = <String, dynamic>{
        'client_id': '33333333-3333-3333-3333-333333333333',
        'prestataire_id': '44444444-4444-4444-4444-444444444444',
        'created_at': '2026-05-08T20:00:00.000Z',
      };
      final m = SupabaseDomainCodec.favori(row);
      expect(SupabaseDomainCodec.favori(m.toSupabaseMap()), m);
    });

    test('Conversation (last_message_at null)', () {
      final row = <String, dynamic>{
        'id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        'client_id': '33333333-3333-3333-3333-333333333333',
        'prestataire_id': '44444444-4444-4444-4444-444444444444',
        'last_message_at': null,
      };
      final m = SupabaseDomainCodec.conversation(row);
      expect(m.lastMessageAt, isNull);
      final encoded = m.toSupabaseMap();
      expect(SupabaseDomainCodec.conversation(encoded), m);
    });

    test('Conversation avec last_message_at', () {
      final row = <String, dynamic>{
        'id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        'client_id': '33333333-3333-3333-3333-333333333333',
        'prestataire_id': '44444444-4444-4444-4444-444444444444',
        'last_message_at': '2026-05-10T16:00:00.000Z',
      };
      final m = SupabaseDomainCodec.conversation(row);
      expect(m.lastMessageAt, isNotNull);
    });

    test('Message', () {
      final row = <String, dynamic>{
        'id': 'cccccccc-cccc-cccc-cccc-cccccccccccc',
        'conversation_id': 'bbbbbbbb-bbbb-bbbb-bbbb-bbbbbbbbbbbb',
        'sender_id': '33333333-3333-3333-3333-333333333333',
        'contenu': 'Bonjour, je suis disponible samedi.',
        'is_read': false,
        'created_at': '2026-05-10T16:05:00.000Z',
      };
      final m = SupabaseDomainCodec.message(row);
      expect(SupabaseDomainCodec.message(m.toSupabaseMap()), m);
    });

    test('SupabaseDomainCodec.row copie défensive', () {
      final source = <String, dynamic>{
        'id': '11111111-1111-1111-1111-111111111111',
        'email': 'x@y.z',
        'created_at': '2026-01-01T00:00:00.000Z',
      };
      final copy = SupabaseDomainCodec.row(source);
      source['email'] = 'hacked@evil.com';
      final m = SupabaseDomainCodec.appUser(copy);
      expect(m.email, 'x@y.z');
    });
  });
}
