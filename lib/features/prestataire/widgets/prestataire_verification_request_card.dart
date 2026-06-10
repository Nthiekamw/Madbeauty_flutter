import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../services/supabase/prestataire/prestataire_verification_service.dart';
import '../../../shared/theme/app_colors.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../models/prestataire_verification_state.dart';

final prestataireVerificationServiceProvider =
    Provider<PrestataireVerificationService>((ref) {
  return PrestataireVerificationService.fromEnv();
});

final prestataireVerificationStatusProvider =
    FutureProvider.autoDispose<PrestataireVerificationState>((ref) async {
  return ref.read(prestataireVerificationServiceProvider).fetchStatus();
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
      await ref.read(prestataireVerificationServiceProvider).requestVerification();
      ref.invalidate(prestataireVerificationStatusProvider);
      if (mounted) {
        AppSnackBar.show(
          context,
          message: DiscProfile.prestataireVerificationRequestOk,
          kind: AppSnackKind.success,
        );
      }
    } on PrestataireVerificationException catch (e) {
      if (!mounted) return;
      final message = switch (e.code) {
        'already_verified' => DiscProfile.prestataireVerificationVerified,
        'already_pending' => DiscProfile.prestataireVerificationPending,
        _ => DiscProfile.prestataireVerificationRequestErr,
      };
      AppSnackBar.error(context, message);
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
        child: statusAsync.when(
          loading: () => const LinearProgressIndicator(),
          error: (_, __) => _RequestBody(
            theme: theme,
            state: PrestataireVerificationState.empty(),
            loading: _loading,
            onRequest: _request,
          ),
          data: (state) {
            if (!state.found) return const SizedBox.shrink();
            if (state.isVerified) {
              return _VerifiedBody(theme: theme, verifiedAt: state.verifiedAt);
            }
            return _RequestBody(
              theme: theme,
              state: state,
              loading: _loading,
              onRequest: _request,
            );
          },
        ),
      ),
    );
  }
}

class _VerifiedBody extends StatelessWidget {
  const _VerifiedBody({required this.theme, this.verifiedAt});

  final ThemeData theme;
  final DateTime? verifiedAt;

  @override
  Widget build(BuildContext context) {
    final dateText = verifiedAt != null
        ? DiscProfile.prestataireVerificationVerifiedSince.replaceFirst(
            '%s',
            MaterialLocalizations.of(context).formatShortDate(
              verifiedAt!.toLocal(),
            ),
          )
        : null;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 44,
          height: 44,
          decoration: BoxDecoration(
            color: AppColors.successBg12,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.successBorder35),
          ),
          child: const Icon(Icons.verified_rounded, color: AppColors.success),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                DiscProfile.prestataireVerificationVerified,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                  color: AppColors.success,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DiscProfile.prestataireVerificationVerifiedBody,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                  height: 1.35,
                ),
              ),
              if (dateText != null) ...[
                const SizedBox(height: 6),
                Text(
                  dateText,
                  style: theme.textTheme.labelMedium?.copyWith(
                    color: theme.colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}

class _RequestBody extends StatelessWidget {
  const _RequestBody({
    required this.theme,
    required this.state,
    required this.loading,
    required this.onRequest,
  });

  final ThemeData theme;
  final PrestataireVerificationState state;
  final bool loading;
  final VoidCallback onRequest;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          DiscProfile.prestataireVerificationRequestTitle,
          style: theme.textTheme.titleSmall?.copyWith(
            fontFamily: AppFonts.display,
            fontWeight: FontWeight.w800,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          DiscProfile.prestataireVerificationRequestBody,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.35,
          ),
        ),
        if (state.isPending) ...[
          const SizedBox(height: 12),
          _StatusBanner(
            icon: Icons.hourglass_top_rounded,
            color: theme.colorScheme.primary,
            text: DiscProfile.prestataireVerificationPending,
          ),
        ],
        if (state.wasRevoked) ...[
          const SizedBox(height: 12),
          _StatusBanner(
            icon: Icons.info_outline_rounded,
            color: theme.colorScheme.error,
            title: DiscProfile.prestataireVerificationRevokedTitle,
            text: state.adminNote ?? '',
          ),
          const SizedBox(height: 6),
          Text(
            DiscProfile.prestataireVerificationRevokedHint,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
              height: 1.35,
            ),
          ),
        ],
        if (state.canRequest) ...[
          const SizedBox(height: 12),
          FilledButton(
            onPressed: loading ? null : onRequest,
            child: loading
                ? const SizedBox(
                    width: 18,
                    height: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Text(
                    state.wasRevoked
                        ? DiscProfile.prestataireVerificationRequestAgainCta
                        : DiscProfile.prestataireVerificationRequestCta,
                  ),
          ),
        ],
      ],
    );
  }
}

class _StatusBanner extends StatelessWidget {
  const _StatusBanner({
    required this.icon,
    required this.color,
    this.title,
    required this.text,
  });

  final IconData icon;
  final Color color;
  final String? title;
  final String text;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withValues(alpha: 0.28)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, size: 20, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (title != null) ...[
                  Text(
                    title!,
                    style: theme.textTheme.labelLarge?.copyWith(
                      fontWeight: FontWeight.w800,
                      color: color,
                    ),
                  ),
                  const SizedBox(height: 4),
                ],
                Text(
                  text,
                  style: theme.textTheme.bodySmall?.copyWith(height: 1.35),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
