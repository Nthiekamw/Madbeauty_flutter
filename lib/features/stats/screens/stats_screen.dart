import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(DiscNav.statsTitle)),
    );
  }
}
