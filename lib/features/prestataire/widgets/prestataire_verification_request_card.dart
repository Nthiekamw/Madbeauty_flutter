import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../services/supabase/prestataire/prestataire_verification_service.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';

final _prestataireVerificationServiceProvider =
    Provider<PrestataireVerificationService>((ref) {
  return PrestataireVerificationService.fromEnv();
});

final prestataireVerificationStatusProvider =
    FutureProvider.autoDispose<DateTime?>((ref) async {
  return ref.read(_prestataireVerificationServiceProvider).fetchRequestedAt();
});

class PrestataireVerificationRequestCard extends ConsumerStatefulWidget {
  const PrestataireVerificationRequestCard({super.key});

  @override
  ConsumerState<PrestataireVerificationRequestCard> createState() =>
      _PrestataireVerificationRequestCardState();
}

class _PrestataireVerificationRequestCardState
    extends ConsumerState<PrestataireVerificationRequestCard> {
  bool _loading = false;

  Future<void> _request() async {
    if (_loading) return;
    setState(() => _loading = true);
    try {
      await ref.read(_prestataireVerificationServiceProvider).requestVerification();
      ref.invalidate(prestataireVerificationStatusProvider);
      if (mounted) {
        AppSnackBar.show(context, message: DiscProfile.prestataireVerificationRequestOk);
      }
    } catch (_) {
      if (mounted) {
        AppSnackBar.error(context, DiscProfile.prestataireVerificationRequestErr);
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusAsync = ref.watch(prestataireVerificationStatusProvider);
    final theme = Theme.of(context);

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              DiscProfile.prestataireVerificationRequestTitle,
              style: theme.textTheme.titleSmall,
            ),
            const SizedBox(height: 6),
            Text(
              DiscProfile.prestataireVerificationRequestBody,
              style: theme.textTheme.bodySmall,
            ),
            const SizedBox(height: 10),
            statusAsync.when(
              data: (requestedAt) {
                if (requestedAt != null) {
                  return Text(
                    DiscProfile.prestataireVerificationPending,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.primary,
                    ),
                  );
                }
                return FilledButton(
                  onPressed: _loading ? null : _request,
                  child: _loading
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text(DiscProfile.prestataireVerificationRequestCta),
                );
              },
              loading: () => const LinearProgressIndicator(),
              error: (_, __) => FilledButton(
                onPressed: _loading ? null : _request,
                child: const Text(DiscProfile.prestataireVerificationRequestCta),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
