import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/constants/app_strings.dart';
import '../../../core/errors/app_failure.dart';
import '../../../core/errors/supabase_service_exception.dart';
import '../../../core/models/domain/reel/reel_feed_item.dart';
import '../../../shared/theme/app_fonts.dart';
import '../../../shared/widgets/app/app_snack_bar.dart';
import '../../../shared/widgets/discovery/content/discovery_list_skeleton.dart';
import '../../../shared/widgets/discovery/discovery_empty_state.dart';
import '../../auth/guest/guest_mode_provider.dart';
import '../providers/reel_feed_provider.dart';

Future<void> showReelCommentsSheet(
  BuildContext context, {
  required String reelId,
}) {
  return showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    builder: (ctx) => ReelCommentsSheet(reelId: reelId),
  );
}

class ReelCommentsSheet extends ConsumerStatefulWidget {
  const ReelCommentsSheet({super.key, required this.reelId});

  final String reelId;

  @override
  ConsumerState<ReelCommentsSheet> createState() => _ReelCommentsSheetState();
}

class _ReelCommentsSheetState extends ConsumerState<ReelCommentsSheet> {
  final _controller = TextEditingController();
  final _scrollController = ScrollController();
  final _focusNode = FocusNode();

  List<ReelComment> _items = const [];
  bool _loading = true;
  bool _loadingMore = false;
  bool _sending = false;
  bool _hasMore = true;
  Object? _error;
  DateTime? _cursorCreatedAt;
  String? _cursorId;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    WidgetsBinding.instance.addPostFrameCallback((_) => _refresh());
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (!_hasMore || _loadingMore || _loading) return;
    final pos = _scrollController.position;
    if (pos.pixels >= pos.maxScrollExtent - 120) {
      _loadMore();
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final page = await ref.read(reelServiceProvider).listComments(
            reelId: widget.reelId,
          );
      if (!mounted) return;
      setState(() {
        _items = page.items;
        _hasMore = page.items.length >= 30 && page.hasMore;
        _cursorCreatedAt = page.nextCursorCreatedAt;
        _cursorId = page.nextCursorId;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _loading = false;
        _error = e;
      });
    }
  }

  Future<void> _loadMore() async {
    final cursorCreatedAt = _cursorCreatedAt;
    final cursorId = _cursorId;
    if (cursorCreatedAt == null || cursorId == null) {
      setState(() => _hasMore = false);
      return;
    }
    setState(() => _loadingMore = true);
    try {
      final page = await ref.read(reelServiceProvider).listComments(
            reelId: widget.reelId,
            cursorCreatedAt: cursorCreatedAt,
            cursorId: cursorId,
          );
      if (!mounted) return;
      setState(() {
        _items = [..._items, ...page.items];
        _loadingMore = false;
        _hasMore = page.items.length >= 30 && page.hasMore;
        _cursorCreatedAt = page.nextCursorCreatedAt;
        _cursorId = page.nextCursorId;
      });
    } catch (_) {
      if (!mounted) return;
      setState(() => _loadingMore = false);
    }
  }

  String _mapSendError(Object error) {
    final raw = error is AppFailure
        ? error.message
        : error is SupabaseServiceException
            ? error.message
            : error.toString();
    final lower = raw.toLowerCase();
    if (lower.contains('reel_comment_rate_limit')) {
      return DiscReel.commentRateLimit;
    }
    if (lower.contains('reel_comment_invalid_body')) {
      return DiscReel.commentInvalid;
    }
    return DiscReel.commentError;
  }

  Future<void> _send() async {
    final isGuest = ref.read(guestModeProvider);
    if (isGuest) {
      AppSnackBar.show(context, message: DiscReel.commentLoginRequired);
      return;
    }
    final text = _controller.text.trim();
    if (text.isEmpty || text.length > 500) {
      AppSnackBar.error(context, DiscReel.commentInvalid);
      return;
    }
    setState(() => _sending = true);
    try {
      final created = await ref.read(reelServiceProvider).addComment(
            reelId: widget.reelId,
            body: text,
          );
      if (!mounted) return;
      _controller.clear();
      setState(() {
        _items = [created, ..._items];
        _sending = false;
      });
      ref
          .read(reelFeedControllerProvider.notifier)
          .bumpCommentsCount(widget.reelId, 1);
    } catch (e) {
      if (!mounted) return;
      setState(() => _sending = false);
      AppSnackBar.error(context, _mapSendError(e));
    }
  }

  Future<void> _delete(ReelComment comment) async {
    final previous = _items;
    setState(() {
      _items = _items.where((e) => e.id != comment.id).toList();
    });
    try {
      await ref.read(reelServiceProvider).deleteComment(comment.id);
      ref
          .read(reelFeedControllerProvider.notifier)
          .bumpCommentsCount(widget.reelId, -1);
    } catch (_) {
      if (!mounted) return;
      setState(() => _items = previous);
      AppSnackBar.error(context, DiscReel.commentDeleteError);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final sheetHeight = MediaQuery.sizeOf(context).height * 0.72;
    final bottomInset = MediaQuery.viewInsetsOf(context).bottom;

    return Padding(
      padding: EdgeInsets.only(bottom: bottomInset),
      child: SizedBox(
        height: sheetHeight.clamp(280.0, 720.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 8),
              child: Text(
                DiscReel.commentsSheetTitle,
                style: theme.textTheme.titleLarge?.copyWith(
                  fontFamily: AppFonts.display,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
            Expanded(child: _buildList(theme)),
            const Divider(height: 1),
            SafeArea(
              top: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(12, 8, 8, 8),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: TextField(
                        controller: _controller,
                        focusNode: _focusNode,
                        minLines: 1,
                        maxLines: 4,
                        maxLength: 500,
                        textInputAction: TextInputAction.send,
                        onSubmitted: (_) {
                          if (!_sending) _send();
                        },
                        decoration: InputDecoration(
                          hintText: DiscReel.commentHint,
                          counterText: '',
                          isDense: true,
                          filled: true,
                          fillColor: theme.colorScheme.surfaceContainerHighest
                              .withValues(alpha: 0.55),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(22),
                            borderSide: BorderSide.none,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 14,
                            vertical: 10,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 4),
                    IconButton.filled(
                      onPressed: _sending ? null : _send,
                      tooltip: DiscReel.commentSend,
                      icon: _sending
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.send_rounded),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildList(ThemeData theme) {
    if (_loading && _items.isEmpty) {
      return const DiscoveryListSkeleton(
        rowCount: 5,
        rowHeight: 64,
        padding: EdgeInsets.fromLTRB(16, 8, 16, 16),
      );
    }
    if (_error != null && _items.isEmpty) {
      final body = _error is AppFailure
          ? (_error! as AppFailure).message
          : DiscReel.commentsLoadError;
      return Center(
        child: DiscoveryEmptyState(
          icon: Icons.wifi_off_rounded,
          title: DiscReel.commentsLoadError,
          body: body,
          actionLabel: DiscReel.retry,
          onAction: _refresh,
        ),
      );
    }
    if (_items.isEmpty) {
      return Center(
        child: DiscoveryEmptyState(
          icon: Icons.chat_bubble_outline_rounded,
          title: DiscReel.commentsEmptyTitle,
          body: DiscReel.commentsEmptyBody,
        ),
      );
    }

    final timeFmt = DateFormat.Hm();
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 12),
      itemCount: _items.length + (_loadingMore ? 1 : 0),
      itemBuilder: (context, index) {
        if (index >= _items.length) {
          return const Padding(
            padding: EdgeInsets.symmetric(vertical: 16),
            child: Center(
              child: SizedBox(
                width: 22,
                height: 22,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          );
        }
        final comment = _items[index];
        final avatar = comment.authorAvatarUrl?.trim();
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              CircleAvatar(
                radius: 18,
                backgroundImage:
                    avatar != null && avatar.isNotEmpty
                        ? NetworkImage(avatar)
                        : null,
                child: avatar == null || avatar.isEmpty
                    ? Text(
                        comment.authorName.isNotEmpty
                            ? comment.authorName[0].toUpperCase()
                            : '?',
                        style: theme.textTheme.labelLarge,
                      )
                    : null,
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            comment.authorName,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: theme.textTheme.labelLarge?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                        Text(
                          timeFmt.format(comment.createdAt.toLocal()),
                          style: theme.textTheme.labelSmall?.copyWith(
                            color: theme.colorScheme.onSurfaceVariant,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Text(
                      comment.body,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (comment.isMine)
                      Align(
                        alignment: Alignment.centerLeft,
                        child: TextButton(
                          onPressed: () => _delete(comment),
                          style: TextButton.styleFrom(
                            visualDensity: VisualDensity.compact,
                            padding: EdgeInsets.zero,
                            minimumSize: const Size(0, 32),
                            tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                          ),
                          child: const Text(DiscReel.commentDelete),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
