import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Incrémenté à chaque affichage de l’onglet Profil (client ou prestataire).
final profileTabVisibleTickProvider =
    NotifierProvider<ProfileTabVisibleTickNotifier, int>(
  ProfileTabVisibleTickNotifier.new,
);

class ProfileTabVisibleTickNotifier extends Notifier<int> {
  @override
  int build() => 0;

  void markVisible() => state++;
}
