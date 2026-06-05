import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/supabase_error_handler.dart';
import '../../../../core/models/domain/catalog/service_beaute.dart';

/// Résultat d’un retrait de services du catalogue prestataire.
class ServiceBeauteRemoveResult {
  const ServiceBeauteRemoveResult({
    this.deletedCount = 0,
    this.deactivatedCount = 0,
  });

  final int deletedCount;
  final int deactivatedCount;

  bool get archivedInsteadOfDeleted => deactivatedCount > 0;
}

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

  /// Retire du catalogue : suppression si possible, sinon `is_actif = false`
  /// (réservations existantes — FK `reservations_service_id_fkey`).
  Future<ServiceBeauteRemoveResult> deleteManyForPrestataire({
    required String prestataireId,
    required List<String> ids,
  }) async {
    if (ids.isEmpty) return const ServiceBeauteRemoveResult();
    return SupabaseErrorHandler.run(
      operation: 'serviceBeaute.deleteManyForPrestataire',
      action: () async {
        final refResponse = await _client
            .from('reservations')
            .select('service_id')
            .inFilter('service_id', ids);
        final referenced = (refResponse as List<dynamic>)
            .map((row) => (row as Map<String, dynamic>)['service_id'] as String)
            .toSet();

        final toDeactivate = ids.where(referenced.contains).toList();
        final toDelete = ids.where((id) => !referenced.contains(id)).toList();

        if (toDeactivate.isNotEmpty) {
          await _client
              .from('services_beaute')
              .update({'is_actif': false})
              .eq('prestataire_id', prestataireId)
              .inFilter('id', toDeactivate);
        }
        if (toDelete.isNotEmpty) {
          await _client
              .from('services_beaute')
              .delete()
              .eq('prestataire_id', prestataireId)
              .inFilter('id', toDelete);
        }

        return ServiceBeauteRemoveResult(
          deletedCount: toDelete.length,
          deactivatedCount: toDeactivate.length,
        );
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

