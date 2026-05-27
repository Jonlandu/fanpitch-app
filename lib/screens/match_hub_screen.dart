// Match Hub — the rich landing surface for the "Match" tab.
//
// Layout (top → bottom):
//   1. Hero carousel of featured matches (live first, then nearest upcoming)
//   2. "Live now" tiles with possession bars
//   3. "Upcoming" horizontal carousel of cards
//   4. "Recently finished" compact list
//   5. Standings (mini table — top 5)
//   6. Top scorers (podium-style top 3)
//
// Standings + scorers are derived from real Match data; per-match stats
// (possession, lineups, etc.) are deterministically faked by matchId so
// they're stable across re-opens.
import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../l10n/generated/app_localizations.dart';
import '../models/match.dart';
import '../models/team.dart';
import '../providers/matches_provider.dart';
import '../services/fake_match_data.dart';
import '../services/standings_calculator.dart';
import '../theme.dart';

class MatchHubScreen extends ConsumerWidget {
  const MatchHubScreen({super.key});

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
        data: (all) => _Hub(matches: all),
      ),
    );
  }
}

class _Hub extends StatelessWidget {
  const _Hub({required this.matches});
  final List<Match> matches;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);

    final live = matches.where((m) => m.isLive).toList()
      ..sort((a, b) => a.kickoffAt.compareTo(b.kickoffAt));
    final upcoming = matches.where((m) => m.status == 'UPCOMING').toList()
      ..sort((a, b) => a.kickoffAt.compareTo(b.kickoffAt));
    final finished = matches.where((m) => m.isFinished).toList()
      ..sort((a, b) => b.kickoffAt.compareTo(a.kickoffAt));

    // Hero carousel: live first, then next 4 upcoming.
    final featured = <Match>[
      ...live,
      ...upcoming.take(5 - live.length.clamp(0, 5)),
    ].take(5).toList();

    final standings = calculateStandings(matches).take(5).toList();
    final scorers = FakeMatchData.topScorers(finished, limit: 5);

    return ListView(
      physics: const AlwaysScrollableScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 24),
      children: [
        if (featured.isNotEmpty) ...[
          const SizedBox(height: 8),
          _HeroCarousel(matches: featured),
        ],

        _SectionHeader(
          icon: Icons.fiber_manual_record,
          iconColor: context.fp.liveIndicator,
          title: l.hubLiveNow,
        ),
        if (live.isEmpty)
          _EmptyHint(text: l.hubNoLive)
        else
          ...live.take(3).map((m) => _LiveTile(match: m)),

        _SectionHeader(
          icon: Icons.event,
          title: l.hubUpcoming,
          trailing: matches.length > 3
              ? _SeeAllLink(onTap: () => context.go('/matches/all'))
              : null,
        ),
        if (upcoming.isEmpty)
          _EmptyHint(text: l.hubNoUpcoming)
        else
          _UpcomingStrip(matches: upcoming.take(8).toList()),

        _SectionHeader(
          icon: Icons.flag_outlined,
          title: l.hubFinished,
          trailing: finished.length > 3
              ? _SeeAllLink(onTap: () => context.go('/matches/all'))
              : null,
        ),
        if (finished.isEmpty)
          _EmptyHint(text: l.hubNoFinished)
        else
          ...finished.take(4).map((m) => _FinishedTile(match: m)),

        if (standings.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.emoji_events_outlined,
            title: l.hubStandings,
          ),
          _StandingsTable(rows: standings),
        ],

        if (scorers.isNotEmpty) ...[
          _SectionHeader(
            icon: Icons.sports_soccer,
            title: l.hubTopScorers,
          ),
          _TopScorersBlock(scorers: scorers),
        ],
      ],
    );
  }
}

// ── Section header ───────────────────────────────────────────────────

class _SectionHeader extends StatelessWidget {
  const _SectionHeader({
    required this.icon,
    required this.title,
    this.iconColor,
    this.trailing,
  });
  final IconData icon;
  final String title;
  final Color? iconColor;
  final Widget? trailing;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 22, 16, 10),
      child: Row(
        children: [
          Icon(icon, size: 18, color: iconColor ?? context.colors.primary),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              title.toUpperCase(),
              style: context.type.titleSmall?.copyWith(
                fontWeight: FontWeight.w800,
                letterSpacing: 0.8,
                color: context.colors.onSurface,
              ),
            ),
          ),
          if (trailing != null) trailing!,
        ],
      ),
    );
  }
}

class _SeeAllLink extends StatelessWidget {
  const _SeeAllLink({required this.onTap});
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              AppL10n.of(context).hubSeeAll,
              style: context.type.labelMedium?.copyWith(
                color: context.colors.primary,
                fontWeight: FontWeight.w700,
              ),
            ),
            Icon(
              Icons.chevron_right,
              size: 18,
              color: context.colors.primary,
            ),
          ],
        ),
      ),
    );
  }
}

class _EmptyHint extends StatelessWidget {
  const _EmptyHint({required this.text});
  final String text;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
      child: Text(
        text,
        style: context.type.bodySmall?.copyWith(color: FanPitchColors.muted),
      ),
    );
  }
}

// ── Hero carousel ────────────────────────────────────────────────────

class _HeroCarousel extends StatefulWidget {
  const _HeroCarousel({required this.matches});
  final List<Match> matches;
  @override
  State<_HeroCarousel> createState() => _HeroCarouselState();
}

class _HeroCarouselState extends State<_HeroCarousel> {
  final _ctl = PageController(viewportFraction: 0.92);
  Timer? _timer;
  int _index = 0;

  @override
  void initState() {
    super.initState();
    if (widget.matches.length > 1) {
      _timer = Timer.periodic(const Duration(seconds: 6), (_) {
        if (!mounted || !_ctl.hasClients) return;
        final next = (_index + 1) % widget.matches.length;
        _ctl.animateToPage(
          next,
          duration: const Duration(milliseconds: 450),
          curve: Curves.easeOutCubic,
        );
      });
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SizedBox(
          height: 180,
          child: PageView.builder(
            controller: _ctl,
            onPageChanged: (i) => setState(() => _index = i),
            itemCount: widget.matches.length,
            itemBuilder: (_, i) => Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: _HeroCard(match: widget.matches[i]),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(widget.matches.length, (i) {
            final active = i == _index;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              height: 6,
              width: active ? 18 : 6,
              decoration: BoxDecoration(
                color: active
                    ? context.colors.primary
                    : context.colors.outlineVariant,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
      ],
    );
  }
}

class _HeroCard extends StatelessWidget {
  const _HeroCard({required this.match});
  final Match match;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    final palette = context.fp;
    final isLive = match.isLive;
    final gradient = isLive ? palette.liveGradient : palette.brandGradient;

    return InkWell(
      onTap: () => _openMatch(context, match),
      borderRadius: BorderRadius.circular(20),
      child: Ink(
        decoration: BoxDecoration(
          gradient: gradient,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Padding(
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  if (isLive) _LiveDot(),
                  if (isLive) const SizedBox(width: 6),
                  Text(
                    isLive ? l.matchStatusLive : l.hubFeatured,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      letterSpacing: 1.1,
                    ),
                  ),
                  const Spacer(),
                  Text(
                    match.competition.isEmpty
                        ? 'FanPitch'
                        : match.competition,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  Expanded(
                    child: _HeroTeamSide(team: match.homeTeam, alignEnd: false),
                  ),
                  SizedBox(
                    width: 90,
                    child: Center(
                      child: isLive || match.isFinished
                          ? Text(
                              '${match.homeScore} - ${match.awayScore}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 32,
                                fontWeight: FontWeight.w900,
                                letterSpacing: -1,
                              ),
                            )
                          : Text(
                              DateFormat('HH:mm')
                                  .format(match.kickoffAt.toLocal()),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 24,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                    ),
                  ),
                  Expanded(
                    child: _HeroTeamSide(team: match.awayTeam, alignEnd: true),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  const Icon(Icons.place_outlined,
                      size: 12, color: Colors.white70),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      match.venue.isEmpty
                          ? DateFormat('EEE d MMM')
                              .format(match.kickoffAt.toLocal())
                          : match.venue,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _HeroTeamSide extends StatelessWidget {
  const _HeroTeamSide({required this.team, required this.alignEnd});
  final Team team;
  final bool alignEnd;
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          alignEnd ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        _TeamCrest(team: team, size: 44, light: true),
        const SizedBox(height: 6),
        Text(
          team.shortName,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 14,
            fontWeight: FontWeight.w800,
          ),
        ),
      ],
    );
  }
}

class _LiveDot extends StatefulWidget {
  @override
  State<_LiveDot> createState() => _LiveDotState();
}

class _LiveDotState extends State<_LiveDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _c;
  @override
  void initState() {
    super.initState();
    _c = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: Tween(begin: 0.4, end: 1.0).animate(_c),
      child: Container(
        width: 8,
        height: 8,
        decoration: const BoxDecoration(
          color: Colors.white,
          shape: BoxShape.circle,
        ),
      ),
    );
  }
}

// ── Live tile ────────────────────────────────────────────────────────

class _LiveTile extends StatelessWidget {
  const _LiveTile({required this.match});
  final Match match;

  @override
  Widget build(BuildContext context) {
    final stats = FakeMatchData.stats(match);
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 8),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openMatch(context, match),
          child: Padding(
            padding: const EdgeInsets.all(14),
            child: Column(
              children: [
                Row(
                  children: [
                    _LiveDot(),
                    const SizedBox(width: 6),
                    Text(
                      AppL10n.of(context).matchStatusLive.toUpperCase(),
                      style: TextStyle(
                        color: context.fp.liveIndicator,
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      match.competition,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: FanPitchColors.muted,
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: _TeamRow(team: match.homeTeam, alignEnd: false),
                    ),
                    Text(
                      '${match.homeScore} - ${match.awayScore}',
                      style: context.type.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w900,
                        letterSpacing: -0.5,
                      ),
                    ),
                    Expanded(
                      child: _TeamRow(team: match.awayTeam, alignEnd: true),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                _PossessionBar(
                  homePct: stats.possessionHome,
                  homeColor: _hexColor(match.homeTeam.colorPrimary),
                  awayColor: _hexColor(match.awayTeam.colorPrimary),
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    Text(
                      '${stats.possessionHome}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      AppL10n.of(context).hubPossession,
                      style: const TextStyle(
                        fontSize: 10,
                        color: FanPitchColors.muted,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.6,
                      ),
                    ),
                    const Spacer(),
                    Text(
                      '${stats.possessionAway}%',
                      style: const TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PossessionBar extends StatelessWidget {
  const _PossessionBar({
    required this.homePct,
    required this.homeColor,
    required this.awayColor,
  });
  final int homePct;
  final Color homeColor;
  final Color awayColor;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(6),
      child: SizedBox(
        height: 8,
        child: Row(
          children: [
            Expanded(flex: homePct, child: Container(color: homeColor)),
            Expanded(flex: 100 - homePct, child: Container(color: awayColor)),
          ],
        ),
      ),
    );
  }
}

// ── Upcoming strip (horizontal scroll) ──────────────────────────────

class _UpcomingStrip extends StatelessWidget {
  const _UpcomingStrip({required this.matches});
  final List<Match> matches;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 150,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: matches.length,
        separatorBuilder: (_, __) => const SizedBox(width: 8),
        itemBuilder: (_, i) => _UpcomingCard(match: matches[i]),
      ),
    );
  }
}

class _UpcomingCard extends StatelessWidget {
  const _UpcomingCard({required this.match});
  final Match match;

  @override
  Widget build(BuildContext context) {
    final date = DateFormat('EEE d MMM').format(match.kickoffAt.toLocal());
    final time = DateFormat('HH:mm').format(match.kickoffAt.toLocal());
    return SizedBox(
      width: 240,
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openMatch(context, match),
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  match.competition.isEmpty ? 'FanPitch' : match.competition,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.labelSmall?.copyWith(
                    color: FanPitchColors.muted,
                  ),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    _TeamCrest(team: match.homeTeam, size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        match.homeTeam.shortName,
                        overflow: TextOverflow.ellipsis,
                        style: context.type.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 6),
                Row(
                  children: [
                    _TeamCrest(team: match.awayTeam, size: 28),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        match.awayTeam.shortName,
                        overflow: TextOverflow.ellipsis,
                        style: context.type.titleSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
                const Spacer(),
                Row(
                  children: [
                    const Icon(Icons.schedule,
                        size: 13, color: FanPitchColors.muted),
                    const SizedBox(width: 4),
                    Text(
                      '$date • $time',
                      style: context.type.bodySmall?.copyWith(
                        color: FanPitchColors.muted,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Finished tile ────────────────────────────────────────────────────

class _FinishedTile extends StatelessWidget {
  const _FinishedTile({required this.match});
  final Match match;

  @override
  Widget build(BuildContext context) {
    final winnerHome = match.homeScore > match.awayScore;
    final winnerAway = match.awayScore > match.homeScore;
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 4, 12, 4),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => _openMatch(context, match),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: _FinishedSide(
                    team: match.homeTeam,
                    score: match.homeScore,
                    isWinner: winnerHome,
                    alignEnd: false,
                  ),
                ),
                Container(
                  height: 24,
                  width: 1,
                  color: context.colors.outlineVariant,
                  margin: const EdgeInsets.symmetric(horizontal: 10),
                ),
                Expanded(
                  child: _FinishedSide(
                    team: match.awayTeam,
                    score: match.awayScore,
                    isWinner: winnerAway,
                    alignEnd: true,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _FinishedSide extends StatelessWidget {
  const _FinishedSide({
    required this.team,
    required this.score,
    required this.isWinner,
    required this.alignEnd,
  });
  final Team team;
  final int score;
  final bool isWinner;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final children = [
      _TeamCrest(team: team, size: 26),
      const SizedBox(width: 8),
      Expanded(
        child: Text(
          team.shortName,
          overflow: TextOverflow.ellipsis,
          textAlign: alignEnd ? TextAlign.right : TextAlign.left,
          style: context.type.titleSmall?.copyWith(
            fontWeight: isWinner ? FontWeight.w800 : FontWeight.w500,
            color: isWinner
                ? context.colors.onSurface
                : FanPitchColors.muted,
          ),
        ),
      ),
      const SizedBox(width: 8),
      Text(
        '$score',
        style: context.type.titleMedium?.copyWith(
          fontWeight: FontWeight.w900,
          color: isWinner ? context.colors.primary : FanPitchColors.muted,
        ),
      ),
    ];
    return Row(
      children: alignEnd ? children.reversed.toList() : children,
    );
  }
}

// ── Team row (used in live tile) ─────────────────────────────────────

class _TeamRow extends StatelessWidget {
  const _TeamRow({required this.team, required this.alignEnd});
  final Team team;
  final bool alignEnd;

  @override
  Widget build(BuildContext context) {
    final crest = _TeamCrest(team: team, size: 36);
    final label = Text(
      team.shortName,
      style: context.type.titleSmall?.copyWith(fontWeight: FontWeight.w700),
    );
    return Row(
      mainAxisAlignment:
          alignEnd ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: alignEnd
          ? [label, const SizedBox(width: 10), crest]
          : [crest, const SizedBox(width: 10), label],
    );
  }
}

// ── Team crest (cached image or coloured initial) ───────────────────

class _TeamCrest extends StatelessWidget {
  const _TeamCrest({
    required this.team,
    required this.size,
    this.light = false,
  });
  final Team team;
  final double size;
  final bool light;

  @override
  Widget build(BuildContext context) {
    final url = team.crestUrl;
    if (url != null && url.isNotEmpty) {
      return ClipOval(
        child: CachedNetworkImage(
          imageUrl: url,
          width: size,
          height: size,
          fit: BoxFit.cover,
          placeholder: (_, __) => _initialFallback(),
          errorWidget: (_, __, ___) => _initialFallback(),
        ),
      );
    }
    return _initialFallback();
  }

  Widget _initialFallback() {
    final color = _hexColor(team.colorPrimary);
    final initial = team.shortName.isNotEmpty
        ? team.shortName.substring(0, 1).toUpperCase()
        : '?';
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: color,
        shape: BoxShape.circle,
        border: light
            ? Border.all(color: Colors.white.withValues(alpha: 0.5), width: 1)
            : null,
      ),
      alignment: Alignment.center,
      child: Text(
        initial,
        style: TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w900,
          fontSize: size * 0.42,
        ),
      ),
    );
  }
}

// ── Standings mini table ────────────────────────────────────────────

class _StandingsTable extends StatelessWidget {
  const _StandingsTable({required this.rows});
  final List<StandingsRow> rows;

  @override
  Widget build(BuildContext context) {
    final l = AppL10n.of(context);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 6),
          child: Column(
            children: [
              _StandingsHeaderRow(l: l),
              const Divider(height: 1),
              for (var i = 0; i < rows.length; i++)
                _StandingsDataRow(rank: i + 1, row: rows[i]),
            ],
          ),
        ),
      ),
    );
  }
}

class _StandingsHeaderRow extends StatelessWidget {
  const _StandingsHeaderRow({required this.l});
  final AppL10n l;
  @override
  Widget build(BuildContext context) {
    final style = context.type.labelSmall?.copyWith(
      color: FanPitchColors.muted,
      fontWeight: FontWeight.w800,
    );
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 8, 12, 8),
      child: Row(
        children: [
          SizedBox(width: 22, child: Text('#', style: style)),
          Expanded(child: Text(l.standingsTeam, style: style)),
          SizedBox(width: 26, child: Center(child: Text(l.standingsP, style: style))),
          SizedBox(width: 26, child: Center(child: Text(l.standingsW, style: style))),
          SizedBox(width: 26, child: Center(child: Text(l.standingsD, style: style))),
          SizedBox(width: 26, child: Center(child: Text(l.standingsL, style: style))),
          SizedBox(width: 34, child: Center(child: Text(l.standingsGd, style: style))),
          SizedBox(
            width: 34,
            child: Center(
              child: Text(l.standingsPts,
                  style: style?.copyWith(color: context.colors.primary)),
            ),
          ),
        ],
      ),
    );
  }
}

class _StandingsDataRow extends StatelessWidget {
  const _StandingsDataRow({required this.rank, required this.row});
  final int rank;
  final StandingsRow row;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(12, 6, 12, 6),
      child: Row(
        children: [
          SizedBox(
            width: 22,
            child: Text(
              '$rank',
              style: context.type.bodySmall?.copyWith(
                fontWeight: FontWeight.w700,
                color: rank <= 3 ? context.colors.primary : null,
              ),
            ),
          ),
          Expanded(
            child: Row(
              children: [
                _TeamCrest(team: row.team, size: 20),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    row.team.shortName,
                    overflow: TextOverflow.ellipsis,
                    style: context.type.bodySmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(width: 26, child: Center(child: _num(context, row.played))),
          SizedBox(width: 26, child: Center(child: _num(context, row.wins))),
          SizedBox(width: 26, child: Center(child: _num(context, row.draws))),
          SizedBox(width: 26, child: Center(child: _num(context, row.losses))),
          SizedBox(
            width: 34,
            child: Center(
              child: Text(
                row.goalDiff >= 0 ? '+${row.goalDiff}' : '${row.goalDiff}',
                style: context.type.bodySmall?.copyWith(
                  color: row.goalDiff > 0
                      ? context.fp.success
                      : (row.goalDiff < 0
                          ? context.fp.danger
                          : FanPitchColors.muted),
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
          SizedBox(
            width: 34,
            child: Center(
              child: Text(
                '${row.points}',
                style: context.type.titleSmall?.copyWith(
                  color: context.colors.primary,
                  fontWeight: FontWeight.w900,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _num(BuildContext c, int v) => Text(
        '$v',
        style: c.type.bodySmall?.copyWith(fontWeight: FontWeight.w600),
      );
}

// ── Top scorers (podium) ────────────────────────────────────────────

class _TopScorersBlock extends StatelessWidget {
  const _TopScorersBlock({required this.scorers});
  final List<ScorerEntry> scorers;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: Column(
          children: [
            for (var i = 0; i < scorers.length && i < 5; i++)
              _ScorerRow(rank: i + 1, scorer: scorers[i]),
          ],
        ),
      ),
    );
  }
}

class _ScorerRow extends StatelessWidget {
  const _ScorerRow({required this.rank, required this.scorer});
  final int rank;
  final ScorerEntry scorer;

  @override
  Widget build(BuildContext context) {
    final medalColor = switch (rank) {
      1 => context.fp.goldBadge,
      2 => const Color(0xFFC0C0C0),
      3 => const Color(0xFFCD7F32),
      _ => FanPitchColors.muted,
    };
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: rank <= 3
                  ? medalColor.withValues(alpha: 0.18)
                  : context.colors.surfaceContainer,
            ),
            alignment: Alignment.center,
            child: Text(
              '$rank',
              style: TextStyle(
                color: rank <= 3 ? medalColor : FanPitchColors.muted,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
          const SizedBox(width: 12),
          _TeamCrest(team: scorer.team, size: 26),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  scorer.playerName,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.titleSmall?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                Text(
                  scorer.team.name,
                  overflow: TextOverflow.ellipsis,
                  style: context.type.bodySmall?.copyWith(
                    color: FanPitchColors.muted,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
            decoration: BoxDecoration(
              color: context.colors.primary.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(Icons.sports_soccer,
                    size: 13, color: context.colors.primary),
                const SizedBox(width: 4),
                Text(
                  AppL10n.of(context).hubGoals(scorer.goals),
                  style: TextStyle(
                    color: context.colors.primary,
                    fontWeight: FontWeight.w800,
                    fontSize: 12,
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

// ── Shared helpers ───────────────────────────────────────────────────

void _openMatch(BuildContext context, Match m) {
  if (m.status == 'UPCOMING') {
    context.go('/predict/${m.id}');
  } else {
    context.go('/match/${m.id}');
  }
}

Color _hexColor(String hex) {
  final cleaned = hex.replaceAll('#', '');
  if (cleaned.length != 6) return FanPitchColors.pitchGreen;
  return Color(int.parse('FF$cleaned', radix: 16));
}
