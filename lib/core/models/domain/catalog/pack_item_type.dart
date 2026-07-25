/// Type d’élément dans un pack (service beauté ou produit boutique).
enum PackItemType {
  service,
  produit;

  static PackItemType fromDb(String? raw) {
    final v = raw?.trim().toLowerCase();
    return switch (v) {
      'produit' => produit,
      _ => service,
    };
  }

  String get dbValue => name;
}
