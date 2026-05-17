import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/constants/app_strings.dart';
import '../../auth/widgets/role_switch_section.dart';
import '../../../router/app_router.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../providers/current_prestataire_provider.dart';
import '../logic/prestataire_profile_completeness.dart';
import '../providers/prestataire_profile_form_provider.dart';
import '../widgets/prestataire_profile_load_error.dart';

class PrestataireDashboardScreen extends ConsumerWidget {
  const PrestataireDashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(prestataireProfileFormProvider);
    final currentPrestataire = switch (ref.watch(currentPrestataireProvider)) {
      AsyncData(:final value) => value,
      _ => null,
    };
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text(DiscNav.prestDashboard),
      ),
      body: async.when(
        data: (data) {
          final currentName = currentPrestataire?.nomSalon?.trim();
          final hasProfile = data.isProfessionallyComplete;
          final title = currentName != null && currentName.isNotEmpty
              ? currentName
              : data.nomSalon.trim().isNotEmpty
              ? data.nomSalon.trim()
              : DiscNav.prestDashboard;

          return ListView(
            padding: const EdgeInsets.all(24),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  AppAvatar(
                    imageUrl: data.avatarUrl,
                    displayName: title,
                    radius: 36,
                  ),
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
                        const SizedBox(height: 6),
                        Text(
                          hasProfile
                              ? DiscPrestaDash.welcome
                              : DiscPrestaDash.profileMissing,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: () => context.goNamed(AppRouteNames.prestataireProfile),
                icon: const Icon(Icons.edit_outlined),
                label: const Text(
                  DiscPrestaDash.editProfile,
                ),
              ),
              const SizedBox(height: 8),
              const RoleSwitchSection(sectionTitle: DiscNav.profileSpace),
              const SizedBox(height: 16),
              _DashboardMetricGrid(
                city: currentPrestataire?.ville ?? data.ville,
                specialtiesCount: data.selectedCategoryIds.length,
                servicesCount: data.services.length,
              ),
            ],
          );
        },
        error: (_, __) => PrestataireProfileLoadError(
          onRetry: () => ref.invalidate(prestataireProfileFormProvider),
        ),
        loading: () => const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class _DashboardMetricGrid extends StatelessWidget {
  const _DashboardMetricGrid({
    required this.city,
    required this.specialtiesCount,
    required this.servicesCount,
  });

  final String? city;
  final int specialtiesCount;
  final int servicesCount;

  @override
  Widget build(BuildContext context) {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: [
        _MetricCard(
          label: DiscPrestaDash.city,
          value: city?.trim().isEmpty ?? true ? '-' : city!.trim(),
        ),
        _MetricCard(
          label: DiscPrestaDash.specialties,
          value: specialtiesCount.toString(),
        ),
        _MetricCard(
          label: DiscPrestaDash.svcCount,
          value: servicesCount.toString(),
        ),
      ],
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      width: 156,
      child: Card(
        margin: EdgeInsets.zero,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                label,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
