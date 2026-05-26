import 'package:flutter/material.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/match.dart';
import '../models/match_event.dart';

/// Inline match stats derived from the event timeline:
/// - Scorers grouped by team (with minutes)
/// - Yellow + red card counts per team
/// - Possession proxy from per-team event counts
///
/// Everything is computed locally — no extra backend call — so the panel
/// is always in sync with what the user sees in the timeline.
class MatchStatsPanel extends StatelessWidget {
  const MatchStatsPanel({super.key, required this.match, required this.events});

  final Match match;
  final List<MatchEvent> events;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final stats = _MatchStats.fromEvents(
      events: events,
      homeTeamId: match.homeTeam.id,
      awayTeamId: match.awayTeam.id,
    );
    final scheme = Theme.of(context).colorScheme;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      clipBehavior: Clip.antiAlias,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(14, 12, 14, 14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header: competition + venue + current minute if live
            Row(
              children: [
                Icon(Icons.bar_chart_rounded, size: 18, color: scheme.primary),
                const SizedBox(width: 6),
                Text(
                  l.matchStatsTitle,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w800),
                ),
                const Spacer(),
                if (match.isLive)
                  _MinuteBadge(minute: stats.currentMinute, l: l),
              ],
            ),
            if (match.competition.isNotEmpty || match.venue.isNotEmpty) ...[
              const SizedBox(height: 6),
              Text(
                [
                  match.competition,
                  match.venue,
                ].where((s) => s.isNotEmpty).join(' • '),
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
              ),
            ],

            const SizedBox(height: 14),

            // Possession bar
            _PossessionBar(
              homeShort: match.homeTeam.shortName,
              awayShort: match.awayTeam.shortName,
              homePct: stats.homePossession,
              label: l.matchStatsPossession,
            ),

            if (events.isEmpty) ...[
              const SizedBox(height: 14),
              Center(
                child: Text(
                  l.matchStatsNoEvents,
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            ] else ...[
              const SizedBox(height: 14),
              // Two columns: scorers + cards
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _Column(
                        title: l.matchStatsScorers,
                        icon: Icons.sports_soccer,
                        homeShort: match.homeTeam.shortName,
                        awayShort: match.awayTeam.shortName,
                        homeLines: stats.homeScorers,
                        awayLines: stats.awayScorers,
                      ),
                    ),
                    const VerticalDivider(width: 16),
                    Expanded(
                      child: _Column(
                        title: l.matchStatsCards,
                        icon: Icons.style_rounded,
                        homeShort: match.homeTeam.shortName,
                        awayShort: match.awayTeam.shortName,
                        homeLines: stats.homeCards,
                        awayLines: stats.awayCards,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _MatchStats {
  _MatchStats({
    required this.currentMinute,
    required this.homePossession,
    required this.homeScorers,
    required this.awayScorers,
    required this.homeCards,
    required this.awayCards,
  });

  final int currentMinute; // last event minute, capped to 90
  final double homePossession; // 0..1, away = 1 - homePossession
  final List<String> homeScorers;
  final List<String> awayScorers;
  final List<String> homeCards;
  final List<String> awayCards;

  static _MatchStats fromEvents({
    required List<MatchEvent> events,
    required int homeTeamId,
    required int awayTeamId,
  }) {
    final homeScorers = <String>[];
    final awayScorers = <String>[];
    final homeCards = <String>[];
    final awayCards = <String>[];

    int homeCount = 0;
    int awayCount = 0;
    int lastMinute = 0;

    for (final e in events) {
      if (e.minute > lastMinute) lastMinute = e.minute;
      final isHome = e.teamId == homeTeamId;
      final isAway = e.teamId == awayTeamId;
      if (isHome) {
        homeCount += 1;
      } else if (isAway) {
        awayCount += 1;
      }

      switch (e.type) {
        case 'GOAL':
        case 'PEN':
          final name = e.playerName.isEmpty ? '—' : e.playerName;
          final line = "$name (${e.minute}')";
          if (isHome) {
            homeScorers.add(line);
          } else if (isAway) {
            awayScorers.add(line);
          }
          break;
        case 'OG':
          final line = "${e.playerName} OG (${e.minute}')";
          // Own-goal: counts for the OTHER side.
          if (isHome) {
            awayScorers.add(line);
          } else if (isAway) {
            homeScorers.add(line);
          }
          break;
        case 'YELLOW':
        case 'RED':
          final tag = e.type == 'RED' ? '🟥' : '🟨';
          final name = e.playerName.isEmpty ? '—' : e.playerName;
          final line = "$tag $name (${e.minute}')";
          if (isHome) {
            homeCards.add(line);
          } else if (isAway) {
            awayCards.add(line);
          }
          break;
      }
    }

    // Possession proxy: if no team-attributed events yet, 50/50.
    double homePossession;
    final total = homeCount + awayCount;
    if (total == 0) {
      homePossession = 0.5;
    } else {
      homePossession = homeCount / total;
    }

    return _MatchStats(
      currentMinute: lastMinute.clamp(0, 90),
      homePossession: homePossession,
      homeScorers: homeScorers,
      awayScorers: awayScorers,
      homeCards: homeCards,
      awayCards: awayCards,
    );
  }
}

class _MinuteBadge extends StatelessWidget {
  const _MinuteBadge({required this.minute, required this.l});
  final int minute;
  final AppL10n l;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.redAccent.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(99),
        border: Border.all(color: Colors.redAccent),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(
            Icons.fiber_manual_record,
            color: Colors.redAccent,
            size: 10,
          ),
          const SizedBox(width: 4),
          Text(
            l.matchMinute(minute),
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: Colors.redAccent,
            ),
          ),
        ],
      ),
    );
  }
}

class _PossessionBar extends StatelessWidget {
  const _PossessionBar({
    required this.homeShort,
    required this.awayShort,
    required this.homePct,
    required this.label,
  });

  final String homeShort;
  final String awayShort;
  final double homePct; // 0..1
  final String label;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final homePercent = (homePct * 100).round();
    final awayPercent = 100 - homePercent;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            Text(
              '$homeShort  $homePercent%',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
            const Spacer(),
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: scheme.onSurfaceVariant),
            ),
            const Spacer(),
            Text(
              '$awayPercent%  $awayShort',
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(99),
          child: Row(
            children: [
              Expanded(
                flex: (homePct * 1000).round().clamp(1, 1000),
                child: Container(height: 8, color: scheme.primary),
              ),
              Expanded(
                flex: ((1 - homePct) * 1000).round().clamp(1, 1000),
                child: Container(height: 8, color: scheme.tertiary),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class _Column extends StatelessWidget {
  const _Column({
    required this.title,
    required this.icon,
    required this.homeShort,
    required this.awayShort,
    required this.homeLines,
    required this.awayLines,
  });

  final String title;
  final IconData icon;
  final String homeShort;
  final String awayShort;
  final List<String> homeLines;
  final List<String> awayLines;

  @override
  Widget build(BuildContext context) {
    final muted = Theme.of(context).colorScheme.onSurfaceVariant;
    Widget side(String label, List<String> lines) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w800,
            color: muted,
            letterSpacing: 0.6,
          ),
        ),
        const SizedBox(height: 4),
        if (lines.isEmpty)
          Text('—', style: TextStyle(color: muted, fontSize: 12))
        else
          for (final line in lines)
            Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(line, style: const TextStyle(fontSize: 12)),
            ),
      ],
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(icon, size: 14, color: muted),
            const SizedBox(width: 4),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w800,
                color: muted,
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
        side(homeShort, homeLines),
        const SizedBox(height: 8),
        side(awayShort, awayLines),
      ],
    );
  }
}
