import 'package:flutter/material.dart';

import '../models/match.dart';

class ScoreHeader extends StatelessWidget {
  const ScoreHeader({
    super.key,
    required this.match,
    required this.homeScore,
    required this.awayScore,
  });

  final Match match;
  final int homeScore;
  final int awayScore;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Theme.of(context).colorScheme.primaryContainer,
            Theme.of(context).colorScheme.surface,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
      ),
      child: Row(
        children: [
          Expanded(child: _teamCell(context, match.homeTeam.shortName, homeScore)),
          const Text('vs',
              style: TextStyle(fontWeight: FontWeight.w300, fontSize: 16)),
          Expanded(child: _teamCell(context, match.awayTeam.shortName, awayScore)),
        ],
      ),
    );
  }

  Widget _teamCell(BuildContext context, String name, int score) {
    return Column(
      children: [
        Text(name,
            style:
                const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
        const SizedBox(height: 4),
        Text('$score',
            style: const TextStyle(
                fontSize: 56, fontWeight: FontWeight.w900, height: 1)),
      ],
    );
  }
}
