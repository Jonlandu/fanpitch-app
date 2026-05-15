import 'package:flutter/foundation.dart';

/// Single source of truth for backend URLs, with smart per-platform defaults.
///
/// Override at run time with:
///   flutter run --dart-define=API_BASE=https://my-api.example.com \
///               --dart-define=WS_BASE=wss://my-api.example.com
///
/// Auto-detected defaults:
/// - Web (Chrome) / desktop / iOS simulator: `127.0.0.1`
///   (we avoid `localhost` because on macOS it can resolve to IPv6 `::1`,
///    which daphne — bound to IPv4 0.0.0.0 — does not answer.)
/// - Android emulator: `10.0.2.2` (host loopback)
class AppConfig {
  static const _envApi = String.fromEnvironment('API_BASE');
  static const _envWs = String.fromEnvironment('WS_BASE');

  static String get apiBase =>
      _envApi.isNotEmpty ? _envApi : _autoBase(httpScheme: true);

  static String get wsBase =>
      _envWs.isNotEmpty ? _envWs : _autoBase(httpScheme: false);

  static String _autoBase({required bool httpScheme}) {
    final scheme = httpScheme ? 'http' : 'ws';
    if (kIsWeb) return '$scheme://127.0.0.1:8000';
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return '$scheme://10.0.2.2:8000';
      default:
        return '$scheme://127.0.0.1:8000';
    }
  }
}
