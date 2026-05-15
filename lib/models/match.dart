import 'team.dart';

class Match {
  final int id;
  final Team homeTeam;
  final Team awayTeam;
  final DateTime kickoffAt;
  final String status; // UPCOMING / LIVE / FINISHED
  final int homeScore;
  final int awayScore;
  final String competition;
  final String venue;

  Match({
    required this.id,
    required this.homeTeam,
    required this.awayTeam,
    required this.kickoffAt,
    required this.status,
    required this.homeScore,
    required this.awayScore,
    required this.competition,
    required this.venue,
  });

  bool get isLive => status == 'LIVE';
  bool get isFinished => status == 'FINISHED';

  factory Match.fromJson(Map<String, dynamic> j) => Match(
    id: j['id'] as int,
    homeTeam: Team.fromJson(j['home_team'] as Map<String, dynamic>),
    awayTeam: Team.fromJson(j['away_team'] as Map<String, dynamic>),
    kickoffAt: DateTime.parse(j['kickoff_at'] as String),
    status: j['status'] as String,
    homeScore: (j['home_score'] ?? 0) as int,
    awayScore: (j['away_score'] ?? 0) as int,
    competition: (j['competition'] ?? '') as String,
    venue: (j['venue'] ?? '') as String,
  );
}
