import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

class PrestataireProfileLoadError extends StatelessWidget {
  const PrestataireProfileLoadError({
    super.key,
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DiscPrestaForm.loadErr,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
            const SizedBox(height: 16),
            FilledButton.tonal(
              onPressed: onRetry,
              child: const Text(DiscList.retry),
            ),
          ],
        ),
      ),
    );
  }
}
