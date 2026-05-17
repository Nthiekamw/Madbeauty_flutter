import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../wizard/register_wizard_screen.dart';

class RegisterRoute extends ConsumerWidget {
  const RegisterRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const RegisterWizardScreen();
  }
}
