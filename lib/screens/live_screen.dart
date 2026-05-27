// Live tab — surface every match currently flagged LIVE as a big card the
// fan can tap to open the broadcast view. The broadcast itself is a
// pre-recorded sample (see live_video_pool.dart) because the simulator
// doesn't produce real video — swap when an HLS/RTMP source exists.
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../providers/matches_provider.dart';
import '../services/fake_match_data.dart';
import '../services/live_video_pool.dart';
import '../theme.dart';

class LiveScreen extends ConsumerWidget {
  const LiveScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchesProvider);
    final l = AppL10n.of(context);

    return RefreshIndicator(
      onRefresh: () => ref.read(matchesProvider.notifier).refresh(),
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => ListView(
          padding: const EdgeInsets.all(24),
          children: [
            const SizedBox(height: 80),
            Center(child: Text('${l.commonError}: $e')),
          ],
        ),
        data: (all) {
          // Featured matches (synthetic, with YouTube clips) come first,
          // then real LIVE matches from the backend.
          final live = <Match>[
            ...featuredLiveMatches(),
            ...all.where((m) => m.isLive),
          ];

          if (live.isEmpty) {
            return ListView(
              padding: const EdgeInsets.all(24),
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                const SizedBox(height: 96),
                Center(
                  child: Icon(
                    Icons.live_tv_outlined,
                    size: 56,
                    color: FanPitchColors.muted,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    l.liveNoMatches,
                    textAlign: TextAlign.center,
                    style: context.type.bodyMedium?.copyWith(
                      color: FanPitchColors.muted,
                    ),
                  ),
                ),
              ],
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 24),
            physics: const AlwaysScrollableScrollPhysics(),
            itemCount: live.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (_, i) => _LiveBroadcastCard(match: live[i]),
          );
        },
      ),
    );
  }
}

class _LiveBroadcastCard extends StatelessWidget {
  const _LiveBroadcastCard({required this.match});
  final Match match;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final palette = context.fp;
    final time = DateFormat('HH:mm').format(match.kickoffAt.toLocal());
    final stats = FakeMatchData.stats(match);

    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () => context.go('/live/${match.id}'),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Thumbnail-style hero with team gradient + LIVE badge + play.
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          _hexColor(match.homeTeam.colorPrimary),
                          _hexColor(match.awayTeam.colorPrimary),
                        ],
                      ),
                    ),
                  ),
                  // Dark scrim so badge + score read well.
                  const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.center,
                        end: Alignment.bottomCenter,
                        colors: [Colors.transparent, Color(0xCC000000)],
                      ),
                    ),
                  ),
                  // Centred play icon.
                  Center(
                    child: Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.85),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.play_arrow_rounded,
                        size: 40,
                        color: Colors.black,
                      ),
                    ),
                  ),
                  // LIVE badge top-left.
                  Positioned(
                    top: 10,
                    left: 10,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 8,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: palette.liveIndicator,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.fiber_manual_record,
                            size: 8,
                            color: Colors.white,
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
                  ),
                  // Score + teams bottom-left.
                  Positioned(
                    left: 12,
                    right: 12,
                    bottom: 10,
                    child: Row(
                      children: [
                        Expanded(
                          child: Text(
                            '${match.homeTeam.shortName}  ${match.homeScore} - ${match.awayScore}  ${match.awayTeam.shortName}',
                            overflow: TextOverflow.ellipsis,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              letterSpacing: -0.4,
                            ),
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 8,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.white.withValues(alpha: 0.18),
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Text(
                            '${_liveMinute(match)}\'',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 12,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Strip below thumbnail: competition + venue + watch CTA.
            Padding(
              padding: const EdgeInsets.fromLTRB(14, 10, 12, 10),
              child: Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          match.competition.isEmpty
                              ? 'FanPitch Cup'
                              : match.competition,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.type.titleSmall?.copyWith(
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          '${match.venue.isEmpty ? "—" : match.venue} • $time • ${stats.possessionHome}/${stats.possessionAway} %',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: context.type.bodySmall?.copyWith(
                            color: FanPitchColors.muted,
                          ),
                        ),
                      ],
                    ),
                  ),
                  FilledButton.icon(
                    onPressed: () => context.go('/live/${match.id}'),
                    icon: const Icon(Icons.play_arrow, size: 18),
                    label: Text(l.liveWatch),
                    style: FilledButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 14,
                        vertical: 10,
                      ),
                      minimumSize: const Size(0, 36),
                      textStyle: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Small ribbon with team crests, for a "broadcast bug" feel.
            Container(
              decoration: BoxDecoration(
                color: context.colors.surfaceContainer,
                border: Border(
                  top: BorderSide(color: context.colors.outlineVariant),
                ),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _CrestDot(team: match.homeTeam),
                  const SizedBox(width: 6),
                  Text(
                    match.homeTeam.name,
                    style: context.type.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    'vs',
                    style: context.type.labelSmall?.copyWith(
                      color: FanPitchColors.muted,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    match.awayTeam.name,
                    style: context.type.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(width: 6),
                  _CrestDot(team: match.awayTeam),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Rough "current minute" — kickoff was N minutes ago, capped at 90.
  static int _liveMinute(Match m) {
    final mins = DateTime.now().difference(m.kickoffAt).inMinutes;
    return mins.clamp(1, 90);
  }
}

class _CrestDot extends StatelessWidget {
  const _CrestDot({required this.team});
  final Team team;
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 14,
      height: 14,
      decoration: BoxDecoration(
        color: _hexColor(team.colorPrimary),
        shape: BoxShape.circle,
      ),
    );
  }
}

Color _hexColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  if (cleaned.length != 6) return FanPitchColors.pitchGreen;
  return Color(int.parse('FF$cleaned', radix: 16));
}
