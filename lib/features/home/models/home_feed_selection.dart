/// Sélection active sur l'accueil (recherche ou inspiration).
enum HomeFeedSource { search, inspiration }

class HomeFeedSelection {
  const HomeFeedSelection({
    required this.query,
    required this.source,
  });

  final String query;
  final HomeFeedSource source;
}

