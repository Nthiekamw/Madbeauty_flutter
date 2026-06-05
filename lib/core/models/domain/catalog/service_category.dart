/// Ligne [categories_service] (filtres chips du listing).
class ServiceCategory {
  const ServiceCategory({
    required this.id,
    required this.nom,
    this.icone,
  });

  final String id;
  final String nom;
  final String? icone;
}

