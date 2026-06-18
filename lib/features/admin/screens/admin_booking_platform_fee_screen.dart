import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/admin/admin_booking_platform_fee_settings.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/content/discovery_section_error.dart';
import '../../booking/providers/booking_platform_fee_settings_provider.dart';
import '../providers/admin_booking_platform_fee_provider.dart';
import '../widgets/admin_screen_scaffold.dart';

class AdminBookingPlatformFeeScreen extends ConsumerStatefulWidget {
  const AdminBookingPlatformFeeScreen({super.key});

  @override
  ConsumerState<AdminBookingPlatformFeeScreen> createState() =>
      _AdminBookingPlatformFeeScreenState();
}

class _AdminBookingPlatformFeeScreenState
    extends ConsumerState<AdminBookingPlatformFeeScreen> {
  final _feeController = TextEditingController(text: '0');
  final _freeCountController = TextEditingController(text: '2');
  bool _saving = false;
  bool _initialLoaded = false;

  @override
  void dispose() {
    _feeController.dispose();
    _freeCountController.dispose();
    super.dispose();
  }

  void _loadFromSettings(AdminBookingPlatformFeeSettings settings) {
    if (_initialLoaded) return;
    _initialLoaded = true;
    _feeController.text = (settings.feeCents / 100).toStringAsFixed(2);
    _freeCountController.text = '${settings.freeBookingCount}';
  }

  int? _parseFeeCents() {
    final raw = _feeController.text.trim().replaceAll(',', '.');
    final euros = double.tryParse(raw);
    if (euros == null || euros < 0 || euros > 1000) return null;
    return (euros * 100).round();
  }

  int? _parseFreeCount() {
    final value = int.tryParse(_freeCountController.text.trim());
    if (value == null || value < 0 || value > 100) return null;
    return value;
  }

  Future<void> _save() async {
    final feeCents = _parseFeeCents();
    final freeCount = _parseFreeCount();
    if (feeCents == null || freeCount == null) {
      AppSnackBar.show(
        context,
        message: DiscProfile.adminBookingFeeInvalid,
        kind: AppSnackKind.error,
      );
      return;
    }

    final service = ref.read(adminBookingPlatformFeeServiceProvider);
    if (service == null) return;

    setState(() => _saving = true);
    try {
      await service.updateSettings(
        feeCents: feeCents,
        freeBookingCount: freeCount,
      );
      ref.invalidate(adminBookingPlatformFeeSettingsProvider);
      ref.invalidate(bookingPlatformFeeSettingsProvider);
      if (!mounted) return;
      AppSnackBar.show(
        context,
        message: DiscProfile.adminBookingFeeSaved,
        kind: AppSnackKind.success,
      );
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.error(context, CoreStrings.errorUnexpected);
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final settingsAsync = ref.watch(adminBookingPlatformFeeSettingsProvider);
    final theme = Theme.of(context);

    return AdminScreenScaffold(
      title: DiscProfile.actionAdminBookingPlatformFee,
      body: settingsAsync.when(
        loading: () => const DiscoveryListSkeleton(rowCount: 4),
        error: (_, __) => DiscoverySectionError(
          message: CoreStrings.errorUnexpected,
          onRetry: () => ref.invalidate(adminBookingPlatformFeeSettingsProvider),
        ),
        data: (settings) {
          _loadFromSettings(settings);
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
            children: [
              const AdminScreenIntroBanner(
                icon: Icons.payments_outlined,
                title: DiscProfile.adminBookingFeeIntroTitle,
                body: DiscProfile.adminBookingFeeIntroBody,
              ),
              const SizedBox(height: 20),
              Text(
                DiscProfile.adminBookingFeeAmountLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _feeController,
                enabled: !_saving,
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  labelText: DiscProfile.adminBookingFeeAmountHint,
                  suffixText: '€',
                  helperText: DiscProfile.adminBookingFeeAmountHelper,
                ),
              ),
              const SizedBox(height: 20),
              Text(
                DiscProfile.adminBookingFeeFreeCountLabel,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _freeCountController,
                enabled: !_saving,
                keyboardType: TextInputType.number,
                inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                decoration: InputDecoration(
                  labelText: DiscProfile.adminBookingFeeFreeCountHint,
                  helperText: DiscProfile.adminBookingFeeFreeCountHelper,
                ),
              ),
              const SizedBox(height: 24),
              FilledButton.icon(
                onPressed: _saving ? null : () => unawaited(_save()),
                icon: _saving
                    ? const SizedBox(
                        width: 18,
                        height: 18,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Icon(Icons.save_outlined),
                label: Text(DiscProfile.adminBookingFeeSaveAction),
              ),
            ],
          );
        },
      ),
    );
  }
}
