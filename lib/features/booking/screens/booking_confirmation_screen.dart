import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../services/offline/offline_queue_helper.dart';
import '../../../services/offline/pending_offline_action.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/booking/booking_service_providers.dart'
    show
        bookingServiceProvider,
        invalidateBookingDetail,
        invalidateClientReservations;
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app_avatar.dart';
import '../../../shared/widgets/app_button.dart';
import '../../prestataire/providers/prestataire_detail_provider.dart';
import '../providers/is_own_prestataire_profile_provider.dart';
import '../logic/booking_create_failure.dart';
import '../logic/booking_formatters.dart';
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
  String? _errorMessage;

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
          body: _queuedOffline ? DiscBk.doneBodyQueued : DiscBk.doneBody,
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
                value: '${widget.price.toStringAsFixed(2)} €',
                meta: formatBookingServiceMeta(
                  durationMinutes: widget.durationMinutes,
                  price: widget.price,
                ),
                theme: theme,
                primary: primary,
                isDark: isDark,
              ),

              const SizedBox(height: 14),

              // Mention de confiance
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: const Color(0xFF10B981).withValues(alpha: 0.2),
                  ),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.shield_outlined,
                        size: 18, color: Color(0xFF10B981)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        DiscBk.recapTrust,
                        style: theme.textTheme.bodySmall?.copyWith(
                          fontFamily: AppFonts.body,
                          color: const Color(0xFF10B981),
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),

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
                  isLoading: _isSubmitting,
                  enabled: !_isSubmitting && !isOwnProfile,
                  onPressed: _isSubmitting || isOwnProfile ? null : _confirm,
                  child: const Text(DiscBk.recapCta),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _confirm() async {
    final bookingService = ref.read(bookingServiceProvider);
    if (bookingService == null) {
      setState(() => _errorMessage = DiscBk.errGenericSave);
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
      });
      return;
    }

    setState(() {
      _isSubmitting = true;
      _errorMessage = null;
    });

    try {
      final reservation = await bookingService.create(
        prestataireId: widget.prestataireId,
        serviceId: widget.serviceId,
        dateHeure: widget.dateTime,
      );
      invalidateBookingDetail(ref, reservation.id);
      invalidateClientReservations(ref);
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _isSuccess = true;
        _queuedOffline = false;
      });
    } catch (error) {
      if (!mounted) return;
      setState(() {
        _isSubmitting = false;
        _errorMessage = bookingCreateFailureMessage(error);
      });
    }
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
    required this.meta,
    required this.theme,
    required this.primary,
    required this.isDark,
  });

  final String label;
  final String value;
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
    );
  }
}
