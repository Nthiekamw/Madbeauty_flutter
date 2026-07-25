/// Ligne du panier boutique (snapshot prix / nom pour affichage offline).
class BoutiqueCartLine {
  const BoutiqueCartLine({
    required this.produitId,
    required this.nom,
    required this.prix,
    required this.quantite,
    this.conditionnement,
    this.imageUrl,
  });

  final String produitId;
  final String nom;
  final double prix;
  final int quantite;
  final String? conditionnement;
  final String? imageUrl;

  double get lineTotal => prix * quantite;

  BoutiqueCartLine copyWith({
    int? quantite,
    String? nom,
    double? prix,
    String? conditionnement,
    String? imageUrl,
  }) =>
      BoutiqueCartLine(
        produitId: produitId,
        nom: nom ?? this.nom,
        prix: prix ?? this.prix,
        quantite: quantite ?? this.quantite,
        conditionnement: conditionnement ?? this.conditionnement,
        imageUrl: imageUrl ?? this.imageUrl,
      );

  Map<String, dynamic> toJson() => {
        'produitId': produitId,
        'nom': nom,
        'prix': prix,
        'quantite': quantite,
        'conditionnement': conditionnement,
        'imageUrl': imageUrl,
      };

  factory BoutiqueCartLine.fromJson(Map<String, dynamic> json) {
    return BoutiqueCartLine(
      produitId: json['produitId'] as String,
      nom: json['nom'] as String? ?? '',
      prix: (json['prix'] as num?)?.toDouble() ?? 0,
      quantite: (json['quantite'] as num?)?.toInt() ?? 1,
      conditionnement: json['conditionnement'] as String?,
      imageUrl: json['imageUrl'] as String?,
    );
  }
}

/// Panier mono-prestataire (un Connect account = un panier).
class BoutiqueCartState {
  const BoutiqueCartState({
    this.prestataireId,
    this.prestataireName,
    this.lines = const [],
  });

  final String? prestataireId;
  final String? prestataireName;
  final List<BoutiqueCartLine> lines;

  static const empty = BoutiqueCartState();

  bool get isEmpty => lines.isEmpty;
  bool get isNotEmpty => lines.isNotEmpty;

  int get totalQuantity =>
      lines.fold<int>(0, (sum, line) => sum + line.quantite);

  double get totalAmount =>
      lines.fold<double>(0, (sum, line) => sum + line.lineTotal);

  Map<String, dynamic> toJson() => {
        'prestataireId': prestataireId,
        'prestataireName': prestataireName,
        'lines': lines.map((e) => e.toJson()).toList(),
      };

  factory BoutiqueCartState.fromJson(Map<String, dynamic>? json) {
    if (json == null || json.isEmpty) return empty;
    final rawLines = json['lines'];
    final lines = <BoutiqueCartLine>[];
    if (rawLines is List) {
      for (final item in rawLines) {
        if (item is Map) {
          lines.add(
            BoutiqueCartLine.fromJson(Map<String, dynamic>.from(item)),
          );
        }
      }
    }
    return BoutiqueCartState(
      prestataireId: json['prestataireId'] as String?,
      prestataireName: json['prestataireName'] as String?,
      lines: List.unmodifiable(lines),
    );
  }
}
