import '../../models/domain/catalog/pack_item.dart';
import '../../models/domain/catalog/pack_item_type.dart';
import '../../models/domain/catalog/service_beaute.dart';

/// Durée cumulée d’un pack (services × quantité).
int computePackDurationMinutes({
  required List<PackItem> items,
  required Map<String, ServiceBeaute> servicesById,
}) {
  var total = 0;
  for (final item in items) {
    if (item.itemType != PackItemType.service) continue;
    final id = item.serviceId;
    if (id == null) continue;
    final service = servicesById[id];
    final duree = service?.dureeMinutes ?? 30;
    total += (duree < 1 ? 30 : duree) * (item.quantite < 1 ? 1 : item.quantite);
  }
  return total < 1 ? 0 : total;
}

/// True si le créneau [start, start+duration) tient dans [plageStart, plageEnd)
/// (minutes depuis minuit) et ne traverse pas minuit.
bool slotFitsDurationInPlage({
  required int startMinutes,
  required int durationMinutes,
  required int plageStartMinutes,
  required int plageEndMinutes,
}) {
  if (durationMinutes < 1) return false;
  final end = startMinutes + durationMinutes;
  if (end > 24 * 60) return false;
  return startMinutes >= plageStartMinutes && end <= plageEndMinutes;
}

/// Chevauchement d’intervalles semi-ouverts [aStart, aEnd) ∩ [bStart, bEnd).
bool intervalsOverlap({
  required DateTime aStart,
  required DateTime aEnd,
  required DateTime bStart,
  required DateTime bEnd,
}) {
  return aStart.isBefore(bEnd) && aEnd.isAfter(bStart);
}
