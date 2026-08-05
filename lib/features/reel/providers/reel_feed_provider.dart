import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/models/domain/reel/reel_feed_item.dart';
import '../../../services/supabase/reel/reel_service.dart';

final reelServiceProvider = Provider<ReelService>((ref) {
  return ReelService.fromEnv();
});

class ReelFeedState {
  const ReelFeedState({
    this.items = const [],
    this.isLoading = false,
    this.isLoadingMore = false,
    this.hasMore = true,
    this.error,
    this.cursorScore,
    this.cursorCreatedAt,
    this.cursorId,
  });

  final List<ReelFeedItem> items;
  final bool isLoading;
  final bool isLoadingMore;
  final bool hasMore;
  final Object? error;
  final double? cursorScore;
  final DateTime? cursorCreatedAt;
  final String? cursorId;

  ReelFeedState copyWith({
    List<ReelFeedItem>? items,
    bool? isLoading,
    bool? isLoadingMore,
    bool? hasMore,
    Object? error,
    bool clearError = false,
    double? cursorScore,
    DateTime? cursorCreatedAt,
    String? cursorId,
  }) {
    return ReelFeedState(
      items: items ?? this.items,
      isLoading: isLoading ?? this.isLoading,
      isLoadingMore: isLoadingMore ?? this.isLoadingMore,
      hasMore: hasMore ?? this.hasMore,
      error: clearError ? null : (error ?? this.error),
      cursorScore: cursorScore ?? this.cursorScore,
      cursorCreatedAt: cursorCreatedAt ?? this.cursorCreatedAt,
      cursorId: cursorId ?? this.cursorId,
    );
  }
}

class ReelFeedController extends Notifier<ReelFeedState> {
  @override
  ReelFeedState build() {
    Future.microtask(refresh);
    return const ReelFeedState(isLoading: true);
  }

  ReelService get _service => ref.read(reelServiceProvider);

  Future<void> refresh() async {
    state = state.copyWith(isLoading: true, clearError: true);
    try {
      final page = await _service.listFeed();
      state = ReelFeedState(
        items: page.items,
        hasMore: page.items.length >= 20 && page.hasMore,
        cursorScore: page.nextCursorScore,
        cursorCreatedAt: page.nextCursorCreatedAt,
        cursorId: page.nextCursorId,
      );
    } catch (e) {
      state = state.copyWith(isLoading: false, error: e);
    }
  }

  Future<void> loadMore() async {
    if (state.isLoading || state.isLoadingMore || !state.hasMore) return;
    final cursorScore = state.cursorScore;
    final cursorCreatedAt = state.cursorCreatedAt;
    final cursorId = state.cursorId;
    if (cursorScore == null || cursorCreatedAt == null || cursorId == null) {
      state = state.copyWith(hasMore: false);
      return;
    }
    state = state.copyWith(isLoadingMore: true, clearError: true);
    try {
      final page = await _service.listFeed(
        cursorScore: cursorScore,
        cursorCreatedAt: cursorCreatedAt,
        cursorId: cursorId,
      );
      state = state.copyWith(
        items: [...state.items, ...page.items],
        isLoadingMore: false,
        hasMore: page.items.length >= 20 && page.hasMore,
        cursorScore: page.nextCursorScore,
        cursorCreatedAt: page.nextCursorCreatedAt,
        cursorId: page.nextCursorId,
      );
    } catch (e) {
      state = state.copyWith(isLoadingMore: false, error: e);
    }
  }

  Future<void> recordView(String reelId) async {
    try {
      await _service.recordView(reelId);
    } catch (_) {
      // Non bloquant : la vue est un signal soft.
    }
  }

  Future<bool> toggleLike(String reelId) async {
    final index = state.items.indexWhere((e) => e.id == reelId);
    if (index < 0) return false;
    final current = state.items[index];
    final optimisticLiked = !current.likedByMe;
    final optimisticCount = optimisticLiked
        ? current.likesCount + 1
        : (current.likesCount - 1).clamp(0, 1 << 30);
    final optimistic = [...state.items];
    optimistic[index] = current.copyWith(
      likedByMe: optimisticLiked,
      likesCount: optimisticCount,
    );
    state = state.copyWith(items: optimistic);
    try {
      final liked = await _service.toggleLike(reelId);
      final confirmed = [...state.items];
      final i = confirmed.indexWhere((e) => e.id == reelId);
      if (i >= 0) {
        confirmed[i] = current.copyWith(
          likedByMe: liked,
          likesCount: liked
              ? (current.likedByMe
                  ? current.likesCount
                  : current.likesCount + 1)
              : (current.likedByMe
                  ? (current.likesCount - 1).clamp(0, 1 << 30)
                  : current.likesCount),
        );
        state = state.copyWith(items: confirmed);
      }
      return liked;
    } catch (_) {
      final rollback = [...state.items];
      final i = rollback.indexWhere((e) => e.id == reelId);
      if (i >= 0) rollback[i] = current;
      state = state.copyWith(items: rollback);
      rethrow;
    }
  }

  Future<bool> toggleFavorite(String reelId) async {
    final index = state.items.indexWhere((e) => e.id == reelId);
    if (index < 0) return false;
    final current = state.items[index];
    final optimisticSaved = !current.savedByMe;
    final optimistic = [...state.items];
    optimistic[index] = current.copyWith(savedByMe: optimisticSaved);
    state = state.copyWith(items: optimistic);
    try {
      final saved = await _service.toggleFavorite(reelId);
      final confirmed = [...state.items];
      final i = confirmed.indexWhere((e) => e.id == reelId);
      if (i >= 0) {
        confirmed[i] = current.copyWith(savedByMe: saved);
        state = state.copyWith(items: confirmed);
      }
      return saved;
    } catch (_) {
      final rollback = [...state.items];
      final i = rollback.indexWhere((e) => e.id == reelId);
      if (i >= 0) rollback[i] = current;
      state = state.copyWith(items: rollback);
      rethrow;
    }
  }

  Future<void> focusReel(String reelId) async {
    final id = reelId.trim();
    if (id.isEmpty) return;
    final existing = state.items.indexWhere((e) => e.id == id);
    if (existing >= 0) {
      if (existing > 0) {
        final items = [...state.items];
        final item = items.removeAt(existing);
        state = state.copyWith(items: [item, ...items]);
      }
      return;
    }
    try {
      final item = await _service.getFeedItem(id);
      if (item == null) return;
      final withoutDup = state.items.where((e) => e.id != item.id).toList();
      state = state.copyWith(items: [item, ...withoutDup]);
    } catch (_) {
      // Soft : le feed reste utilisable sans le focus.
    }
  }

  void bumpCommentsCount(String reelId, int delta) {
    final index = state.items.indexWhere((e) => e.id == reelId);
    if (index < 0) return;
    final current = state.items[index];
    final next = [...state.items];
    next[index] = current.copyWith(
      commentsCount: (current.commentsCount + delta).clamp(0, 1 << 30),
    );
    state = state.copyWith(items: next);
  }
}

final reelFeedControllerProvider =
    NotifierProvider.autoDispose<ReelFeedController, ReelFeedState>(
  ReelFeedController.new,
);

final prestataireReelPostsProvider =
    FutureProvider.autoDispose.family<List<ReelPostOwned>, String>((
  ref,
  prestataireId,
) async {
  final service = ref.watch(reelServiceProvider);
  return service.listOwnPosts(prestataireId: prestataireId);
});

final clientReelFavoritesProvider =
    FutureProvider.autoDispose<List<ReelFeedItem>>((ref) async {
  final service = ref.watch(reelServiceProvider);
  return service.listFavorites();
});
