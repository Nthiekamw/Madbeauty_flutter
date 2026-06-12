import 'package:flutter/material.dart';

import '../../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';

/// Squelette pour liste verticale du catalogue (écran listing).
class ListingVerticalSkeleton extends StatelessWidget {
  const ListingVerticalSkeleton({super.key, this.rowCount = 8});

  final int rowCount;

  @override
  Widget build(BuildContext context) {
    return DiscoveryListSkeleton(rowCount: rowCount);
  }
}
