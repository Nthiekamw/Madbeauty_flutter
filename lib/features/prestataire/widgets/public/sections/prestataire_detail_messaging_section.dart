import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../../core/constants/app_strings.dart';
import '../../../../../router/navigation_extensions.dart';
import '../../../../../shared/layout/discovery_responsive.dart';
import '../../../../../shared/theme/discovery_styles.dart';
import '../../../../messaging/messaging_navigation.dart';
import '../../../../messaging/models/client_presta_chat_access.dart';
import '../../../../messaging/providers/client_presta_chat_access_provider.dart';
import '../detail/sections/prestataire_detail_section_layout.dart';
import '../detail/sections/prestataire_detail_surface.dart';

/// Bloc messagerie (hors bouton « Contacter » dans la carte identité).
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
        final theme = Theme.of(context);
        final pad = DiscoveryResponsive.of(context).horizontalPadding;

        return Padding(
          padding: EdgeInsets.fromLTRB(pad, 18, pad, 0),
          child: PrestataireDetailSurface.cardMaterial(
            theme: theme,
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
        PrestataireDetailSectionHeader(
          icon: Icons.forum_rounded,
          title: DiscPrestaDetail.contactSectionTitle,
        ),
        const SizedBox(height: 8),
        Text(
          DiscPrestaDetail.contactReadyBody,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.icon(
          onPressed: onOpen,
          icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
          label: Text(DiscPrestaDetail.contactOpenChat),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 42),
            shape: RoundedRectangleBorder(
              borderRadius: DiscoveryStyles.chipBorderRadius,
            ),
          ),
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
        PrestataireDetailSectionHeader(
          icon: Icons.hourglass_top_rounded,
          title: DiscPrestaDetail.contactPendingTitle,
        ),
        const SizedBox(height: 8),
        Text(
          DiscPrestaDetail.contactPendingBody,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        OutlinedButton(
          onPressed: onViewReservations,
          style: OutlinedButton.styleFrom(
            minimumSize: const Size(0, 42),
            foregroundColor: tertiary,
            shape: RoundedRectangleBorder(
              borderRadius: DiscoveryStyles.chipBorderRadius,
            ),
          ),
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
        PrestataireDetailSectionHeader(
          icon: Icons.chat_bubble_outline_rounded,
          title: DiscPrestaDetail.contactBookTitle,
        ),
        const SizedBox(height: 8),
        Text(
          DiscPrestaDetail.contactBookBody,
          style: theme.textTheme.bodySmall?.copyWith(
            color: theme.colorScheme.onSurfaceVariant,
            fontSize: 11,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 12),
        FilledButton.tonalIcon(
          onPressed: onBook,
          icon: const Icon(Icons.calendar_month_rounded, size: 18),
          label: Text(DiscPrestaDetail.actionBookSvc),
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 42),
            shape: RoundedRectangleBorder(
              borderRadius: DiscoveryStyles.chipBorderRadius,
            ),
          ),
        ),
      ],
    );
  }
}
