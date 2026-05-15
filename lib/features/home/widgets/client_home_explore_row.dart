import 'package:flutter/material.dart';

import '../../../core/constants/app_strings.dart';

/// Puces « inspiration » vers la recherche / listing.
class ClientHomeExploreRow extends StatelessWidget {
  const ClientHomeExploreRow({
    super.key,
    required this.onPick,
  });

  final ValueChanged<String> onPick;

  static const List<String> _topics = [
    'Tresses',
    'Locks',
    'Coiffure afro',
    'Coupe',
    'Entretien',
  ];

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DiscHome.inspireTitle,
          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                fontWeight: FontWeight.w600,
              ),
        ),
        const SizedBox(height: 6),
        Text(
          DiscHome.inspireSub,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.onSurfaceVariant,
              ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _topics
              .map(
                (t) => ActionChip(
                  label: Text(t),
                  onPressed: () => onPick(t),
                ),
              )
              .toList(),
        ),
      ],
    );
  }
}
