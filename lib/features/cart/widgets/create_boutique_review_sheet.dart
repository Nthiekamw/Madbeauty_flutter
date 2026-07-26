import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../services/supabase/prestataire/boutique/boutique_providers.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';

/// Bottom sheet : note produits d’une commande boutique.
Future<bool?> showCreateBoutiqueReviewSheet(
  BuildContext context, {
  required String commandeId,
  required String productsLabel,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: true,
    showDragHandle: true,
    builder: (context) => CreateBoutiqueReviewSheet(
      commandeId: commandeId,
      productsLabel: productsLabel,
    ),
  );
}

class CreateBoutiqueReviewSheet extends ConsumerStatefulWidget {
  const CreateBoutiqueReviewSheet({
    super.key,
    required this.commandeId,
    required this.productsLabel,
  });

  final String commandeId;
  final String productsLabel;

  @override
  ConsumerState<CreateBoutiqueReviewSheet> createState() =>
      _CreateBoutiqueReviewSheetState();
}

class _CreateBoutiqueReviewSheetState
    extends ConsumerState<CreateBoutiqueReviewSheet> {
  int _note = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;
  String? _error;

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _mapError(Object error) {
    final raw = error is AppFailure ? error.message : error.toString();
    final msg = raw.toLowerCase();
    if (msg.contains('déjà') ||
        msg.contains('deja') ||
        msg.contains('unique') ||
        msg.contains('duplicate')) {
      return DiscBoutique.clientReviewAlready;
    }
    if (raw.trim().isNotEmpty &&
        raw != CoreStrings.errorUnexpected &&
        !raw.startsWith('SupabaseServiceException')) {
      return raw;
    }
    return DiscBoutique.clientReviewError;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_submitting) return;
    if (_note < 1) {
      setState(() => _error = DiscReview.errorSelectNote);
      return;
    }

    final service = ref.read(boutiqueCommandeServiceProvider);
    if (service == null) {
      setState(() => _error = DiscBoutique.clientReviewError);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      await service.createAvisBoutique(
        commandeId: widget.commandeId,
        note: _note,
        commentaire: _commentController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pop(true);
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _submitting = false;
        _error = _mapError(e);
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 8, 20, 20 + bottom),
      child: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              DiscBoutique.clientReviewTitle,
              style: theme.textTheme.titleLarge?.copyWith(
                fontFamily: AppFonts.display,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              DiscBoutique.clientReviewSubtitle,
              style: theme.textTheme.bodyMedium?.copyWith(
                color: theme.colorScheme.onSurfaceVariant,
              ),
            ),
            if (widget.productsLabel.trim().isNotEmpty) ...[
              const SizedBox(height: 10),
              Text(
                widget.productsLabel,
                style: theme.textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                for (var i = 1; i <= 5; i++)
                  IconButton(
                    onPressed: _submitting
                        ? null
                        : () => setState(() {
                              _note = i;
                              _error = null;
                            }),
                    icon: Icon(
                      i <= _note ? Icons.star_rounded : Icons.star_outline_rounded,
                      color: theme.colorScheme.primary,
                      size: 36,
                    ),
                  ),
              ],
            ),
            if (_note > 0)
              Text(
                DiscReview.starsSelected(_note),
                textAlign: TextAlign.center,
                style: theme.textTheme.labelLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            const SizedBox(height: 12),
            TextField(
              controller: _commentController,
              maxLines: 3,
              enabled: !_submitting,
              decoration: const InputDecoration(
                labelText: DiscReview.commentHint,
              ),
            ),
            if (_error != null) ...[
              const SizedBox(height: 10),
              Text(
                _error!,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.error,
                ),
              ),
            ],
            const SizedBox(height: 16),
            FilledButton(
              onPressed: _submitting ? null : _submit,
              child: _submitting
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Text(DiscBoutique.clientReviewSubmit),
            ),
          ],
        ),
      ),
    );
  }
}

/// Helper snack après publication.
void showBoutiqueReviewSuccessSnack(BuildContext context) {
  AppSnackBar.success(context, DiscBoutique.clientReviewSuccess);
}
