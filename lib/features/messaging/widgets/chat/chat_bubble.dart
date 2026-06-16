import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/widgets/app/app_network_image.dart';
import '../../../../shared/widgets/gallery/fullscreen_photo_gallery.dart';
import '../../logic/chat_message_receipt.dart';

/// Bulle de message avec regroupement visuel (style messagerie moderne).
class ChatBubble extends StatelessWidget {
  const ChatBubble({
    super.key,
    required this.text,
    required this.isMine,
    required this.timeLabel,
    this.imageUrl,
    this.receiptStatus,
    this.isFirstInGroup = true,
    this.isLastInGroup = true,
  });

  final String text;
  final bool isMine;
  final String timeLabel;
  final String? imageUrl;
  final ChatMessageReceiptStatus? receiptStatus;
  final bool isFirstInGroup;
  final bool isLastInGroup;

  static const _largeRadius = 20.0;
  static const _mediumRadius = 14.0;
  static const _tailRadius = 6.0;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final hasImage = imageUrl?.trim().isNotEmpty == true;
    final showText = text.trim().isNotEmpty &&
        !(hasImage && text.trim() == DiscChat.imageMessagePreview);
    final showMeta = isLastInGroup;
    final groupedGap = isFirstInGroup ? 6.0 : 2.0;

    final fg = isMine ? AppColors.white : theme.colorScheme.onSurface;

    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: Padding(
        padding: EdgeInsets.only(
          left: isMine ? 56 : 14,
          right: isMine ? 14 : 56,
          top: groupedGap,
          bottom: showMeta ? 2 : 0,
        ),
        child: Column(
          crossAxisAlignment:
              isMine ? CrossAxisAlignment.end : CrossAxisAlignment.start,
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: _radiusForGroup(isMine),
                gradient: isMine
                    ? LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          theme.colorScheme.primary,
                          Color.lerp(
                            theme.colorScheme.primary,
                            theme.colorScheme.secondary,
                            0.35,
                          )!,
                        ],
                      )
                    : null,
                color: isMine
                    ? null
                    : (isDark
                        ? theme.colorScheme.surfaceContainerHighest
                        : theme.colorScheme.surface),
                border: isMine
                    ? null
                    : Border.all(
                        color: theme.colorScheme.outline.withValues(alpha: 0.1),
                      ),
                boxShadow: [
                  if (isLastInGroup)
                    BoxShadow(
                      color: isMine
                          ? theme.colorScheme.primary.withValues(alpha: 0.22)
                          : (isDark
                              ? AppColors.scrimDark20
                              : AppColors.scrimLight05),
                      blurRadius: isMine ? 14 : 8,
                      offset: const Offset(0, 3),
                    ),
                ],
              ),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: MediaQuery.sizeOf(context).width * 0.76,
                ),
                child: Padding(
                  padding: EdgeInsets.fromLTRB(
                    14,
                    isFirstInGroup ? 11 : 8,
                    14,
                    isLastInGroup ? 10 : 8,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (hasImage) ...[
                        _ChatBubbleImage(
                          url: imageUrl!.trim(),
                          errorColor: fg,
                          onTap: () => FullscreenPhotoGallery.open(
                            context,
                            urls: [imageUrl!.trim()],
                          ),
                        ),
                        if (showText) const SizedBox(height: 8),
                      ],
                      if (showText)
                        Text(
                          text,
                          style: theme.textTheme.bodyLarge?.copyWith(
                            fontFamily: AppFonts.body,
                            color: fg,
                            height: 1.38,
                            fontSize: 15.5,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
            if (showMeta) ...[
              const SizedBox(height: 4),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    timeLabel,
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant
                          .withValues(alpha: 0.85),
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  if (isMine && receiptStatus != null) ...[
                    const SizedBox(width: 4),
                    Icon(
                      receiptStatus == ChatMessageReceiptStatus.sent
                          ? Icons.check_rounded
                          : Icons.done_all_rounded,
                      size: 14,
                      color: receiptStatus == ChatMessageReceiptStatus.read
                          ? AppColors.chatReadReceipt
                          : theme.colorScheme.onSurfaceVariant
                              .withValues(alpha: 0.65),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 2),
            ],
          ],
        ),
      ),
    );
  }

  BorderRadius _radiusForGroup(bool mine) {
    if (isFirstInGroup && isLastInGroup) {
      return BorderRadius.only(
        topLeft: const Radius.circular(_largeRadius),
        topRight: const Radius.circular(_largeRadius),
        bottomLeft: Radius.circular(mine ? _largeRadius : _tailRadius),
        bottomRight: Radius.circular(mine ? _tailRadius : _largeRadius),
      );
    }
    if (isFirstInGroup) {
      return BorderRadius.only(
        topLeft: const Radius.circular(_largeRadius),
        topRight: const Radius.circular(_largeRadius),
        bottomLeft: Radius.circular(mine ? _mediumRadius : _tailRadius),
        bottomRight: Radius.circular(mine ? _tailRadius : _mediumRadius),
      );
    }
    if (isLastInGroup) {
      return BorderRadius.only(
        topLeft: Radius.circular(mine ? _mediumRadius : _tailRadius),
        topRight: Radius.circular(mine ? _tailRadius : _mediumRadius),
        bottomLeft: Radius.circular(mine ? _largeRadius : _tailRadius),
        bottomRight: Radius.circular(mine ? _tailRadius : _largeRadius),
      );
    }
    return BorderRadius.only(
      topLeft: Radius.circular(mine ? _mediumRadius : _tailRadius),
      topRight: Radius.circular(mine ? _tailRadius : _mediumRadius),
      bottomLeft: Radius.circular(mine ? _mediumRadius : _tailRadius),
      bottomRight: Radius.circular(mine ? _tailRadius : _mediumRadius),
    );
  }
}

class _ChatBubbleImage extends StatelessWidget {
  const _ChatBubbleImage({
    required this.url,
    required this.errorColor,
    required this.onTap,
  });

  final String url;
  final Color errorColor;
  final VoidCallback onTap;

  static const double _maxHeight = 260;
  static const double _minHeight = 112;

  @override
  Widget build(BuildContext context) {
    final maxWidth = MediaQuery.sizeOf(context).width * 0.58;

    return GestureDetector(
      onTap: onTap,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxHeight: _maxHeight),
        child: AppNetworkImage(
          url: url,
          width: maxWidth,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.high,
          borderRadius: BorderRadius.circular(12),
          placeholder: SizedBox(
            width: maxWidth,
            height: _minHeight,
            child: const Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: SizedBox(
            width: maxWidth,
            height: _minHeight,
            child: Center(
              child: Icon(
                Icons.broken_image_outlined,
                color: errorColor.withValues(alpha: 0.8),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
