import 'pack_item.dart';
import 'pack_item_type.dart';
import 'pack_offre.dart';
import 'produit_boutique.dart';
import 'service_beaute.dart';

/// Agrégat pack + lignes hydratées + prix catalogue calculé.
class PackOffreDetail {
  const PackOffreDetail({
    required this.pack,
    required this.items,
    required this.prixCatalogue,
  });

  final PackOffre pack;
  final List<PackItem> items;
  final double prixCatalogue;

  double get prixPack => pack.prixPack;

  double? get discountPercent => pack.discountPercent(prixCatalogue);
}

/// Calcule le prix catalogue d’un pack à partir des prix unitaires connus.
double computePackPrixCatalogue({
  required List<PackItem> items,
  required Map<String, ServiceBeaute> servicesById,
  required Map<String, ProduitBoutique> produitsById,
}) {
  var total = 0.0;
  for (final item in items) {
    switch (item.itemType) {
      case PackItemType.service:
        final s =
            item.serviceId == null ? null : servicesById[item.serviceId];
        if (s != null) total += s.prix * item.quantite;
      case PackItemType.produit:
        final p =
            item.produitId == null ? null : produitsById[item.produitId];
        if (p != null) total += p.prix * item.quantite;
    }
  }
  return total;
}
