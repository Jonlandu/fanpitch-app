# FanPitch Mobile

Flutter 3 app (iOS + Android), wired to the FanPitch Django backend over HTTP + WebSocket.

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
