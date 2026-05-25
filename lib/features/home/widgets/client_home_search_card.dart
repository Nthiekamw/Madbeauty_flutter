import 'package:flutter/material.dart';

import '../../../shared/theme/prototype_palette.dart';
import '../../../shared/widgets/discovery_search_card.dart';

/// Barre de recherche mise en avant sur l’accueil.
class ClientHomeSearchCard extends StatelessWidget {
  const ClientHomeSearchCard({
    super.key,
    required this.controller,
    required this.hint,
    required this.searchTooltip,
    required this.onSubmit,
  });

  final TextEditingController controller;
  final String hint;
  final String searchTooltip;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final isDark = theme.brightness == Brightness.dark;

    return DiscoverySearchCard(
      controller: controller,
      hint: hint,
      onSubmitted: onSubmit,
      compact: true,
      suffixIcon: isDark
          ? IconButton.filled(
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
            )
          : Container(
              padding: EdgeInsets.all(
                MediaQuery.sizeOf(context).width / 100 * 1.5,
              ),
              decoration: BoxDecoration(
                color: PrototypePalette.creamClient,
                borderRadius: BorderRadius.circular(
                  MediaQuery.sizeOf(context).width / 100 * 2,
                ),
              ),
              child: Icon(
                Icons.tune_rounded,
                color: PrototypePalette.textMed,
                size: MediaQuery.sizeOf(context).width / 100 * 4.2,
              ),
            ),
    );
  }
}
