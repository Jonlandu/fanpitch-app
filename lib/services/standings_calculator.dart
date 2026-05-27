// Pure standings calculation from a list of Match records.
//
// Counts wins/draws/losses, goal diff and points for every team that
// appears in at least one match. Unfinished matches are ignored.
//
// Sorting follows FIFA convention: points desc, goal diff desc,
// goals for desc, then team name asc as a tiebreaker.
import '../models/match.dart';
import '../models/team.dart';

class StandingsRow {
  final Team team;
  final int played;
  final int wins;
  final int draws;
  final int losses;
  final int goalsFor;
  final int goalsAgainst;

  const StandingsRow({
    required this.team,
    required this.played,
    required this.wins,
    required this.draws,
    required this.losses,
    required this.goalsFor,
    required this.goalsAgainst,
  });

  int get goalDiff => goalsFor - goalsAgainst;
  int get points => wins * 3 + draws;
}

List<StandingsRow> calculateStandings(List<Match> matches) {
  final acc = <int, _TeamAcc>{};

  for (final m in matches) {
    if (m.status != 'FINISHED') continue;
    final h = acc.putIfAbsent(m.homeTeam.id, () => _TeamAcc(m.homeTeam));
    final a = acc.putIfAbsent(m.awayTeam.id, () => _TeamAcc(m.awayTeam));
    h.played++;
    a.played++;
    h.goalsFor += m.homeScore;
    h.goalsAgainst += m.awayScore;
    a.goalsFor += m.awayScore;
    a.goalsAgainst += m.homeScore;
    if (m.homeScore > m.awayScore) {
      h.wins++;
      a.losses++;
    } else if (m.homeScore < m.awayScore) {
      a.wins++;
      h.losses++;
    } else {
      h.draws++;
      a.draws++;
    }
  }

  final rows = acc.values
      .map((t) => StandingsRow(
            team: t.team,
            played: t.played,
            wins: t.wins,
            draws: t.draws,
            losses: t.losses,
            goalsFor: t.goalsFor,
            goalsAgainst: t.goalsAgainst,
          ))
      .toList()
    ..sort((a, b) {
      final p = b.points.compareTo(a.points);
      if (p != 0) return p;
      final gd = b.goalDiff.compareTo(a.goalDiff);
      if (gd != 0) return gd;
      final gf = b.goalsFor.compareTo(a.goalsFor);
      if (gf != 0) return gf;
      return a.team.name.compareTo(b.team.name);
    });

  return rows;
}

class _TeamAcc {
  _TeamAcc(this.team);
  final Team team;
  int played = 0;
  int wins = 0;
  int draws = 0;
  int losses = 0;
  int goalsFor = 0;
  int goalsAgainst = 0;
}
