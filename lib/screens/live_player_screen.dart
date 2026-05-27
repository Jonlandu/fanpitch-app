// Live broadcast view — full-screen player on top, match header and
// commentary timeline below. The player flavour depends on the source:
//
//   - Mp4Source     → video_player (the simulated live clips)
//   - YouTubeSource → youtube_player_flutter (real broadcasts, e.g.
//                     the 2022 World Cup Final)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:video_player/video_player.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/match.dart';
import '../providers/matches_provider.dart';
import '../services/fake_match_data.dart';
import '../services/live_video_pool.dart';
import '../theme.dart';

class LivePlayerScreen extends ConsumerStatefulWidget {
  const LivePlayerScreen({super.key, required this.matchId});
  final int matchId;
  @override
  ConsumerState<LivePlayerScreen> createState() => _LivePlayerScreenState();
}

class _LivePlayerScreenState extends ConsumerState<LivePlayerScreen> {
  late final LiveSource _source;

  // Mp4 path:
  VideoPlayerController? _mp4Ctl;
  bool _mp4Ready = false;
  bool _mp4Error = false;
  bool _controlsVisible = true;

  // YouTube path:
  YoutubePlayerController? _ytCtl;

  @override
  void initState() {
    super.initState();
    _source = liveSourceFor(widget.matchId);
    switch (_source) {
      case Mp4Source(url: final url):
        _initMp4(url);
      case YouTubeSource(videoId: final id):
        _initYoutube(id);
    }
  }

  Future<void> _initMp4(String url) async {
    final ctl = VideoPlayerController.networkUrl(Uri.parse(url));
    _mp4Ctl = ctl;
    try {
      await ctl.initialize();
      ctl.setLooping(true);
      await ctl.play();
      if (!mounted) return;
      setState(() => _mp4Ready = true);
    } catch (_) {
      if (!mounted) return;
      setState(() => _mp4Error = true);
    }
  }

  void _initYoutube(String videoId) {
    _ytCtl = YoutubePlayerController(
      initialVideoId: videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
        loop: false,
        enableCaption: true,
      ),
    );
  }

  @override
  void dispose() {
    _mp4Ctl?.dispose();
    _ytCtl?.dispose();
    super.dispose();
  }

  void _toggleMp4() {
    final c = _mp4Ctl;
    if (c == null || !_mp4Ready) return;
    setState(() {
      if (c.value.isPlaying) {
        c.pause();
      } else {
        c.play();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final matches = ref.watch(matchesProvider);
    // Featured (synthetic) matches aren't in the backend list, so check
    // the synthetic pool first.
    final match = featuredMatchById(widget.matchId) ??
        matches.maybeWhen(
          data: (list) => list.where((m) => m.id == widget.matchId).firstOrNull,
          orElse: () => null,
        );

    final playerArea = switch (_source) {
      Mp4Source() => _Mp4PlayerArea(
          controller: _mp4Ctl,
          ready: _mp4Ready,
          hasError: _mp4Error,
          controlsVisible: _controlsVisible,
          onTap: () =>
              setState(() => _controlsVisible = !_controlsVisible),
          onPlayPause: _toggleMp4,
          match: match,
          onClose: () => context.go('/'),
        ),
      YouTubeSource() => _YoutubePlayerArea(
          controller: _ytCtl!,
          match: match,
          onClose: () => context.go('/'),
        ),
    };

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        backgroundColor: Colors.black,
        body: SafeArea(
          bottom: false,
          child: Column(
            children: [
              playerArea,
              Expanded(
                child: ColoredBox(
                  color: context.colors.surface,
                  child: match == null
                      ? Center(
                          child: Text(
                            l.commonLoading,
                            style: TextStyle(color: FanPitchColors.muted),
                          ),
                        )
                      : _MatchInfoPanel(match: match),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── YouTube player area ─────────────────────────────────────────────

class _YoutubePlayerArea extends StatelessWidget {
  const _YoutubePlayerArea({
    required this.controller,
    required this.match,
    required this.onClose,
  });
  final YoutubePlayerController controller;
  final Match? match;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        YoutubePlayer(
          controller: controller,
          showVideoProgressIndicator: true,
          progressIndicatorColor: context.fp.liveIndicator,
          progressColors: ProgressBarColors(
            playedColor: context.fp.liveIndicator,
            handleColor: context.fp.liveIndicator,
          ),
        ),
        Positioned(
          top: 8,
          left: 8,
          right: 12,
          child: Row(
            children: [
              Material(
                color: Colors.black.withValues(alpha: 0.55),
                shape: const CircleBorder(),
                child: IconButton(
                  icon: const Icon(Icons.close, color: Colors.white),
                  onPressed: onClose,
                ),
              ),
              const SizedBox(width: 8),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: context.fp.liveIndicator,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.fiber_manual_record,
                        color: Colors.white, size: 8),
                    SizedBox(width: 4),
                    Text(
                      'LIVE',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 11,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1,
                      ),
                    ),
                  ],
                ),
              ),
              const Spacer(),
              if (match != null) _ScoreBug(match: match!),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Mp4 player area ─────────────────────────────────────────────────

class _Mp4PlayerArea extends StatelessWidget {
  const _Mp4PlayerArea({
    required this.controller,
    required this.ready,
    required this.hasError,
    required this.controlsVisible,
    required this.onTap,
    required this.onPlayPause,
    required this.match,
    required this.onClose,
  });
  final VideoPlayerController? controller;
  final bool ready;
  final bool hasError;
  final bool controlsVisible;
  final VoidCallback onTap;
  final VoidCallback onPlayPause;
  final Match? match;
  final VoidCallback onClose;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return AspectRatio(
      aspectRatio: 16 / 9,
      child: GestureDetector(
        onTap: onTap,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Container(color: Colors.black),
            if (ready && controller != null)
              FittedBox(
                fit: BoxFit.cover,
                child: SizedBox(
                  width: controller!.value.size.width,
                  height: controller!.value.size.height,
                  child: VideoPlayer(controller!),
                ),
              )
            else if (hasError)
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    l.liveStreamError,
                    textAlign: TextAlign.center,
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
              )
            else
              const Center(
                child: CircularProgressIndicator(color: Colors.white),
              ),
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: IgnorePointer(
                ignoring: !controlsVisible,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: controlsVisible ? 1 : 0,
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [Color(0xCC000000), Colors.transparent],
                      ),
                    ),
                    padding: const EdgeInsets.fromLTRB(8, 8, 12, 18),
                    child: Row(
                      children: [
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.white),
                          onPressed: onClose,
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: context.fp.liveIndicator,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(
                                Icons.fiber_manual_record,
                                color: Colors.white,
                                size: 8,
                              ),
                              SizedBox(width: 4),
                              Text(
                                'LIVE',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 1,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const Spacer(),
                        if (match != null) _ScoreBug(match: match!),
                      ],
                    ),
                  ),
                ),
              ),
            ),
            if (ready)
              IgnorePointer(
                ignoring: !controlsVisible,
                child: AnimatedOpacity(
                  duration: const Duration(milliseconds: 180),
                  opacity: controlsVisible ? 1 : 0,
                  child: Center(
                    child: Material(
                      color: Colors.black54,
                      shape: const CircleBorder(),
                      child: IconButton(
                        iconSize: 48,
                        icon: Icon(
                          controller!.value.isPlaying
                              ? Icons.pause
                              : Icons.play_arrow,
                          color: Colors.white,
                        ),
                        onPressed: onPlayPause,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ScoreBug extends StatelessWidget {
  const _ScoreBug({required this.match});
  final Match match;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.white24),
      ),
      child: Text(
        '${match.homeTeam.shortName} ${match.homeScore} - ${match.awayScore} ${match.awayTeam.shortName}',
        style: const TextStyle(
          color: Colors.white,
          fontSize: 13,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.2,
        ),
      ),
    );
  }
}

// ── Below-player panel ──────────────────────────────────────────────

class _MatchInfoPanel extends StatelessWidget {
  const _MatchInfoPanel({required this.match});
  final Match match;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final time = DateFormat('HH:mm').format(match.kickoffAt.toLocal());
    final timeline = FakeMatchData.timeline(match);

    return ListView(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
      children: [
        Text(
          match.competition.isEmpty ? 'FanPitch Cup' : match.competition,
          style: context.type.labelMedium?.copyWith(
            color: FanPitchColors.muted,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 6),
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Text(
                match.homeTeam.name,
                style: context.type.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Text(
              '${match.homeScore} - ${match.awayScore}',
              style: context.type.displaySmall?.copyWith(
                fontWeight: FontWeight.w900,
                letterSpacing: -1,
              ),
            ),
            Expanded(
              child: Text(
                match.awayTeam.name,
                textAlign: TextAlign.right,
                style: context.type.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            const Icon(Icons.place_outlined,
                size: 14, color: FanPitchColors.muted),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                '${match.venue.isEmpty ? "—" : match.venue} • $time',
                style: context.type.bodySmall?.copyWith(
                  color: FanPitchColors.muted,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: 20),
        Row(
          children: [
            Icon(Icons.timeline,
                size: 16, color: context.colors.primary),
            const SizedBox(width: 6),
            Text(
              l.liveCommentary.toUpperCase(),
              style: context.type.titleSmall?.copyWith(
                letterSpacing: 0.8,
                fontWeight: FontWeight.w800,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),

        if (timeline.isEmpty)
          Padding(
            padding: const EdgeInsets.all(16),
            child: Text(
              l.matchStatsNoEvents,
              style: TextStyle(color: FanPitchColors.muted),
            ),
          )
        else
          ...timeline.reversed.map((e) => _EventRow(event: e, match: match)),
      ],
    );
  }
}

class _EventRow extends StatelessWidget {
  const _EventRow({required this.event, required this.match});
  final FakeMatchEvent event;
  final Match match;

  @override
  Widget build(BuildContext context) {
    final isHome = event.side == LineupSide.home;
    final team = isHome ? match.homeTeam : match.awayTeam;
    final l = AppL10n.of(context);

    final (icon, color, label) = switch (event.type) {
      'GOAL' => (
        Icons.sports_soccer,
        context.colors.primary,
        'But',
      ),
      'YELLOW' => (
        Icons.crop_portrait,
        FanPitchColors.warning,
        'Carton jaune',
      ),
      'RED' => (
        Icons.crop_portrait,
        FanPitchColors.danger,
        'Carton rouge',
      ),
      _ => (Icons.circle_outlined, FanPitchColors.muted, event.type),
    };

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            child: Text(
              l.liveMinute(event.minute),
              textAlign: TextAlign.center,
              style: context.type.labelMedium?.copyWith(
                color: FanPitchColors.muted,
                fontWeight: FontWeight.w800,
              ),
            ),
          ),
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.14),
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, size: 16, color: color),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$label — ${event.playerName}',
                  style: context.type.bodyMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  team.name +
                      (event.assistName != null
                          ? ' • assist ${event.assistName}'
                          : ''),
                  style: context.type.bodySmall?.copyWith(
                    color: FanPitchColors.muted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
