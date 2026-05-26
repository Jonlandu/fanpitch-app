import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:visibility_detector/visibility_detector.dart';

import '../l10n/generated/app_localizations.dart';
import '../providers/reels_provider.dart';
import '../widgets/status_reel.dart';

/// Vertical full-screen swipeable feed, like TikTok / IG Reels.
///
/// - 2 tabs at the top: For You / Following
/// - PageView.builder with one [StatusReel] per page
/// - Impression tracker: when a reel is visible >= 2s, we record the dwell.
class ReelsFeedScreen extends ConsumerStatefulWidget {
  const ReelsFeedScreen({super.key});
  @override
  ConsumerState<ReelsFeedScreen> createState() => _ReelsFeedScreenState();
}

class _ReelsFeedScreenState extends ConsumerState<ReelsFeedScreen> {
  final PageController _pc = PageController();
  int _activeIndex = 0;
  final Map<int, DateTime> _visibleSince = {};

  @override
  void dispose() {
    _pc.dispose();
    super.dispose();
  }

  void _onVisibilityChanged(int statusId, double fraction) {
    final ctrl = ref.read(reelsProvider.notifier);
    if (fraction >= 0.6) {
      _visibleSince.putIfAbsent(statusId, () => DateTime.now());
    } else {
      final start = _visibleSince.remove(statusId);
      if (start != null) {
        final dwell = DateTime.now().difference(start).inMilliseconds;
        if (dwell >= 2000) {
          ctrl.recordImpression(statusId, dwell);
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final state = ref.watch(reelsProvider);
    final ctrl = ref.read(reelsProvider.notifier);
    final l = AppL10n.of(context);

    return Scaffold(
      backgroundColor: Colors.black,
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        toolbarHeight: 56,
        title: _TopTabs(tab: state.tab, onTap: ctrl.switchTab),
        actions: [
          IconButton(
            icon: const Icon(Icons.add, color: Colors.white),
            tooltip: l.createPost,
            onPressed: () => context.go('/status/new'),
          ),
        ],
      ),
      body: state.loading
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : state.error != null
          ? Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      '${l.feedLoadError}\n${state.error}',
                      textAlign: TextAlign.center,
                      style: const TextStyle(color: Colors.white),
                    ),
                    const SizedBox(height: 16),
                    FilledButton(
                      onPressed: ctrl.refresh,
                      child: Text(l.feedRetry),
                    ),
                  ],
                ),
              ),
            )
          : state.items.isEmpty
          ? _EmptyState(onRefresh: ctrl.refresh, tab: state.tab)
          : PageView.builder(
              controller: _pc,
              scrollDirection: Axis.vertical,
              onPageChanged: (i) {
                setState(() => _activeIndex = i);
                if (i >= state.items.length - 3) ctrl.loadMore();
              },
              itemCount: state.items.length,
              itemBuilder: (_, i) {
                final s = state.items[i];
                return VisibilityDetector(
                  key: ValueKey('reel-${s.id}'),
                  onVisibilityChanged: (info) =>
                      _onVisibilityChanged(s.id, info.visibleFraction),
                  child: StatusReel(
                    status: s,
                    isActive: i == _activeIndex,
                    onChanged: ctrl.replaceItem,
                  ),
                );
              },
            ),
    );
  }
}

class _TopTabs extends StatelessWidget {
  const _TopTabs({required this.tab, required this.onTap});
  final FeedTab tab;
  final void Function(FeedTab) onTap;

  Widget _tab(BuildContext ctx, String label, FeedTab t) {
    final selected = tab == t;
    return InkWell(
      onTap: () => onTap(t),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.white60,
            fontWeight: selected ? FontWeight.w900 : FontWeight.w500,
            fontSize: 16,
            shadows: const [Shadow(blurRadius: 4, color: Colors.black54)],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _tab(context, l.feedForYou, FeedTab.forYou),
        _tab(context, l.feedFollowing, FeedTab.following),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({required this.onRefresh, required this.tab});
  final VoidCallback onRefresh;
  final FeedTab tab;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final msg = tab == FeedTab.following
        ? l.feedEmptyFollowing
        : l.feedEmptyForYou;
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(msg, style: const TextStyle(color: Colors.white)),
          const SizedBox(height: 16),
          FilledButton.icon(
            onPressed: onRefresh,
            icon: const Icon(Icons.refresh),
            label: Text(l.feedRefresh),
          ),
        ],
      ),
    );
  }
}
