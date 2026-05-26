import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:web_socket_channel/web_socket_channel.dart';

import '../utils/config.dart';
import 'auth_storage.dart';

/// One WebSocket connection per match room.
class MatchSocket {
  MatchSocket(this._token);
  final String _token;

  WebSocketChannel? _ch;
  final _ctrl = StreamController<Map<String, dynamic>>.broadcast();
  Stream<Map<String, dynamic>> get stream => _ctrl.stream;
  bool _closed = false;

  Future<void> connect(int matchId) async {
    final uri = Uri.parse(
      '${AppConfig.wsBase}/ws/match/$matchId/?token=$_token',
    );
    final ch = WebSocketChannel.connect(uri);
    _ch = ch;
    ch.stream.listen(
      (raw) {
        try {
          final m = jsonDecode(raw as String) as Map<String, dynamic>;
          _ctrl.add(m);
        } catch (_) {
          /* ignore malformed */
        }
      },
      onError: (e) {
        if (!_closed) _ctrl.addError(e);
      },
      onDone: () {
        if (!_closed) _ctrl.close();
      },
      cancelOnError: false,
    );
  }

  void sendReaction({
    required String targetType,
    required int targetId,
    required String emoji,
  }) {
    _ch?.sink.add(
      jsonEncode({
        'type': 'reaction.send',
        'target_type': targetType,
        'target_id': targetId,
        'emoji': emoji,
      }),
    );
  }

  void votePoll(int pollId, int optionIndex) {
    _ch?.sink.add(
      jsonEncode({
        'type': 'poll.vote',
        'poll_id': pollId,
        'option_index': optionIndex,
      }),
    );
  }

  void ping() {
    _ch?.sink.add(jsonEncode({'type': 'ping'}));
  }

  void dispose() {
    _closed = true;
    _ch?.sink.close();
    _ctrl.close();
  }
}

class MatchSocketFactory {
  MatchSocketFactory(this._storage);
  final AuthStorage _storage;

  Future<MatchSocket?> create() async {
    final token = await _storage.readAccess();
    if (token == null) return null;
    return MatchSocket(token);
  }
}

final matchSocketFactoryProvider = Provider<MatchSocketFactory>((ref) {
  return MatchSocketFactory(ref.read(authStorageProvider));
});
