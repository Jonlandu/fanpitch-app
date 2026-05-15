import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../services/api_client.dart';

class LeaderboardScreen extends ConsumerStatefulWidget {
  const LeaderboardScreen({super.key});
  @override
  ConsumerState<LeaderboardScreen> createState() => _LeaderboardScreenState();
}

class _LeaderboardScreenState extends ConsumerState<LeaderboardScreen> {
  String _scope = 'global';
  late Future<Map<String, dynamic>> _future;

  @override
  void initState() {
    super.initState();
    _future = ref.read(apiClientProvider).leaderboard(scope: _scope);
  }

  void _setScope(String s) {
    setState(() {
      _scope = s;
      _future = ref.read(apiClientProvider).leaderboard(scope: s);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Leaderboard'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(48),
          child: Row(
            children: ['global', 'week'].map((s) {
              final selected = s == _scope;
              return Expanded(
                child: InkWell(
                  onTap: () => _setScope(s),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      border: Border(
                        bottom: BorderSide(
                          color: selected
                              ? Theme.of(context).colorScheme.primary
                              : Colors.transparent,
                          width: 3,
                        ),
                      ),
                    ),
                    child: Center(
                      child: Text(
                        s.toUpperCase(),
                        style: TextStyle(
                            fontWeight: selected ? FontWeight.w800 : FontWeight.w500),
                      ),
                    ),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ),
      body: FutureBuilder<Map<String, dynamic>>(
        future: _future,
        builder: (ctx, snap) {
          if (snap.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Text('Error: ${snap.error}'));
          }
          final entries = (snap.data?['entries'] as List? ?? []);
          if (entries.isEmpty) {
            return const Center(child: Text('No entries yet.'));
          }
          return ListView.separated(
            itemCount: entries.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (_, i) {
              final e = entries[i] as Map<String, dynamic>;
              return ListTile(
                leading: CircleAvatar(child: Text('${i + 1}')),
                title: Text(e['display_name'] ?? e['username']),
                subtitle: Text(e['country'] ?? ''),
                trailing: Text('${e['points']} pts',
                    style: const TextStyle(fontWeight: FontWeight.w700)),
              );
            },
          );
        },
      ),
    );
  }
}
