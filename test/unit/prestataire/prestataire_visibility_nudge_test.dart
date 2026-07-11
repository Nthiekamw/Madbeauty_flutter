import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/models/domain/prestataire/prestataire_subscription_status.dart';
import 'package:madbeauty/core/models/domain/user/lieu_travail.dart';
import 'package:madbeauty/core/models/domain/user/prestataire_profile.dart';
import 'package:madbeauty/features/prestataire/logic/prestataire_visibility_nudge.dart';
import 'package:madbeauty/services/supabase/prestataire/profile_form/prestataire_profile_form_service.dart';

PrestataireProfileFormData _completeForm({
  String adresse = '12 rue de la Paix',
  String codePostal = '75001',
}) {
  return PrestataireProfileFormData(
    nomSalon: 'Salon Test',
    nomAffiche: 'Marie',
    bio: 'Bio',
    description: 'Description complète',
    experienceProfessionnelle: '10 ans',
    anneesExperience: '10',
    ville: 'Paris',
    adresse: adresse,
    codePostal: codePostal,
    lieuTravail: LieuTravail.home,
    avatarUrl: 'https://example.com/avatar.jpg',
    categories: const [],
    selectedCategoryIds: {'cat-1'},
    services: const [
      PrestataireServiceFormData(
        nom: 'Coupe',
        categorieId: 'cat-1',
        prix: 50,
        dureeMinutes: 60,
      ),
    ],
  );
}

void main() {
  test('null si form ou abonnement absent', () {
    expect(
      resolvePrestataireVisibilityNudge(
        form: null,
        storedProfile: null,
        subscription: const PrestataireSubscriptionStatus(status: 'active'),
      ),
      isNull,
    );
    expect(
      resolvePrestataireVisibilityNudge(
        form: _completeForm(),
        storedProfile: null,
        subscription: null,
      ),
      isNull,
    );
  });

  test('profil incomplet → incompleteProfile', () {
    final nudge = resolvePrestataireVisibilityNudge(
      form: PrestataireProfileFormData.empty,
      storedProfile: null,
      subscription: const PrestataireSubscriptionStatus(status: 'active'),
    );

    expect(nudge, isNotNull);
    expect(nudge!.kind, PrestataireVisibilityNudgeKind.incompleteProfile);
    expect(nudge.pushType, 'prestataire_profile_incomplete');
  });

  test('adresse manquante → corps carte', () {
    final nudge = resolvePrestataireVisibilityNudge(
      form: _completeForm(adresse: '', codePostal: ''),
      storedProfile: null,
      subscription: const PrestataireSubscriptionStatus(status: 'active'),
    );

    expect(nudge, isNotNull);
    expect(nudge!.kind, PrestataireVisibilityNudgeKind.incompleteProfile);
    expect(nudge.inAppId, 'prestataire_visibility_incomplete_profile');
  });

  test('profil complet sans abo → needsSubscription', () {
    final nudge = resolvePrestataireVisibilityNudge(
      form: _completeForm(),
      storedProfile: null,
      subscription: const PrestataireSubscriptionStatus(status: 'none'),
    );

    expect(nudge, isNotNull);
    expect(nudge!.kind, PrestataireVisibilityNudgeKind.needsSubscription);
    expect(nudge.pushType, 'prestataire_catalog_visibility');
  });

  test('profil complet + abo sans géoloc → missingMapLocation', () {
    final nudge = resolvePrestataireVisibilityNudge(
      form: _completeForm(),
      storedProfile: PrestataireProfile(
        id: 'p1',
        userId: 'u1',
        createdAt: DateTime.utc(2026),
      ),
      subscription: const PrestataireSubscriptionStatus(status: 'active'),
    );

    expect(nudge, isNotNull);
    expect(nudge!.kind, PrestataireVisibilityNudgeKind.missingMapLocation);
    expect(nudge.pushType, 'prestataire_map_missing');
    expect(nudge.inAppId, 'prestataire_visibility_missing_map');
  });

  test('tout est OK → null', () {
    final nudge = resolvePrestataireVisibilityNudge(
      form: _completeForm(),
      storedProfile: PrestataireProfile(
        id: 'p1',
        userId: 'u1',
        latitude: 48.85,
        longitude: 2.35,
        createdAt: DateTime.utc(2026),
      ),
      subscription: const PrestataireSubscriptionStatus(status: 'active'),
    );

    expect(nudge, isNull);
  });
}
