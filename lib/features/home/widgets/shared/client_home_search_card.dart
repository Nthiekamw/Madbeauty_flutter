import 'package:flutter/material.dart';

import '../../../../shared/widgets/discovery/discovery_search_card.dart';

/// Barre de recherche mise en avant sur l’accueil.
class ClientHomeSearchCard extends StatelessWidget {
  const ClientHomeSearchCard({
    super.key,
    required this.controller,
    required this.hint,
    required this.searchTooltip,
    required this.onSubmit,
    this.onChanged,
  });

  final TextEditingController controller;
  final String hint;
  final String searchTooltip;
  final VoidCallback onSubmit;
  final ValueChanged<String>? onChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DiscoverySearchCard(
      controller: controller,
      hint: hint,
      onChanged: onChanged,
      onSubmitted: onSubmit,
      suffixIcon: IconButton.filled(
        tooltip: searchTooltip,
        onPressed: onSubmit,
        style: IconButton.styleFrom(
          backgroundColor: theme.colorScheme.primary,
          foregroundColor: theme.colorScheme.onPrimary,
          minimumSize: const Size(40, 40),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        icon: const Icon(Icons.arrow_forward_rounded, size: 20),
      ),
    );
  }
}

