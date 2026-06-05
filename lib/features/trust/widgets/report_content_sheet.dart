import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../services/supabase/trust/content_report_service.dart';
import '../../../services/supabase/trust/trust_service_providers.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';

Future<void> showReportContentSheet(
  BuildContext context, {
  required ContentReportTargetType targetType,
  required String targetId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    showDragHandle: true,
    builder: (ctx) => Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.viewInsetsOf(ctx).bottom,
      ),
      child: _ReportContentSheet(
        targetType: targetType,
        targetId: targetId,
      ),
    ),
  );
}

class _ReportContentSheet extends ConsumerStatefulWidget {
  const _ReportContentSheet({
    required this.targetType,
    required this.targetId,
  });

  final ContentReportTargetType targetType;
  final String targetId;

  @override
  ConsumerState<_ReportContentSheet> createState() =>
      _ReportContentSheetState();
}

class _ReportContentSheetState extends ConsumerState<_ReportContentSheet> {
  static const _reasons = [
    DiscReport.reasonSpam,
    DiscReport.reasonHarassment,
    DiscReport.reasonScam,
    DiscReport.reasonOther,
  ];

  String _reason = DiscReport.reasonSpam;
  final _details = TextEditingController();
  bool _submitting = false;

  @override
  void dispose() {
    _details.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final service = ref.read(contentReportServiceProvider);
    if (service == null) {
      AppSnackBar.error(context, DiscReport.err);
      return;
    }

    setState(() => _submitting = true);
    try {
      await service.submit(
        targetType: widget.targetType,
        targetId: widget.targetId,
        reason: _reason,
        details: _details.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop();
      AppSnackBar.success(context, DiscReport.ok);
    } catch (_) {
      if (mounted) AppSnackBar.error(context, DiscReport.err);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              DiscReport.sheetTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              DiscReport.sheetBody,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
                height: 1.45,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              DiscReport.reasonLabel,
              style: theme.textTheme.labelLarge?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            ..._reasons.map(
              (r) => RadioListTile<String>(
                value: r,
                groupValue: _reason,
                title: Text(r),
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
              controller: _details,
              maxLines: 3,
              decoration: const InputDecoration(
                labelText: DiscReport.detailsLabel,
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
                  : const Text(DiscReport.submit),
            ),
          ],
        ),
      ),
    );
  }
}

