import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/catalog/produit_boutique.dart';

/// Ligne wishlist avec produit joint (peut être null si produit inaccessible).
class WishlistEntry {
  const WishlistEntry({
    required this.produitId,
    required this.alertOnRestock,
    required this.alertOnPriceDrop,
    required this.lastSeenPrice,
    this.createdAt,
    this.produit,
  });

  final String produitId;
  final bool alertOnRestock;
  final bool alertOnPriceDrop;
  final double lastSeenPrice;
  final DateTime? createdAt;
  final ProduitBoutique? produit;

  WishlistEntry copyWith({
    bool? alertOnRestock,
    bool? alertOnPriceDrop,
    double? lastSeenPrice,
    ProduitBoutique? produit,
  }) {
    return WishlistEntry(
      produitId: produitId,
      alertOnRestock: alertOnRestock ?? this.alertOnRestock,
      alertOnPriceDrop: alertOnPriceDrop ?? this.alertOnPriceDrop,
      lastSeenPrice: lastSeenPrice ?? this.lastSeenPrice,
      createdAt: createdAt,
      produit: produit ?? this.produit,
    );
  }

  static WishlistEntry fromJson(Map<String, dynamic> json) {
    ProduitBoutique? produit;
    final rawProduit = json['produits_boutique'];
    if (rawProduit is Map) {
      produit = ProduitBoutique.fromJson(
        Map<String, dynamic>.from(rawProduit),
      );
    }

    return WishlistEntry(
      produitId: json['produit_id'] as String,
      alertOnRestock: json['alert_on_restock'] as bool? ?? true,
      alertOnPriceDrop: json['alert_on_price_drop'] as bool? ?? true,
      lastSeenPrice: (json['last_seen_price'] as num?)?.toDouble() ?? 0,
      createdAt: json['created_at'] == null
          ? null
          : DateTime.tryParse(json['created_at'] as String),
      produit: produit,
    );
  }
}

class WishlistService {
  WishlistService(this._client);

  final SupabaseClient _client;

  Future<List<String>> listProduitIds(String clientId) =>
      SupabaseErrorHandler.run(
        operation: 'wishlist.listProduitIds',
        action: () async {
          final response = await _client
              .from('wishlist_produits')
              .select('produit_id')
              .eq('client_id', clientId)
              .order('created_at', ascending: false);

          return (response as List<dynamic>)
              .map((row) => (row as Map)['produit_id'] as String)
              .toList();
        },
      );

  Future<List<WishlistEntry>> listWithProducts(String clientId) =>
      SupabaseErrorHandler.run(
        operation: 'wishlist.listWithProducts',
        action: () async {
          final response = await _client
              .from('wishlist_produits')
              .select(
                'produit_id, alert_on_restock, alert_on_price_drop, '
                'last_seen_price, created_at, produits_boutique(*)',
              )
              .eq('client_id', clientId)
              .order('created_at', ascending: false);

          return (response as List<dynamic>)
              .map(
                (row) => WishlistEntry.fromJson(
                  Map<String, dynamic>.from(row as Map),
                ),
              )
              .toList();
        },
      );

  Future<void> add({
    required String clientId,
    required String produitId,
    required double lastSeenPrice,
    bool alertOnRestock = true,
    bool alertOnPriceDrop = true,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'wishlist.add',
        action: () async {
          await _client.from('wishlist_produits').upsert({
            'client_id': clientId,
            'produit_id': produitId,
            'last_seen_price': lastSeenPrice,
            'alert_on_restock': alertOnRestock,
            'alert_on_price_drop': alertOnPriceDrop,
          });
        },
      );

  Future<void> remove({
    required String clientId,
    required String produitId,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'wishlist.remove',
        action: () async {
          await _client
              .from('wishlist_produits')
              .delete()
              .eq('client_id', clientId)
              .eq('produit_id', produitId);
        },
      );

  Future<void> updateAlerts({
    required String clientId,
    required String produitId,
    bool? alertOnRestock,
    bool? alertOnPriceDrop,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'wishlist.updateAlerts',
        action: () async {
          final patch = <String, dynamic>{};
          if (alertOnRestock != null) {
            patch['alert_on_restock'] = alertOnRestock;
          }
          if (alertOnPriceDrop != null) {
            patch['alert_on_price_drop'] = alertOnPriceDrop;
          }
          if (patch.isEmpty) return;

          await _client
              .from('wishlist_produits')
              .update(patch)
              .eq('client_id', clientId)
              .eq('produit_id', produitId);
        },
      );
}
