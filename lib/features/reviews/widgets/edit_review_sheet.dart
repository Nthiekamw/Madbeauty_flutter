import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../../services/supabase/profile/client_profile_providers.dart';
import '../../../services/supabase/storage/storage_providers.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../auth/providers/auth_notifier.dart';
import '../../prestataire/providers/profile/current_prestataire_provider.dart';
import '../models/client_review_list_item.dart';
import '../providers/prestataire_note_moyenne_provider.dart';
import '../../../services/supabase/reviews/review_service.dart';
import '../providers/review_provider.dart';
import 'review_photo_picker.dart';
import 'review_photos_row.dart';
import '../../../shared/theme/app_colors.dart';

Future<bool?> showEditReviewSheet(
  BuildContext context, {
  required ClientReviewListItem item,
  bool readOnly = false,
}) {
  return showModalBottomSheet<bool>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (context) => EditReviewSheet(item: item, readOnly: readOnly),
  );
}

Future<void> showViewReviewSheet(
  BuildContext context, {
  required ClientReviewListItem item,
}) {
  return showEditReviewSheet(context, item: item, readOnly: true);
}

class EditReviewSheet extends ConsumerStatefulWidget {
  const EditReviewSheet({
    super.key,
    required this.item,
    this.readOnly = false,
  });

  final ClientReviewListItem item;
  final bool readOnly;

  @override
  ConsumerState<EditReviewSheet> createState() => _EditReviewSheetState();
}

class _EditReviewSheetState extends ConsumerState<EditReviewSheet> {
  late int _note;
  late final TextEditingController _commentController;
  bool _submitting = false;
  late List<String> _photoUrls;
  List<Uint8List> _newPhotoBytes = const [];

  @override
  void initState() {
    super.initState();
    _note = widget.item.review.note;
    _photoUrls = List<String>.from(widget.item.review.photoUrls);
    _commentController = TextEditingController(
      text: widget.item.review.commentaire?.trim() ?? '',
    );
  }

  @override
  void dispose() {
    _commentController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (widget.readOnly) return;

    final client = ref.read(currentClientProfileProvider).asData?.value;
    final ownPrestaId =
        ref.read(currentPrestataireProvider).asData?.value?.id;
    final canEdit = widget.item.canEditAsClient(
      client?.id,
      ownPrestataireId: ownPrestaId,
    );
    if (_note < 1 || _submitting || !canEdit) return;

    final service = ref.read(reviewServiceProvider);
    final storage = ref.read(storageServiceProvider);
    final userId = ref.read(authNotifierProvider).asData?.value?.id;
    if (service == null || client == null || storage == null || userId == null) {
      if (mounted) AppSnackBar.error(context, DiscReview.errorGeneric);
      return;
    }

    setState(() => _submitting = true);
    try {
      final uploaded = <String>[];
      for (final bytes in _newPhotoBytes) {
        final url = await storage.uploadReviewPhoto(
          userId: userId,
          reviewId: widget.item.review.id,
          file: StorageUploadFile(bytes: bytes),
        );
        uploaded.add(url);
      }
      final allUrls = [..._photoUrls, ...uploaded].take(ReviewService.maxReviewPhotos).toList();

      await service.update(
        reviewId: widget.item.review.id,
        clientId: client.id,
        note: _note,
        commentaire: _commentController.text,
        photoUrls: allUrls,
      );
      ref.invalidate(clientReviewsForCurrentClientProvider);
      ref.invalidate(hasReviewedProvider(widget.item.review.bookingId));
      ref.invalidate(reviewsByPrestataireProvider(widget.item.review.prestataireId));
      ref.invalidate(
        prestataireNoteMoyenneProvider(widget.item.review.prestataireId),
      );
      if (mounted) {
        AppSnackBar.show(context, message: DiscReview.editSuccess);
        Navigator.of(context).pop(true);
      }
    } on StateError catch (e) {
      if (!mounted) return;
      final msg = e.message.contains('délai')
          ? DiscReview.errorEditExpired
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
    final clientId = ref.watch(currentClientProfileProvider).asData?.value?.id;
    final ownPrestaId =
        ref.watch(currentPrestataireProvider).asData?.value?.id;
    final canEdit = !widget.readOnly &&
        widget.item.canEditAsClient(
          clientId,
          ownPrestataireId: ownPrestaId,
        );
    final blockedOnOwnBusiness = !widget.readOnly &&
        clientId == widget.item.review.clientId &&
        ownPrestaId != null &&
        ownPrestaId.isNotEmpty &&
        widget.item.review.prestataireId == ownPrestaId;
    final prestataireLabel =
        widget.item.prestataireName?.trim().isNotEmpty == true
            ? widget.item.prestataireName!.trim()
            : DiscBk.unknownPresta;

    return Padding(
      padding: EdgeInsets.fromLTRB(20, 16, 20, 16 + bottom),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            canEdit
                ? DiscReview.editTitle
                : (widget.readOnly
                    ? DiscPrestaDetail.reviewsTitle
                    : DiscReview.viewTitle),
            style: theme.textTheme.titleLarge?.copyWith(
              fontFamily: AppFonts.display,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            prestataireLabel,
            style: theme.textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.w700,
              color: theme.colorScheme.primary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.readOnly
                ? DiscReview.prestataireViewOnlyHint
                : blockedOnOwnBusiness
                    ? DiscReview.editBlockedOnOwnBusiness
                    : canEdit
                        ? (widget.item.daysLeftToEditFor(
                                clientId,
                                ownPrestataireId: ownPrestaId,
                              ) !=
                              null
                            ? DiscReview.daysLeftToEdit(
                                widget.item.daysLeftToEditFor(
                                  clientId,
                                  ownPrestataireId: ownPrestaId,
                                )!,
                              )
                            : DiscReview.editDeadlineHint)
                        : DiscReview.editExpiredLabel,
            style: theme.textTheme.bodySmall?.copyWith(
              color: theme.colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(5, (i) {
              final star = i + 1;
              final filled = star <= _note;
              return IconButton(
                onPressed: canEdit ? () => setState(() => _note = star) : null,
                icon: Icon(
                  filled ? Icons.star_rounded : Icons.star_outline_rounded,
                  color: filled
                      ? AppColors.starReview
                      : theme.colorScheme.outline,
                  size: 44,
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
          TextField(
            controller: _commentController,
            readOnly: !canEdit,
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
          if (!canEdit && _photoUrls.isNotEmpty) ...[
            const SizedBox(height: 12),
            ReviewPhotosRow(urls: _photoUrls),
          ],
          if (canEdit) ...[
            const SizedBox(height: 12),
            ReviewPhotoPicker(
              initialUrls: _photoUrls,
              onChanged: (bytes, urls) => setState(() {
                _newPhotoBytes = bytes;
                _photoUrls = urls;
              }),
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
                  : Text(DiscReview.editSubmit),
            ),
          ],
        ],
      ),
    );
  }
}

