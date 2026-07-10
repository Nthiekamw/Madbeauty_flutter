import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/config/stripe_platform_policy.dart';
import '../../../../core/constants/app_strings.dart';
import '../../../../services/stripe/prestataire_billing_payment_methods_provider.dart';
import '../../../../services/stripe/stripe_prestataire_subscription_service.dart';
import '../../../../services/stripe/stripe_service.dart';
import '../../../../services/stripe/stripe_subscription_providers.dart';
import '../../../../shared/utils/app_url_launcher.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';
import '../../../../shared/widgets/stripe/saved_stripe_cards_panel.dart';
import '../../../../shared/widgets/stripe/stripe_test_card_hint.dart';
import '../../providers/profile/prestataire_profile_form_provider.dart';

/// Carte d’abonnement prestataire (liste + Customer Sheet dans l’app).
class PrestataireSubscriptionBillingCardsSection extends ConsumerStatefulWidget {
  const PrestataireSubscriptionBillingCardsSection({super.key});

  @override
  ConsumerState<PrestataireSubscriptionBillingCardsSection> createState() =>
      _PrestataireSubscriptionBillingCardsSectionState();
}

class _PrestataireSubscriptionBillingCardsSectionState
    extends ConsumerState<PrestataireSubscriptionBillingCardsSection> {
  bool _sheetBusy = false;
  bool _portalBusy = false;

  void _snack(String message, {AppSnackKind kind = AppSnackKind.info}) {
    AppSnackBar.show(context, message: message, kind: kind);
  }

  Future<bool> _ensureProfileForBilling() async {
    final formService = ref.read(prestataireProfileFormServiceProvider);
    if (formService == null) {
      _snack(DiscPrestaSub.payUnavailable, kind: AppSnackKind.error);
      return false;
    }
    try {
      await formService.ensureProfileForBilling();
      ref.invalidate(prestataireProfileFormProvider);
      return true;
    } catch (_) {
      _snack(DiscPrestaSub.profileRequired, kind: AppSnackKind.error);
      return false;
    }
  }

  Future<void> _openCustomerSheet() async {
    final service = ref.read(stripePrestaSubscriptionServiceProvider);
    if (service == null) {
      _snack(DiscPrestaSub.payUnavailable, kind: AppSnackKind.error);
      return;
    }

    setState(() => _sheetBusy = true);
    try {
      if (!await _ensureProfileForBilling()) return;
      await service.presentCustomerSheet();
      if (!mounted) return;
      ref.invalidate(prestataireBillingPaymentMethodsProvider);
      _snack(DiscPaymentMethods.cardsUpdated, kind: AppSnackKind.success);
    } on StripePrestaSubscriptionException catch (e) {
      _snack(e.message, kind: AppSnackKind.error);
    } catch (e) {
      debugPrint('presta customer sheet: $e');
      _snack(DiscPaymentMethods.sheetErr, kind: AppSnackKind.error);
    } finally {
      if (mounted) setState(() => _sheetBusy = false);
    }
  }

  Future<void> _openPortalFallback() async {
    final service = ref.read(stripePrestaSubscriptionServiceProvider);
    if (service == null) return;

    setState(() => _portalBusy = true);
    try {
      if (!await _ensureProfileForBilling()) return;
      final url = await service.createBillingPortalUrl();
      if (!mounted) return;
      final opened = await AppUrlLauncher.openInApp(context, url);
      if (!mounted) return;
      if (opened) {
        ref.invalidate(prestataireBillingPaymentMethodsProvider);
      } else {
        _snack(DiscPrestaSub.browserErr, kind: AppSnackKind.error);
      }
    } on StripePrestaSubscriptionException catch (e) {
      _snack(e.message, kind: AppSnackKind.error);
    } finally {
      if (mounted) setState(() => _portalBusy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (!StripePlatformPolicy.isEnabled) {
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
          const StripeTestCardHint(),
          const SizedBox(height: 12),
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
              child: Text(DiscPaymentMethods.subscriptionManage),
            ),
        ],
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        const StripeTestCardHint(),
        const SizedBox(height: 12),
        SavedStripeCardsPanel(
          title: DiscPaymentMethods.subscriptionTitle,
          hint: DiscPaymentMethods.subscriptionHint,
          manageLabel: DiscPaymentMethods.subscriptionManage,
          methodsAsync: ref.watch(prestataireBillingPaymentMethodsProvider),
          busy: _sheetBusy || _portalBusy,
          onManage: _openCustomerSheet,
          onPortalFallback: _openPortalFallback,
          onRetry: () => ref.invalidate(prestataireBillingPaymentMethodsProvider),
        ),
      ],
    );
  }
}
