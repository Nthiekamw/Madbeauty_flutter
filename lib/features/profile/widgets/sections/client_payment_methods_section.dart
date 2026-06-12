import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../services/stripe/client_payment_methods_provider.dart';
import '../../../../services/stripe/stripe_client_payment_providers.dart';
import '../../../../services/stripe/stripe_client_payment_service.dart';
import '../../../../services/stripe/stripe_service.dart';
import '../../../../shared/utils/app_url_launcher.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';
import '../../../../shared/widgets/stripe/saved_stripe_cards_panel.dart';

/// Cartes bancaires client (liste + Customer Sheet dans l’app).
class ClientPaymentMethodsSection extends ConsumerStatefulWidget {
  const ClientPaymentMethodsSection({super.key});

  @override
  ConsumerState<ClientPaymentMethodsSection> createState() =>
      _ClientPaymentMethodsSectionState();
}

class _ClientPaymentMethodsSectionState
    extends ConsumerState<ClientPaymentMethodsSection> {
  bool _sheetBusy = false;
  bool _portalBusy = false;

  void _snack(String message, {AppSnackKind kind = AppSnackKind.info}) {
    AppSnackBar.show(context, message: message, kind: kind);
  }

  Future<void> _openCustomerSheet() async {
    final service = ref.read(stripeClientPaymentServiceProvider);
    if (service == null) {
      _snack(DiscPaymentMethods.unavailable, kind: AppSnackKind.error);
      return;
    }

    setState(() => _sheetBusy = true);
    try {
      await service.presentCustomerSheet();
      if (!mounted) return;
      ref.invalidate(clientPaymentMethodsProvider);
      _snack(DiscPaymentMethods.cardsUpdated, kind: AppSnackKind.success);
    } on StripeClientPaymentException catch (e) {
      _snack(e.message, kind: AppSnackKind.error);
    } catch (e) {
      debugPrint('customer sheet: $e');
      _snack(DiscPaymentMethods.sheetErr, kind: AppSnackKind.error);
    } finally {
      if (mounted) setState(() => _sheetBusy = false);
    }
  }

  Future<void> _openPortalFallback() async {
    final service = ref.read(stripeClientPaymentServiceProvider);
    if (service == null) return;

    setState(() => _portalBusy = true);
    try {
      final url = await service.createBillingPortalUrl();
      if (!mounted) return;
      final opened = await AppUrlLauncher.openInApp(context, url);
      if (!mounted) return;
      if (opened) {
        ref.invalidate(clientPaymentMethodsProvider);
      } else {
        _snack(DiscPaymentMethods.browserErr, kind: AppSnackKind.error);
      }
    } on StripeClientPaymentException catch (e) {
      _snack(e.message, kind: AppSnackKind.error);
    } finally {
      if (mounted) setState(() => _portalBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!StripeService.isConfigured) {
      return Text(
        DiscPaymentMethods.unavailable,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: Theme.of(context).colorScheme.error,
            ),
      );
    }

    if (kIsWeb) {
      return Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            DiscPaymentMethods.webFallbackHint,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
          ),
          const SizedBox(height: 12),
          if (_portalBusy)
            const Center(child: CircularProgressIndicator(strokeWidth: 2))
          else
            FilledButton(
              onPressed: _openPortalFallback,
              child: Text(DiscPaymentMethods.clientCardsManage),
            ),
        ],
      );
    }

    return SavedStripeCardsPanel(
      title: DiscPaymentMethods.clientCardsTitle,
      hint: DiscPaymentMethods.clientCardsHint,
      manageLabel: DiscPaymentMethods.clientCardsManage,
      methodsAsync: ref.watch(clientPaymentMethodsProvider),
      busy: _sheetBusy || _portalBusy,
      onManage: _openCustomerSheet,
      onPortalFallback: _openPortalFallback,
      onRetry: () => ref.invalidate(clientPaymentMethodsProvider),
    );
  }
}
