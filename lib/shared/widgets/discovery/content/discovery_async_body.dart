import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/constants/app_strings.dart';
import 'discovery_detail_skeleton.dart';
import 'discovery_empty_state.dart';
import 'discovery_list_skeleton.dart';

/// Corps standard pour un [AsyncValue] : shimmer, erreur réseau + retry, données.
class DiscoveryAsyncBody<T> extends StatelessWidget {
  const DiscoveryAsyncBody({
    super.key,
    required this.async,
    required this.data,
    this.loading,
    this.useDetailSkeleton = false,
    this.listRowCount = 6,
    this.listRowHeight = 100,
    this.onRetry,
    this.errorTitle,
    this.errorBody,
    this.wrapErrorInRefresh = false,
    this.onRefresh,
  });

  final AsyncValue<T> async;
  final Widget Function(T value) data;
  final Widget? loading;
  final bool useDetailSkeleton;
  final int listRowCount;
  final double listRowHeight;
  final VoidCallback? onRetry;
  final String? errorTitle;
  final String? errorBody;
  final bool wrapErrorInRefresh;
  final Future<void> Function()? onRefresh;

  Widget _defaultLoading() {
    if (loading != null) return loading!;
    if (useDetailSkeleton) return const DiscoveryDetailSkeleton();
    return DiscoveryListSkeleton(
      rowCount: listRowCount,
      rowHeight: listRowHeight,
    );
  }

  Widget _errorWidget(BuildContext context) {
    final theme = Theme.of(context);
    final body = DiscoveryEmptyState(
      icon: Icons.cloud_off_outlined,
      title: errorTitle ?? CoreStrings.networkErrorTitle,
      body: errorBody ?? CoreStrings.networkErrorBody,
      iconColor: theme.colorScheme.error,
      actionLabel: onRetry != null ? DiscList.retry : null,
      onAction: onRetry,
    );

    if (!wrapErrorInRefresh || onRefresh == null) {
      return Center(child: body);
    }

    return RefreshIndicator(
      onRefresh: onRefresh!,
      child: ListView(
        physics: const AlwaysScrollableScrollPhysics(),
        children: [body],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return async.when(
      loading: _defaultLoading,
      error: (_, __) => _errorWidget(context),
      data: data,
    );
  }
}
