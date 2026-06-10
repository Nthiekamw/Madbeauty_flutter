import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/widgets/discovery/discovery_screen_header.dart';
import '../../../../shared/widgets/discovery/discovery_search_card.dart';
import '../../models/listing_catalog_layout.dart';
import '../content/listing_layout_toggle.dart';

/// En-tête recherche : titre léger, champ de recherche, bascule liste / grille.
class ListingSearchHeader extends StatelessWidget {
  const ListingSearchHeader({
    super.key,
    required this.searchController,
    required this.onSearchChanged,
    required this.onSearchClear,
    required this.catalogLayout,
    required this.onCatalogLayoutChanged,
    this.showLayoutToggle = true,
  });

  final TextEditingController searchController;
  final ValueChanged<String> onSearchChanged;
  final VoidCallback onSearchClear;
  final ListingCatalogLayout catalogLayout;
  final ValueChanged<ListingCatalogLayout> onCatalogLayoutChanged;
  final bool showLayoutToggle;

  @override
  Widget build(BuildContext context) {
    final layout = DiscoveryResponsive.of(context);
    final hPad = layout.horizontalPadding;
    final toggle = showLayoutToggle
        ? ListingLayoutToggle(
            layout: catalogLayout,
            onChanged: onCatalogLayoutChanged,
          )
        : null;

    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        mainAxisSize: MainAxisSize.min,
        children: [
          DiscoveryScreenHeader(
            compact: true,
            title: DiscNav.searchTitle,
            icon: Icons.storefront_rounded,
            action: layout.isCompact ? null : toggle,
          ),
          Padding(
            padding: EdgeInsets.fromLTRB(hPad, 0, hPad, 0),
            child: DiscoverySearchCard(
              controller: searchController,
              hint: DiscList.hintSearch,
              onChanged: onSearchChanged,
              suffixIcon: searchController.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).deleteButtonTooltip,
                      onPressed: onSearchClear,
                      icon: Icon(
                        Icons.close_rounded,
                        color: Theme.of(context).colorScheme.onSurfaceVariant,
                      ),
                    ),
            ),
          ),
          if (layout.isCompact && toggle != null)
            Padding(
              padding: EdgeInsets.fromLTRB(hPad, 6, hPad, 0),
              child: Align(
                alignment: Alignment.centerRight,
                child: toggle,
              ),
            ),
        ],
      ),
    );
  }
}

