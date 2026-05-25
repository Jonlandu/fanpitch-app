# FanPitch Mobile

[![CI](https://github.com/Jonlandu/fanpitch-app/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Jonlandu/fanpitch-app/actions/workflows/ci.yml)
[![Flutter 3](https://img.shields.io/badge/flutter-3.x-02569B.svg?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart 3](https://img.shields.io/badge/dart-3.x-0175C2.svg?logo=dart&logoColor=white)](https://dart.dev)
[![Material 3](https://img.shields.io/badge/Material-3-757575.svg?logo=material-design&logoColor=white)](https://m3.material.io)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-FE5196.svg)](https://www.conventionalcommits.org)

> **Mobile companion** to [`fanpitch-api`](https://github.com/Jonlandu/fanpitch-api) — built for the AWS World Sports Innovation Cup 2026.

Flutter 3 (iOS + Android) with Riverpod, go_router, dio + JWT refresh interceptor, and `web_socket_channel` for live match rooms.

- 🏗️ **Architecture overview** → [`ARCHITECTURE.md`](ARCHITECTURE.md)
- 🤝 **How to contribute** → [`CONTRIBUTING.md`](CONTRIBUTING.md)
- 🔒 **Security policy** → [`SECURITY.md`](SECURITY.md)

```
lib/
├── main.dart
├── app.dart
├── theme.dart
├── router.dart            ← go_router with auth guard
├── utils/config.dart      ← API_BASE / WS_BASE from --dart-define
├── models/                ← pure Dart data classes
├── services/
│   ├── api_client.dart    ← dio + auto JWT refresh interceptor
│   ├── socket_client.dart ← WebSocket match room
│   └── auth_storage.dart  ← secure token storage
├── providers/             ← Riverpod state notifiers
├── screens/               ← top-level pages
└── widgets/               ← reusable: event card, reaction bar, poll, status…
```

## Run

```bash
flutter pub get

# iOS simulator
flutter run -d "iPhone 15" \
  --dart-define=API_BASE=http://localhost:8000 \
  --dart-define=WS_BASE=ws://localhost:8000

# Android emulator
flutter run -d emulator-5554 \
  --dart-define=API_BASE=http://10.0.2.2:8000 \
  --dart-define=WS_BASE=ws://10.0.2.2:8000
```

Login with demo credentials (`admin / admin12345` or `kinshasa_kid / fanpitch1234` after running `python manage.py demo_setup` on the backend).

## Notes for judges

- **Auth:** access + refresh JWT stored in `flutter_secure_storage`. A dio interceptor auto-refreshes on 401.
- **WebSocket:** one connection per match room, `?token=<JWT>` in the URL.
- **State:** Riverpod `StateNotifier` per concern; `autoDispose` for the match room so leaving the screen tears the socket down.
- **Theming:** Material 3 dynamic color, seed = "pitch green" (#1FB76C).
