import 'package:flutter/material.dart';

import '../../../../core/constants/app_strings.dart';
import '../../../../shared/theme/app_fonts.dart';
import '../../logic/chat_message_moderator.dart';
import '../../logic/chat_message_templates.dart';
import 'chat_content_width.dart';
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
    this.enabled = true,
    this.inputHint,
    this.onAttachImage,
    this.attachingImage = false,
    this.quickReplyTemplates = const [],
    this.recentOutgoingMessages = const [],
  });

  final TextEditingController controller;
  final bool sending;
  final VoidCallback onSend;
  final bool enabled;
  final String? inputHint;
  final VoidCallback? onAttachImage;
  final bool attachingImage;
  final List<ChatMessageTemplate> quickReplyTemplates;
  final List<String> recentOutgoingMessages;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  ChatMessageModerationResult _moderation = ChatMessageModerationResult.none;
  bool _hasText = false;

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
    final hasText = widget.controller.text.trim().isNotEmpty;
    final next = ChatMessageModerator.analyze(
      widget.controller.text,
      context: ChatMessageModerationContext(
        recentOutgoingMessages: widget.recentOutgoingMessages,
      ),
    );
    if (hasText != _hasText ||
        next.violations.length != _moderation.violations.length ||
        next.primary != _moderation.primary) {
      setState(() {
        _hasText = hasText;
        _moderation = next;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bottom = MediaQuery.viewPaddingOf(context).bottom;
    final busy = widget.sending || widget.attachingImage;
    final canSend =
        widget.enabled && !busy && _hasText && !_moderation.isBlocked;
    final canAttach = widget.enabled && !busy && widget.onAttachImage != null;
    final canType = widget.enabled && !busy;

    return Material(
      color: theme.colorScheme.surface.withValues(alpha: 0.98),
      elevation: 0,
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: theme.colorScheme.surface,
          borderRadius: const BorderRadius.vertical(top: Radius.circular(22)),
          border: Border(
            top: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.1),
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: theme.shadowColor.withValues(alpha: 0.08),
              blurRadius: 20,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: ChatContentWidth(
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
                padding: EdgeInsets.fromLTRB(12, 8, 12, 10 + bottom),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    if (widget.onAttachImage != null) ...[
                      _CircleIconButton(
                        tooltip: DiscChat.attachImageTooltip,
                        onPressed: canAttach ? widget.onAttachImage : null,
                        icon: widget.attachingImage
                            ? SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: theme.colorScheme.primary,
                                ),
                              )
                            : Icon(
                                Icons.add_photo_alternate_outlined,
                                size: 22,
                                color: canAttach
                                    ? theme.colorScheme.primary
                                    : theme.colorScheme.onSurfaceVariant
                                        .withValues(alpha: 0.4),
                              ),
                      ),
                      const SizedBox(width: 4),
                    ],
                    Expanded(
                      child: TextField(
                        controller: widget.controller,
                        enabled: canType,
                        minLines: 1,
                        maxLines: 5,
                        textCapitalization: TextCapitalization.sentences,
                        textInputAction: TextInputAction.send,
                        style: theme.textTheme.bodyLarge?.copyWith(
                          fontFamily: AppFonts.body,
                          fontSize: 15.5,
                          height: 1.35,
                        ),
                        decoration: InputDecoration(
                          hintText: widget.inputHint ?? DiscChat.inputHint,
                          hintStyle: theme.textTheme.bodyLarge?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant
                                .withValues(alpha: 0.65),
                          ),
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.65),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 18,
                            vertical: 11,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26),
                            borderSide: BorderSide(
                              color: _moderation.isBlocked
                                  ? theme.colorScheme.error
                                      .withValues(alpha: 0.45)
                                  : theme.colorScheme.outline
                                      .withValues(alpha: 0.12),
                            ),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(26),
                            borderSide: BorderSide(
                              color: _moderation.isBlocked
                                  ? theme.colorScheme.error
                                  : theme.colorScheme.primary
                                      .withValues(alpha: 0.55),
                              width: 1.5,
                            ),
                          ),
                        ),
                        onSubmitted: (_) {
                          if (canSend) widget.onSend();
                        },
                      ),
                    ),
                    const SizedBox(width: 8),
                    _SendButton(
                      enabled: canSend,
                      sending: widget.sending,
                      onPressed: widget.onSend,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.tooltip,
    required this.onPressed,
    required this.icon,
  });

  final String tooltip;
  final VoidCallback? onPressed;
  final Widget icon;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Tooltip(
      message: tooltip,
      child: Material(
        color: theme.colorScheme.primary.withValues(alpha: 0.08),
        shape: const CircleBorder(),
        child: InkWell(
          onTap: onPressed,
          customBorder: const CircleBorder(),
          child: SizedBox(
            width: 42,
            height: 42,
            child: Center(child: icon),
          ),
        ),
      ),
    );
  }
}

class _SendButton extends StatelessWidget {
  const _SendButton({
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

    return AnimatedOpacity(
      duration: const Duration(milliseconds: 180),
      opacity: enabled ? 1 : 0.4,
      child: DecoratedBox(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              theme.colorScheme.primary,
              Color.lerp(
                theme.colorScheme.primary,
                theme.colorScheme.secondary,
                0.4,
              )!,
            ],
          ),
          shape: BoxShape.circle,
          boxShadow: enabled
              ? [
                  BoxShadow(
                    color: theme.colorScheme.primary.withValues(alpha: 0.32),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ]
              : null,
        ),
        child: Material(
          color: AppColors.transparent,
          shape: const CircleBorder(),
          child: InkWell(
            onTap: enabled ? onPressed : null,
            customBorder: const CircleBorder(),
            child: SizedBox(
              width: 46,
              height: 46,
              child: Center(
                child: sending
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: AppColors.white,
                        ),
                      )
                    : const Icon(
                        Icons.arrow_upward_rounded,
                        size: 22,
                        color: AppColors.white,
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
