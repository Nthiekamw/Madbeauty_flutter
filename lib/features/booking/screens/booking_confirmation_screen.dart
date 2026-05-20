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
          final timeLabel = _formatTime(widget.dateTime);

          return ListView(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
            children: [
              Card(
                elevation: 0,
                color: theme.colorScheme.primaryContainer.withValues(
                  alpha: 0.45,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(24),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Row(
                    children: [
                      AppAvatar(
                        imageUrl: detail.avatarUrl,
                        displayName: prestataireName,
                        radius: 36,
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              DiscBk.recapPresta,
                              style: theme.textTheme.labelLarge?.copyWith(
                                color: theme.colorScheme.onSurfaceVariant,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              prestataireName,
                              style: theme.textTheme.titleLarge?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                            if (profile.ville?.trim().isNotEmpty == true) ...[
                              const SizedBox(height: 4),
                              Text(
                                profile.ville!.trim(),
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: theme.colorScheme.onSurfaceVariant,
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 16),
              _RecapRow(
                label: DiscBk.recapSvc,
                value: widget.serviceName,
              ),
              _RecapRow(
                label: DiscBk.recapDate,
                value: formatBookingDate(widget.dateTime),
              ),
              _RecapRow(
                label: DiscBk.recapTime,
                value: timeLabel,
              ),
              _RecapRow(
                label: DiscBk.recapPrice,
                value: '${widget.price.toStringAsFixed(2)} €',
                highlight: true,
              ),
              const SizedBox(height: 8),
              Text(
                formatBookingServiceMeta(
                  durationMinutes: widget.durationMinutes,
                  price: widget.price,
                ),
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                DiscBk.recapTrust,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              if (_errorMessage != null) ...[
                const SizedBox(height: 16),
                Material(
                  color: theme.colorScheme.errorContainer,
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(
                          Icons.error_outline,
                          color: theme.colorScheme.onErrorContainer,
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _errorMessage!,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: theme.colorScheme.onErrorContainer,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
              if (isOwnProfile) ...[
                const SizedBox(height: 12),
                BookingMessage(
                  icon: Icons.person_outline,
                  title: DiscBk.cannotBookOwnTitle,
                  message: DiscBk.cannotBookOwnBody,
                ),
              ],
              const SizedBox(height: 20),
              AppButton(
                isLoading: _isSubmitting,
                enabled: !_isSubmitting && !isOwnProfile,
                onPressed:
                    _isSubmitting || isOwnProfile ? null : _confirm,
                child: const Text(DiscBk.recapCta),
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
      setState(() {
        _errorMessage = DiscBk.errGenericSave;
      });
      return;
    }

    final detail = ref.read(prestataireDetailProvider(widget.prestataireId)).value;
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

class _RecapRow extends StatelessWidget {
  const _RecapRow({
    required this.label,
    required this.value,
    this.highlight = false,
  });

  final String label;
  final String value;
  final bool highlight;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Card(
      margin: const EdgeInsets.only(bottom: 10),
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    label,
                    style: theme.textTheme.labelLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: (highlight
                            ? theme.textTheme.headlineSmall
                            : theme.textTheme.titleMedium)
                        ?.copyWith(fontWeight: FontWeight.w800),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
