import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

import '../../../core/constants/app_strings.dart';
import '../../../features/auth/providers/auth_notifier.dart';
import '../../../services/notifications/live_refresh.dart';
import '../../../services/supabase/messaging/messaging_providers.dart';
import '../../../services/supabase/storage/storage_providers.dart';
import '../../../services/supabase/storage/storage_service.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../messaging_navigation.dart';

/// Sheet + envoi d’un rendu avant/après depuis le détail résa presta.
Future<void> showSendResultMediaSheet(
  BuildContext context,
  WidgetRef ref, {
  required String reservationId,
}) async {
  final label = await showModalBottomSheet<String>(
    context: context,
    showDragHandle: true,
    builder: (ctx) {
      final theme = Theme.of(ctx);
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                DiscChat.sendResultMediaTitle,
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                DiscChat.sendResultMediaBody,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: 16),
              _ResultOption(
                label: DiscChat.resultLabelBefore,
                onTap: () => Navigator.pop(ctx, 'before'),
              ),
              _ResultOption(
                label: DiscChat.resultLabelAfter,
                onTap: () => Navigator.pop(ctx, 'after'),
              ),
              _ResultOption(
                label: DiscChat.resultLabelResult,
                onTap: () => Navigator.pop(ctx, 'result'),
              ),
            ],
          ),
        ),
      );
    },
  );
  if (label == null || !context.mounted) return;

  final user = switch (ref.read(authNotifierProvider)) {
    AsyncData(:final value) => value,
    _ => null,
  };
  if (user == null) return;

  final picked = await ImagePicker().pickImage(
    source: ImageSource.gallery,
    maxWidth: 2048,
    imageQuality: 88,
  );
  if (picked == null || !context.mounted) return;

  late final StorageUploadFile uploadFile;
  try {
    uploadFile = await StorageUploadFile.fromXFile(picked);
    StorageService.validateImageFile(uploadFile);
  } catch (_) {
    if (context.mounted) {
      AppSnackBar.show(context, message: DiscChat.sendResultMediaError);
    }
    return;
  }

  final storage = ref.read(storageServiceProvider);
  final messageService = ref.read(messageServiceProvider);
  final messagingService = ref.read(messagingServiceProvider);
  if (storage == null || messageService == null || messagingService == null) {
    if (context.mounted) {
      AppSnackBar.show(context, message: DiscChat.sendResultMediaError);
    }
    return;
  }

  try {
    final allowed =
        await messagingService.isChatOpenForBooking(reservationId);
    if (!allowed) {
      if (context.mounted) {
        AppSnackBar.show(context, message: DiscChat.contactNotConfirmed);
      }
      return;
    }
    final conv = await messageService.ensureThreadForBooking(reservationId);
    final imageUrl = await storage.uploadChatAttachment(
      userId: user.id,
      bookingId: reservationId,
      file: uploadFile,
    );
    await messageService.sendImage(
      conversationId: conv.id,
      senderId: user.id,
      imageUrl: imageUrl,
      kind: 'result_media',
      resultLabel: label,
    );
    refreshMessagingInbox(ref);
    if (!context.mounted) return;
    AppSnackBar.success(context, DiscChat.sendResultMediaSuccess);
    await openChatForReservation(
      context,
      ref,
      reservationId,
      viewerRole: MessagingInboxRole.prestataire,
    );
  } catch (_) {
    if (context.mounted) {
      AppSnackBar.show(context, message: DiscChat.sendResultMediaError);
    }
  }
}

class _ResultOption extends StatelessWidget {
  const _ResultOption({required this.label, required this.onTap});

  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: OutlinedButton(
        onPressed: onTap,
        child: Text(label),
      ),
    );
  }
}
