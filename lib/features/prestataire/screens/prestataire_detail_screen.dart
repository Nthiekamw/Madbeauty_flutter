import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../providers/prestataire_detail_provider.dart';

/// Fiche publique d’un prestataire (catalogue client).
class PrestataireDetailScreen extends ConsumerWidget {
  const PrestataireDetailScreen({
    super.key,
    required this.prestataireId,
  });

  final String prestataireId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(prestataireDetailProvider(prestataireId));
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(DiscoveryStrings.prestataireDetailScreenTitle),
      ),
      body: async.when(
        data: (profile) {
          if (profile == null) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Text(
                  DiscoveryStrings.prestataireDetailNotFound,
                  textAlign: TextAlign.center,
                  style: theme.textTheme.bodyLarge,
                ),
              ),
            );
          }
          final salon = profile.nomSalon?.trim();
          final title =
              (salon != null && salon.isNotEmpty) ? salon : 'Salon';
          final ville = profile.ville?.trim();

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  AppAvatar(displayName: title, radius: 40),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: theme.textTheme.headlineSmall?.copyWith(
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        if (ville != null && ville.isNotEmpty) ...[
                          const SizedBox(height: 6),
                          Text(
                            ville,
                            style: theme.textTheme.bodyLarge?.copyWith(
                              color: theme.colorScheme.onSurfaceVariant,
                            ),
                          ),
                        ],
                        if (profile.noteMoyenne != null) ...[
                          const SizedBox(height: 8),
                          Text(
                            '★ ${profile.noteMoyenne!.toStringAsFixed(1)}',
                            style: theme.textTheme.titleMedium?.copyWith(
                              color: theme.colorScheme.primary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                        if (profile.isVerified) ...[
                          const SizedBox(height: 8),
                          Row(
                            children: [
                              Icon(
                                Icons.verified,
                                size: 20,
                                color: theme.colorScheme.primary,
                              ),
                              const SizedBox(width: 6),
                              Text(
                                DiscoveryStrings.prestataireDetailVerified,
                                style: theme.textTheme.labelLarge,
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                ],
              ),
              if (profile.bio != null && profile.bio!.trim().isNotEmpty) ...[
                const SizedBox(height: 24),
                Text(
                  DiscoveryStrings.prestataireDetailBioTitle,
                  style: theme.textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  profile.bio!.trim(),
                  style: theme.textTheme.bodyLarge?.copyWith(height: 1.45),
                ),
              ],
            ],
          );
        },
        error: (_, __) => Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              DiscoveryStrings.prestataireDetailLoadError,
              textAlign: TextAlign.center,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: theme.colorScheme.error,
              ),
            ),
          ),
        ),
        loading: () => const Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: CircularProgressIndicator(),
          ),
        ),
      ),
    );
  }
}
