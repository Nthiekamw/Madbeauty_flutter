import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';
import 'package:madbeauty/core/models/domain/user/lieu_travail.dart';
import 'package:madbeauty/core/models/domain/user/user_profile.dart';
import 'package:madbeauty/services/supabase/prestataire/catalog/prestataire_filters.dart';
import 'package:madbeauty/services/supabase/prestataire/catalog/prestataire_service.dart';
import 'package:madbeauty/services/supabase/prestataire/photos/photo_realisation_service.dart';
import 'package:madbeauty/services/supabase/prestataire/profile_form/prestataire_profile_form_service.dart';
import 'package:madbeauty/services/supabase/prestataire/services/service_beaute_service.dart';
import 'package:madbeauty/services/location/geocoding_service.dart';
import 'package:madbeauty/services/supabase/profile/profile_service.dart';
import 'package:madbeauty/services/supabase/storage/storage_service.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const _runIntegration = bool.fromEnvironment(
  'MADBEAUTY_RUN_SUPABASE_INTEGRATION',
);
const _supabaseUrl = String.fromEnvironment('SUPABASE_URL');
const _supabaseAnonKey = String.fromEnvironment('SUPABASE_ANON_KEY');
const _testEmail = String.fromEnvironment('SUPABASE_TEST_EMAIL');
const _testPassword = String.fromEnvironment('SUPABASE_TEST_PASSWORD');

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'services Supabase réels: profils, prestataires, spécialités, services et avatar',
    () async {
      final client = SupabaseClient(_supabaseUrl, _supabaseAnonKey);
      final auth = await client.auth.signInWithPassword(
        email: _testEmail,
        password: _testPassword,
      );
      final user = auth.user;
      expect(user, isNotNull, reason: 'Le compte de test doit exister.');

      final profileService = ProfileService(client);
      final storageService = StorageService(client);
      final photoRealisationService = PhotoRealisationService(
        client,
        storageService: storageService,
      );
      final prestataireService = PrestataireService(
        client,
        profileService: profileService,
      );
      final serviceBeauteService = ServiceBeauteService(client);
      final formService = PrestataireProfileFormService(
        client: client,
        prestataireService: prestataireService,
        serviceBeauteService: serviceBeauteService,
        profileService: profileService,
        storageService: storageService,
        geocodingService: GeocodingService(),
      );

      final originalProfile = await profileService.getByUserId(user!.id);
      final runId = DateTime.now().millisecondsSinceEpoch.toString();
      final salonName = 'Salon intégration $runId';
      final serviceName = 'Service intégration $runId';
      final extraServiceName = 'Service temporaire $runId';

      try {
        final categories = await prestataireService.getServiceCategories();
        expect(categories, isNotEmpty);
        final categoryId = categories.first.id;

        final avatarUrl = await storageService.uploadAvatar(
          userId: user.id,
          file: StorageUploadFile(
            bytes: _onePixelPng,
            fileName: 'avatar_$runId.png',
            mimeType: 'image/png',
          ),
        );
        expect(avatarUrl, contains('profile-photos'));

        await profileService.upsertAvatar(
          userId: user.id,
          avatarUrl: avatarUrl,
        );
        final profileByUserId = await profileService.getByUserId(user.id);
        expect(profileByUserId?.avatarUrl, isNotEmpty);

        if (profileByUserId != null) {
          await profileService.update(
            profileByUserId.copyWith(
              nom: 'Integration',
              prenom: 'Test',
              telephone: '+33000000000',
            ),
          );
          final profileById = await profileService.getById(profileByUserId.id);
          expect(profileById?.nom, 'Integration');

          final profilesByUserId = await profileService.getByUserIds([user.id]);
          expect(profilesByUserId[user.id]?.id, profileByUserId.id);
        }

        await formService.save(
          PrestataireProfileSavePayload(
            nomSalon: salonName,
            nomAffiche: salonName,
            bio: 'Profil créé par le test intégration Supabase.',
            description: 'Salon de test intégration.',
            experienceProfessionnelle: '',
            anneesExperience: '',
            ville: 'Paris',
            adresse: '10 rue de Test',
            codePostal: '75001',
            pays: 'FR',
            lieuTravail: LieuTravail.both,
            avatarBytes: _onePixelPng,
            avatarFileName: 'form_avatar_$runId.png',
            avatarMimeType: 'image/png',
            services: [
              PrestataireServiceFormData(
                nom: serviceName,
                categorieId: categoryId,
                prix: 25,
                dureeMinutes: 45,
              ),
            ],
          ),
        );

        final formData = await formService.fetch();
        expect(formData.prestataireId, isNotNull);
        expect(formData.nomSalon, salonName);
        expect(formData.selectedCategoryIds, contains(categoryId));
        expect(formData.services.map((s) => s.nom), contains(serviceName));

        final prestataire = await prestataireService.getByUserId(user.id);
        expect(prestataire, isNotNull);
        expect(prestataire!.nomSalon, salonName);

        final realisation = await photoRealisationService.uploadAndCreate(
          prestataireId: prestataire.id,
          file: StorageUploadFile(
            bytes: _onePixelPng,
            fileName: 'realisation_$runId.png',
            mimeType: 'image/png',
          ),
        );
        expect(realisation.url, contains('realisation-photos'));
        await photoRealisationService.delete(realisation.id);
        await storageService.deleteFile(realisation.url);

        final prestataireById = await prestataireService.getById(
          prestataire.id,
        );
        expect(prestataireById?.id, prestataire.id);

        await prestataireService.upsert(
          PrestataireUpsertData(
            userId: user.id,
            nomSalon: salonName,
            bio: 'Profil géolocalisé par le test intégration Supabase.',
            ville: 'Paris',
            latitude: 48.8566,
            longitude: 2.3522,
          ),
        );

        final all = await prestataireService.getAll(
          filters: PrestataireFilters(
            query: salonName,
            categoryId: categoryId,
            limit: 1000,
          ),
        );
        expect(all.map((entry) => entry.profile.id), contains(prestataire.id));

        final nearby = await prestataireService.getNearby(
          48.8566,
          2.3522,
          10,
          fetchCap: 1000,
        );
        expect(nearby.map((p) => p.id), contains(prestataire.id));

        final bestRated = await prestataireService.getBestRated(limit: 1000);
        expect(bestRated, isNotEmpty);

        final specialtyNames = await prestataireService.getSpecialtyNames(
          prestataire.id,
        );
        expect(specialtyNames, isNotEmpty);

        final specialtyData = await prestataireService
            .getSpecialtyDataForPrestataires([prestataire.id]);
        expect(
          specialtyData.categoryIdsByPrestataire[prestataire.id],
          contains(categoryId),
        );

        final services = await serviceBeauteService.getByPrestataire(
          prestataire.id,
        );
        expect(services.map((service) => service.nom), contains(serviceName));

        await serviceBeauteService.upsert(
          ServiceBeauteUpsertData(
            prestataireId: prestataire.id,
            nom: extraServiceName,
            prix: 12,
            dureeMinutes: 20,
          ),
        );
        final withExtra = await serviceBeauteService.getByPrestataire(
          prestataire.id,
        );
        final extraService = withExtra.singleWhere(
          (service) => service.nom == extraServiceName,
        );
        expect(extraService.prix, 12);

        await serviceBeauteService.delete(extraService.id);
        final afterDelete = await serviceBeauteService.getByPrestataire(
          prestataire.id,
        );
        expect(
          afterDelete.map((service) => service.id),
          isNot(contains(extraService.id)),
        );

        final ids = await serviceBeauteService.getIdsByPrestataire(
          prestataire.id,
        );
        expect(ids, isNotEmpty);
      } finally {
        await _restoreProfileIfPossible(profileService, originalProfile);
        await client.auth.signOut();
      }
    },
    skip: _integrationSkipReason,
  );
}

String? get _integrationSkipReason {
  if (_runIntegration &&
      _supabaseUrl.isNotEmpty &&
      _supabaseAnonKey.isNotEmpty &&
      _testEmail.isNotEmpty &&
      _testPassword.isNotEmpty) {
    return null;
  }
  return 'Définis MADBEAUTY_RUN_SUPABASE_INTEGRATION=true, SUPABASE_URL, '
      'SUPABASE_ANON_KEY, SUPABASE_TEST_EMAIL et SUPABASE_TEST_PASSWORD.';
}

Future<void> _restoreProfileIfPossible(
  ProfileService profileService,
  UserProfile? originalProfile,
) async {
  if (originalProfile == null) return;
  await profileService.update(originalProfile);
}

final _onePixelPng = Uint8List.fromList(const [
  0x89,
  0x50,
  0x4e,
  0x47,
  0x0d,
  0x0a,
  0x1a,
  0x0a,
  0x00,
  0x00,
  0x00,
  0x0d,
  0x49,
  0x48,
  0x44,
  0x52,
  0x00,
  0x00,
  0x00,
  0x01,
  0x00,
  0x00,
  0x00,
  0x01,
  0x08,
  0x06,
  0x00,
  0x00,
  0x00,
  0x1f,
  0x15,
  0xc4,
  0x89,
  0x00,
  0x00,
  0x00,
  0x0a,
  0x49,
  0x44,
  0x41,
  0x54,
  0x78,
  0x9c,
  0x63,
  0x00,
  0x01,
  0x00,
  0x00,
  0x05,
  0x00,
  0x01,
  0x0d,
  0x0a,
  0x2d,
  0xb4,
  0x00,
  0x00,
  0x00,
  0x00,
  0x49,
  0x45,
  0x4e,
  0x44,
  0xae,
  0x42,
  0x60,
  0x82,
]);
