import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/match.dart';
import '../services/api_client.dart';

class MatchesController extends StateNotifier<AsyncValue<List<Match>>> {
  MatchesController(this._api) : super(const AsyncValue.loading()) {
    refresh();
  }
  final ApiClient _api;

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      state = AsyncValue.data(await _api.listMatches());
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final matchesProvider =
    StateNotifierProvider<MatchesController, AsyncValue<List<Match>>>(
        (ref) => MatchesController(ref.read(apiClientProvider)));
