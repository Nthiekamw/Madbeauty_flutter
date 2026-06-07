import 'package:madbeauty/core/config/pricing_config.dart';
import 'package:madbeauty/core/constants/app_strings.dart';
import 'package:madbeauty/shared/utils/currency_format.dart';

/// Ligne affichée dans le bandeau paiement.
class ReservationPaymentLine {
  const ReservationPaymentLine({
    required this.label,
    required this.amountCents,
    this.emphasize = false,
  });

  final String label;
  final int amountCents;
  final bool emphasize;

  String get formattedAmount => formatCentsEur(amountCents);
}

/// Montants et libellés dérivés des colonnes `reservations`.
class ReservationPaymentDisplay {
  const ReservationPaymentDisplay({
    this.paymentMode,
    this.servicePriceCents,
    this.platformFeeCents,
    this.prestataireAmountCents,
    this.amountCents,
    this.paymentStatus,
  });

  final String? paymentMode;
  final int? servicePriceCents;
  final int? platformFeeCents;
  final int? prestataireAmountCents;
  final int? amountCents;
  final String? paymentStatus;

  factory ReservationPaymentDisplay.fromMap(Map<String, dynamic> map) {
    return ReservationPaymentDisplay(
      paymentMode: map['payment_mode'] as String?,
      servicePriceCents: (map['service_price_cents'] as num?)?.toInt(),
      platformFeeCents: (map['platform_fee_cents'] as num?)?.toInt(),
      prestataireAmountCents: (map['prestataire_amount_cents'] as num?)?.toInt(),
      amountCents: (map['amount_cents'] as num?)?.toInt(),
      paymentStatus: map['payment_status'] as String?,
    );
  }

  factory ReservationPaymentDisplay.fromFields({
    String? paymentMode,
    int? servicePriceCents,
    int? platformFeeCents,
    int? prestataireAmountCents,
    int? amountCents,
    String? paymentStatus,
  }) {
    return ReservationPaymentDisplay(
      paymentMode: paymentMode,
      servicePriceCents: servicePriceCents,
      platformFeeCents: platformFeeCents,
      prestataireAmountCents: prestataireAmountCents,
      amountCents: amountCents,
      paymentStatus: paymentStatus,
    );
  }

  bool get hasStructuredMode =>
      paymentMode == 'deposit_20' || paymentMode == 'on_site';

  bool get shouldShow =>
      hasStructuredMode ||
      (amountCents != null && amountCents! > 0) ||
      (servicePriceCents != null && servicePriceCents! > 0);

  bool get isDepositMode => paymentMode == 'deposit_20';

  bool get isOnSiteMode => paymentMode == 'on_site';

  int get resolvedServiceCents => servicePriceCents ?? 0;

  int get resolvedPlatformFee =>
      platformFeeCents ??
      (hasStructuredMode ? 0 : 0);

  int get resolvedPrestaPortion {
    if (prestataireAmountCents != null) return prestataireAmountCents!;
    if (isDepositMode && resolvedServiceCents > 0) {
      return ((resolvedServiceCents * PricingConfig.depositPercent) / 100)
          .round();
    }
    return 0;
  }

  int get balanceOnSiteCents {
    if (resolvedServiceCents <= 0) return 0;
    if (isOnSiteMode) return resolvedServiceCents;
    if (isDepositMode) {
      return resolvedServiceCents - resolvedPrestaPortion;
    }
    return 0;
  }

  int get paidInAppCents => amountCents ?? 0;

  bool get hasPaidInApp =>
      paidInAppCents > 0 &&
      (paymentStatus == 'authorized' ||
          paymentStatus == 'captured' ||
          paymentStatus == null);

  String get modeLabel => switch (paymentMode) {
        'deposit_20' => DiscResPay.modeDeposit20,
        'on_site' => DiscResPay.modeOnSite,
        _ => DiscResPay.modeUnknown,
      };

  /// Bandeau client (liste / détail).
  List<ReservationPaymentLine> clientLines() {
    final lines = <ReservationPaymentLine>[];

    if (hasStructuredMode) {
      if (resolvedPlatformFee > 0) {
        lines.add(
          ReservationPaymentLine(
            label: DiscResPay.platformFee,
            amountCents: resolvedPlatformFee,
          ),
        );
      }
      if (isDepositMode && resolvedPrestaPortion > 0) {
        lines.add(
          ReservationPaymentLine(
            label: DiscResPay.paidInApp,
            amountCents: resolvedPrestaPortion,
            emphasize: true,
          ),
        );
      } else if (isOnSiteMode &&
          paidInAppCents > 0 &&
          resolvedPlatformFee <= 0) {
        lines.add(
          ReservationPaymentLine(
            label: DiscResPay.paidInApp,
            amountCents: paidInAppCents,
            emphasize: true,
          ),
        );
      }
      if (balanceOnSiteCents > 0) {
        lines.add(
          ReservationPaymentLine(
            label: DiscResPay.collectOnSite,
            amountCents: balanceOnSiteCents,
            emphasize: true,
          ),
        );
      }
      return lines;
    }

    if (paidInAppCents > 0 && hasPaidInApp) {
      lines.add(
        ReservationPaymentLine(
          label: DiscResPay.legacyPaid,
          amountCents: paidInAppCents,
          emphasize: true,
        ),
      );
    }
    return lines;
  }

  /// Bandeau prestataire.
  List<ReservationPaymentLine> prestataireLines() {
    final lines = <ReservationPaymentLine>[];

    if (resolvedServiceCents > 0) {
      lines.add(
        ReservationPaymentLine(
          label: DiscResPay.serviceTotal,
          amountCents: resolvedServiceCents,
        ),
      );
    }

    if (hasStructuredMode) {
      if (isDepositMode && resolvedPrestaPortion > 0) {
        lines.add(
          ReservationPaymentLine(
            label: DiscResPay.depositReceived,
            amountCents: resolvedPrestaPortion,
            emphasize: true,
          ),
        );
      }
      if (balanceOnSiteCents > 0) {
        lines.add(
          ReservationPaymentLine(
            label: DiscResPay.collectOnSite,
            amountCents: balanceOnSiteCents,
            emphasize: true,
          ),
        );
      }
      return lines;
    }

    if (paidInAppCents > 0 && hasPaidInApp) {
      lines.add(
        ReservationPaymentLine(
          label: DiscResPay.depositReceived,
          amountCents: paidInAppCents,
          emphasize: true,
        ),
      );
    }
    return lines;
  }
}

String formatCentsEur(int cents) => CurrencyFormat.eurCents(cents);
