import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../../services/storage/review_prompt_store.dart';
import '../../../services/supabase/profile/client_profile_providers.dart';
import '../../../services/supabase/storage/storage_providers.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
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
  List<Uint8List> _photoBytes = const [];

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (_note < 1 || _submitting) return;

    final service = ref.read(reviewServiceProvider);
    final storage = ref.read(storageServiceProvider);
    final client = await ref.read(currentClientProfileProvider.future);
    final userId = ref.read(authNotifierProvider).asData?.value?.id;
    if (service == null || client == null || storage == null || userId == null) {
      if (mounted) AppSnackBar.error(context, DiscReview.errorGeneric);
      return;
    }

    setState(() => _submitting = true);
    try {
      final reviewId = await service.create(
        bookingId: widget.bookingId,
        clientId: client.id,
        note: _note,
        commentaire: _commentController.text,
      );

      if (_photoBytes.isNotEmpty) {
        final urls = <String>[];
        for (final bytes in _photoBytes) {
          final url = await storage.uploadReviewPhoto(
            userId: userId,
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
      if (mounted) {
        AppSnackBar.show(context, message: DiscReview.success);
        Navigator.of(context).pop(true);
      }
    } on StateError catch (e) {
      if (!mounted) return;
      final msg = e.message.contains('terminée')
          ? DiscReview.errorNotCompleted
          : e.message.contains('déjà')
              ? DiscReview.errorAlreadyExists
              : DiscReview.errorGeneric;
      AppSnackBar.error(context, msg);
    } catch (_) {
      if (mounted) AppSnackBar.error(context, DiscReview.errorGeneric);
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewInsetsOf(context).bottom;
    final maxH = MediaQuery.sizeOf(context).height * 0.92;

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
                      onPressed: () => setState(() => _note = star),
                      icon: Icon(
                        filled ? Icons.star_rounded : Icons.star_outline_rounded,
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
              const SizedBox(height: 20),
              FilledButton(
                onPressed: _note >= 1 && !_submitting ? _submit : null,
                child: _submitting
                    ? const SizedBox(
                        height: 22,
                        width: 22,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Text(DiscReview.submit),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

