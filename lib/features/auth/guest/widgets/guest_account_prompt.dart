import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../router/navigation_extensions.dart';
import '../../../../shared/widgets/app/app_button.dart';
import '../../../../shared/widgets/discovery/discovery_empty_state.dart';

/// Invite à se connecter / s’inscrire pour une action réservée aux comptes.
class GuestAccountPrompt extends StatelessWidget {
  const GuestAccountPrompt({
    super.key,
    required this.icon,
    required this.title,
    required this.message,
  });

  final IconData icon;
  final String title;
  final String message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 24),
        child: DiscoveryEmptyState(
          icon: icon,
          title: title,
          body: message,
          iconColor: Theme.of(context).colorScheme.primary,
          extraActions: [
            AppButton(
              onPressed: () => context.pushLogin(),
              child: const Text(AuthStrings.guestCtaLogin),
            ),
            const SizedBox(height: 10),
            AppButton(
              variant: AppButtonVariant.secondary,
              onPressed: () => context.pushRegister(),
              child: const Text(AuthStrings.guestCtaRegister),
            ),
          ],
        ),
      ),
    );
  }
}

