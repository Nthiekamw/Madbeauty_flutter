import '../../router/prestataire_public_route.dart';

/// Espace métier actuel : détermine la couleur d'accent (client = vert, prestataire = bleu).
enum AppArea {
  client,
  prestataire,
}

AppArea appAreaFromPath(String path) {
  if (isPublicPrestataireProfilePath(path) ||
      path.startsWith('/prestataires')) {
    return AppArea.client;
  }
  if (path.startsWith('/prestataire')) {
    return AppArea.prestataire;
  }
  return AppArea.client;
}

