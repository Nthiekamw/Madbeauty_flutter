import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/constants/app_strings.dart';
import '../../reviews/providers/prestataire_note_moyenne_provider.dart';
import '../../reviews/providers/review_provider.dart';
import '../../reviews/widgets/create_review_sheet.dart';
import '../logic/client_reservation_ui_status.dart';
import '../models/client_reservation_summary.dart';

/// Bouton « Noter » ou badge « Avis publié » pour une réservation passée terminée.
class ClientReservationReviewAction extends ConsumerWidget {
  const ClientReservationReviewAction({
    super.key,
    required this.item,
    this.onReviewSubmitted,
  });

  final ClientReservationSummary item;
  final VoidCallback? onReviewSubmitted;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ui = clientReservationUiStatusFromStatut(item.statut);
    if (ui != ClientReservationUiStatus.done) {
      return const SizedBox.shrink();
    }

    final reviewedAsync = ref.watch(hasReviewedProvider(item.id));

    return reviewedAsync.when(
      loading: () => const SizedBox(
        width: 20,
        height: 20,
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (_, __) => const SizedBox.shrink(),
      data: (reviewed) {
        if (reviewed) {
          return Tooltip(
            message: DiscReview.alreadyRated,
            child: Icon(
              Icons.check_circle_outline_rounded,
              size: 22,
              color: Theme.of(context).colorScheme.secondary,
            ),
          );
        }
        return TextButton(
          onPressed: () async {
            final ok = await showCreateReviewSheet(
              context,
              bookingId: item.id,
              prestataireName: item.prestataireName?.trim().isNotEmpty == true
                  ? item.prestataireName!.trim()
                  : DiscBk.unknownPresta,
              prestataireId: item.prestataireId,
            );
            if (ok == true) {
              ref.invalidate(hasReviewedProvider(item.id));
              if (item.prestataireId != null) {
                ref.invalidate(reviewsByPrestataireProvider(item.prestataireId!));
                ref.invalidate(prestataireNoteMoyenneProvider(item.prestataireId!));
              }
              onReviewSubmitted?.call();
            }
          },
          style: TextButton.styleFrom(
            minimumSize: const Size(0, 34),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
          ),
          child: Text(DiscReview.rateCta),
        );
      },
    );
  }
}

