// Live broadcast sources + synthetic "featured" matches.
//
// FanPitch's match simulator emits events but no real video, so the Live tab
// plays placeholders. Two flavours of source are supported:
//
//   - Mp4Source   → for the rest, pre-recorded clips from the well-known
//                   Google sample bucket (the standard public Flutter pool).
//   - YouTubeSource → for a hand-picked featured fixture (currently the
//                   2022 World Cup Final, Argentina vs France) so the demo
//                   actually shows real football playing back.
//
// Synthetic "featured" matches use negative IDs to never collide with the
// backend's real Match rows. LiveScreen prepends them; LivePlayerScreen
// resolves them via [featuredMatchById].
//
// Swap the sample URLs / video ID for real broadcast feeds when available.
import '../models/match.dart';
import '../models/team.dart';

sealed class LiveSource {
  const LiveSource();
}

class Mp4Source extends LiveSource {
  final String url;
  const Mp4Source(this.url);
}

class YouTubeSource extends LiveSource {
  /// The 11-char YouTube video ID, not the full URL.
  final String videoId;
  const YouTubeSource(this.videoId);
}

const List<String> _samplePool = [
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/BigBuckBunny.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ElephantsDream.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerBlazes.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerEscapes.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerFun.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerJoyrides.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/ForBiggerMeltdowns.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/Sintel.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/TearsOfSteel.mp4',
  'https://commondatastorage.googleapis.com/gtv-videos-bucket/sample/SubaruOutbackOnStreetAndDirt.mp4',
];

// ── Featured matches (synthetic, negative IDs) ──────────────────────
//
// These are appended to the LIVE list client-side. The video ID below
// is the FIFA channel's "Argentina v France | 2022 #FIFAWorldCup Final
// | Extended Highlights" upload — swap if it ever 404s or gets region
// locked.
const _featuredArgFraId = -1;
const _featuredYoutubeId = 'i9dy3v2dGsM';

// Kickoff is pinned to app launch so the in-match minute organically
// grows: starts at ~23' when the user opens the app, ticks up from there.
final DateTime _featuredKickoff =
    DateTime.now().subtract(const Duration(minutes: 23));

List<Match> _featuredMatches() => [
      Match(
        id: _featuredArgFraId,
        homeTeam: Team(
          id: -1001,
          name: 'Argentina',
          shortName: 'ARG',
          country: 'Argentina',
          colorPrimary: '#75AADB',
        ),
        awayTeam: Team(
          id: -1002,
          name: 'France',
          shortName: 'FRA',
          country: 'France',
          colorPrimary: '#0055A4',
        ),
        kickoffAt: _featuredKickoff,
        status: 'LIVE',
        homeScore: 3,
        awayScore: 3,
        competition: 'FIFA World Cup 2022 — Final',
        venue: 'Lusail Stadium, Qatar',
      ),
    ];

/// All synthetic featured live matches, in display order.
List<Match> featuredLiveMatches() => List.unmodifiable(_featuredMatches());

/// Resolve a synthetic featured match by id (used by the player screen
/// since these IDs aren't in the backend `/matches/` response).
Match? featuredMatchById(int id) {
  for (final m in _featuredMatches()) {
    if (m.id == id) return m;
  }
  return null;
}

/// Returns the broadcast source for [matchId]. Featured matches map to
/// their hand-picked YouTube clip; everything else lands on a stable
/// sample mp4 chosen by `matchId % pool.length`.
LiveSource liveSourceFor(int matchId) {
  if (matchId == _featuredArgFraId) {
    return const YouTubeSource(_featuredYoutubeId);
  }
  if (_samplePool.isEmpty) return const Mp4Source('');
  return Mp4Source(_samplePool[matchId.abs() % _samplePool.length]);
}
