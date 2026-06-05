import 'package:flutter/material.dart';

import '../../listing/screens/listing_screen.dart';

/// Alias vers le catalogue / exploration (même UX que [ListingScreen]).
class SearchScreen extends StatelessWidget {
  const SearchScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const ListingScreen();
  }
}

