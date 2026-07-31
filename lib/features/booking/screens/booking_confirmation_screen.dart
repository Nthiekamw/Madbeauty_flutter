import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/models/domain/booking/booking_platform_fee_settings.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/referral/referral_providers.dart';
import '../../../services/supabase/loyalty/loyalty_providers.dart';
import '../../../services/supabase/relations/client_prestataire_relation_providers.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_detail_skeleton.dart';
import '../../prestataire/providers/catalog/prestataire_detail_provider.dart';
import '../logic/booking_confirmation_submit.dart';
import '../logic/booking_payment_flow.dart';
import '../logic/booking_pricing.dart';
import '../providers/booking_platform_fee_settings_provider.dart';
import '../providers/client_prior_booking_count_provider.dart';
import '../providers/is_own_prestataire_profile_provider.dart';
import '../providers/prestataire_online_payment_provider.dart';
import '../../../shared/layout/web_flow_scaffold.dart';
import '../../../shared/layout/web_flow_panel.dart';
import '../widgets/confirmation/booking_confirmation_recap_body.dart';
import '../widgets/shared/booking_message.dart';
import '../widgets/shared/booking_success_view.dart';
import '../widgets/shared/add_to_calendar_sheet.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  const BookingConfirmationScreen({
    super.key,
    required this.prestataireId,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.durationMinutes,
    required this.dateTime,
    this.packId,
  });

  final String prestataireId;
  final String serviceId;
  final String serviceName;
  final double price;
  final int durationMinutes;
  final DateTime dateTime;
  final String? packId;

  @override
  ConsumerState<BookingConfirmationScreen> createState() =>
      _BookingConfirmationScreenState();
}

class _BookingConfirmationScreenState
    extends ConsumerState<BookingConfirmationScreen> {
  bool _isSubmitting = false;
  bool _isSuccess = false;
  bool _queuedOffline = false;
  bool _paidWithStripe = false;
  bool _paidOnSite = false;
  String? _errorMessage;
  BookingPaymentPhase _paymentPhase = BookingPaymentPhase.idle;
  BookingPaymentModeKind _paymentMode = BookingPaymentModeKind.onSite;
  bool _applyLoyaltyReward = false;

  @override
  Widget build(BuildContext context) {
    if (_isSuccess) {
      return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          title: const Text(DiscBk.doneAppBar),
        ),
        body: BookingSuccessView(
          onViewReservations: () => context.goMyReservations(),
          onGoHome: () => context.goHome(),
          onAddToCalendar: _queuedOffline
              ? null
              : () => showAddToCalendarSheet(
                    context,
                    reservationId:
                        '${widget.prestataireId}_${widget.dateTime.toIso8601String()}',
                    title:
                        '${widget.serviceName} — MadBeauty',
                    start: widget.dateTime,
                    durationMinutes: widget.durationMinutes,
                  ),
          body: _queuedOffline
              ? DiscBk.doneBodyQueued
              : _paidWithStripe
                  ? DiscBk.doneBodyPaid
                  : _paidOnSite
                      ? DiscPay.doneBodyOnSite
                      : DiscBk.doneBody,
        ),
      );
    }

    final prestataireAsync = ref.watch(
      prestataireDetailProvider(widget.prestataireId),
    );
    final isOwnProfile = ref
        .watch(isOwnPrestataireProfileProvider(widget.prestataireId))
        .maybeWhen(data: (value) => value, orElse: () => false);
    final depositAvailableAsync = ref.watch(
      prestataireDepositAvailableProvider(widget.prestataireId),
    );
    final depositAvailable = depositAvailableAsync.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );
    final priorCount = ref.watch(clientPriorBookingCountProvider).maybeWhen(
          data: (value) => value,
          orElse: () => 0,
        );
    final referralDiscountPercent =
        ref.watch(clientReferralDiscountPercentProvider);
    final vipDiscountPercent =
        ref.watch(clientVipDiscountPercentProvider(widget.prestataireId));
    final loyaltyInfo = ref.watch(myLoyaltyInfoProvider).maybeWhen(
          data: (value) => value,
          orElse: () => null,
        );
    final isPack = widget.packId != null && widget.packId!.trim().isNotEmpty;
    final loyaltyAvailable = !isPack && loyaltyInfo?.canRedeem == true;
    if (!loyaltyAvailable && _applyLoyaltyReward) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted) setState(() => _applyLoyaltyReward = false);
      });
    }
    final stripeAvailable = BookingPaymentFlow.isPaymentAvailable;

    final platformFeeSettings = ref
        .watch(bookingPlatformFeeSettingsProvider)
        .maybeWhen(data: (value) => value, orElse: () => null);
    final feeSettings =
        platformFeeSettings ?? BookingPlatformFeeSettings.defaults;

    var provisionalMode = depositAvailable && stripeAvailable
        ? _paymentMode
        : BookingPaymentModeKind.onSite;

    BookingPricingBreakdown? breakdown;
    try {
      breakdown = computeBookingPricing(
        servicePriceEur: widget.price,
        paymentMode: provisionalMode,
        priorBookingCount: priorCount,
        prestataireAcceptsConnect: depositAvailable,
        platformFeeSettings: feeSettings,
        referralDiscountPercent: referralDiscountPercent,
        vipDiscountPercent: vipDiscountPercent,
        applyLoyaltyReward: _applyLoyaltyReward && loyaltyAvailable,
      );
      if (breakdown.isFullyCoveredByLoyalty) {
        provisionalMode = BookingPaymentModeKind.onSite;
        breakdown = computeBookingPricing(
          servicePriceEur: widget.price,
          paymentMode: provisionalMode,
          priorBookingCount: priorCount,
          prestataireAcceptsConnect: depositAvailable,
          platformFeeSettings: feeSettings,
          referralDiscountPercent: referralDiscountPercent,
          vipDiscountPercent: vipDiscountPercent,
          applyLoyaltyReward: _applyLoyaltyReward && loyaltyAvailable,
        );
      }
    } on BookingPricingException {
      breakdown = null;
    }
    final effectiveMode = provisionalMode;

    return WebFlowScaffold(
      appBar: AppBar(
        title: const Text(DiscBk.recapTitle),
        centerTitle: true,
      ),
      body: prestataireAsync.when(
        loading: () => const DiscoveryDetailSkeleton(),
        error: (_, __) => const BookingMessage(
          icon: Icons.storefront_outlined,
          title: DiscBk.recapPrestaBadTitle,
          message: DiscBk.recapPrestaBadBody,
        ),
        data: (detail) {
          if (detail == null) {
            return const BookingMessage(
              icon: Icons.storefront_outlined,
              title: DiscBk.recapPrestaBadTitle,
              message: DiscBk.recapPrestaBadBody,
            );
          }

          final profile = detail.profile;
          final salon = profile.nomSalon?.trim();
          final prestataireName =
              salon != null && salon.isNotEmpty ? salon : 'Salon';

          return WebFlowPanel(
            child: BookingConfirmationRecapBody(
            prestataireName: prestataireName,
            avatarUrl: detail.avatarUrl,
            ville: profile.ville,
            serviceName: widget.serviceName,
            dateTime: widget.dateTime,
            durationMinutes: widget.durationMinutes,
            price: widget.price,
            breakdown: breakdown,
            effectiveMode: effectiveMode,
            acceptsOnline: depositAvailable,
            stripeAvailable: stripeAvailable,
            isOwnProfile: isOwnProfile,
            isSubmitting: _isSubmitting,
            acceptsOnlineLoading: depositAvailableAsync.isLoading,
            errorMessage: _errorMessage,
            ctaLabel: _ctaLabel(breakdown),
            onPaymentModeChanged: (mode) => setState(() => _paymentMode = mode),
            onConfirm: _confirm,
            loyaltyAvailable: loyaltyAvailable,
            applyLoyaltyReward: _applyLoyaltyReward && loyaltyAvailable,
            onApplyLoyaltyChanged: (v) =>
                setState(() => _applyLoyaltyReward = v),
            loyaltyMaxRewardEuros: loyaltyInfo?.maxRewardEuros ?? 50,
          ),
          );
        },
      ),
    );
  }

  String _ctaLabel(BookingPricingBreakdown? breakdown) {
    if (!_isSubmitting) {
      if (breakdown == null) return DiscBk.recapCta;
      if (breakdown.requiresInAppPayment) {
        return DiscPay.recapCtaPayAmount.replaceFirst(
          '%s',
          CurrencyFormat.eur(breakdown.totalChargeEur, decimals: true),
        );
      }
      return DiscPay.recapCtaOnSite;
    }
    return switch (_paymentPhase) {
      BookingPaymentPhase.preparing => DiscPay.preparing,
      BookingPaymentPhase.presenting => DiscPay.preparing,
      BookingPaymentPhase.confirming => DiscPay.confirming,
      BookingPaymentPhase.idle => DiscBk.recapCta,
    };
  }

  Future<void> _confirm() async {
    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    final result = await BookingConfirmationSubmit.confirm(
      ref: ref,
      context: context,
      prestataireId: widget.prestataireId,
      serviceId: widget.serviceId,
      serviceName: widget.serviceName,
      price: widget.price,
      dateTime: widget.dateTime,
      paymentMode: _paymentMode,
      packId: widget.packId,
      applyLoyaltyReward: _applyLoyaltyReward,
      onPhase: (phase) {
        if (!mounted) return;
        setState(() => _paymentPhase = phase);
      },
      onError: _showConfirmError,
    );

    if (!mounted) return;
    if (result == null) return;

    setState(() {
      _isSubmitting = false;
      _isSuccess = true;
      _queuedOffline = result.queuedOffline;
      _paidWithStripe = result.paidWithStripe;
      _paidOnSite = result.paidOnSite;
    });
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted) return;
      AppSnackBar.success(context, DiscBk.bookingCreatedSnack);
    });
  }

  void _showConfirmError(String message) {
    if (!mounted) return;
    setState(() {
      _isSubmitting = false;
      _paymentPhase = BookingPaymentPhase.idle;
      _errorMessage = message;
    });
    AppSnackBar.show(
      context,
      message: message,
      kind: AppSnackKind.error,
      duration: const Duration(seconds: 5),
    );
  }
}
