class MatchEvent {
  final int id;
  final int matchId;
  final int minute;
  final String type;
  final int? teamId;
  final String playerName;
  final String detail;

  MatchEvent({
    required this.id,
    required this.matchId,
    required this.minute,
    required this.type,
    this.teamId,
    required this.playerName,
    required this.detail,
  });

  factory MatchEvent.fromJson(Map<String, dynamic> j) => MatchEvent(
    id: j['id'] as int,
    matchId: (j['match'] ?? j['match_id'] ?? 0) as int,
    minute: (j['minute'] ?? 0) as int,
    type: j['type'] as String,
    teamId: j['team'] as int?,
    playerName: (j['player_name'] ?? j['player'] ?? '') as String,
    detail: (j['detail'] ?? '') as String,
  );

  /// Parsed from a WS payload (which uses `kind` for the event type).
  factory MatchEvent.fromWsPayload(Map<String, dynamic> j) => MatchEvent(
    id: (j['id'] ?? 0) as int,
    matchId: (j['match_id'] ?? 0) as int,
    minute: (j['minute'] ?? 0) as int,
    type: (j['kind'] ?? j['type'] ?? '') as String,
    teamId: j['team_id'] as int?,
    playerName: (j['player'] ?? '') as String,
    detail: (j['detail'] ?? '') as String,
  );
}
