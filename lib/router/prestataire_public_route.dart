/// Fiche publique `/prestataire/:uuid` (hors espace pro `/prestataire/dashboard`, etc.).
final _uuidPattern = RegExp(
  r'^[0-9a-f]{8}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{4}-[0-9a-f]{12}$',
  caseSensitive: false,
);

const prestataireShellSegments = {
  'dashboard',
  'agenda',
  'clients',
  'messages',
  'profile',
  'horaires',
  'reservations',
};

bool isPublicPrestataireId(String? value) {
  final id = value?.trim();
  if (id == null || id.isEmpty) return false;
  if (prestataireShellSegments.contains(id.toLowerCase())) return false;
  return _uuidPattern.hasMatch(id);
}

bool isPublicPrestataireProfilePath(String location) {
  const prefix = '/prestataire/';
  if (!location.startsWith(prefix)) return false;
  final id = location.substring(prefix.length).split('/').first;
  return isPublicPrestataireId(id);
}
