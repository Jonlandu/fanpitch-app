class Prediction {
  final int id;
  final int userId;
  final int matchId;
  final int homeScore;
  final int awayScore;
  final int pointsAwarded;

  Prediction({
    required this.id,
    required this.userId,
    required this.matchId,
    required this.homeScore,
    required this.awayScore,
    required this.pointsAwarded,
  });

  factory Prediction.fromJson(Map<String, dynamic> j) => Prediction(
    id: j['id'] as int,
    userId: j['user'] as int,
    matchId: j['match'] as int,
    homeScore: (j['home_score'] ?? 0) as int,
    awayScore: (j['away_score'] ?? 0) as int,
    pointsAwarded: (j['points_awarded'] ?? 0) as int,
  );
}
