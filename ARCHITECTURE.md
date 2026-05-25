# FanPitch mobile — Architecture

> **TL;DR**: A Flutter 3 app with Riverpod for state, go_router for
> navigation, dio for HTTP (with auto-refresh JWT interceptor), and
> `web_socket_channel` for the live match feed. Talks to the
> [`fanpitch-api`](https://github.com/Jonlandu/fanpitch-api) backend
> over HTTP and WebSocket; JWT carried in the `Authorization` header
> for HTTP and as `?token=` for WebSocket.

## High-level diagram

```mermaid
flowchart LR
  subgraph App[📱 Flutter app]
    direction TB
    UI[Screens + widgets]
    Riv[(Riverpod state)]
    Router[go_router]
    UI <--> Riv
    UI <--> Router
    Riv -- "HTTP (dio)" --> Api
    Riv -- "WS (web_socket_channel)" --> Sock
  end

  subgraph Services[lib/services]
    Api[ApiClient<br/>dio + JWT interceptor]
    Sock[MatchSocket]
    Storage[AuthStorage<br/>flutter_secure_storage]
    Down[MediaDownloader<br/>gal + dio]
    Api <--> Storage
    Sock <--> Storage
  end

  subgraph Backend[AWS — fanpitch-api]
    HTTP[/api/v1/...]
    WS[/ws/match/<id>/]
  end

  App -- HTTPS --> HTTP
  App -. WS .-> WS
```

## Lib layout

```
lib/
├── main.dart               Entry point; initializes VisibilityDetector, ProviderScope
├── app.dart                FanPitchApp = MaterialApp.router
├── theme.dart              FanPitchColors + FanPitchPalette extension + light/dark themes
├── router.dart             go_router with auth + onboarding gate
│
├── utils/
│   └── config.dart         AppConfig (API_BASE / WS_BASE from --dart-define)
│
├── models/                 Pure Dart DTOs (User, Profile, Match, MatchEvent,
│                           StatusPost, Prediction, Poll, Team)
│
├── services/
│   ├── api_client.dart     dio + Authorization header injection +
│   │                       refresh-on-401 interceptor with retry
│   ├── socket_client.dart  MatchSocket (web_socket_channel wrapper)
│   ├── auth_storage.dart   flutter_secure_storage wrapper
│   └── media_downloader.dart  gal + dio → save remote URL to phone gallery
│
├── providers/              Riverpod state notifiers:
│   ├── auth_provider.dart        AuthController, AsyncValue<AppUser?>
│   ├── matches_provider.dart     MatchesController
│   ├── feed_provider.dart        FeedController (for-you, following, impressions)
│   ├── match_room_provider.dart  MatchRoomController (autoDispose, tears down socket)
│   └── reels_provider.dart       ReelsController
│
├── screens/                Top-level routes:
│   ├── splash_screen.dart        Animated logo (scales + ripples) while bootstrapping auth
│   ├── onboarding_screen.dart    4-page swipeable onboarding (first-launch only)
│   ├── login_screen.dart
│   ├── register_screen.dart
│   ├── main_tabs.dart            Bottom nav (Matches / Feed / Profile)
│   ├── matches_list_screen.dart
│   ├── match_room_screen.dart    Live event ticker + reactions + polls (WS room)
│   ├── reels_feed_screen.dart    TikTok-style for-you + following feeds
│   ├── create_status_screen.dart
│   ├── predictions_screen.dart
│   ├── profile_screen.dart       Current user's profile
│   ├── user_profile_screen.dart  Any user's public profile (clickable)
│   └── leaderboard_screen.dart
│
└── widgets/                Reusable cards / bars / sheets:
    ├── status_card.dart          Author header (tappable → profile), media (with
    │                             download overlay), reaction bar
    ├── status_reel.dart, side_reaction_bar.dart, image_composer.dart
    ├── event_card.dart, score_header.dart
    ├── poll_card.dart, reaction_bar.dart, comment_sheet.dart
```

## Auth + routing flow

```
App launch
   ▼
SplashScreen (animated logo + ripples)
   │
   │  authProvider bootstraps:
   │   1. Read access token from flutter_secure_storage
   │   2. If present → GET /api/v1/auth/me/ → AppUser
   │   3. If error → clear tokens → not-logged-in
   │
   ▼
firstLaunchProvider checks SharedPreferences flag `fp_onboarding_seen_v1`
   │
   ├── Not seen yet → OnboardingScreen (4 pages)
   │                      ▼
   │                  /register OR /login
   ├── Seen + not logged in → /login
   └── Seen + logged in     → MainTabs (matches / feed / profile)
```

## Brand palette

Locked in [`lib/theme.dart`](lib/theme.dart):

| Token | Value | Use |
|---|---|---|
| Pitch Green | `#00A651` | Primary, CTAs, brand |
| Pitch Green+ | `#1FB76C` | Primary hover, dark-mode primary |
| Fan Orange | `#FF6B2C` | Accent, energy moments, live state |
| Fan Orange+ | `#FF8852` | Orange hover |
| Ink Black | `#0D1117` | Text on light / dark surfaces |
| Soft Ink | `#1B2027` | Secondary surfaces on dark |
| Crowd White | `#FFFFFF` | Primary surface on light |
| Off White | `#F5F7F8` | Secondary surface on light |
| Live | `#E5363B` | Live match red dot |
| Gold | `#FFC83D` | Top badge, MOTM, top of leaderboard |

Gradients available via `context.fp.brandGradient` (vert → orange
diagonal) and `context.fp.liveGradient` (red → orange diagonal).

## Brand assets

Master SVGs under `assets/branding/`:
- `app_icon.svg` — 1024×1024 rounded square, the master for all OS icons.
- `logo_mark.svg`, `logo_horizontal.svg`, `logo_horizontal_dark.svg`,
  `logo_stacked.svg` — brand variations.

Regenerate all iOS + Android raster icons:
```bash
bash assets/branding/generate_icons.sh
```

(Requires `librsvg` — `brew install librsvg` on macOS.)

## Why these choices

| Decision | Alternative | Why |
|---|---|---|
| **Riverpod** | Provider, Bloc, GetX | Compile-safe DI, autoDispose for short-lived screens (match room socket), great with go_router. |
| **go_router** | Navigator 2.0 raw | Less boilerplate, declarative auth-guard via `redirect`. |
| **dio** | `http` | Interceptors for JWT refresh-on-401, multipart uploads, presigned S3 PUTs. |
| **flutter_secure_storage** | shared_preferences | JWTs live in Keychain / Keystore, not plain prefs. |
| **flutter_animate** | Rive / Lottie | Code-defined animations = no runtime asset, no extra ~250 KB binary. |
| **flutter_svg** | rasterized PNG only | The logo SVG renders crisp at any size including 1024 splash. |
| **gal** | image_gallery_saver | Modern, type-safe, handles iOS 14 photo-add permission cleanly. |
