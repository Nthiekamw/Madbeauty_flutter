import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/async_state_test_provider.dart';

class AsyncStateTestScreen extends ConsumerWidget {
  const AsyncStateTestScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final mode = ref.watch(asyncStateTestModeProvider);
    final async = ref.watch(asyncStateTestProvider);
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Test des states')),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Écran interne pour vérifier le rendu loading / data / error '
            'des widgets basés sur AsyncValue.',
            style: theme.textTheme.bodyLarge,
          ),
          const SizedBox(height: 20),
          SegmentedButton<AsyncStateTestMode>(
            segments: const [
              ButtonSegment(
                value: AsyncStateTestMode.loading,
                icon: Icon(Icons.hourglass_empty),
                label: Text('Loading'),
              ),
              ButtonSegment(
                value: AsyncStateTestMode.data,
                icon: Icon(Icons.check_circle_outline),
                label: Text('Data'),
              ),
              ButtonSegment(
                value: AsyncStateTestMode.error,
                icon: Icon(Icons.error_outline),
                label: Text('Error'),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (selection) {
              if (selection.isEmpty) return;
              ref
                  .read(asyncStateTestModeProvider.notifier)
                  .setMode(selection.first);
            },
          ),
          const SizedBox(height: 24),
          _AsyncStatePreview(async: async),
        ],
      ),
    );
  }
}

class _AsyncStatePreview extends StatelessWidget {
  const _AsyncStatePreview({required this.async});

  final AsyncValue<List<String>> async;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: async.when(
          loading: () => const _LoadingPreview(),
          data: (items) => _DataPreview(items: items),
          error: (error, _) => _ErrorPreview(message: error.toString()),
        ),
      ),
    );
  }
}

class _LoadingPreview extends StatelessWidget {
  const _LoadingPreview();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        const CircularProgressIndicator(),
        const SizedBox(height: 16),
        Text('Chargement en cours...', style: theme.textTheme.titleMedium),
      ],
    );
  }
}

class _DataPreview extends StatelessWidget {
  const _DataPreview({required this.items});

  final List<String> items;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('Données chargées', style: theme.textTheme.titleMedium),
        const SizedBox(height: 12),
        for (final item in items)
          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.done),
            title: Text(item),
          ),
      ],
    );
  }
}

class _ErrorPreview extends StatelessWidget {
  const _ErrorPreview({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(
          Icons.cloud_off_outlined,
          color: theme.colorScheme.error,
          size: 40,
        ),
        const SizedBox(height: 12),
        Text(
          'Erreur détectée',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.error,
          ),
        ),
        const SizedBox(height: 8),
        Text(message),
      ],
    );
  }
}

