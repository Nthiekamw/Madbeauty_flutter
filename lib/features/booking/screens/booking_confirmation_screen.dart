import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart' show FunctionException;

import '../../../core/config/app_config.dart';
import '../../../core/constants/app_strings.dart';
import '../../../services/offline/offline_queue_helper.dart';
import '../../../services/offline/pending_offline_action.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/stripe/stripe_booking_payment_service.dart';
import '../../../services/stripe/stripe_payment_exception.dart';
import '../../../services/stripe/stripe_payment_providers.dart';
import '../../../services/supabase/booking/booking_service_providers.dart'
    show
        bookingServiceProvider,
        invalidateBookingDetail,
        invalidateClientReservations;
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/utils/currency_format.dart';
import '../../../shared/widgets/app/app_avatar.dart';
import '../../../shared/widgets/app/app_button.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../prestataire/providers/prestataire_detail_provider.dart';
import '../../../services/supabase/referral/referral_providers.dart';
import '../providers/client_prior_booking_count_provider.dart';
import '../providers/prestataire_online_payment_provider.dart';
import '../providers/is_own_prestataire_profile_provider.dart';
import '../logic/booking_create_failure.dart';
import '../logic/booking_formatters.dart';
import '../logic/booking_payment_flow.dart';
import '../logic/booking_pricing.dart';
import '../widgets/booking_checkout_panel.dart';
import '../widgets/booking_message.dart';
import '../widgets/booking_success_view.dart';

class BookingConfirmationScreen extends ConsumerStatefulWidget {
  const BookingConfirmationScreen({
    super.key,
    required this.prestataireId,
    required this.serviceId,
    required this.serviceName,
    required this.price,
    required this.durationMinutes,
    required this.dateTime,
  });

  final String prestataireId;
  final String serviceId;
  final String serviceName;
  final double price;
  final int durationMinutes;
  final DateTime dateTime;

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
    final isOwnAsync = ref.watch(
      isOwnPrestataireProfileProvider(widget.prestataireId),
    );
    final isOwnProfile = isOwnAsync.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );
    final acceptsOnlineAsync = ref.watch(
      prestataireAcceptsOnlinePaymentProvider(widget.prestataireId),
    );
    final acceptsOnline = acceptsOnlineAsync.maybeWhen(
      data: (value) => value,
      orElse: () => false,
    );
    final priorCount = ref.watch(clientPriorBookingCountProvider).maybeWhen(
          data: (value) => value,
          orElse: () => 0,
        );
    final referralDiscountPercent =
        ref.watch(clientReferralDiscountPercentProvider);
    final stripeAvailable = BookingPaymentFlow.isPaymentAvailable;
    final effectiveMode = acceptsOnline && stripeAvailable
        ? _paymentMode
        : BookingPaymentModeKind.onSite;

    BookingPricingBreakdown? breakdown;
    try {
      breakdown = computeBookingPricing(
        servicePriceEur: widget.price,
        paymentMode: effectiveMode,
        priorBookingCount: priorCount,
        prestataireAcceptsConnect: acceptsOnline,
        referralDiscountPercent: referralDiscountPercent,
      );
    } on BookingPricingException {
      breakdown = null;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text(DiscBk.recapTitle),
        centerTitle: true,
      ),
      body: prestataireAsync.when(
        loading: () => const Center(child: CircularProgressIndicator()),
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
          final theme = Theme.of(context);
          final isDark = theme.brightness == Brightness.dark;
          final primary = theme.colorScheme.primary;

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
            children: [
              // ── Carte prestataire hero ─────────────────────────────
              DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    stops: const [0.0, 0.6, 1.0],
                    colors: [
                      primary.withValues(alpha: isDark ? 0.45 : 0.7),
                      theme.colorScheme.primaryContainer.withValues(
                        alpha: isDark ? 0.6 : 0.88,
                      ),
                      theme.colorScheme.tertiary.withValues(
                        alpha: isDark ? 0.25 : 0.35,
                      ),
                    ],
                  ),
                  border: Border.all(
                    color: primary.withValues(alpha: isDark ? 0.3 : 0.18),
                    width: 1.5,
                  ),
                  boxShadow: isDark
                      ? null
                      : [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.12),
                            blurRadius: 16,
                            offset: const Offset(0, 5),
                          ),
                        ],
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: Colors.white.withValues(alpha: 0.3),
                            width: 2.5,
                          ),
                        ),
                        child: AppAvatar(
                          imageUrl: detail.avatarUrl,
                          displayName: prestataireName,
                          radius: 34,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DiscBk.recapPresta,
                              style: TextStyle(
                                fontFamily: AppFonts.body,
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: Colors.white.withValues(alpha: 0.7),
                                letterSpacing: 0.3,
                              ),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              prestataireName,
                              style: const TextStyle(
                                fontFamily: AppFonts.display,
                                fontWeight: FontWeight.w800,
                                fontSize: 18,
                                color: Colors.white,
                                height: 1.1,
                              ),
                            ),
                            if (profile.ville?.trim().isNotEmpty == true) ...[
                              const SizedBox(height: 5),
                              Row(
                                children: [
                                  const Icon(Icons.location_on_rounded,
                                      size: 13, color: Colors.white70),
                                  const SizedBox(width: 4),
                                  Flexible(
                                    child: Text(
                                      profile.ville!.trim(),
                                      maxLines: 1,
                                      overflow: TextOverflow.ellipsis,
                                      style: const TextStyle(
                                        color: Colors.white70,
                                        fontSize: 13,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── Récap détails ──────────────────────────────────────
              Text(
                'Détails de la réservation',
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 10),

              _RecapCard(
                rows: [
                  _RecapItem(
                    icon: Icons.content_cut_rounded,
                    label: DiscBk.recapSvc,
                    value: widget.serviceName,
                  ),
                  _RecapItem(
                    icon: Icons.calendar_today_rounded,
                    label: DiscBk.recapDate,
                    value: formatBookingDate(widget.dateTime),
                  ),
                  _RecapItem(
                    icon: Icons.schedule_rounded,
                    label: DiscBk.recapTime,
                    value: _formatTime(widget.dateTime),
                  ),
                ],
              ),

              const SizedBox(height: 10),

              // Prix mis en avant
              _PriceHighlight(
                label: DiscBk.recapPrice,
                value: breakdown != null && breakdown.hasReferralDiscount
                    ? CurrencyFormat.eurCents(breakdown.servicePriceCents)
                    : CurrencyFormat.eur(widget.price, decimals: true),
                originalValue: breakdown != null && breakdown.hasReferralDiscount
                    ? CurrencyFormat.eur(widget.price, decimals: true)
                    : null,
                meta: formatBookingServiceMeta(
                  durationMinutes: widget.durationMinutes,
                  price: breakdown != null && breakdown.hasReferralDiscount
                      ? breakdown.servicePriceEur
                      : widget.price,
                ),
                theme: theme,
                primary: primary,
                isDark: isDark,
              ),

              if (breakdown != null && breakdown.hasReferralDiscount) ...[
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: const Color(0xFF7C3AED).withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: const Color(0xFF7C3AED).withValues(alpha: 0.25),
                    ),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(
                        Icons.local_offer_outlined,
                        size: 20,
                        color: Color(0xFF6D28D9),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          DiscPay.recapReferralDiscountBanner,
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: const Color(0xFF5B21B6),
                            height: 1.4,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 14),

              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: theme.colorScheme.surfaceContainerHighest
                      .withValues(alpha: isDark ? 0.35 : 0.65),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      size: 18,
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        DiscBk.recapCancelPolicy,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: AppFonts.body,
                          color: theme.colorScheme.onSurfaceVariant,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 14),

              if (breakdown != null) ...[
                BookingCheckoutPanel(
                  breakdown: breakdown,
                  paymentMode: effectiveMode,
                  prestataireAcceptsDeposit: acceptsOnline,
                  stripeAvailable: stripeAvailable,
                  onPaymentModeChanged: (mode) {
                    setState(() => _paymentMode = mode);
                  },
                ),
                const SizedBox(height: 14),
              ],

              // Mention de confiance
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: (breakdown?.requiresInAppPayment == true
                          ? const Color(0xFF10B981)
                          : theme.colorScheme.primary)
                      .withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: (breakdown?.requiresInAppPayment == true
                            ? const Color(0xFF10B981)
                            : theme.colorScheme.primary)
                        .withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      breakdown?.requiresInAppPayment == true
                          ? Icons.shield_outlined
                          : Icons.payments_outlined,
                      size: 18,
                      color: breakdown?.requiresInAppPayment == true
                          ? const Color(0xFF10B981)
                          : theme.colorScheme.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        breakdown?.requiresInAppPayment == true
                            ? DiscPay.recapTrust
                            : stripeAvailable
                                ? DiscPay.recapTrustOnSite
                                : DiscBk.recapTrust,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: AppFonts.body,
                          color: breakdown?.requiresInAppPayment == true
                              ? const Color(0xFF10B981)
                              : theme.colorScheme.primary,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              if (!stripeAvailable &&
                  breakdown?.requiresInAppPayment == true) ...[
                const SizedBox(height: 12),
                BookingMessage(
                  icon: Icons.payment_outlined,
                  title: 'Paiement indisponible',
                  message: DiscPay.errNotConfigured,
                ),
              ],

              // Erreur
              if (_errorMessage != null) ...[
                const SizedBox(height: 14),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: theme.colorScheme.errorContainer,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(Icons.error_rounded,
                          color: theme.colorScheme.onErrorContainer, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          _errorMessage!,
                          style: theme.textTheme.bodyMedium?.copyWith(
                            color: theme.colorScheme.onErrorContainer,
                            height: 1.4,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // Propre profil
              if (isOwnProfile) ...[
                const SizedBox(height: 12),
                BookingMessage(
                  icon: Icons.person_outline,
                  title: DiscBk.cannotBookOwnTitle,
                  message: DiscBk.cannotBookOwnBody,
                ),
              ],

              const SizedBox(height: 24),

              // CTA confirmer
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: !_isSubmitting && !isOwnProfile && !isDark
                      ? [
                          BoxShadow(
                            color: primary.withValues(alpha: 0.3),
                            blurRadius: 18,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: AppButton(
                  isLoading: _isSubmitting || acceptsOnlineAsync.isLoading,
                  enabled: !_isSubmitting &&
                      !isOwnProfile &&
                      !acceptsOnlineAsync.isLoading,
                  onPressed: _isSubmitting || isOwnProfile ? null : _confirm,
                  child: Text(_ctaLabel(breakdown)),
                ),
              ),
            ],
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
    final bookingService = ref.read(bookingServiceProvider);
    final payments = ref.read(stripeBookingPaymentServiceProvider);

    final acceptsOnline = await ref.read(
      prestataireAcceptsOnlinePaymentProvider(widget.prestataireId).future,
    );
    final priorCount = await ref.read(clientPriorBookingCountProvider.future);
    final referralDiscountPercent =
        ref.read(clientReferralDiscountPercentProvider);
    final effectiveMode = acceptsOnline && BookingPaymentFlow.isPaymentAvailable
        ? _paymentMode
        : BookingPaymentModeKind.onSite;

    BookingPricingBreakdown breakdown;
    try {
      breakdown = computeBookingPricing(
        servicePriceEur: widget.price,
        paymentMode: effectiveMode,
        priorBookingCount: priorCount,
        prestataireAcceptsConnect: acceptsOnline,
        referralDiscountPercent: referralDiscountPercent,
      );
    } on BookingPricingException {
      _showConfirmError(DiscPay.errDepositRequiresConnect);
      return;
    }

    if (!AppConfig.hasSupabase) {
      _showConfirmError(
        'Configuration Supabase absente. Relance avec '
        'flutter run --dart-define-from-file=.env',
      );
      return;
    }
    if (breakdown.requiresInAppPayment && payments == null) {
      _showConfirmError(DiscPay.errNotConfigured);
      return;
    }
    if (bookingService == null) {
      _showConfirmError(DiscBk.errGenericSave);
      return;
    }

    final detail =
        ref.read(prestataireDetailProvider(widget.prestataireId)).value;
    final profile = detail?.profile;
    final salon = profile?.nomSalon?.trim();
    final prestataireName =
        salon != null && salon.isNotEmpty ? salon : 'Salon';

    final localId = PendingOfflineAction.newLocalReservationId();
    final queued = await enqueueIfOffline(
      ref: ref,
      context: context,
      action: PendingOfflineAction.create(
        type: OfflineActionType.bookingCreate,
        payload: {
          'localReservationId': localId,
          'prestataireId': widget.prestataireId,
          'serviceId': widget.serviceId,
          'dateHeure': widget.dateTime.toIso8601String(),
          'serviceName': widget.serviceName,
          'prestataireName': prestataireName,
          'prestataireAvatarUrl': detail?.avatarUrl,
        },
      ),
    );

    if (queued) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _isSuccess = true;
        _queuedOffline = true;
        _paidWithStripe = false;
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
      _paymentPhase = BookingPaymentPhase.idle;
    });

    try {
      if (breakdown.requiresInAppPayment) {
        final paymentService = ref.read(stripeBookingPaymentServiceProvider);
        if (paymentService == null) {
          throw const StripePaymentNotConfiguredException();
        }
        final flow = BookingPaymentFlow(paymentService);
        final reservation = await flow.payAndCreateReservation(
          prestataireId: widget.prestataireId,
          serviceId: widget.serviceId,
          dateHeure: widget.dateTime,
          paymentMode: effectiveMode,
          onPhase: (phase) {
            if (!mounted) return;
            setState(() => _paymentPhase = phase);
          },
        );
        invalidateBookingDetail(ref, reservation.id);
        invalidateClientReservations(ref);
        ref.invalidate(clientPriorBookingCountProvider);
        ref.invalidate(myReferralInfoProvider);
        if (!mounted) return;
        setState(() {
          _isSubmitting = false;
          _isSuccess = true;
          _queuedOffline = false;
          _paidWithStripe = true;
          _paidOnSite = effectiveMode == BookingPaymentModeKind.onSite;
        });
        return;
      }

      final reservation = await bookingService.create(
        prestataireId: widget.prestataireId,
        serviceId: widget.serviceId,
        dateHeure: widget.dateTime,
        paymentMode: effectiveMode.wireValue,
        servicePriceCents: breakdown.servicePriceCents,
        platformFeeCents: breakdown.platformFeeCents,
        originalServicePriceCents: breakdown.hasReferralDiscount
            ? breakdown.originalServicePriceCents
            : null,
        referralDiscountPercent: breakdown.referralDiscountPercent,
      );
      invalidateBookingDetail(ref, reservation.id);
      invalidateClientReservations(ref);
      ref.invalidate(clientPriorBookingCountProvider);
      ref.invalidate(myReferralInfoProvider);
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _isSuccess = true;
        _queuedOffline = false;
        _paidWithStripe = false;
        _paidOnSite = true;
      });
    } on StripePaymentException catch (e) {
      _showConfirmError(BookingPaymentFlow.messageFor(e));
    } on FormatException catch (e) {
      _showConfirmError(
        e.message.isNotEmpty ? e.message : DiscBk.errGenericSave,
      );
    } catch (error, stackTrace) {
      debugPrint('Booking confirm failed: $error\n$stackTrace');
      _showConfirmError(_resolveConfirmError(error));
    }
  }

  String _resolveConfirmError(Object error) {
    if (error is StripePaymentException) {
      return BookingPaymentFlow.messageFor(error);
    }
    if (error is FunctionException) {
      return BookingPaymentFlow.messageFor(
        StripeBookingPaymentService.fromInvokeError(error),
      );
    }
    return bookingCreateFailureMessage(error);
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

  String _formatTime(DateTime value) {
    final hour = value.hour.toString().padLeft(2, '0');
    final minute = value.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }
}

// ─── Carte récap groupée ──────────────────────────────────────────────────────

class _RecapCard extends StatelessWidget {
  const _RecapCard({required this.rows});
  final List<_RecapItem> rows;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: theme.colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: theme.colorScheme.outline.withValues(alpha: isDark ? 0.14 : 0.1),
        ),
        boxShadow: isDark
            ? null
            : [
                BoxShadow(
                  color: theme.colorScheme.primary.withValues(alpha: 0.05),
                  blurRadius: 8,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Column(
        children: [
          for (var i = 0; i < rows.length; i++) ...[
            if (i > 0)
              Divider(
                height: 1,
                indent: 16,
                endIndent: 16,
                color: theme.colorScheme.outline.withValues(alpha: 0.1),
              ),
            rows[i],
          ],
        ],
      ),
    );
  }
}

class _RecapItem extends StatelessWidget {
  const _RecapItem({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primary = theme.colorScheme.primary;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 18, color: primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: AppFonts.body,
                    color: theme.colorScheme.onSurfaceVariant,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  value,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontFamily: AppFonts.display,
                    fontWeight: FontWeight.w700,
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

// ─── Prix mis en avant ────────────────────────────────────────────────────────

class _PriceHighlight extends StatelessWidget {
  const _PriceHighlight({
    required this.label,
    required this.value,
    this.originalValue,
    required this.meta,
    required this.theme,
    required this.primary,
    required this.isDark,
  });

  final String label;
  final String value;
  final String? originalValue;
  final String meta;
  final ThemeData theme;
  final Color primary;
  final bool isDark;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: primary.withValues(alpha: isDark ? 0.12 : 0.07),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: primary.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: primary.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(Icons.payments_rounded, size: 22, color: primary),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: theme.textTheme.labelSmall?.copyWith(
                    fontFamily: AppFonts.body,
                    color: primary.withValues(alpha: 0.8),
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  meta,
                  style: theme.textTheme.bodySmall?.copyWith(
                    fontFamily: AppFonts.body,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (originalValue != null) ...[
                Text(
                  originalValue!,
                  style: theme.textTheme.bodySmall?.copyWith(
                    decoration: TextDecoration.lineThrough,
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 2),
              ],
              Text(
                value,
                style: TextStyle(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w900,
                  fontSize: 24,
                  color: primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
