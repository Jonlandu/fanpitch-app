import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/match_room_provider.dart';
import '../widgets/event_card.dart';
import '../widgets/poll_card.dart';
import '../widgets/score_header.dart';

class MatchRoomScreen extends ConsumerWidget {
  const MatchRoomScreen({super.key, required this.matchId});
  final int matchId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchRoomProvider(matchId));
    final controller = ref.read(matchRoomProvider(matchId).notifier);

    if (state.match == null && state.error == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (state.error != null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Match')),
        body: Center(child: Text('Error: ${state.error}')),
      );
    }
    final m = state.match!;
    return Scaffold(
      appBar: AppBar(
        title: Text('${m.homeTeam.shortName} vs ${m.awayTeam.shortName}'),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Chip(
              label: Text(state.connected ? 'LIVE' : 'OFF',
                  style: const TextStyle(fontSize: 11)),
              backgroundColor: state.connected
                  ? Colors.redAccent.withValues(alpha: 0.15)
                  : Theme.of(context).disabledColor.withValues(alpha: 0.15),
              side: BorderSide(
                color: state.connected ? Colors.redAccent : Theme.of(context).disabledColor,
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          ScoreHeader(
            match: m,
            homeScore: state.homeScore,
            awayScore: state.awayScore,
          ),
          if (state.polls.isNotEmpty)
            SizedBox(
              height: 168,
              child: ListView.builder(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                itemCount: state.polls.length,
                itemBuilder: (_, i) => PollCard(
                  poll: state.polls[i],
                  onVote: (idx) => controller.votePoll(state.polls[i].id, idx),
                ),
              ),
            ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: state.events.length,
              itemBuilder: (_, i) {
                final ev = state.events[i];
                return EventCard(
                  event: ev,
                  homeTeamId: m.homeTeam.id,
                  awayTeamId: m.awayTeam.id,
                  reactionCounts: _countsFor(state.reactionCounts, ev.id),
                  onReact: (emoji) =>
                      controller.react(eventId: ev.id, emoji: emoji),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Map<String, int> _countsFor(Map<String, int> all, int eventId) {
    final prefix = '$eventId:';
    return {
      for (final e in all.entries)
        if (e.key.startsWith(prefix)) e.key.substring(prefix.length): e.value,
    };
  }
}
