import 'package:flutter/material.dart';

import '../models/match_event.dart';
import 'reaction_bar.dart';

class EventCard extends StatelessWidget {
  const EventCard({
    super.key,
    required this.event,
    required this.homeTeamId,
    required this.awayTeamId,
    required this.reactionCounts,
    required this.onReact,
  });

  final MatchEvent event;
  final int homeTeamId;
  final int awayTeamId;
  final Map<String, int> reactionCounts;
  final void Function(String emoji) onReact;

  IconData _icon() {
    switch (event.type) {
      case 'GOAL':
      case 'PEN':
        return Icons.sports_soccer;
      case 'OG':
        return Icons.swap_horiz;
      case 'YELLOW':
        return Icons.square_outlined;
      case 'RED':
        return Icons.square_rounded;
      case 'SUB':
        return Icons.compare_arrows;
      case 'HALFTIME':
        return Icons.pause_circle_outline;
      case 'FULLTIME':
        return Icons.stop_circle_outlined;
      case 'KICKOFF':
        return Icons.play_circle_outline;
      default:
        return Icons.timeline;
    }
  }

  Color _color(BuildContext context) {
    switch (event.type) {
      case 'GOAL':
      case 'PEN':
        return Colors.green;
      case 'OG':
        return Colors.orange;
      case 'YELLOW':
        return Colors.amber;
      case 'RED':
        return Colors.red;
      case 'HALFTIME':
      case 'FULLTIME':
        return Theme.of(context).colorScheme.primary;
      default:
        return Theme.of(context).colorScheme.outline;
    }
  }

  String _title() {
    switch (event.type) {
      case 'GOAL':
        return 'GOAL — ${event.playerName}';
      case 'OG':
        return 'Own goal — ${event.playerName}';
      case 'PEN':
        return 'Penalty — ${event.playerName}';
      case 'YELLOW':
        return 'Yellow — ${event.playerName}';
      case 'RED':
        return 'Red — ${event.playerName}';
      case 'KICKOFF':
        return 'Kickoff';
      case 'HALFTIME':
        return 'Halftime';
      case 'FULLTIME':
        return 'Fulltime';
      case 'SUB':
        return 'Substitution';
      default:
        return event.type;
    }
  }

  @override
  Widget build(BuildContext context) {
    final c = _color(context);
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 4, horizontal: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 16,
                  backgroundColor: c.withValues(alpha: 0.15),
                  child: Icon(_icon(), color: c, size: 18),
                ),
                const SizedBox(width: 12),
                Text("${event.minute}'",
                    style: const TextStyle(fontWeight: FontWeight.w800)),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    _title(),
                    style: const TextStyle(fontWeight: FontWeight.w600),
                  ),
                ),
              ],
            ),
            if (event.detail.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 4, left: 40),
                child: Text(event.detail,
                    style: Theme.of(context).textTheme.bodySmall),
              ),
            const SizedBox(height: 8),
            ReactionBar(counts: reactionCounts, onReact: onReact),
          ],
        ),
      ),
    );
  }
}
