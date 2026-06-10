import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../logic/chat_message_moderator.dart';
import '../../logic/chat_message_templates.dart';
import 'chat_moderation_banner.dart';
import 'chat_quick_replies_strip.dart';
import '../../../../shared/theme/app_colors.dart';

/// Champ de saisie + bouton Envoyer (bas de l'écran chat).
class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.sending,
    required this.onSend,
    this.onAttachImage,
    this.attachingImage = false,
    this.quickReplyTemplates = const [],
    this.recentOutgoingMessages = const [],
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final VoidCallback? onAttachImage;
  final bool attachingImage;
  final List<ChatMessageTemplate> quickReplyTemplates;
  final List<String> recentOutgoingMessages;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  ChatMessageModerationResult _moderation = ChatMessageModerationResult.none;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    _onTextChanged();
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant ChatComposer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.recentOutgoingMessages != widget.recentOutgoingMessages) {
      _onTextChanged();
    }
  }

  void _onTextChanged() {
    final next = ChatMessageModerator.analyze(
      widget.controller.text,
      context: ChatMessageModerationContext(
        recentOutgoingMessages: widget.recentOutgoingMessages,
      ),
    );
    if (next.violations.length != _moderation.violations.length ||
        (next.primary != _moderation.primary)) {
      setState(() => _moderation = next);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final text = widget.controller.text.trim();
    final busy = widget.sending || widget.attachingImage;
    final canSend = !busy && text.isNotEmpty && !_moderation.isBlocked;
    final canAttach = !busy && widget.onAttachImage != null;

    return Material(
      color: theme.colorScheme.surfaceContainerLowest,
      elevation: 12,
      shadowColor: theme.shadowColor.withValues(alpha: 0.12),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.quickReplyTemplates.isNotEmpty)
            ChatQuickRepliesStrip(
              templates: widget.quickReplyTemplates,
              onPick: (text) {
                widget.controller.text = text;
                widget.controller.selection = TextSelection.collapsed(
                  offset: text.length,
                );
                _onTextChanged();
              },
            ),
          ChatModerationBanner(moderation: _moderation),
          Padding(
            padding: EdgeInsets.fromLTRB(12, 10, 12, 10 + bottom),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (widget.onAttachImage != null) ...[
                  IconButton(
                    tooltip: DiscChat.attachImageTooltip,
                    onPressed: canAttach ? widget.onAttachImage : null,
                    icon: widget.attachingImage
                        ? SizedBox(
                            width: 22,
                            height: 22,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              color: theme.colorScheme.primary,
                            ),
                          )
                        : Icon(
                            Icons.image_outlined,
                            color: canAttach
                                ? theme.colorScheme.primary
                                : theme.colorScheme.onSurfaceVariant
                                    .withValues(alpha: 0.45),
                          ),
                  ),
                ],
                Expanded(
                  child: TextField(
                    controller: widget.controller,
                    minLines: 1,
                    maxLines: 5,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: DiscChat.inputHint,
                      filled: true,
                      fillColor: theme.colorScheme.surfaceContainerHighest,
                      contentPadding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: _moderation.isBlocked
                              ? theme.colorScheme.error.withValues(alpha: 0.5)
                              : theme.colorScheme.outline
                                  .withValues(alpha: 0.25),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: _moderation.isBlocked
                              ? theme.colorScheme.error.withValues(alpha: 0.5)
                              : theme.colorScheme.outline
                                  .withValues(alpha: 0.25),
                        ),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(24),
                        borderSide: BorderSide(
                          color: _moderation.isBlocked
                              ? theme.colorScheme.error
                              : theme.colorScheme.primary,
                          width: 1.4,
                        ),
                      ),
                    ),
                    onSubmitted: (_) {
                      if (canSend) widget.onSend();
                    },
                  ),
                ),
                const SizedBox(width: 8),
                _GradientSendButton(
                  enabled: canSend,
                  sending: widget.sending,
                  onPressed: widget.onSend,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _GradientSendButton extends StatelessWidget {
  const _GradientSendButton({
    required this.enabled,
    required this.sending,
    required this.onPressed,
  });

  final bool enabled;
  final bool sending;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final opacity = enabled ? 1.0 : 0.45;

    return Opacity(
      opacity: opacity,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              theme.colorScheme.secondary,
            ],
          ),
          borderRadius: BorderRadius.circular(22),
          boxShadow: [
            BoxShadow(
              color: theme.colorScheme.primary.withValues(alpha: 0.35),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: AppColors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(22),
            onTap: enabled ? onPressed : null,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              child: sending
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: AppColors.white,
                      ),
                    )
                  : Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.send_rounded,
                          size: 18,
                          color: AppColors.white,
                        ),
                        const SizedBox(width: 6),
                        Text(
                          DiscChat.send,
                          style: theme.textTheme.labelLarge?.copyWith(
                            fontFamily: AppFonts.body,
                            fontWeight: FontWeight.w700,
                            color: AppColors.white,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

