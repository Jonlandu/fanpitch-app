import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_storage.dart';

void _logAuth(String msg) {
  if (kDebugMode) debugPrint('🔐 AUTH | $msg');
}

class AuthController extends StateNotifier<AsyncValue<AppUser?>> {
  AuthController(this._api, this._storage) : super(const AsyncValue.loading()) {
    _logAuth('AuthController constructed → state=loading, firing _bootstrap');
    _bootstrap();
  }

  final ApiClient _api;
  final AuthStorage _storage;

  /// Last error from login / register, so the screens can show a snackbar
  /// WITHOUT putting the auth state into AsyncError (which would crash the
  /// router that needs to know "logged in or not").
  Object? lastError;

  Future<void> _bootstrap() async {
    _logAuth('_bootstrap: start, reading storage…');
    try {
      final token = await _storage.readAccess();
      _logAuth(
        '_bootstrap: storage.readAccess = ${token == null ? "null" : "${token.substring(0, 12)}..."}',
      );
      if (token == null) {
        _logAuth('_bootstrap: no token → state=data(null)');
        state = const AsyncValue.data(null);
        return;
      }
      _logAuth('_bootstrap: calling api.getMe()…');
      final me = await _api.getMe();
      _logAuth('_bootstrap: getMe OK (user=${me.username}) → state=data(user)');
      state = AsyncValue.data(me);
    } catch (e) {
      _logAuth('_bootstrap: caught $e → clearing storage + state=data(null)');
      try {
        await _storage.clear();
      } catch (_) {
        /* ignore */
      }
      state = const AsyncValue.data(null);
    }
  }

  Future<bool> login(String username, String password) async {
    _logAuth('login: start username=$username, state=loading');
    lastError = null;
    state = const AsyncValue.loading();
    try {
      _logAuth('login: calling api.login()…');
      final tokens = await _api.login(username, password);
      _logAuth('login: tokens received, writing to storage…');
      await _storage.writeTokens(tokens.access, tokens.refresh);
      _logAuth('login: tokens written, calling api.getMe()…');
      final me = await _api.getMe();
      _logAuth('login: getMe OK (user=${me.username}) → state=data(user) ✓');
      state = AsyncValue.data(me);
      return true;
    } catch (e) {
      _logAuth('login: caught $e → state=data(null) ✗');
      lastError = e;
      state = const AsyncValue.data(null);
      return false;
    }
  }

  Future<bool> register({
    required String username,
    required String email,
    required String password,
    String? displayName,
    String? country,
  }) async {
    _logAuth(
      'register: start username=$username country=$country, state=loading',
    );
    lastError = null;
    state = const AsyncValue.loading();
    try {
      _logAuth('register: calling api.register()…');
      final r = await _api.register(
        username: username,
        email: email,
        password: password,
        displayName: displayName,
        country: country,
      );
      _logAuth('register: tokens received, writing to storage…');
      await _storage.writeTokens(r.tokens.access, r.tokens.refresh);
      _logAuth(
        'register: tokens written → state=data(user=${r.user.username}) ✓',
      );
      state = AsyncValue.data(r.user);
      return true;
    } catch (e) {
      _logAuth('register: caught $e → state=data(null) ✗');
      lastError = e;
      state = const AsyncValue.data(null);
      return false;
    }
  }

  Future<void> logout() async {
    _logAuth('logout: called (state was=${state.valueOrNull?.username})');
    lastError = null;
    try {
      await _storage.clear();
    } catch (_) {
      /* ignore */
    }
    state = const AsyncValue.data(null);
    _logAuth('logout: state=data(null)');
  }
}

final authProvider =
    StateNotifierProvider<AuthController, AsyncValue<AppUser?>>((ref) {
      return AuthController(
        ref.read(apiClientProvider),
        ref.read(authStorageProvider),
      );
    });
