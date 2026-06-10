import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../services/stripe/stripe_client_payment_providers.dart';
import '../../../../services/stripe/stripe_client_payment_service.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/utils/app_url_launcher.dart';
import '../../../../shared/widgets/app/app_snack_bar.dart';
import '../../../../shared/widgets/app/app_button.dart';

/// Cartes bancaires client (portail Stripe).
class ClientPaymentMethodsSection extends ConsumerStatefulWidget {
  const ClientPaymentMethodsSection({super.key});

  @override
  ConsumerState<ClientPaymentMethodsSection> createState() =>
      _ClientPaymentMethodsSectionState();
}

class _ClientPaymentMethodsSectionState
    extends ConsumerState<ClientPaymentMethodsSection> {
  bool _busy = false;

  void _snack(String message, {AppSnackKind kind = AppSnackKind.info}) {
    AppSnackBar.show(context, message: message, kind: kind);
  }

  Future<void> _openPortal() async {
    final service = ref.read(stripeClientPaymentServiceProvider);
    if (service == null) {
      _snack(DiscPaymentMethods.unavailable, kind: AppSnackKind.error);
      return;
    }

    setState(() => _busy = true);
    try {
      final url = await service.createBillingPortalUrl();
      if (!context.mounted) return;
      final opened = await AppUrlLauncher.openInApp(context, url);
      if (!context.mounted) return;
      if (!opened) {
        _snack(DiscPaymentMethods.browserErr, kind: AppSnackKind.error);
      } else {
        _snack(DiscPaymentMethods.portalOpened);
      }
    } on StripeClientPaymentException catch (e) {
      _snack(e.message, kind: AppSnackKind.error);
    } catch (e) {
      debugPrint('client billing portal: $e');
      _snack(DiscPaymentMethods.portalErr, kind: AppSnackKind.error);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: primary.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(Icons.credit_card_rounded, color: primary),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DiscPaymentMethods.clientCardsTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DiscPaymentMethods.clientCardsHint,
                    style: theme.textTheme.bodySmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.35,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        if (_busy)
          const Center(
            child: Padding(
              padding: EdgeInsets.all(8),
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          )
        else
          AppButton(
            variant: AppButtonVariant.primary,
            onPressed: _openPortal,
            child: Text(DiscPaymentMethods.clientCardsManage),
          ),
      ],
    );
  }
}
