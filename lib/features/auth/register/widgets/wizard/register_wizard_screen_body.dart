import 'package:flutter/material.dart';

import '../../../widgets/auth_error_banner.dart';
import '../../providers/register_wizard_form_controller.dart';
import 'register_wizard_step_widgets.dart';

/// Corps animé du wizard (3 étapes + bannière d'erreur).
class RegisterWizardScreenBody extends StatelessWidget {
  const RegisterWizardScreenBody({
    super.key,
    required this.form,
    required this.formEnabled,
    required this.theme,
    required this.onSurfaceVariant,
    required this.onGoogleSignIn,
  });

  final RegisterWizardFormController form;
  final bool formEnabled;
  final ThemeData theme;
  final Color onSurfaceVariant;
  final VoidCallback? onGoogleSignIn;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AnimatedSwitcher(
          duration: const Duration(milliseconds: 320),
          switchInCurve: Curves.easeOutCubic,
          switchOutCurve: Curves.easeInCubic,
          transitionBuilder: (child, animation) {
            final offset = Tween<Offset>(
              begin: const Offset(0.03, 0),
              end: Offset.zero,
            ).animate(CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            ));
            return FadeTransition(
              opacity: animation,
              child: SlideTransition(position: offset, child: child),
            );
          },
          child: KeyedSubtree(
            key: ValueKey<int>(form.step),
            child: switch (form.step) {
              0 => RegisterWizardIdentityStep(
                  form: form,
                  formEnabled: formEnabled,
                  onSurfaceVariant: onSurfaceVariant,
                  onGoogleSignIn: onGoogleSignIn,
                ),
              1 => RegisterWizardRoleStep(
                  form: form,
                  formEnabled: formEnabled,
                  theme: theme,
                  onSurfaceVariant: onSurfaceVariant,
                ),
              _ => RegisterWizardExtrasStep(
                  form: form,
                  formEnabled: formEnabled,
                  onSurfaceVariant: onSurfaceVariant,
                ),
            },
          ),
        ),
        if (form.error != null) ...[
          const SizedBox(height: 10),
          AuthErrorBanner(message: form.error!),
        ],
      ],
    );
  }
}
