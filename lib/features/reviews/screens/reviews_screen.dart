import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

class ReviewsScreen extends StatelessWidget {
  const ReviewsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(DiscoveryStrings.screenReviews)),
    );
  }
}
