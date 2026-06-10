import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../shared/theme/app_fonts.dart';
import '../../../../../shared/widgets/discovery/discovery_surface_card.dart';
import '../../../../messaging/messaging_navigation.dart';
import '../../../../messaging/models/client_presta_chat_access.dart';
import '../../../../messaging/providers/client_presta_chat_access_provider.dart';
import '../../../../../router/navigation_extensions.dart';

/// Bloc messagerie sous le hero (hors bouton « Contacter » dans l'en-tête).
class PrestataireDetailMessagingSection extends ConsumerWidget {
  const PrestataireDetailMessagingSection({
    super.key,
    required this.prestataireId,
  });

  final String prestataireId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final accessAsync = ref.watch(
      clientPrestaChatAccessProvider(prestataireId),
    );

    return accessAsync.when(
      loading: () => const SizedBox(height: 8),
      error: (_, __) => const SizedBox.shrink(),
      data: (access) {
        return Padding(
          padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
          child: DiscoverySurfaceCard(
            padding: const EdgeInsets.all(16),
            child: switch (access.kind) {
              ClientPrestaChatAccessKind.ready => _ReadyContent(
                  onOpen: () => openChatWithPrestataire(
                    context,
                    ref,
                    prestataireId,
                  ),
                ),
              ClientPrestaChatAccessKind.awaitingPrestaResponse =>
                _PendingContent(
                  onViewReservations: () => context.goMyReservations(),
                ),
              ClientPrestaChatAccessKind.noBooking => _BookFirstContent(
                  onBook: () => context.pushBooking(
                    prestataireId: prestataireId,
                  ),
                ),
            },
          ),
        );
      },
    );
  }
}

class _ReadyContent extends StatelessWidget {
  const _ReadyContent({required this.onOpen});

  final VoidCallback onOpen;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Icon(
              Icons.forum_rounded,
              color: theme.colorScheme.primary,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                DiscPrestaDetail.contactSectionTitle,
                style: theme.textTheme.titleSmall?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Text(
          DiscPrestaDetail.contactReadyBody,
          style: theme.textTheme.bodyMedium?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 14),
        FilledButton.icon(
          onPressed: onOpen,
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
          label: Text(DiscPrestaDetail.contactOpenChat),
        ),
      ],
    );
  }
}

class _PendingContent extends StatelessWidget {
  const _PendingContent({required this.onViewReservations});

  final VoidCallback onViewReservations;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final tertiary = theme.colorScheme.tertiary;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(Icons.hourglass_top_rounded, color: tertiary, size: 22),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DiscPrestaDetail.contactPendingTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DiscPrestaDetail.contactPendingBody,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        OutlinedButton(
          onPressed: onViewReservations,
          child: Text(DiscPrestaDetail.contactViewReservations),
        ),
      ],
    );
  }
}

class _BookFirstContent extends StatelessWidget {
  const _BookFirstContent({required this.onBook});

  final VoidCallback onBook;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.chat_bubble_outline_rounded,
              color: theme.colorScheme.onSurfaceVariant,
              size: 22,
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    DiscPrestaDetail.contactBookTitle,
                    style: theme.textTheme.titleSmall?.copyWith(
                      fontFamily: AppFonts.display,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    DiscPrestaDetail.contactBookBody,
                    style: theme.textTheme.bodyMedium?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 14),
        FilledButton.tonalIcon(
          onPressed: onBook,
          icon: const Icon(Icons.calendar_month_rounded, size: 20),
          label: Text(DiscPrestaDetail.actionBookSvc),
        ),
      ],
    );
  }
}

