import 'package:flutter/material.dart';
import 'package:flutter_stripe_web/flutter_stripe_web.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/layout/discovery_responsive.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/discovery_styles.dart';
import '../../../../shared/widgets/stripe/stripe_test_card_hint.dart';
import '../../../../services/stripe/stripe_booking_payment_service.dart';
import '../../../../services/stripe/stripe_payment_exception.dart';
import '../../../../services/stripe/stripe_web_bootstrap.dart';
import 'booking_web_payment_element_theme.dart';

/// Paiement réservation sur Flutter Web (Payment Element — PaymentSheet indispo).
Future<void> showBookingWebPaymentDialog(
  BuildContext context, {
  required BookingPaymentSheetData sheet,
  required String amountLabel,
}) async {
  final paid = await showDialog<bool>(
    context: context,
    barrierDismissible: false,
    barrierColor: AppColors.black.withValues(alpha: 0.45),
    builder: (dialogContext) => _BookingWebPaymentDialog(
      sheet: sheet,
      amountLabel: amountLabel,
    ),
  );
  if (paid != true) {
    throw const StripePaymentCanceledException();
  }
}

class _BookingWebPaymentDialog extends StatefulWidget {
  const _BookingWebPaymentDialog({
    required this.sheet,
    required this.amountLabel,
  });

  final BookingPaymentSheetData sheet;
  final String amountLabel;

  @override
  State<_BookingWebPaymentDialog> createState() =>
      _BookingWebPaymentDialogState();
}

class _BookingWebPaymentDialogState extends State<_BookingWebPaymentDialog> {
  bool _cardComplete = false;
  bool _submitting = false;
  String? _errorMessage;
  late final Future<bool> _stripeReadyFuture =
      StripeWebBootstrap.ensureInitialized();

  Future<void> _pay() async {
    if (!_cardComplete || _submitting) return;

    final stripeReady = await _stripeReadyFuture;
    if (!stripeReady) {
      if (!mounted) return;
      setState(() => _errorMessage = DiscPay.errNotConfigured);
      return;
    }
    if (WebStripe.elements == null) {
      setState(() => _errorMessage = DiscPay.webPayStripeNotReady);
      return;
    }

    setState(() {
      _submitting = true;
      _errorMessage = null;
    });

    try {
      await WebStripe.instance.confirmPaymentElement(
        ConfirmPaymentElementOptions(
          confirmParams: ConfirmPaymentParams(
            return_url: Uri.base.removeFragment().toString(),
          ),
          redirect: PaymentConfirmationRedirect.ifRequired,
        ),
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      final message = e.toString();
      if (message.contains('canceled') || message.contains('Canceled')) {
        Navigator.of(context).pop(false);
        return;
      }
      setState(() {
        _submitting = false;
        _errorMessage = _paymentErrorMessage(e);
      });
    }
  }

  String _paymentErrorMessage(Object error) {
    final message = error.toString().trim();
    if (message.isEmpty || message == 'null') return DiscPay.errGeneric;
    final lowered = message.toLowerCase();
    if (lowered.contains('mounted payment element')) {
      return DiscPay.webPayStripeNotReady;
    }
    if (message.length > 180) return DiscPay.errGeneric;
    return message;
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;
    final layout = DiscoveryResponsive.of(context);
    final maxWidth = layout.isTablet ? 480.0 : 420.0;
    final stackActions = layout.stackStepperActions;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: layout.horizontalPadding,
        vertical: 24,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: Material(
          color: theme.colorScheme.surface,
          elevation: 8,
          shadowColor: AppColors.brandBrown.withValues(alpha: 0.2),
          shape: RoundedRectangleBorder(
            borderRadius: DiscoveryStyles.cardBorderRadius,
          ),
          clipBehavior: Clip.antiAlias,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              _Header(onClose: _submitting ? null : () => Navigator.of(context).pop(false)),
              Flexible(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _AmountHero(amountLabel: widget.amountLabel, primary: primary),
                      const SizedBox(height: 14),
                      Text(
                        DiscPay.recapTrust,
                        style: theme.textTheme.bodySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      const StripeTestCardHint(compact: true),
                      const SizedBox(height: 12),
                      _StripeFormCard(
                        stripeReadyFuture: _stripeReadyFuture,
                        clientSecret: widget.sheet.paymentIntentClientSecret,
                        brightness: theme.brightness,
                        onCardChanged: (complete) {
                          if (_cardComplete == complete) return;
                          setState(() => _cardComplete = complete);
                        },
                      ),
                      if (_errorMessage != null) ...[
                        const SizedBox(height: 12),
                        _ErrorBanner(message: _errorMessage!),
                      ],
                    ],
                  ),
                ),
              ),
              _ActionsBar(
                stackActions: stackActions,
                submitting: _submitting,
                canPay: _cardComplete,
                onCancel: () => Navigator.of(context).pop(false),
                onPay: _pay,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.onClose});

  final VoidCallback? onClose;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 18, 12, 14),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            primary.withValues(alpha: 0.1),
            AppColors.brandGold.withValues(alpha: 0.06),
          ],
        ),
        border: Border(
          bottom: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.12)),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.lock_rounded, color: primary, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DiscPay.webPayTitle,
                  style: theme.textTheme.titleLarge?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  DiscPay.webPaySecuredBy,
                  style: theme.textTheme.labelSmall?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: onClose,
            tooltip: DiscPay.webPayCancel,
            icon: const Icon(Icons.close_rounded),
          ),
        ],
      ),
    );
  }
}

class _AmountHero extends StatelessWidget {
  const _AmountHero({required this.amountLabel, required this.primary});

  final String amountLabel;
  final Color primary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.cardSurfaceLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.22)),
      ),
      child: Row(
        children: [
          Icon(Icons.credit_card_rounded, color: primary, size: 26),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  DiscPay.webPayDueNow,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  amountLabel,
                  style: theme.textTheme.headlineSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w900,
                    color: primary,
                    letterSpacing: -0.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _StripeFormCard extends StatelessWidget {
  const _StripeFormCard({
    required this.stripeReadyFuture,
    required this.clientSecret,
    required this.brightness,
    required this.onCardChanged,
  });

  final Future<bool> stripeReadyFuture;
  final String clientSecret;
  final Brightness brightness;
  final ValueChanged<bool> onCardChanged;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Container(
      padding: const EdgeInsets.fromLTRB(12, 12, 12, 8),
      decoration: BoxDecoration(
        color: theme.brightness == Brightness.dark
            ? AppColors.darkSurfaceContainer
            : AppColors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: 0.18),
        ),
      ),
      child: FutureBuilder<bool>(
        future: stripeReadyFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const SizedBox(
              height: 220,
              child: Center(child: CircularProgressIndicator()),
            );
          }
          if (snapshot.data != true) {
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 8),
              child: Text(
                DiscPay.errNotConfigured,
                textAlign: TextAlign.center,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            );
          }
          return PaymentElement(
            clientSecret: clientSecret,
            height: 260,
            appearance: bookingWebPaymentElementAppearance(brightness),
            paymentMethodOrder: bookingWebPaymentMethodOrder,
            layout: const PaymentElementLayout(
              type: PaymentElementLayoutType.accordion,
              defaultCollapsed: false,
              radios: false,
            ),
            onCardChanged: (details) {
              onCardChanged(details?.complete == true);
            },
          );
        },
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: theme.colorScheme.error.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: theme.colorScheme.error.withValues(alpha: 0.25),
        ),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.error_outline_rounded, color: theme.colorScheme.error, size: 18),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              message,
              style: theme.textTheme.bodySmall?.copyWith(
                color: theme.colorScheme.error,
                height: 1.35,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActionsBar extends StatelessWidget {
  const _ActionsBar({
    required this.stackActions,
    required this.submitting,
    required this.canPay,
    required this.onCancel,
    required this.onPay,
  });

  final bool stackActions;
  final bool submitting;
  final bool canPay;
  final VoidCallback onCancel;
  final VoidCallback onPay;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final cancelButton = OutlinedButton(
      onPressed: submitting ? null : onCancel,
      child: const Text(DiscPay.webPayCancel),
    );
    final payButton = FilledButton(
      onPressed: canPay && !submitting ? onPay : null,
      child: submitting
          ? SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: theme.colorScheme.onPrimary,
              ),
            )
          : Text(DiscPay.webPayConfirm),
    );

    return Container(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 20),
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        border: Border(
          top: BorderSide(color: theme.colorScheme.outline.withValues(alpha: 0.1)),
        ),
      ),
      child: stackActions
          ? Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                payButton,
                const SizedBox(height: 8),
                cancelButton,
              ],
            )
          : Row(
              children: [
                Expanded(child: cancelButton),
                const SizedBox(width: 12),
                Expanded(flex: 2, child: payButton),
              ],
            ),
    );
  }
}
