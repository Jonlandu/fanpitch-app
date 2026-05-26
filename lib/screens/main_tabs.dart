import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/generated/app_localizations.dart';
import 'matches_list_screen.dart';
import 'profile_screen.dart';
import 'reels_feed_screen.dart';

class MainTabs extends ConsumerStatefulWidget {
  const MainTabs({super.key});
  @override
  ConsumerState<MainTabs> createState() => _MainTabsState();
}

class _MainTabsState extends ConsumerState<MainTabs> {
  int _index = 0;

  static const _pages = <Widget>[
    ReelsFeedScreen(),
    MatchesListScreen(),
    ProfileScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    // The Reels feed runs its own immersive AppBar, so we hide ours on tab 0.
    final showAppBar = _index != 0;
    return Scaffold(
      extendBody: _index == 0,
      appBar: showAppBar
          ? AppBar(
              title: Text(_index == 1 ? l.matchesTitle : l.tabMe),
              actions: [
                IconButton(
                  icon: const Icon(Icons.emoji_events_outlined),
                  tooltip: l.leaderboardTitle,
                  onPressed: () => context.go('/leaderboard'),
                ),
              ],
            )
          : null,
      body: IndexedStack(index: _index, children: _pages),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: [
          NavigationDestination(
            icon: const Icon(Icons.dynamic_feed),
            label: l.tabForYou,
          ),
          NavigationDestination(
            icon: const Icon(Icons.sports_soccer),
            label: l.tabMatches,
          ),
          NavigationDestination(icon: const Icon(Icons.person), label: l.tabMe),
        ],
      ),
    );
  }
}
