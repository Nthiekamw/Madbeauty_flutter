import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/supabase_error_handler.dart';
import '../../../../core/models/domain/catalog/service_beaute.dart';

class ServiceBeauteUpsertData {
  const ServiceBeauteUpsertData({
    this.id,
    required this.prestataireId,
    required this.nom,
    this.description,
    this.categorieId,
    this.prix = 0,
    this.dureeMinutes = 60,
    this.isActif = true,
  });

  final String? id;
  final String prestataireId;
  final String nom;
  final String? description;
  final String? categorieId;
  final double prix;
  final int dureeMinutes;
  final bool isActif;
}

class ServiceBeauteService {
  ServiceBeauteService(this._client);

  final SupabaseClient _client;

  Future<List<ServiceBeaute>> getByPrestataire(String prestataireId) =>
      SupabaseErrorHandler.run(
        operation: 'serviceBeaute.getByPrestataire',
        action: () async {
          final response = await _client
              .from('services_beaute')
              .select()
              .eq('prestataire_id', prestataireId)
              .eq('is_actif', true)
              .order('nom');
          return (response as List<dynamic>)
              .map((row) => ServiceBeaute.fromJson(row as Map<String, dynamic>))
              .toList();
        },
      );

  Future<void> upsert(ServiceBeauteUpsertData service) =>
      SupabaseErrorHandler.run(
        operation: 'serviceBeaute.upsert',
        action: () async {
          final values = {
            'prestataire_id': service.prestataireId,
            'nom': service.nom.trim(),
            'prix': service.prix,
            'duree_minutes': service.dureeMinutes,
            'is_actif': service.isActif,
            if (service.description != null &&
                service.description!.trim().isNotEmpty)
              'description': service.description!.trim(),
            if (service.categorieId != null &&
                service.categorieId!.trim().isNotEmpty)
              'categorie_id': service.categorieId!.trim(),
          };

          final id = service.id;
          if (id == null) {
            await _client.from('services_beaute').insert(values);
            return;
          }

          await _client
              .from('services_beaute')
              .update(values)
              .eq('prestataire_id', service.prestataireId)
              .eq('id', id);
        },
      );

  Future<void> delete(String id) => SupabaseErrorHandler.run(
    operation: 'serviceBeaute.delete',
    action: () async {
      await _client.from('services_beaute').delete().eq('id', id);
    },
  );

  Future<void> deleteManyForPrestataire({
    required String prestataireId,
    required List<String> ids,
  }) async {
    if (ids.isEmpty) return;
    await SupabaseErrorHandler.run(
      operation: 'serviceBeaute.deleteManyForPrestataire',
      action: () async {
        await _client
            .from('services_beaute')
            .delete()
            .eq('prestataire_id', prestataireId)
            .inFilter('id', ids);
      },
    );
  }

  Future<Set<String>> getIdsByPrestataire(String prestataireId) =>
      SupabaseErrorHandler.run(
        operation: 'serviceBeaute.getIdsByPrestataire',
        action: () async {
          final response = await _client
              .from('services_beaute')
              .select('id')
              .eq('prestataire_id', prestataireId);
          return (response as List<dynamic>)
              .map((row) => (row as Map<String, dynamic>)['id'] as String?)
              .whereType<String>()
              .toSet();
        },
      );
}
