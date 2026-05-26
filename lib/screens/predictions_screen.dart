import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../models/match.dart';
import '../services/api_client.dart';

class PredictionsScreen extends ConsumerStatefulWidget {
  const PredictionsScreen({super.key, required this.matchId});
  final int matchId;

  @override
  ConsumerState<PredictionsScreen> createState() => _PredictionsScreenState();
}

class _PredictionsScreenState extends ConsumerState<PredictionsScreen> {
  Match? _match;
  int _home = 1;
  int _away = 1;
  bool _busy = false;
  String? _msg;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final api = ref.read(apiClientProvider);
    try {
      final m = await api.getMatch(widget.matchId);
      setState(() => _match = m);
    } catch (e) {
      setState(() => _msg = 'Could not load match: $e');
    }
  }

  Future<void> _submit() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _msg = null;
    });
    try {
      await ref
          .read(apiClientProvider)
          .submitPrediction(matchId: widget.matchId, home: _home, away: _away);
      setState(() => _msg = 'Prediction locked: $_home–$_away');
    } catch (e) {
      setState(() => _msg = 'Error: $e');
    } finally {
      setState(() => _busy = false);
    }
  }

  Widget _stepper(String label, int value, ValueChanged<int> onChange) {
    return Column(
      children: [
        Text(label, style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        Text(
          '$value',
          style: const TextStyle(fontSize: 48, fontWeight: FontWeight.w800),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.remove_circle_outline, size: 32),
              onPressed: value > 0 ? () => onChange(value - 1) : null,
            ),
            IconButton(
              icon: const Icon(Icons.add_circle_outline, size: 32),
              onPressed: value < 9 ? () => onChange(value + 1) : null,
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    final m = _match;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Prediction'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/'),
        ),
      ),
      body: m == null
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Text(
                    '${m.homeTeam.name}  vs  ${m.awayTeam.name}',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    m.competition.isEmpty ? 'FanPitch Match' : m.competition,
                  ),
                  const SizedBox(height: 32),
                  Row(
                    children: [
                      Expanded(
                        child: _stepper(
                          m.homeTeam.shortName,
                          _home,
                          (v) => setState(() => _home = v),
                        ),
                      ),
                      const SizedBox(width: 24),
                      Expanded(
                        child: _stepper(
                          m.awayTeam.shortName,
                          _away,
                          (v) => setState(() => _away = v),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 32),
                  FilledButton.icon(
                    onPressed: _busy ? null : _submit,
                    icon: const Icon(Icons.lock_outline),
                    label: const Text('Lock prediction'),
                  ),
                  const SizedBox(height: 16),
                  if (_msg != null)
                    Text(_msg!, style: const TextStyle(color: Colors.green)),
                  const Spacer(),
                  Text(
                    'Scoring: exact +50 · winner +20 · goal-diff +10',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
    );
  }
}
