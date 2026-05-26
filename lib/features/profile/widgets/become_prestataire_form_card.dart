import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/widgets/discovery_surface_card.dart';
import '../../auth/widgets/auth_step_section.dart';

class BecomePrestataireFormCard extends StatelessWidget {
  const BecomePrestataireFormCard({
    super.key,
    required this.salonController,
    required this.villeController,
    required this.bioController,
    this.errorText,
  });

  final TextEditingController salonController;
  final TextEditingController villeController;
  final TextEditingController bioController;
  final String? errorText;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return DiscoverySurfaceCard(
      padding: const EdgeInsets.all(16),
      child: AuthStepSection(
        title: AuthStrings.becomePrestaStep1Title,
        subtitle: AuthStrings.becomePrestaStep1Body,
        icon: Icons.edit_location_alt_outlined,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: salonController,
              decoration: const InputDecoration(
                labelText: AuthStrings.registerFieldSalon,
                prefixIcon: Icon(Icons.storefront_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: villeController,
              decoration: const InputDecoration(
                labelText: AuthStrings.registerFieldVille,
                prefixIcon: Icon(Icons.location_city_outlined),
              ),
              textCapitalization: TextCapitalization.words,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: bioController,
              decoration: const InputDecoration(
                labelText: AuthStrings.registerFieldBioPresta,
                prefixIcon: Icon(Icons.notes_outlined),
                alignLabelWithHint: true,
              ),
              maxLines: 3,
              textCapitalization: TextCapitalization.sentences,
            ),
            if (errorText != null) ...[
              const SizedBox(height: 12),
              DecoratedBox(
                decoration: BoxDecoration(
                  color: theme.colorScheme.errorContainer.withValues(
                    alpha: 0.35,
                  ),
                  borderRadius: DiscoveryStyles.chipBorderRadius,
                ),
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Text(
                    errorText!,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onErrorContainer,
                    ),
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
