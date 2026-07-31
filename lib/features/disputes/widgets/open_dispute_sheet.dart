import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/supabase_service_exception.dart';
import '../../../router/navigation_extensions.dart';
import '../../../services/supabase/disputes/dispute_providers.dart';
import '../../../services/supabase/disputes/dispute_service.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';

Future<void> showOpenDisputeSheet(
  BuildContext context, {
  required String reservationId,
  required DisputeSenderRole viewerRole,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(ctx).bottom,
      ),
      child: _OpenDisputeSheet(
        reservationId: reservationId,
        viewerRole: viewerRole,
      ),
    ),
  );
}

class _OpenDisputeSheet extends ConsumerStatefulWidget {
  const _OpenDisputeSheet({
    required this.reservationId,
    required this.viewerRole,
  });

  final String reservationId;
  final DisputeSenderRole viewerRole;

  @override
  ConsumerState<_OpenDisputeSheet> createState() => _OpenDisputeSheetState();
}

class _OpenDisputeSheetState extends ConsumerState<_OpenDisputeSheet> {
  DisputeReason _reason = DisputeReason.quality;
  final _summary = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _summary.dispose();
    super.dispose();
  }

  String _mapError(Object error) {
    final raw = error is SupabaseServiceException
        ? error.message
        : error.toString();
    final lower = raw.toLowerCase();
    if (lower.contains('dispute_already_open')) {
      return DiscDispute.errAlreadyOpen;
    }
    if (lower.contains('dispute_not_eligible')) {
      return DiscDispute.errNotEligible;
    }
    if (lower.contains('forbidden')) {
      return DiscDispute.errForbidden;
    }
    if (lower.contains('reservation_not_found') ||
        lower.contains('dispute_not_found')) {
      return DiscDispute.errNotFound;
    }
    return DiscDispute.submitErr;
  }

  Future<void> _submit() async {
    final service = ref.read(disputeServiceProvider);
    if (service == null) {
      AppSnackBar.error(context, DiscDispute.submitErr);
      return;
    }

    setState(() => _submitting = true);
    try {
      final dispute = await service.open(
        reservationId: widget.reservationId,
        reason: _reason,
        summary: _summary.text,
      );
      ref.invalidate(activeDisputeForReservationProvider(widget.reservationId));
      ref.invalidate(myDisputesProvider);
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackBar.success(context, DiscDispute.submitOk);
      if (widget.viewerRole == DisputeSenderRole.prestataire) {
        context.pushPrestataireDisputeDetail(dispute.id);
      } else {
        context.pushClientDisputeDetail(dispute.id);
      }
    } catch (e) {
      if (mounted) AppSnackBar.error(context, _mapError(e));
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              DiscDispute.sheetTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DiscDispute.sheetBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DiscDispute.reasonLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ...DisputeReason.values.map(
              (r) => RadioListTile<DisputeReason>(
                value: r,
                groupValue: _reason,
                title: Text(DiscDispute.reasonLabelOf(r.value)),
                onChanged: _submitting
                    ? null
                    : (v) {
                        if (v != null) setState(() => _reason = v);
                      },
                contentPadding: EdgeInsets.zero,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _summary,
              maxLines: 3,
              maxLength: 1000,
              enabled: !_submitting,
              decoration: const InputDecoration(
                labelText: DiscDispute.summaryLabel,
                hintText: DiscDispute.summaryHint,
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      height: 22,
                      width: 22,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(DiscDispute.submit),
            ),
          ],
        ),
      ),
    );
  }
}
