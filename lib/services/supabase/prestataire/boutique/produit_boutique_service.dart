import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../../core/errors/supabase_error_handler.dart';
import '../../../../core/models/domain/catalog/produit_boutique.dart';
import '../../storage/storage_service.dart';

class ProduitBoutiqueUpsertData {
  const ProduitBoutiqueUpsertData({
    this.id,
    required this.prestataireId,
    required this.nom,
    this.description,
    this.conditionnement,
    this.categorie = ProduitBoutiqueCategorie.autre,
    this.prix = 0,
    this.imageUrl,
    this.isActif = true,
  });

  final String? id;
  final String prestataireId;
  final String nom;
  final String? description;
  final String? conditionnement;
  final ProduitBoutiqueCategorie categorie;
  final double prix;
  final String? imageUrl;
  final bool isActif;
}

class ProduitBoutiqueService {
  ProduitBoutiqueService(this._client, {StorageService? storageService})
      : _storageService = storageService;

  final SupabaseClient _client;
  final StorageService? _storageService;

  Future<List<ProduitBoutique>> getByPrestataire(
    String prestataireId, {
    bool actifsOnly = true,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'produitBoutique.getByPrestataire',
        action: () async {
          var query = _client
              .from('produits_boutique')
              .select()
              .eq('prestataire_id', prestataireId);
          if (actifsOnly) {
            query = query.eq('is_actif', true);
          }
          final response = await query.order('nom');
          return (response as List<dynamic>)
              .map(
                (row) =>
                    ProduitBoutique.fromJson(row as Map<String, dynamic>),
              )
              .toList();
        },
      );

  Future<ProduitBoutique> upsert(ProduitBoutiqueUpsertData data) =>
      SupabaseErrorHandler.run(
        operation: 'produitBoutique.upsert',
        action: () async {
          final values = <String, dynamic>{
            'prestataire_id': data.prestataireId,
            'nom': data.nom.trim(),
            'prix': data.prix,
            'categorie': data.categorie.dbValue,
            'is_actif': data.isActif,
            if (data.description != null &&
                data.description!.trim().isNotEmpty)
              'description': data.description!.trim()
            else
              'description': null,
            if (data.conditionnement != null &&
                data.conditionnement!.trim().isNotEmpty)
              'conditionnement': data.conditionnement!.trim()
            else
              'conditionnement': null,
            if (data.imageUrl != null && data.imageUrl!.trim().isNotEmpty)
              'image_url': data.imageUrl!.trim()
            else
              'image_url': null,
          };

          final id = data.id;
          if (id == null) {
            final inserted = await _client
                .from('produits_boutique')
                .insert(values)
                .select()
                .single();
            return ProduitBoutique.fromJson(inserted);
          }

          final updated = await _client
              .from('produits_boutique')
              .update(values)
              .eq('prestataire_id', data.prestataireId)
              .eq('id', id)
              .select()
              .single();
          return ProduitBoutique.fromJson(updated);
        },
      );

  Future<String> uploadImage({
    required String prestataireId,
    required StorageUploadFile file,
  }) {
    final storage = _storageService;
    if (storage == null) {
      throw StateError('StorageService requis pour uploader une image produit.');
    }
    return storage.uploadRealisation(
      prestataireId: prestataireId,
      file: file,
    );
  }

  /// Soft-delete : `is_actif = false` (conserve les packs qui référencent).
  Future<void> deactivate({
    required String prestataireId,
    required String id,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'produitBoutique.deactivate',
        action: () async {
          await _client
              .from('produits_boutique')
              .update({'is_actif': false})
              .eq('prestataire_id', prestataireId)
              .eq('id', id);
        },
      );

  Future<int> countActifs(String prestataireId) => SupabaseErrorHandler.run(
        operation: 'produitBoutique.countActifs',
        action: () async {
          final response = await _client
              .from('produits_boutique')
              .select('id')
              .eq('prestataire_id', prestataireId)
              .eq('is_actif', true);
          return (response as List<dynamic>).length;
        },
      );
}
