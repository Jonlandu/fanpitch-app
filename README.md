# FanPitch Mobile

[![CI](https://github.com/Jonlandu/fanpitch-app/actions/workflows/ci.yml/badge.svg?branch=main)](https://github.com/Jonlandu/fanpitch-app/actions/workflows/ci.yml)
[![Flutter 3](https://img.shields.io/badge/flutter-3.x-02569B.svg?logo=flutter&logoColor=white)](https://flutter.dev)
[![Dart 3](https://img.shields.io/badge/dart-3.x-0175C2.svg?logo=dart&logoColor=white)](https://dart.dev)
[![Material 3](https://img.shields.io/badge/Material-3-757575.svg?logo=material-design&logoColor=white)](https://m3.material.io)
[![Conventional Commits](https://img.shields.io/badge/Conventional%20Commits-1.0.0-FE5196.svg)](https://www.conventionalcommits.org)

> **Live the match. Together. Out loud.**
>
> Mobile companion to [`fanpitch-api`](https://github.com/Jonlandu/fanpitch-api) — built for the AWS World Sports Innovation Cup 2026, Challenge 3 "Fan Squad".

Flutter 3 (iOS + Android) with Riverpod, go_router, dio + JWT refresh interceptor, `web_socket_channel` for live match rooms, and `youtube_player_flutter` + `video_player` for broadcasts.

## What's inside

A 4-tab app:

| Tab | What it does |
|---|---|
| 📲 **Pour toi (For You)** | TikTok-style vertical reels of fan posts (image + text + AI caption). 7-day auto-expiring. Reactions, comments, impressions. |
| 🔴 **Live** | Every active match as a broadcast card. Featured: **2022 World Cup Final ARG 3-3 FRA** plays via YouTube. Others use a sample mp4 pool. Score bug + LIVE badge + commentary timeline. |
| ⚽ **Matchs (Match Hub)** | Hero carousel · live tiles with possession bar · upcoming carousel · recently finished · standings table · top scorers podium. Inspired by 1xBet's depth. |
| 👤 **Moi (Me)** | Profile, points, level, country, badges, language picker (🇫🇷 🇬🇧 🇪🇸 🇵🇹 🇩🇪). |

Plus a real-time **Match Room** behind every LIVE tile, with WebSocket-pushed events, auto-spawned polls, and the simulator's bot reactions.

## Submission for judges

- 🎯 **Hackathon submission package**: see [`deliverables/`](deliverables/) — 5-slide executive summary, 3-minute video script, submission checklist.
- 🏗️ **Architecture deep-dive** → [`ARCHITECTURE.md`](ARCHITECTURE.md)
- 🤝 **How to contribute** → [`CONTRIBUTING.md`](CONTRIBUTING.md)
- 🔒 **Security policy** → [`SECURITY.md`](SECURITY.md)

## Quick run

### Against the live AWS backend (recommended)

```bash
bash scripts/run.sh prod
```

This points the app at the deployed EC2 instance in eu-central-1:
`http://ec2-63-184-221-33.eu-central-1.compute.amazonaws.com`

### Against a local backend

```bash
# 1. Bring the backend up (in fanpitch-api/)
daphne -b 0.0.0.0 -p 8000 fanpitch.asgi:application

# 2. Run the app
flutter pub get

# iOS simulator
flutter run -d "iPhone 16 Plus" \
  --dart-define=API_BASE=http://localhost:8000 \
  --dart-define=WS_BASE=ws://localhost:8000

# Android emulator
flutter run -d emulator-5554 \
  --dart-define=API_BASE=http://10.0.2.2:8000 \
  --dart-define=WS_BASE=ws://10.0.2.2:8000
```

## Demo credentials

All seeded fan accounts share the same password: **`fanpitch2026`**

| Username | Country | Personality |
|---|---|---|
| `congo_general` | 🇨🇩 DR Congo | The general |
| `lisbon_lion` | 🇵🇹 Portugal | Ronaldo apologist |
| `paris_fan` | 🇫🇷 France | Paris Saint-Fan |
| `messi_devoto` | 🇦🇷 Argentina | Messi devotee |
| `samba_king` | 🇧🇷 Brazil | Joga bonito |
| `atlas_lion` | 🇲🇦 Morocco | Atlas Lion |
| ... | | 20 fans across 10 countries |

Admin: `admin / admin12345` (`/admin/`).

## Source layout

```
lib/
├── main.dart
├── app.dart
├── theme.dart                ← FanPitch palette (green/orange/black/white) + Material 3
├── router.dart               ← go_router with auth guard + Live + Match Hub routes
├── utils/config.dart         ← API_BASE / WS_BASE from --dart-define
├── models/                   ← pure Dart data classes
├── services/
│   ├── api_client.dart       ← dio + auto JWT refresh interceptor
│   ├── socket_client.dart    ← WebSocket match room
│   ├── auth_storage.dart     ← secure token storage
│   ├── fake_match_data.dart  ← deterministic stats/lineups/scorers (matchId-seeded)
│   ├── standings_calculator.dart ← real W/D/L/GD/Pts from FINISHED matches
│   └── live_video_pool.dart  ← LiveSource (mp4 vs YouTube) + featured fixtures
├── providers/                ← Riverpod state notifiers
├── screens/
│   ├── reels_feed_screen.dart      ← Tab 1
│   ├── live_screen.dart            ← Tab 2 — list of live broadcasts
│   ├── live_player_screen.dart     ← full-screen player (mp4 or YouTube)
│   ├── match_hub_screen.dart       ← Tab 3 — the rich landing surface
│   ├── matches_list_screen.dart    ← flat list (see-all)
│   ├── match_room_screen.dart      ← live room with WebSocket
│   ├── predictions_screen.dart
│   ├── profile_screen.dart         ← Tab 4
│   └── ...
└── widgets/                  ← reusable: event card, reaction bar, poll, status…
```

## Notes for judges

- **Auth**: access + refresh JWT stored in `flutter_secure_storage`. A dio interceptor auto-refreshes on 401 (skipped on auth endpoints to avoid loops).
- **WebSocket**: one connection per match room, `?token=<JWT>` in the URL, auto-disposed when leaving the screen.
- **State**: Riverpod `StateNotifier` per concern; `autoDispose` everywhere it makes sense.
- **Theming**: Material 3 with a custom `FanPitchPalette` extension (green pitch `#00A651`, fan orange `#FF6B2C`, gold badge `#FFC83D`). Light + dark themes.
- **Localization**: 5 locales (`app_*.arb` + generated `app_localizations*.dart`).
- **Match Hub data**: standings/top-scorers are *computed from real backend matches*; per-match stats and lineups are deterministically faked client-side (seeded by matchId) so re-opens are stable. Swap the fake generators for real API calls when data lands.
- **Live broadcasts**: sample mp4 from the Google sample bucket pool + one featured YouTube clip (2022 World Cup Final). Swap to HLS/RTMP when a real broadcast source exists.
