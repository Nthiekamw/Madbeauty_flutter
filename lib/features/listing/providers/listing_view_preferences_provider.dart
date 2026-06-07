import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/listing_catalog_layout.dart';
import '../widgets/listing_filters_panel.dart';

/// Préférences d'affichage catalogue (liste/carte, grille/étendu).
class ListingViewPreferences {
  const ListingViewPreferences({
    this.viewMode = ListingViewMode.list,
    this.catalogLayout = ListingCatalogLayout.expanded,
  });

  final ListingViewMode viewMode;
  final ListingCatalogLayout catalogLayout;

  ListingViewPreferences copyWith({
    ListingViewMode? viewMode,
    ListingCatalogLayout? catalogLayout,
  }) {
    return ListingViewPreferences(
      viewMode: viewMode ?? this.viewMode,
      catalogLayout: catalogLayout ?? this.catalogLayout,
    );
  }
}

class ListingViewPreferencesNotifier extends Notifier<ListingViewPreferences> {
  @override
  ListingViewPreferences build() => const ListingViewPreferences();

  void setViewMode(ListingViewMode mode) {
    if (state.viewMode == mode) return;
    state = state.copyWith(viewMode: mode);
  }

  void setCatalogLayout(ListingCatalogLayout layout) {
    if (state.catalogLayout == layout) return;
    state = state.copyWith(catalogLayout: layout);
  }
}

final listingViewPreferencesProvider =
    NotifierProvider<ListingViewPreferencesNotifier, ListingViewPreferences>(
  ListingViewPreferencesNotifier.new,
);

/// Carte grille actuellement développée (pleine largeur dans la liste).
class ListingExpandedCardIdNotifier extends Notifier<String?> {
  @override
  String? build() => null;

  void toggle(String id) {
    state = state == id ? null : id;
  }

  void clear() => state = null;
}

final listingExpandedCardIdProvider =
    NotifierProvider<ListingExpandedCardIdNotifier, String?>(
  ListingExpandedCardIdNotifier.new,
);
