import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/gallery/fullscreen_photo_gallery.dart';

/// Bulle style iMessage / WhatsApp.
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    required this.isMine,
    required this.timeLabel,
    this.imageUrl,
    this.isReadByPeer = true,
  });

  final String text;
  final bool isMine;
  final String timeLabel;
  final String? imageUrl;
  final bool isReadByPeer;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    final bg = isMine
        ? theme.colorScheme.primary
        : (isDark
            ? theme.colorScheme.surfaceContainerHighest
            : theme.colorScheme.surfaceContainerHigh);
    final fg = isMine ? AppColors.white : theme.colorScheme.onSurface;
    final hasImage = imageUrl?.trim().isNotEmpty == true;
    final showText = text.trim().isNotEmpty &&
        !(hasImage && text.trim() == DiscChat.imageMessagePreview);

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
          left: isMine ? 48 : 12,
          right: isMine ? 12 : 48,
          top: 3,
          bottom: 3,
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.78,
              ),
              padding: const EdgeInsets.fromLTRB(14, 10, 14, 8),
              decoration: BoxDecoration(
                color: bg,
                boxShadow: [
                  BoxShadow(
                    color: isDark
                        ? AppColors.scrimDark20
                        : AppColors.scrimLight08,
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(22),
                  topRight: const Radius.circular(22),
                  bottomLeft: Radius.circular(isMine ? 22 : 8),
                  bottomRight: Radius.circular(isMine ? 8 : 22),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  if (hasImage) ...[
                    GestureDetector(
                      onTap: () => FullscreenPhotoGallery.open(
                        context,
                        urls: [imageUrl!.trim()],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(14),
                        child: Image.network(
                          imageUrl!.trim(),
                          width: MediaQuery.sizeOf(context).width * 0.62,
                          fit: BoxFit.cover,
                          loadingBuilder: (context, child, progress) {
                            if (progress == null) return child;
                            return SizedBox(
                              width: MediaQuery.sizeOf(context).width * 0.62,
                              height: 180,
                              child: Center(
                                child: CircularProgressIndicator(
                                  value: progress.expectedTotalBytes != null
                                      ? progress.cumulativeBytesLoaded /
                                          progress.expectedTotalBytes!
                                      : null,
                                  color: isMine
                                      ? AppColors.white
                                      : theme.colorScheme.primary,
                                ),
                              ),
                            );
                          },
                          errorBuilder: (_, __, ___) => SizedBox(
                            width: MediaQuery.sizeOf(context).width * 0.62,
                            height: 120,
                            child: Center(
                              child: Icon(
                                Icons.broken_image_outlined,
                                color: fg.withValues(alpha: 0.8),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (showText) const SizedBox(height: 8),
                  ],
                  if (showText)
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        text,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontFamily: AppFonts.body,
                          color: fg,
                          height: 1.35,
                        ),
                      ),
                    ),
                  const SizedBox(height: 4),
                  Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        timeLabel,
                        style: theme.textTheme.labelSmall?.copyWith(
                          color: isMine
                              ? AppColors.onPrimaryMuted85
                              : theme.colorScheme.outline,
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      if (isMine) ...[
                        const SizedBox(width: 6),
                        Text(
                          isReadByPeer
                              ? DiscChat.readLabel
                              : DiscChat.sentLabel,
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: AppColors.onPrimaryMuted85,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

