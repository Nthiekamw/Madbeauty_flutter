import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/errors/supabase_error_handler.dart';
import '../../../core/models/domain/admin/admin_boutique_order_filters.dart';
import '../../../core/models/domain/admin/admin_boutique_order_summary.dart';
import '../supabase_service.dart';

class AdminBoutiqueService {
  AdminBoutiqueService(this._client);

  final SupabaseClient _client;

  factory AdminBoutiqueService.fromEnv() =>
      AdminBoutiqueService(SupabaseService.client);

  Future<List<AdminBoutiqueOrderSummary>> listOrders({
    AdminBoutiqueOrderFilters filters = const AdminBoutiqueOrderFilters(),
  }) =>
      SupabaseErrorHandler.run(
        operation: 'adminBoutique.listOrders',
        action: () async {
          final rows = await _client.rpc(
            'admin_list_boutique_orders',
            params: {
              'p_limit': filters.limit,
              'p_statut': _emptyToNull(filters.statut),
              'p_payment_status': _emptyToNull(filters.paymentStatus),
              'p_from_date': filters.fromDate?.toUtc().toIso8601String(),
              'p_to_date': filters.toDate?.toUtc().toIso8601String(),
              'p_search': _emptyToNull(filters.search),
            },
          );
          final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
          return list.map(_mapOrder).toList();
        },
      );

  Future<List<AdminBoutiqueCatalogRow>> listCatalog({
    String? search,
    int limit = 200,
  }) =>
      SupabaseErrorHandler.run(
        operation: 'adminBoutique.listCatalog',
        action: () async {
          final rows = await _client.rpc(
            'admin_list_boutique_catalog',
            params: {
              'p_limit': limit,
              'p_search': _emptyToNull(search),
            },
          );
          final list = (rows as List<dynamic>).cast<Map<String, dynamic>>();
          return list.map(_mapCatalog).toList();
        },
      );

  String? _emptyToNull(String? value) {
    final trimmed = value?.trim();
    if (trimmed == null || trimmed.isEmpty) return null;
    return trimmed;
  }

  AdminBoutiqueOrderSummary _mapOrder(Map<String, dynamic> row) {
    return AdminBoutiqueOrderSummary(
      id: row['id'] as String? ?? '',
      createdAt: DateTime.tryParse((row['created_at'] as String?) ?? '') ??
          DateTime.fromMillisecondsSinceEpoch(0),
      statut: row['statut'] as String? ?? '',
      paymentStatus: row['payment_status'] as String? ?? '',
      amountCents: (row['amount_cents'] as num?)?.toInt() ?? 0,
      currency: row['currency'] as String? ?? 'eur',
      fulfillment: row['fulfillment'] as String?,
      clientName: row['client_name'] as String?,
      prestataireSalon: row['prestataire_salon'] as String?,
      prestataireId: row['prestataire_id'] as String? ?? '',
      itemsCount: (row['items_count'] as num?)?.toInt() ?? 0,
      stripePaymentIntentId: row['stripe_payment_intent_id'] as String?,
      paidAt: DateTime.tryParse((row['paid_at'] as String?) ?? ''),
    );
  }

  AdminBoutiqueCatalogRow _mapCatalog(Map<String, dynamic> row) {
    return AdminBoutiqueCatalogRow(
      prestataireId: row['prestataire_id'] as String? ?? '',
      prestataireSalon: row['prestataire_salon'] as String? ?? 'Salon',
      ville: row['ville'] as String?,
      produitsActifs: (row['produits_actifs'] as num?)?.toInt() ?? 0,
      produitsTotal: (row['produits_total'] as num?)?.toInt() ?? 0,
      packsActifs: (row['packs_actifs'] as num?)?.toInt() ?? 0,
      packsTotal: (row['packs_total'] as num?)?.toInt() ?? 0,
      commandesOuvertes: (row['commandes_ouvertes'] as num?)?.toInt() ?? 0,
      commandesTotal: (row['commandes_total'] as num?)?.toInt() ?? 0,
    );
  }
}
