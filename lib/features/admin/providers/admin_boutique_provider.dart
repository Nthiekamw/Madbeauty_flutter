import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../services/supabase/admin/admin_boutique_service.dart';
import '../models/admin_boutique_order_filters.dart';
import '../models/admin_boutique_order_summary.dart';

final adminBoutiqueServiceProvider = Provider<AdminBoutiqueService?>((ref) {
  return AdminBoutiqueService.fromEnv();
});

final adminBoutiqueOrdersProvider = FutureProvider.autoDispose
    .family<List<AdminBoutiqueOrderSummary>, AdminBoutiqueOrderFilters>((
  ref,
  filters,
) async {
  final service = ref.watch(adminBoutiqueServiceProvider);
  if (service == null) return const [];
  return service.listOrders(filters: filters);
});

final adminBoutiqueCatalogProvider =
    FutureProvider.autoDispose.family<List<AdminBoutiqueCatalogRow>, String>((
  ref,
  search,
) async {
  final service = ref.watch(adminBoutiqueServiceProvider);
  if (service == null) return const [];
  return service.listCatalog(search: search);
});
