import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../../router/navigation_extensions.dart';

/// Profil prestataire, services, disponibilités — voir README.
class PrestataireHubScreen extends StatelessWidget {
  const PrestataireHubScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(AppStrings.screenPrestataireHub),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.canPop() ? context.pop() : context.goHome(),
        ),
      ),
      body: Center(child: Text(AppStrings.screenPrestataireHub)),
    );
  }
}
