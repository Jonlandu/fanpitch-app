// Deterministic "rich match" data: lineups, in-match stats, scorers, events.
//
// Backend doesn't carry possession / lineups / cards yet, but the Match tab
// needs to feel complete. Everything here is seeded by (matchId, teamId) so
// reopening a match shows the SAME numbers — feels real, not random noise.
// Swap any of these with real API calls when the data lands.
import 'dart:math';

import '../models/match.dart';
import '../models/team.dart';

// ── Player name pools per country short code ─────────────────────────
// Real-sounding names per country so a Brazilian squad reads like a
// Brazilian squad. 18 names per country (11 starters + 7 bench).
const Map<String, List<String>> _rosterByCountry = {
  'COD': [
    'Mbemba', 'Bakambu', 'Wissa', 'Masuaku', 'Mpoku', 'Bolingi', 'Kayembe',
    'Lukebakio', 'Tisserand', 'Mbabu', 'Kibungu', 'Bushiri', 'Bongonda',
    'Kalulu', 'Mukoko', 'Iboma', 'Sadiki', 'Mukau',
  ],
  'POR': [
    'D. Costa', 'Pepe', 'R. Dias', 'Cancelo', 'B. Fernandes', 'João Félix',
    'Ronaldo', 'R. Leão', 'B. Silva', 'W. Carvalho', 'N. Mendes', 'Otávio',
    'Vitinha', 'Dalot', 'Diogo Jota', 'André Silva', 'Palhinha', 'Neves',
  ],
  'FRA': [
    'Maignan', 'Pavard', 'Upamecano', 'Saliba', 'T. Hernandez', 'Tchouaméni',
    'Camavinga', 'Griezmann', 'Mbappé', 'Coman', 'Giroud', 'Kanté', 'Rabiot',
    'Koundé', 'Dembélé', 'Konaté', 'Mendy', 'Theo',
  ],
  'ARG': [
    'E. Martínez', 'Molina', 'C. Romero', 'Otamendi', 'Tagliafico', 'De Paul',
    'Mac Allister', 'E. Fernández', 'Messi', 'J. Álvarez', 'Di María',
    'Lautaro', 'Acuña', 'Paredes', 'Lo Celso', 'Dybala', 'Foyth', 'Palacios',
  ],
  'BRA': [
    'Alisson', 'Danilo', 'Marquinhos', 'T. Silva', 'A. Sandro', 'Casemiro',
    'L. Paquetá', 'Neymar', 'Vini Jr.', 'Richarlison', 'Raphinha', 'Rodrygo',
    'Militão', 'Antony', 'Pedro', 'Fred', 'G. Jesus', 'Bremer',
  ],
  'MAR': [
    'Bono', 'Hakimi', 'Saiss', 'Aguerd', 'Mazraoui', 'Amrabat', 'Ounahi',
    'Ziyech', 'En-Nesyri', 'Boufal', 'Amallah', 'Cheddira', 'Sabiri',
    'Dari', 'Attiyat-Allah', 'Hamdallah', 'Banoun', 'Tagnaouti',
  ],
  'SEN': [
    'É. Mendy', 'Sabaly', 'Koulibaly', 'A. Diallo', 'Ballo-Touré', 'I. Gueye',
    'N. Mendes', 'I. Sarr', 'S. Mané', 'Diédhiou', 'B. Dia', 'Ciss',
    'Jakobs', 'Pape Matar', 'B. Diatta', 'Bamba Dieng', 'Ndiaye', 'Loum',
  ],
  'CMR': [
    'André Onana', 'Mbeumo', 'Castelletto', 'Nkoulou', 'Tolo', 'Anguissa',
    'Hongla', 'Choupo-Moting', 'Ekambi', 'Aboubakar', 'Toko Ekambi',
    'Onana M.', 'Mbekeli', 'Gouet', 'Ngamaleu', 'Mbeumo K.', 'Wooh', 'Fai',
  ],
  'ESP': [
    'U. Simón', 'Carvajal', 'Laporte', 'Rodri', 'J. Alba', 'Pedri', 'Gavi',
    'Busquets', 'Dani Olmo', 'Morata', 'M. Asensio', 'Ferran', 'Llorente',
    'Ansu Fati', 'Soler', 'Sarabia', 'Eric García', 'Azpilicueta',
  ],
  'NGA': [
    'F. Uzoho', 'O. Aina', 'Troost-Ekong', 'Omeruo', 'Sanusi', 'Iheanacho',
    'Aribo', 'Onyeka', 'Osimhen', 'Lookman', 'Chukwueze', 'Awoniyi',
    'Ndidi', 'Iwobi', 'Bassey', 'Boniface', 'Onyeka F.', 'Dele-Bashiru',
  ],
};

const List<String> _fallbackRoster = [
  'Keeper', 'Right-back', 'Defender', 'Defender', 'Left-back',
  'Holding mid', 'Box-to-box', 'Playmaker', 'Right wing', 'Striker',
  'Left wing', 'Bench 1', 'Bench 2', 'Bench 3', 'Bench 4', 'Bench 5',
  'Bench 6', 'Bench 7',
];

// ── Public models ────────────────────────────────────────────────────

enum LineupSide { home, away }

class FakePlayer {
  final int number;
  final String name;
  final String position; // GK / DEF / MID / FWD
  const FakePlayer({
    required this.number,
    required this.name,
    required this.position,
  });
}

class FakeLineup {
  final String formation; // "4-3-3" / "4-4-2" / "3-5-2"
  final List<FakePlayer> starters; // 11
  final List<FakePlayer> bench; // 7
  const FakeLineup({
    required this.formation,
    required this.starters,
    required this.bench,
  });
}

class FakeMatchStats {
  final int possessionHome;
  int get possessionAway => 100 - possessionHome;
  final int shotsHome, shotsAway;
  final int shotsOnTargetHome, shotsOnTargetAway;
  final int cornersHome, cornersAway;
  final int foulsHome, foulsAway;
  final int yellowHome, yellowAway;
  final int redHome, redAway;
  final int passesHome, passesAway;
  final int passAccuracyHome, passAccuracyAway; // %
  const FakeMatchStats({
    required this.possessionHome,
    required this.shotsHome,
    required this.shotsAway,
    required this.shotsOnTargetHome,
    required this.shotsOnTargetAway,
    required this.cornersHome,
    required this.cornersAway,
    required this.foulsHome,
    required this.foulsAway,
    required this.yellowHome,
    required this.yellowAway,
    required this.redHome,
    required this.redAway,
    required this.passesHome,
    required this.passesAway,
    required this.passAccuracyHome,
    required this.passAccuracyAway,
  });
}

class FakeMatchEvent {
  final int minute;
  final String type; // GOAL / YELLOW / RED / SUB
  final LineupSide side;
  final String playerName;
  final String? assistName; // for GOAL only
  const FakeMatchEvent({
    required this.minute,
    required this.type,
    required this.side,
    required this.playerName,
    this.assistName,
  });
}

class ScorerEntry {
  final String playerName;
  final Team team;
  final int goals;
  const ScorerEntry({
    required this.playerName,
    required this.team,
    required this.goals,
  });
}

// ── Generators ───────────────────────────────────────────────────────

class FakeMatchData {
  /// 11 starters + 7 bench, with positions matching the formation.
  /// Seeded by (teamId, matchId) so the lineup is consistent for a given
  /// match but each team can field a different XI in different fixtures.
  static FakeLineup lineup(Team team, int matchId,
      {required LineupSide side}) {
    final seed = _seed(team.id, matchId, side == LineupSide.home ? 1 : 2);
    final rng = Random(seed);
    final roster = _rosterByCountry[team.country] ??
        _rosterByCountry[team.shortName] ??
        _fallbackRoster;

    // Pick formation deterministically.
    const formations = ['4-3-3', '4-4-2', '3-5-2', '4-2-3-1'];
    final formation = formations[rng.nextInt(formations.length)];
    final parts = _parseFormation(formation);
    // Collapse 4-part formations (e.g. 4-2-3-1) into [DEF, MID, FWD]:
    // first = DEF, last = FWD, everything in between sums into MID.
    final defs = parts.first;
    final fwds = parts.last;
    final mids = parts.length <= 2
        ? 0
        : parts.sublist(1, parts.length - 1).reduce((a, b) => a + b);
    final shape = [defs, mids, fwds];

    // Shuffle the roster deterministically so different matches give
    // different XIs but still drawn from the team's pool.
    final pool = [...roster]..shuffle(rng);
    final names = pool.take(18).toList();
    if (names.length < 18) {
      // Pad if the roster is too short.
      while (names.length < 18) {
        names.add('${team.shortName} #${names.length + 1}');
      }
    }

    final positions = <String>[
      'GK',
      ...List.filled(shape[0], 'DEF'),
      ...List.filled(shape[1], 'MID'),
      ...List.filled(shape[2], 'FWD'),
    ];
    // Numbers: 1 for GK, then ascending unique numbers.
    final numbers = <int>[1];
    final used = <int>{1};
    while (numbers.length < 11) {
      final n = 2 + rng.nextInt(28); // 2..29
      if (used.add(n)) numbers.add(n);
    }

    final starters = <FakePlayer>[
      for (var i = 0; i < 11; i++)
        FakePlayer(
          number: numbers[i],
          name: names[i],
          position: positions[i],
        ),
    ];

    final benchPositions = ['GK', 'DEF', 'DEF', 'MID', 'MID', 'FWD', 'FWD'];
    final bench = <FakePlayer>[
      for (var i = 0; i < 7; i++)
        FakePlayer(
          number: _uniqueNumber(used, rng),
          name: names[11 + i],
          position: benchPositions[i],
        ),
    ];

    return FakeLineup(formation: formation, starters: starters, bench: bench);
  }

  /// Possession + shots + cards + corners. Internally coherent: more
  /// possession ⇒ more passes; more shots ⇒ more corners; cards from
  /// fouls. Seeded by matchId so reopens are stable.
  static FakeMatchStats stats(Match m) {
    final rng = Random(_seed(m.id, m.homeTeam.id, m.awayTeam.id));

    // Possession leans slightly toward whoever scored more (a real
    // dominance heuristic). For 0-0, slight home advantage.
    final scoreDiff = m.homeScore - m.awayScore;
    final possHome = (52 + scoreDiff * 3 + rng.nextInt(7) - 3).clamp(38, 65);

    final totalShots = 18 + rng.nextInt(11); // 18..28
    final shareHome = possHome / 100;
    final shotsHome = (totalShots * shareHome + rng.nextInt(3) - 1)
        .round()
        .clamp(2, totalShots - 2);
    final shotsAway = totalShots - shotsHome;

    // Shots on target = roughly shots scored + some misses on target.
    final sotHome = (m.homeScore + (shotsHome * 0.35).round() + rng.nextInt(2))
        .clamp(m.homeScore, shotsHome);
    final sotAway = (m.awayScore + (shotsAway * 0.35).round() + rng.nextInt(2))
        .clamp(m.awayScore, shotsAway);

    final cornersHome = 3 + rng.nextInt(7);
    final cornersAway = 2 + rng.nextInt(7);

    final foulsHome = 8 + rng.nextInt(8);
    final foulsAway = 8 + rng.nextInt(8);

    // ~1 yellow per 6 fouls, capped.
    final yellowHome = (foulsHome ~/ 6).clamp(0, 4);
    final yellowAway = (foulsAway ~/ 6).clamp(0, 4);

    // Reds are rare — 1 in 8 matches.
    final redHome = rng.nextInt(8) == 0 ? 1 : 0;
    final redAway = rng.nextInt(8) == 0 ? 1 : 0;

    final passesHome = 380 + (possHome * 5) + rng.nextInt(60);
    final passesAway = 380 + ((100 - possHome) * 5) + rng.nextInt(60);
    final accHome = 78 + rng.nextInt(12);
    final accAway = 78 + rng.nextInt(12);

    return FakeMatchStats(
      possessionHome: possHome,
      shotsHome: shotsHome,
      shotsAway: shotsAway,
      shotsOnTargetHome: sotHome,
      shotsOnTargetAway: sotAway,
      cornersHome: cornersHome,
      cornersAway: cornersAway,
      foulsHome: foulsHome,
      foulsAway: foulsAway,
      yellowHome: yellowHome,
      yellowAway: yellowAway,
      redHome: redHome,
      redAway: redAway,
      passesHome: passesHome,
      passesAway: passesAway,
      passAccuracyHome: accHome,
      passAccuracyAway: accAway,
    );
  }

  /// Event timeline matching the actual score. Goals are attributed to
  /// real names from the lineup; cards and subs are sprinkled in.
  static List<FakeMatchEvent> timeline(Match m) {
    final rng = Random(_seed(m.id, 7, 11));
    final st = stats(m);
    final homeLineup = lineup(m.homeTeam, m.id, side: LineupSide.home);
    final awayLineup = lineup(m.awayTeam, m.id, side: LineupSide.away);

    final events = <FakeMatchEvent>[];

    // Goals — pick minutes spread across 90 min, attribute to forwards/mids.
    final homeScorers = _forwardsAndMids(homeLineup);
    final awayScorers = _forwardsAndMids(awayLineup);

    for (var i = 0; i < m.homeScore; i++) {
      events.add(FakeMatchEvent(
        minute: _goalMinute(rng, i, m.homeScore),
        type: 'GOAL',
        side: LineupSide.home,
        playerName: homeScorers[i % homeScorers.length].name,
        assistName: i.isEven
            ? homeLineup.starters[(i + 3) % 11].name
            : null,
      ));
    }
    for (var i = 0; i < m.awayScore; i++) {
      events.add(FakeMatchEvent(
        minute: _goalMinute(rng, i, m.awayScore),
        type: 'GOAL',
        side: LineupSide.away,
        playerName: awayScorers[i % awayScorers.length].name,
        assistName: i.isOdd
            ? awayLineup.starters[(i + 2) % 11].name
            : null,
      ));
    }

    // Yellow cards.
    for (var i = 0; i < st.yellowHome; i++) {
      events.add(FakeMatchEvent(
        minute: 12 + rng.nextInt(75),
        type: 'YELLOW',
        side: LineupSide.home,
        playerName: homeLineup.starters[3 + (i % 7)].name,
      ));
    }
    for (var i = 0; i < st.yellowAway; i++) {
      events.add(FakeMatchEvent(
        minute: 12 + rng.nextInt(75),
        type: 'YELLOW',
        side: LineupSide.away,
        playerName: awayLineup.starters[3 + (i % 7)].name,
      ));
    }

    // Red cards (if any).
    if (st.redHome > 0) {
      events.add(FakeMatchEvent(
        minute: 55 + rng.nextInt(30),
        type: 'RED',
        side: LineupSide.home,
        playerName: homeLineup.starters[2 + rng.nextInt(5)].name,
      ));
    }
    if (st.redAway > 0) {
      events.add(FakeMatchEvent(
        minute: 55 + rng.nextInt(30),
        type: 'RED',
        side: LineupSide.away,
        playerName: awayLineup.starters[2 + rng.nextInt(5)].name,
      ));
    }

    events.sort((a, b) => a.minute.compareTo(b.minute));
    return events;
  }

  /// Top scorers across all FINISHED matches in the season. Each match's
  /// goals are attributed deterministically, then aggregated and ranked.
  static List<ScorerEntry> topScorers(List<Match> finishedMatches,
      {int limit = 10}) {
    final tally = <String, _ScorerAcc>{};

    for (final m in finishedMatches) {
      final tl = timeline(m);
      for (final e in tl) {
        if (e.type != 'GOAL') continue;
        final team = e.side == LineupSide.home ? m.homeTeam : m.awayTeam;
        final key = '${team.id}:${e.playerName}';
        final acc = tally.putIfAbsent(
          key,
          () => _ScorerAcc(team: team, name: e.playerName),
        );
        acc.goals += 1;
      }
    }

    final list = tally.values
        .map((a) =>
            ScorerEntry(playerName: a.name, team: a.team, goals: a.goals))
        .toList()
      ..sort((a, b) => b.goals.compareTo(a.goals));
    return list.take(limit).toList();
  }

  // ── helpers ───────────────────────────────────────────────────────

  static int _seed(int a, int b, int c) =>
      a * 73856093 ^ b * 19349663 ^ c * 83492791;

  static List<int> _parseFormation(String f) =>
      f.split('-').map(int.parse).toList();

  static int _uniqueNumber(Set<int> used, Random rng) {
    for (var attempt = 0; attempt < 200; attempt++) {
      final n = 2 + rng.nextInt(28);
      if (used.add(n)) return n;
    }
    final n = used.length + 1;
    used.add(n);
    return n;
  }

  static List<FakePlayer> _forwardsAndMids(FakeLineup l) {
    final list = l.starters
        .where((p) => p.position == 'FWD' || p.position == 'MID')
        .toList();
    if (list.isEmpty) return l.starters;
    return list;
  }

  /// Spread N goal minutes across a 90-min match without clustering.
  static int _goalMinute(Random rng, int index, int total) {
    final band = 90 ~/ (total + 1);
    final base = band * (index + 1);
    return (base + rng.nextInt(11) - 5).clamp(3, 89);
  }
}

class _ScorerAcc {
  _ScorerAcc({required this.team, required this.name});
  final Team team;
  final String name;
  int goals = 0;
}
