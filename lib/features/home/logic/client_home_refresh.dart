import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../booking/providers/booking_session_providers.dart';
import '../../listing/providers/client_location_provider.dart';
import '../../profile/providers/current_user_profile_provider.dart';
import '../providers/home_feed_provider.dart';
import '../providers/home_prestataire_entries_provider.dart';
import '../providers/home_profile_provider.dart';
import '../providers/nearby_prestataires_provider.dart';
import '../providers/top_rated_prestataires_provider.dart';

/// Invalide les données affichées sur l’accueil client.
void invalidateClientHome(WidgetRef ref) {
  ref.invalidate(homeProfileSnapshotProvider);
  ref.invalidate(currentUserProfileProvider);
  ref.invalidate(clientLocationProvider);
  ref.invalidate(homeTrendingPrestatairesProvider);
  ref.invalidate(homeFeedPrestataireEntriesProvider);
  ref.invalidate(nearbyPrestatairesProvider);
  ref.invalidate(nearbyPrestataireEntriesProvider);
  ref.invalidate(topRatedPrestatairesProvider);
  ref.invalidate(topRatedPrestataireEntriesProvider);
  invalidateClientReservations(ref);
}

/// Pull-to-refresh : recharge profil, prestataires et prochain RDV.
Future<void> refreshClientHome(WidgetRef ref) async {
  invalidateClientHome(ref);
  await Future.wait([
    ref.read(homeProfileSnapshotProvider.future),
    ref.read(currentUserProfileProvider.future),
    ref.read(clientLocationProvider.future),
    ref.read(homeTrendingPrestatairesProvider.future),
    ref.read(homeFeedPrestataireEntriesProvider.future),
    ref.read(nearbyPrestatairesProvider.future),
    ref.read(nearbyPrestataireEntriesProvider.future),
    ref.read(topRatedPrestatairesProvider.future),
    ref.read(topRatedPrestataireEntriesProvider.future),
    ref.read(clientReservationsProvider.future),
  ]);
}
