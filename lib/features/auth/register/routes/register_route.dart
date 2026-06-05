import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../wizard/register_wizard_screen.dart';

class RegisterRoute extends ConsumerWidget {
  const RegisterRoute({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final resume = GoRouterState.of(context).uri.queryParameters['resume'] == '1';
    return RegisterWizardScreen(autoResumeFinalize: resume);
  }
}

