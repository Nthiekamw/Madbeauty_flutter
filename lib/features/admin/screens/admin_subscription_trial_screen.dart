import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/admin/admin_catalog_trial_settings.dart';
import '../../../core/utils/trial_duration_format.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/theme/discovery_styles.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../providers/admin_catalog_trial_provider.dart';
import '../widgets/admin_screen_scaffold.dart';

class AdminSubscriptionTrialScreen extends ConsumerStatefulWidget {
  const AdminSubscriptionTrialScreen({super.key});

  @override
  ConsumerState<AdminSubscriptionTrialScreen> createState() =>
      _AdminSubscriptionTrialScreenState();
}

class _AdminSubscriptionTrialScreenState
    extends ConsumerState<AdminSubscriptionTrialScreen> {
  final _daysController = TextEditingController(text: '90');
  final _searchController = TextEditingController();
  final _extendDaysController = TextEditingController(text: '30');
  String _searchQuery = '';
  bool _saving = false;
  bool _applyingAll = false;
  bool _initialDaysLoaded = false;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.removeListener(_onSearchChanged);
    _daysController.dispose();
    _searchController.dispose();
    _extendDaysController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 350), () {
      final next = _searchController.text.trim();
      if (next == _searchQuery) return;
      setState(() => _searchQuery = next);
    });
  }

  int? _parseDays(String raw) {
    final value = int.tryParse(raw.trim());
    if (value == null || value < 1 || value > 730) return null;
    return value;
  }

  Future<void> _saveDefaultDays() async {
    final days = _parseDays(_daysController.text);
    if (days == null) {
      AppSnackBar.show(
        context,
        message: DiscProfile.adminTrialInvalidDays,
        kind: AppSnackKind.error,
      );
      return;
    }

    final service = ref.read(adminCatalogTrialServiceProvider);
    if (service == null) return;

    setState(() => _saving = true);
    try {
      await service.updateTrialDays(days);
      ref.invalidate(adminCatalogTrialSettingsProvider);
      if (!mounted) return;
      AppSnackBar.show(context, message: DiscProfile.adminTrialSaved);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: DiscProfile.adminActionErr,
        kind: AppSnackKind.error,
      );
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _applyToAll() async {
    final service = ref.read(adminCatalogTrialServiceProvider);
    if (service == null) return;

    setState(() => _applyingAll = true);
    try {
      final count = await service.applyDefaultTrialToUnsubscribed();
      ref.invalidate(adminCatalogTrialSettingsProvider);
      ref.invalidate(adminPrestataireTrialsSearchProvider(_searchQuery));
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: DiscProfile.adminTrialApplyAllDone(count),
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: DiscProfile.adminActionErr,
        kind: AppSnackKind.error,
      );
    } finally {
      if (mounted) setState(() => _applyingAll = false);
    }
  }

  Future<void> _extendTrial(AdminPrestataireTrialSummary prestataire) async {
    final extraDays = _parseDays(_extendDaysController.text);
    if (extraDays == null) {
      AppSnackBar.show(
        context,
        message: DiscProfile.adminTrialInvalidDays,
        kind: AppSnackKind.error,
      );
      return;
    }

    final service = ref.read(adminCatalogTrialServiceProvider);
    if (service == null) return;

    try {
      await service.extendPrestataireTrial(
        prestataireId: prestataire.prestataireId,
        extraDays: extraDays,
      );
      ref.invalidate(adminCatalogTrialSettingsProvider);
      ref.invalidate(adminPrestataireTrialsSearchProvider(_searchQuery));
      if (!mounted) return;
      AppSnackBar.show(context, message: DiscProfile.adminTrialExtendDone);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: DiscProfile.adminActionErr,
        kind: AppSnackKind.error,
      );
    }
  }

  Future<void> _confirmExtend(AdminPrestataireTrialSummary prestataire) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(DiscProfile.adminTrialExtendDialogTitle(prestataire.label)),
        content: TextField(
          controller: _extendDaysController,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
          decoration: InputDecoration(
            labelText: DiscProfile.adminTrialExtendDaysLabel,
            hintText: DiscProfile.adminTrialExtendDaysHint,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(DiscProfile.adminUsersBanCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(DiscProfile.adminTrialExtendConfirm),
          ),
        ],
      ),
    );
    if (confirmed == true && mounted) {
      await _extendTrial(prestataire);
    }
  }

  void _setPresetDays(int days) {
    setState(() => _daysController.text = '$days');
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final settingsAsync = ref.watch(adminCatalogTrialSettingsProvider);
    final searchAsync = ref.watch(adminPrestataireTrialsSearchProvider(_searchQuery));

    ref.listen(adminCatalogTrialSettingsProvider, (previous, next) {
      next.whenData((settings) {
        if (!_initialDaysLoaded) {
          _initialDaysLoaded = true;
          _daysController.text = '${settings.catalogTrialDays}';
        }
      });
    });

    return AdminScreenScaffold(
      title: DiscProfile.actionAdminSubscriptionTrial,
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
        children: [
          const AdminScreenIntroBanner(
            icon: Icons.card_giftcard_outlined,
            title: DiscProfile.adminTrialIntroTitle,
            body: DiscProfile.adminTrialIntroBody,
          ),
          const SizedBox(height: 16),
          settingsAsync.when(
            loading: () => const DiscoveryListSkeleton(
              rowCount: 2,
              rowHeight: 72,
              padding: EdgeInsets.zero,
            ),
            error: (_, __) => DiscoverySectionError(
              message: DiscProfile.adminActionErr,
              onRetry: () => ref.invalidate(adminCatalogTrialSettingsProvider),
            ),
            data: (settings) => _SettingsCard(
              theme: theme,
              settings: settings,
              daysController: _daysController,
              saving: _saving,
              applyingAll: _applyingAll,
              onPreset: _setPresetDays,
              onSave: _saveDefaultDays,
              onApplyAll: _applyToAll,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            DiscProfile.actionAdminUsers,
            style: theme.textTheme.titleMedium?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 10),
          TextField(
            controller: _searchController,
            decoration: InputDecoration(
              hintText: DiscProfile.adminTrialSearchHint,
              prefixIcon: const Icon(Icons.search),
              border: OutlineInputBorder(
                borderRadius: DiscoveryStyles.cardBorderRadius,
              ),
            ),
          ),
          const SizedBox(height: 12),
          searchAsync.when(
            loading: () => const DiscoveryListSkeleton(
              rowCount: 3,
              rowHeight: 88,
              padding: EdgeInsets.zero,
            ),
            error: (_, __) => DiscoverySectionError(
              message: DiscProfile.adminActionErr,
              onRetry: () => ref.invalidate(
                adminPrestataireTrialsSearchProvider(_searchQuery),
              ),
            ),
            data: (items) {
              if (items.isEmpty) {
                return DiscoveryEmptyState(
                  icon: Icons.storefront_outlined,
                  title: DiscProfile.adminTrialSearchEmpty,
                  body: DiscProfile.adminTrialSearchEmptyBody,
                );
              }
              return Column(
                children: [
                  for (final item in items) ...[
                    _PrestataireTrialTile(
                      prestataire: item,
                      onExtend: () => _confirmExtend(item),
                    ),
                    const SizedBox(height: 8),
                  ],
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}

class _SettingsCard extends StatelessWidget {
  const _SettingsCard({
    required this.theme,
    required this.settings,
    required this.daysController,
    required this.saving,
    required this.applyingAll,
    required this.onPreset,
    required this.onSave,
    required this.onApplyAll,
  });

  final ThemeData theme;
  final AdminCatalogTrialSettings settings;
  final TextEditingController daysController;
  final bool saving;
  final bool applyingAll;
  final ValueChanged<int> onPreset;
  final VoidCallback onSave;
  final VoidCallback onApplyAll;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        borderRadius: DiscoveryStyles.cardBorderRadius,
        color: theme.colorScheme.surface,
        border: Border.all(color: AppColors.adminBorder30),
      ),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              children: [
                Expanded(
                  child: _StatChip(
                    label: DiscProfile.adminTrialStatsInTrial,
                    value: '${settings.prestatairesInTrial}',
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _StatChip(
                    label: DiscProfile.adminTrialStatsExpired,
                    value: '${settings.prestatairesExpiredWithoutSub}',
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Text(
              '${DiscProfile.adminTrialDefaultLabel} — '
              '${TrialDurationFormat.labelShort(settings.catalogTrialDays)}',
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              DiscProfile.adminTrialDefaultHint,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                ActionChip(
                  label: Text(DiscProfile.adminTrialPreset1Month),
                  onPressed: () => onPreset(30),
                ),
                ActionChip(
                  label: Text(DiscProfile.adminTrialPreset3Months),
                  onPressed: () => onPreset(90),
                ),
                ActionChip(
                  label: Text(DiscProfile.adminTrialPreset6Months),
                  onPressed: () => onPreset(180),
                ),
              ],
            ),
            const SizedBox(height: 12),
            TextField(
              controller: daysController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              decoration: InputDecoration(
                labelText: DiscProfile.adminTrialDefaultLabel,
                border: OutlineInputBorder(
                  borderRadius: DiscoveryStyles.cardBorderRadius,
                ),
              ),
            ),
            const SizedBox(height: 12),
            FilledButton.icon(
              onPressed: saving ? null : onSave,
              icon: saving
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.save_outlined, size: 18),
              label: Text(DiscProfile.adminTrialSaveAction),
            ),
            const SizedBox(height: 16),
            Divider(color: AppColors.adminBorder30),
            const SizedBox(height: 12),
            Text(
              DiscProfile.adminTrialApplyAllTitle,
              style: theme.textTheme.titleSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              DiscProfile.adminTrialApplyAllBody,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.35,
              ),
            ),
            const SizedBox(height: 10),
            OutlinedButton.icon(
              onPressed: applyingAll ? null : onApplyAll,
              icon: applyingAll
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.refresh_outlined, size: 18),
              label: Text(DiscProfile.adminTrialApplyAllAction),
            ),
            if (settings.catalogTrialDays > 0) ...[
              const SizedBox(height: 8),
              Text(
                'Actuel : ${TrialDurationFormat.labelShort(settings.catalogTrialDays)}',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.label, required this.value});

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
      decoration: BoxDecoration(
        color: AppColors.adminBg12,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.adminBorder30),
      ),
      child: Column(
        children: [
          Text(
            value,
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w900,
            ),
          ),
          Text(
            label,
            textAlign: TextAlign.center,
            style: theme.textTheme.labelSmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrestataireTrialTile extends StatelessWidget {
  const _PrestataireTrialTile({
    required this.prestataire,
    required this.onExtend,
  });

  final AdminPrestataireTrialSummary prestataire;
  final VoidCallback onExtend;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final dateFormat = DateFormat.yMMMd('fr_FR');
    final endsAt = prestataire.catalogTrialEndsAt;
    final statusLabel = prestataire.subscriptionStatus == 'active' ||
            prestataire.subscriptionStatus == 'trialing'
        ? DiscProfile.adminTrialStatusSubscribed
        : prestataire.isInTrial
            ? DiscProfile.adminTrialStatusActive
            : DiscProfile.adminTrialStatusExpired;

    return Material(
      color: theme.colorScheme.surface,
      borderRadius: DiscoveryStyles.cardBorderRadius,
      child: InkWell(
        onTap: onExtend,
        borderRadius: DiscoveryStyles.cardBorderRadius,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: DiscoveryStyles.cardBorderRadius,
            border: Border.all(color: AppColors.adminBorder30),
          ),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        prestataire.label,
                        style: theme.textTheme.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      Text(
                        prestataire.email,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                        ),
                      ),
                      if (endsAt != null) ...[
                        const SizedBox(height: 4),
                        Text(
                          '${DiscProfile.adminTrialEndsAt} : ${dateFormat.format(endsAt.toLocal())}',
                          style: theme.textTheme.labelSmall,
                        ),
                      ],
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppColors.adminBg12,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        statusLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: onExtend,
                      child: Text(DiscProfile.adminTrialExtendAction),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
