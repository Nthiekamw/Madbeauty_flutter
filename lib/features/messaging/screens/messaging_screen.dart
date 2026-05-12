import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

class MessagingScreen extends StatelessWidget {
  const MessagingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(child: Text(DiscoveryStrings.screenMessaging)),
    );
  }
}
