import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/user.dart';
import '../services/api_client.dart';
import '../services/auth_storage.dart';

class AuthController extends StateNotifier<AsyncValue<AppUser?>> {
  AuthController(this._api, this._storage) : super(const AsyncValue.loading()) {
    _bootstrap();
  }

  final ApiClient _api;
  final AuthStorage _storage;

  /// Last error from login / register, so the screens can show a snackbar
  /// WITHOUT putting the auth state into AsyncError (which would crash the
  /// router that needs to know "logged in or not").
  Object? lastError;

  Future<void> _bootstrap() async {
    try {
      final token = await _storage.readAccess();
      if (token == null) {
        state = const AsyncValue.data(null);
        return;
      }
      final me = await _api.getMe();
      state = AsyncValue.data(me);
    } catch (_) {
      // Stale / invalid token, or backend unreachable. Treat as "not logged in".
      try {
        await _storage.clear();
      } catch (_) {
        /* ignore */
      }
      state = const AsyncValue.data(null);
    }
  }

  Future<bool> login(String username, String password) async {
    lastError = null;
    state = const AsyncValue.loading();
    try {
      final tokens = await _api.login(username, password);
      await _storage.writeTokens(tokens.access, tokens.refresh);
      final me = await _api.getMe();
      state = AsyncValue.data(me);
      return true;
    } catch (e) {
      lastError = e;
      state = const AsyncValue.data(null); // stay logged-out, no AsyncError
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
    lastError = null;
    state = const AsyncValue.loading();
    try {
      final r = await _api.register(
        username: username,
        email: email,
        password: password,
        displayName: displayName,
        country: country,
      );
      await _storage.writeTokens(r.tokens.access, r.tokens.refresh);
      // Symmetry with login(): verify the token works against /auth/me/
      // BEFORE flipping the auth state. If the verification fails (token
      // not yet readable from storage, clock skew, etc.) we surface a
      // real error instead of landing the user on a half-broken feed.
      final me = await _api.getMe();
      state = AsyncValue.data(me);
      return true;
    } catch (e) {
      lastError = e;
      state = const AsyncValue.data(null);
      return false;
    }
  }

  Future<void> logout() async {
    lastError = null;
    try {
      await _storage.clear();
    } catch (_) {
      /* ignore */
    }
    state = const AsyncValue.data(null);
  }

  /// Called by [ApiClient] when the refresh-token flow also fails. The
  /// interceptor already cleared the secure storage — we just sync the
  /// in-memory state so the router redirects to /login.
  void handleSessionExpired() {
    // Avoid bouncing if the user is already logged out.
    if (state.valueOrNull == null) return;
    lastError = 'session_expired';
    state = const AsyncValue.data(null);
  }
}

final authProvider =
    StateNotifierProvider<AuthController, AsyncValue<AppUser?>>((ref) {
      final api = ref.read(apiClientProvider);
      final storage = ref.read(authStorageProvider);
      final controller = AuthController(api, storage);
      // Wire the Dio interceptor's session-expired hook to the auth state.
      api.onSessionExpired = controller.handleSessionExpired;
      return controller;
    });
