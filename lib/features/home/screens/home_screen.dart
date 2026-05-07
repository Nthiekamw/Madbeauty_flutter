import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../shared/theme/app_text_styles.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(AppStrings.appName)),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(AppStrings.appName, style: AppTextStyles.display(context)),
              const SizedBox(height: 12),
              Text(AppStrings.tagline, style: AppTextStyles.body(context)),
              const Spacer(),
              if (!AppConfig.hasSupabase)
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          AppStrings.supabaseMissingTitle,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          AppStrings.supabaseMissingBody,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              FilledButton(
                onPressed: () => context.push('/login'),
                child: Text(AppStrings.signInOrSignUp),
              ),
              const SizedBox(height: 12),
              OutlinedButton(
                onPressed: () => context.push('/prestataire'),
                child: Text(AppStrings.openPrestataireSpace),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
