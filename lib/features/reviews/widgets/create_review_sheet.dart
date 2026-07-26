import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../../services/storage/review_prompt_store.dart';
import '../../../services/supabase/profile/client_profile_providers.dart';
import '../../../services/supabase/storage/storage_providers.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../../../shared/theme/app_fonts.dart';
import '../providers/prestataire_note_moyenne_provider.dart';
import '../providers/review_provider.dart';
import 'review_photo_picker.dart';
import '../../../shared/theme/app_colors.dart';

/// Bottom sheet : note (1–5) + commentaire optionnel.
Future<bool?> showCreateReviewSheet(
  BuildContext context, {
  required String bookingId,
  required String prestataireName,
  String? prestataireId,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    isDismissible: true,
    showDragHandle: true,
    builder: (context) => CreateReviewSheet(
      bookingId: bookingId,
      prestataireName: prestataireName,
      prestataireId: prestataireId,
    ),
  );
}

class CreateReviewSheet extends ConsumerStatefulWidget {
  const CreateReviewSheet({
    super.key,
    required this.bookingId,
    required this.prestataireName,
    this.prestataireId,
  });

  final String bookingId;
  final String prestataireName;
  final String? prestataireId;

  @override
  ConsumerState<CreateReviewSheet> createState() => _CreateReviewSheetState();
}

class _CreateReviewSheetState extends ConsumerState<CreateReviewSheet> {
  int _note = 0;
  final _commentController = TextEditingController();
  bool _submitting = false;
  String? _error;
  List<Uint8List> _photoBytes = const [];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  String _mapErrorMessage(String raw) {
    final msg = raw.toLowerCase();
    if (msg.contains('terminée') ||
        msg.contains('terminee') ||
        msg.contains('terminé')) {
      return DiscReview.errorNotCompleted;
    }
    if (msg.contains('déjà') ||
        msg.contains('deja') ||
        msg.contains('unique') ||
        msg.contains('duplicate')) {
      return DiscReview.errorAlreadyExists;
    }
    if (raw.trim().isNotEmpty &&
        raw != CoreStrings.errorUnexpected &&
        !raw.startsWith('SupabaseServiceException')) {
      return raw;
    }
    return DiscReview.errorGeneric;
  }

  Future<void> _submit() async {
    FocusScope.of(context).unfocus();
    if (_submitting) return;

    if (_note < 1) {
      setState(() => _error = DiscReview.errorSelectNote);
      return;
    }

    final service = ref.read(reviewServiceProvider);
    var client = ref.read(currentClientProfileProvider).asData?.value;
    if (client == null) {
      try {
        client = await ref.read(currentClientProfileProvider.future);
      } catch (_) {
        client = null;
      }
    }
    if (service == null || client == null) {
      if (mounted) setState(() => _error = DiscReview.errorGeneric);
      return;
    }

    final needsPhotos = _photoBytes.isNotEmpty;
    final storage = ref.read(storageServiceProvider);
    final userId = ref.read(authNotifierProvider).asData?.value?.id;
    if (needsPhotos && (storage == null || userId == null)) {
      setState(() => _error = DiscReview.errorGeneric);
      return;
    }

    setState(() {
      _submitting = true;
      _error = null;
    });

    try {
      final reviewId = await service.create(
        bookingId: widget.bookingId,
        clientId: client.id,
        note: _note,
        commentaire: _commentController.text,
      );

      if (needsPhotos) {
        final urls = <String>[];
        for (final bytes in _photoBytes) {
          final url = await storage!.uploadReviewPhoto(
            userId: userId!,
            reviewId: reviewId,
            file: StorageUploadFile(bytes: bytes),
          );
          urls.add(url);
        }
        await service.attachPhotoUrls(
          reviewId: reviewId,
          clientId: client.id,
          photoUrls: urls,
        );
      }

      ref.invalidate(hasReviewedProvider(widget.bookingId));
      ref.invalidate(clientReviewsForCurrentClientProvider);
      final prestaId = widget.prestataireId;
      if (prestaId != null) {
        ref.invalidate(reviewsByPrestataireProvider(prestaId));
        ref.invalidate(prestataireNoteMoyenneProvider(prestaId));
      }
      final authUserId = ref.read(authNotifierProvider).asData?.value?.id;
      if (authUserId != null) {
        await ReviewPromptStore.instance.bindToUser(authUserId);
      }
      await ReviewPromptStore.instance.markHandled(widget.bookingId);

      if (!mounted) return;
      final messenger = ScaffoldMessenger.maybeOf(context);
      Navigator.of(context).pop(true);
      // Après fermeture : le snackbar n’est plus masqué par la sheet.
      messenger?.hideCurrentSnackBar();
      messenger?.showSnackBar(
        const SnackBar(
          content: Text(DiscReview.success),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } on AppFailure catch (e) {
      if (!mounted) return;
      setState(() => _error = _mapErrorMessage(e.message));
    } catch (_) {
      if (!mounted) return;
      setState(() => _error = DiscReview.errorGeneric);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.92;
    final error = _error;

    return Padding(
      padding: EdgeInsets.only(bottom: bottom),
      child: ConstrainedBox(
        constraints: BoxConstraints(maxHeight: maxH),
        child: SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                DiscReview.rateTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                widget.prestataireName,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontFamily: AppFonts.body,
                  fontWeight: FontWeight.w700,
                  color: theme.colorScheme.primary,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                DiscReview.rateSubtitle,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: List.generate(5, (i) {
                  final star = i + 1;
                  final filled = star <= _note;
                  return Semantics(
                    label: '$star sur 5',
                    button: true,
                    selected: filled,
                    child: IconButton(
                      onPressed: _submitting
                          ? null
                          : () => setState(() {
                                _note = star;
                                if (_error == DiscReview.errorSelectNote) {
                                  _error = null;
                                }
                              }),
                      icon: Icon(
                        filled
                            ? Icons.star_rounded
                            : Icons.star_outline_rounded,
                        color: filled
                            ? AppColors.starReview
                            : theme.colorScheme.outline,
                        size: 44,
                      ),
                    ),
                  );
                }),
              ),
              if (_note > 0)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    DiscReview.starsSelected(_note),
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                      color: AppColors.starReview,
                    ),
                  ),
                ),
              const SizedBox(height: 12),
              ReviewPhotoPicker(
                onChanged: (bytes, _) => setState(() => _photoBytes = bytes),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _commentController,
                enabled: !_submitting,
                maxLines: 4,
                minLines: 2,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: DiscReview.commentHint,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
              if (error != null) ...[
                const SizedBox(height: 12),
                Text(
                  error,
                  style: theme.textTheme.bodyMedium?.copyWith(
                    color: theme.colorScheme.error,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _submitting ? null : _submit,
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text(DiscReview.submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
