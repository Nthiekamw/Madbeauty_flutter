/// Boutique produits & packs / offres (prestataire + client).
abstract final class DiscBoutique {
  DiscBoutique._();

  // --- Navigation / menus prestataire ---
  static const menuBoutique = 'Ma boutique';
  static const menuBoutiqueHint =
      'Produits physiques visibles sur ta fiche';
  static const menuPacks = 'Packs & offres';
  static const menuPacksHint =
      'Assemblages de services et/ou produits';
  static const editBoutique = 'Gérer la boutique';
  static const editPacks = 'Gérer les packs';

  // --- Dashboard ---
  static const dashSectionTitle = 'Boutique & offres';
  static const dashSectionSubtitle =
      'Produits en vitrine et packs promo pour tes clientes';
  static const dashProduits = 'Produits';
  static const dashPacks = 'Packs';
  static const dashEmptyHint =
      'Ajoute des produits ou crée un pack pour booster ta vitrine.';
  static const dashManageBoutique = 'Boutique';
  static const dashManagePacks = 'Packs';

  // --- Écran boutique prestataire ---
  static const boutiqueTitle = 'Ma boutique';
  static const boutiqueSubtitle =
      'Produits que les clientes voient sur ton onglet Boutique.';
  static const boutiqueEmptyTitle = 'Aucun produit';
  static const boutiqueEmptyBody =
      'Ajoute ton premier produit (soins, accessoires…) pour ouvrir ta boutique.';
  static const boutiqueAdd = 'Ajouter un produit';
  static const boutiqueEdit = 'Modifier le produit';
  static const boutiqueSaved = 'Produit enregistré.';
  static const boutiqueDeactivated = 'Produit retiré de la boutique.';
  static const actionRetirer = 'Retirer';
  static const actionSave = 'Enregistrer';
  static const boutiqueLoadErr =
      'Impossible de charger la boutique. Réessaie.';
  static const boutiqueSaveErr =
      'Impossible d’enregistrer le produit. Réessaie.';

  static const fieldNom = 'Nom du produit';
  static const fieldDescription = 'Description';
  static const fieldConditionnement = 'Conditionnement';
  static const fieldConditionnementHint = 'Ex. 250 ml, 1 pièce';
  static const fieldPrix = 'Prix (€)';
  static const fieldCategorie = 'Catégorie';
  static const fieldPhoto = 'Photo du produit';
  static const actionPickPhoto = 'Ajouter une photo';
  static const actionChangePhoto = 'Changer la photo';
  static const photoUploadErr =
      'Impossible d’envoyer la photo. Réessaie.';
  static const validationNom = 'Indique un nom de produit.';
  static const validationPrix = 'Indique un prix valide (≥ 0).';
  static const validationStock =
      'Indique une quantité en stock valide (≥ 0), ou active le stock illimité.';

  static const fieldStockIllimite = 'Stock illimité';
  static const fieldStockQty = 'Quantité en stock';
  static const stockBadgeUnlimited = 'Illimité';
  static const stockBadgeOut = 'Rupture';
  static String stockBadgeQty(int n) =>
      n <= 0 ? stockBadgeOut : (n == 1 ? '1 en stock' : '$n en stock');
  static const stockLowHint = 'Stock bas';
  static const stockOutClient = 'Rupture de stock';
  static const stockLowClient = 'Plus que quelques exemplaires';
  static const cartRevalidateStockReduced =
      'Certaines quantités ont été ajustées (stock limité).';
  static const cartStockMaxReached = 'Stock maximum atteint pour ce produit.';
  static const cartAddOutOfStock =
      'Ce produit est en rupture de stock.';

  static const catCheveux = 'Cheveux';
  static const catVisage = 'Visage';
  static const catCorps = 'Corps';
  static const catAccessoires = 'Accessoires';
  static const catAutre = 'Autre';
  static const catAll = 'Tout';

  // --- Écran packs prestataire ---
  static const packsTitle = 'Packs & offres';
  static const packsSubtitle =
      'Compose des offres : 2 services, 2 produits, ou un mix.';
  static const packsEmptyTitle = 'Aucun pack';
  static const packsEmptyBody =
      'Crée un pack (ex. Pack Mariage) pour proposer un prix avantageux.';
  static const packsAdd = 'Créer un pack';
  static const packsEdit = 'Modifier le pack';
  /// Libellé court pour la carte liste (évite overflow).
  static const packsActionEdit = 'Modifier';
  static const packsActionPublish = 'Publier';
  static const packsActionUnpublish = 'Dépublier';
  static const packsActionDelete = 'Supprimer';
  static const packsDeleteConfirmTitle = 'Supprimer ce pack ?';
  static const packsDeleteConfirmBody =
      'Cette action est définitive. Les clientes ne le verront plus.';
  static const packsDeleted = 'Pack supprimé.';
  static const packsDeleteErr =
      'Impossible de supprimer le pack. Réessaie.';
  static const packsDeleteInUseErr =
      'Ce pack est lié à des réservations. Dépublie-le plutôt.';
  static const packsSaved = 'Pack enregistré.';
  static const packsDeactivated = 'Pack désactivé.';
  static const packsActivated = 'Pack publié.';
  static const packsLoadErr =
      'Impossible de charger les packs. Réessaie.';
  static const packsSaveErr =
      'Impossible d’enregistrer le pack. Réessaie.';
  static const packsMinItems =
      'Sélectionne au moins 2 éléments (services et/ou produits).';

  static const fieldPackTitre = 'Titre du pack';
  static const fieldPackDescription = 'Description';
  static const fieldPackPrix = 'Prix du pack (€)';
  static const fieldOffreDuJour = 'Offre du jour';
  static const fieldPublier = 'Publier (visible clientes)';
  static const sectionItems = 'Contenu du pack';
  static const sectionServices = 'Services';
  static const sectionProduits = 'Produits boutique';
  static const noServicesHint =
      'Ajoute d’abord des services dans ton catalogue.';
  static const noProduitsHint =
      'Ajoute d’abord des produits dans ta boutique.';
  static const prixCatalogue = 'Prix catalogue';
  static const badgeOffreDuJour = 'Offre du jour';
  static const badgeBrouillon = 'Brouillon';
  static const badgeActif = 'Publié';

  // --- Fiche client ---
  static const navBoutique = 'Boutique';
  static const navOffres = 'Offres';
  static const clientBoutiqueTitle = 'Boutique';
  static const clientBoutiqueEmptyTitle = 'Boutique vide';
  static const clientBoutiqueEmptyBody =
      'Ce prestataire n’a pas encore de produits en vente.';
  static const clientPacksTitle = 'Offres & packs';
  static const clientPacksEmptyTitle = 'Aucune offre';
  static const clientPacksEmptyBody =
      'Pas d’offre spéciale pour le moment.';
  static const clientSearchProduct = 'Rechercher un produit';
  static const actionReserver = 'Réserver';
  static const actionAjouter = 'Ajouter';
  static const actionAddToCart = 'Ajouter au panier';
  static const actionViewCart = 'Voir le panier';
  static const cartTitle = 'Panier boutique';
  static const cartEmptyTitle = 'Panier vide';
  static const cartEmptyBody =
      'Ajoute des produits depuis l’onglet Boutique d’un prestataire.';
  static const cartAdded = 'Produit ajouté au panier.';
  static const cartSwitchedPresta =
      'Panier mis à jour : un seul salon à la fois.';
  static const cartCheckout = 'Commander';
  static const cartCheckoutWebPay = 'Payer maintenant';
  static const cartCheckoutOnSite = 'Commander (payer sur place)';
  static const cartCheckoutGuest =
      'Connecte-toi pour commander.';
  static const cartCheckoutSuccess =
      'Commande enregistrée. Le salon préparera tes produits.';
  static const cartCheckoutSuccessPaid = 'Paiement réussi. Commande confirmée.';
  static const cartCheckoutErr =
      'Impossible de finaliser la commande. Réessaie.';
  static const cartPayWebOnly =
      'Le paiement en ligne des produits est disponible sur le site web. '
      'Tu peux aussi commander et régler sur place.';
  static const cartTotal = 'Total';
  static const packBookServices = 'Réserver le pack';
  static const packAddProducts = 'Ajouter les produits au panier';
  /// CTAs courts sur la fiche publique (évite overflow).
  static const packBookServicesShort = 'Réserver';
  static const packAddProductsShort = 'Au panier';
  static const packMixedHint =
      'Ce pack contient services et produits.';
  static const packBookMultiSoon =
      'La réservation multi-services d’un pack arrive bientôt. '
      'Contacte le salon ou réserve un service unitaire.';
  static const packBookingHeaderLabel = 'Pack sélectionné';
  static const packBookingUnavailableTitle = 'Pack indisponible';
  static const packBookingUnavailableBody =
      'Cette offre n’est plus disponible. Choisis un autre pack ou un service.';
  static const packBookingNoServiceTitle = 'Pack non réservable';
  static const packBookingNoServiceBody =
      'Ce pack ne contient aucun service. Ajoute les produits au panier.';
  static const packContentsTitle = 'Contenu inclus';
  static const packItemService = 'Service';
  static const packItemProduit = 'Produit';
  static const packItemUnavailable = 'Élément indisponible';
  static const packPrixCatalogue = 'Prix catalogue';
  static const packPrixPack = 'Prix du pack';
  static const packSeeDetailsHint = 'Appuie pour voir le détail';
  static const produitSeeDetailsHint = 'Appuie pour voir le détail';
  static String packItemQty(int qty) =>
      qty <= 1 ? '×1' : '×$qty';
  static String packServiceDuration(int minutes) => '$minutes min';
  static String categorieLabel(String dbValue) => switch (dbValue) {
        'cheveux' => catCheveux,
        'visage' => catVisage,
        'corps' => catCorps,
        'accessoires' => catAccessoires,
        _ => catAutre,
      };
  static const cartRevalidateEmpty =
      'Aucun produit du panier n’est plus disponible.';
  static const cartRevalidateRemoved =
      'Certains produits ont été retirés (indisponibles).';
  static const cartRevalidatePrices =
      'Les prix du panier ont été mis à jour.';
  static const menuCart = 'Mon panier';
  static const menuCartHint = 'Produits boutique à commander';
  static const menuClientOrders = 'Mes commandes boutique';
  static const menuClientOrdersHint = 'Suivi de tes achats produits';
  static const clientOrdersTitle = 'Mes commandes boutique';
  static const clientOrdersEmptyTitle = 'Aucune commande';
  static const clientOrdersEmptyBody =
      'Tes commandes de produits apparaîtront ici après un achat.';
  static const clientOrdersLoadErr =
      'Impossible de charger tes commandes. Réessaie.';
  static const clientOrdersUnknownSalon = 'Salon';
  static const clientOrdersGuestBody =
      'Connecte-toi pour suivre tes commandes boutique.';
  static const menuOrders = 'Commandes boutique';
  static const menuOrdersHint = 'Préparer et remettre les commandes clients';
  static const ordersTitle = 'Commandes boutique';
  static const ordersSubtitle =
      'Suivi des commandes produits à préparer ou remettre.';
  static const ordersEmptyTitle = 'Aucune commande';
  static const ordersEmptyBody =
      'Les commandes produits (panier ou inclus dans un pack réservé) '
      'apparaîtront ici.';
  static const ordersPackBadge = 'Inclus pack';
  static const ordersIncludedInBooking = 'Inclus dans la réservation';
  static const ordersLoadErr =
      'Impossible de charger les commandes. Réessaie.';
  static const ordersUpdateErr =
      'Impossible de mettre à jour la commande. Réessaie.';
  static const ordersUpdated = 'Commande mise à jour.';
  static const ordersCanceled = 'Commande annulée.';
  static const ordersUnknownClient = 'Cliente';
  static const ordersActionAdvance = 'Avancer';
  static const ordersActionCancel = 'Annuler';
  static const statutPendingPayment = 'Paiement en attente';
  static const statutPayOnSite = 'À régler sur place';
  static const statutPaid = 'Payée';
  static const statutPreparing = 'En préparation';
  static const statutReady = 'Prête';
  static const statutCompleted = 'Remise confirmée';
  static const statutCanceled = 'Annulée';
  static const dashOrdersOpen = 'Commandes';
  static const dashManageOrders = 'Commandes';
  static const ordersAwaitingClientReceipt =
      'En attente de confirmation de réception par la cliente.';
  static const clientReadyHint =
      'Le salon a préparé ta commande. Confirme quand tu as reçu tes produits.';
  static const clientConfirmReceipt = 'J’ai reçu mes produits';
  static const clientConfirmReceiptSuccess =
      'Réception confirmée. Merci de noter tes produits.';
  static const clientConfirmReceiptErr =
      'Impossible de confirmer la réception. Réessaie.';
  static const clientRateProducts = 'Noter les produits';
  static const clientRateProductsDone = 'Avis publié';
  static const clientReviewTitle = 'Noter tes produits';
  static const clientReviewSubtitle =
      'Ta note aide les autres clientes à choisir leurs soins et produits.';
  static const clientReviewSubmit = 'Publier mon avis';
  static const clientReviewSuccess = 'Merci pour ton avis !';
  static const clientReviewError =
      'Impossible d’enregistrer l’avis. Réessaie.';
  static const clientReviewAlready = 'Tu as déjà noté cette commande.';
  static String dashManageOrdersOpen(int n) =>
      n <= 0 ? dashManageOrders : 'Cmd ($n)';
  static String nextActionLabel(String statutDb) => switch (statutDb) {
        'pay_on_site' || 'paid' => 'Préparer',
        'preparing' => 'Prête',
        _ => ordersActionAdvance,
      };
  static String cartBadge(int n) => n <= 0 ? '' : (n > 99 ? '99+' : '$n');
  static String produitsCount(int n) =>
      n <= 1 ? '$n produit' : '$n produits';
  static String packsCount(int n) => n <= 1 ? '$n pack' : '$n packs';
  static String discountLabel(int percent) => '-$percent %';
  static String prestatairesCount(int n) =>
      n <= 1 ? '$n prestataire' : '$n prestataires';
}
