/// Wishlist produits boutique (client).
abstract final class DiscWishlist {
  DiscWishlist._();

  static const screenTitle = 'Ma wishlist';
  static const profileSectionTitle = 'Ma wishlist';
  static const profileSectionHint =
      'Produits enregistrés et alertes stock / prix';
  static const emptyTitle = 'Aucun produit enregistré';
  static const emptyBody =
      'Appuie sur le cœur sur une fiche produit pour le garder '
      'dans ta liste et recevoir des alertes.';
  static const loginRequired =
      'Connecte-toi pour enregistrer des produits dans ta wishlist.';
  static const toggleError =
      'Impossible de mettre à jour la wishlist. Réessaie.';
  static const loadErrorTitle = 'Impossible de charger ta wishlist';
  static const loadErrorBody =
      'Vérifie ta connexion et réessaie.';
  static const addTooltip = 'Ajouter à la wishlist';
  static const removeTooltip = 'Retirer de la wishlist';
  static const addedFeedback = 'Produit ajouté à ta wishlist.';
  static const removedFeedback = 'Produit retiré de ta wishlist.';
  static const alertRestock = 'Alerte réassort';
  static const alertRestockHint =
      'Préviens-moi quand le produit est de nouveau en stock';
  static const alertPriceDrop = 'Alerte baisse de prix';
  static const alertPriceDropHint =
      'Préviens-moi si le prix baisse';
  static const alertUpdateError =
      'Impossible de mettre à jour les alertes. Réessaie.';
  static const removeAction = 'Retirer';
  static const outOfStockBadge = 'Rupture de stock';
  static const browseAction = 'Découvrir des produits';
}
