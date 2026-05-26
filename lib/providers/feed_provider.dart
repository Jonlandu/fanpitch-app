import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/status_post.dart';
import '../services/api_client.dart';

class FeedController extends StateNotifier<AsyncValue<List<StatusPost>>> {
  FeedController(this._api) : super(const AsyncValue.loading()) {
    refresh();
  }
  final ApiClient _api;

  Future<void> refresh() async {
    state = const AsyncValue.loading();
    try {
      final list = await _api.listStatuses();
      state = AsyncValue.data(list);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }
}

final feedProvider =
    StateNotifierProvider<FeedController, AsyncValue<List<StatusPost>>>(
      (ref) => FeedController(ref.read(apiClientProvider)),
    );
