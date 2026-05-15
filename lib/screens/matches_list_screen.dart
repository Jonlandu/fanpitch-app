import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../models/match.dart';
import '../providers/matches_provider.dart';

class MatchesListScreen extends ConsumerWidget {
  const MatchesListScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(matchesProvider);
    return RefreshIndicator(
      onRefresh: () => ref.read(matchesProvider.notifier).refresh(),
      child: state.when(
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
        data: (list) {
          if (list.isEmpty) {
            return ListView(children: const [
              SizedBox(height: 80),
              Center(child: Text('No matches scheduled.')),
            ]);
          }
          final sorted = [...list]..sort((a, b) {
            int rank(Match m) {
              if (m.isLive) return 0;
              if (m.status == 'UPCOMING') return 1;
              return 2;
            }
            final r = rank(a).compareTo(rank(b));
            if (r != 0) return r;
            return a.kickoffAt.compareTo(b.kickoffAt);
          });
          return ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: sorted.length,
            separatorBuilder: (_, __) => const SizedBox(height: 8),
            itemBuilder: (_, i) => _MatchTile(match: sorted[i]),
          );
        },
      ),
    );
  }
}

class _MatchTile extends StatelessWidget {
  const _MatchTile({required this.match});
  final Match match;

  @override
  Widget build(BuildContext context) {
    final ts = DateFormat('EEE d MMM • HH:mm').format(match.kickoffAt.toLocal());
    Color tone;
    switch (match.status) {
      case 'LIVE':
        tone = Colors.redAccent;
        break;
      case 'FINISHED':
        tone = Theme.of(context).disabledColor;
        break;
      default:
        tone = Theme.of(context).colorScheme.primary;
    }
    return Card(
      clipBehavior: Clip.antiAlias,
      child: ListTile(
        title: Text('${match.homeTeam.shortName}  '
            '${match.homeScore} - ${match.awayScore}  ${match.awayTeam.shortName}',
            style: const TextStyle(fontWeight: FontWeight.w700)),
        subtitle: Text('${match.competition.isEmpty ? "FanPitch Match" : match.competition} • $ts'),
        trailing: Chip(
          label: Text(match.status, style: const TextStyle(fontSize: 11)),
          backgroundColor: tone.withValues(alpha: 0.15),
          side: BorderSide(color: tone),
        ),
        onTap: () {
          if (match.status == 'UPCOMING') {
            context.go('/predict/${match.id}');
          } else {
            context.go('/match/${match.id}');
          }
        },
      ),
    );
  }
}
