import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/status_post.dart';
import '../services/api_client.dart';

enum FeedTab { forYou, following }

class ReelsState {
  final List<StatusPost> items;
  final bool loading;
  final bool loadingMore;
  final String? error;
  final FeedTab tab;

  const ReelsState({
    this.items = const [],
    this.loading = false,
    this.loadingMore = false,
    this.error,
    this.tab = FeedTab.forYou,
  });

  ReelsState copyWith({
    List<StatusPost>? items, bool? loading, bool? loadingMore,
    String? error, FeedTab? tab,
  }) =>
      ReelsState(
        items: items ?? this.items,
        loading: loading ?? this.loading,
        loadingMore: loadingMore ?? this.loadingMore,
        error: error,
        tab: tab ?? this.tab,
      );
}

class ReelsController extends StateNotifier<ReelsState> {
  ReelsController(this._api) : super(const ReelsState(loading: true)) {
    refresh();
    _impressionFlusher = Timer.periodic(
      const Duration(seconds: 8), (_) => _flushImpressions());
  }
  final ApiClient _api;

  // Pending impressions buffer (status id → cumulative dwell ms).
  final Map<int, int> _pendingImpressions = {};
  late final Timer _impressionFlusher;

  Future<void> refresh() async {
    state = state.copyWith(loading: true, error: null);
    try {
      final items = state.tab == FeedTab.forYou
          ? await _api.forYouFeed(limit: 20)
          : await _api.followingFeed(limit: 20);
      state = state.copyWith(items: items, loading: false);
    } catch (e) {
      state = state.copyWith(loading: false, error: e.toString());
    }
  }

  Future<void> loadMore() async {
    if (state.loadingMore) return;
    state = state.copyWith(loadingMore: true);
    try {
      final more = state.tab == FeedTab.forYou
          ? await _api.forYouFeed(limit: 20, offset: state.items.length)
          : await _api.followingFeed(limit: 20, offset: state.items.length);
      final existingIds = {for (final s in state.items) s.id};
      final fresh = more.where((s) => !existingIds.contains(s.id)).toList();
      state = state.copyWith(
        items: [...state.items, ...fresh], loadingMore: false,
      );
    } catch (_) {
      state = state.copyWith(loadingMore: false);
    }
  }

  void switchTab(FeedTab tab) {
    if (tab == state.tab) return;
    state = state.copyWith(tab: tab, items: const []);
    refresh();
  }

  /// Update one item in place after a reaction toggle / comment post.
  void replaceItem(StatusPost updated) {
    final next = [
      for (final s in state.items) s.id == updated.id ? updated : s,
    ];
    state = state.copyWith(items: next);
  }

  /// Called by [StatusReel] when a card has been visible for >= 2s.
  void recordImpression(int statusId, int dwellMs) {
    _pendingImpressions[statusId] =
        (_pendingImpressions[statusId] ?? 0) + dwellMs;
  }

  Future<void> _flushImpressions() async {
    if (_pendingImpressions.isEmpty) return;
    final ids = _pendingImpressions.keys.toList();
    final dwells = _pendingImpressions.values.toList();
    _pendingImpressions.clear();
    try {
      await _api.reportImpressions(ids, dwellMs: dwells);
    } catch (_) {
      // Put them back to retry next tick — capped at 200 to avoid leaks.
      for (var i = 0; i < ids.length && _pendingImpressions.length < 200; i++) {
        _pendingImpressions[ids[i]] =
            (_pendingImpressions[ids[i]] ?? 0) + dwells[i];
      }
    }
  }

  @override
  void dispose() {
    _impressionFlusher.cancel();
    super.dispose();
  }
}

final reelsProvider =
    StateNotifierProvider<ReelsController, ReelsState>(
        (ref) => ReelsController(ref.read(apiClientProvider)));
