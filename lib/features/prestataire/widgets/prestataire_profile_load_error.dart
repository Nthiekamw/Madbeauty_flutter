import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/discovery_empty_state.dart';

class PrestataireProfileLoadError extends StatelessWidget {
  const PrestataireProfileLoadError({
    super.key,
    required this.onRetry,
  });

  final VoidCallback onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: DiscoveryEmptyState(
        icon: Icons.cloud_off_outlined,
        title: DiscPrestaForm.loadErr,
        body: DiscList.pullDownHint,
        iconColor: Theme.of(context).colorScheme.error,
        actionLabel: DiscList.retry,
        onAction: onRetry,
      ),
    );
  }
}
