# FanPitch — Executive Summary (5 slides)

> **AWS World Sports Innovation Cup 2026 · Challenge 3 "Fan Squad" — Real-Time Social Match Experience**
> Submission by team **FanPitch** (Innocent Kibundulu Kazadi · ESI Bourgogne / BMP).
>
> This markdown contains the EXACT content for each of the 5 PowerPoint slides.
> Open Keynote / PowerPoint / Google Slides, create 5 slides, paste each
> section. Use the visual hints in `[VISUAL]` blocks for layout. Export as PDF.

---

## SLIDE 1 — Hook + Problem

### Title
**Two billion people watch football. None of them really watch *alone*.**

### Subtitle
The match is the heartbeat. The social experience is scattered.

### Body bullets
- 🌍 **2 B fans globally** — but the conversation lives across WhatsApp screenshots, Twitter scrolls and stadium nostalgia.
- ❌ **OneFootball / 365Scores** = stats, no community.
- ❌ **Twitter / Threads** = community, but not match-synced, no rewards.
- 🎯 **The gap**: there is no purpose-built social arena synced to the *minute the goal happens*.

### [VISUAL]
Side-by-side: a stat-heavy OneFootball screen | a chaotic WhatsApp scroll | an empty stadium.

---

## SLIDE 2 — Solution: FanPitch's four surfaces

### Title
**FanPitch — Live the match. Together. Out loud.**

### Subtitle
One mobile app, four surfaces, one heartbeat: the live match.

### Body
A Flutter app with a 4-tab navigation. Each tab is a fully shipped surface:

| Tab | What it does |
|---|---|
| 📲 **For You** | TikTok-style vertical reels of fan posts (image + text + AI caption). 7-day auto-expiring "funny status". Reactions, comments, impressions tracked. |
| 🔴 **Live** | Broadcast view of every live match. Real **2022 World Cup Final (ARG 3-3 FRA)** plays as a featured stream + simulated live cards for active matches. Score bug + LIVE badge + commentary timeline overlay. |
| ⚽ **Match Hub** | Featured carousel · live tiles with possession bar · upcoming carousel · recently finished · **standings table** (real W/D/L/GD/Pts) · **top scorers** podium. Inspired by 1xBet's depth. |
| 👤 **Profile** | Points, level, country, badges, language picker (5 locales: 🇫🇷🇬🇧🇪🇸🇵🇹🇩🇪). |

**Plus**, anywhere from the app:
- **Predictions** before kickoff (Oracle badge for exact scores).
- **Live match room** with auto-spawned polls (red card → *"Was it fair?"*).
- **Bedrock-powered AI captions** for posts in FR / EN / Lingala / Swahili.
- **Leaderboard** updated in real time after each finished match.

### [VISUAL]
4 phone mockups in a row, one per tab, with arrows showing the live data flowing through all of them.

---

## SLIDE 3 — Technical Innovation (34 % of score)

### Title
**AWS-native, real-time, AI-augmented. Production-shaped, hackathon-shipped.**

### Architecture
```
   ┌──────────────────────────────────────────────────────────────┐
   │  Flutter Mobile (iOS/Android, Riverpod, go_router)           │
   │  → REST over Dio  → WebSocket (live match room, reactions)   │
   └──────────────────────────────────────────────────────────────┘
                              │ HTTPS / WSS
                              ▼
   ┌──────────────────────────────────────────────────────────────┐
   │  EC2 t2.micro (eu-central-1) — Daphne ASGI (Django Channels) │
   │  ├─ Django REST Framework      (auth · feed · matches · ai)  │
   │  ├─ Channels  (WebSocket fan-out, match-room broadcast)      │
   │  ├─ Celery worker + Beat        (predictions scoring, decay) │
   │  └─ Match simulator             (bots react/post in real time)│
   └──────────────────────────────────────────────────────────────┘
        │              │                  │                 │
        ▼              ▼                  ▼                 ▼
    RDS Postgres   In-container       S3 + Django/serve    Bedrock
    (relational)   Redis 7            (user media          Claude 4.6
                   (channel layer)     local fallback)      (AI captions
                                                            FR/EN/Lin/Sw)
```

### Why this is innovative
- ⚡ **Real-time fan-out via WebSocket Channels** — a goal event hits one channel group, fans on N devices see the score flip in <300 ms.
- 🤖 **Auto-spawned polls** — server inspects `MatchEvent.type`; a `RED` card triggers a poll *"Carton rouge mérité ?"* without any human in the loop.
- 🤖 **Bedrock Claude 4.6** generates fan post captions (multilingual). Cost-bounded, flagged off by default.
- 🎮 **Simulator with personas** — 7 bot personas (ultra, casual, analyst, provocateur) react to events so the room never feels empty.
- 🎬 **Two video backends** — `video_player` for simulated streams, `youtube_player_flutter` for the featured World Cup match.

### [VISUAL]
The architecture box above, rendered cleanly (Excalidraw or hand drawn).

---

## SLIDE 4 — Data layer / APIs served to fans

### Title
**Everything a football fan needs, exposed via REST + WebSocket.**

### Subtitle
33 endpoints organized in 7 domains. Live-documented via OpenAPI / Swagger at `/api/docs/`.

### API surface

| Domain | Endpoints | Purpose |
|---|---|---|
| 🔐 **Auth** | `POST /auth/register/` · `POST /auth/login/` · `POST /auth/refresh/` · `GET /auth/me/` | JWT (access + refresh), auto-retry on 401 |
| 📰 **Feed** | `GET /feed/for-you/` · `GET /feed/following/` | TikTok-style ranked feed, impression-aware |
| ✍️ **Statuses** | `POST /statuses/` · `GET /statuses/{id}` · 7-day auto-expire | "Funny status" — text + media |
| 📷 **Media** | `POST /media/upload-url/` · `POST /media/local-upload/` · `POST /media/` | S3 presign + local fallback for Innovation Sandbox |
| 💬 **Interactions** | `POST /reactions/` · `POST /comments/` · `POST /impressions/` | Emoji reactions, comments, dwell-time tracking |
| ⚽ **Matches** | `GET /matches/` · `GET /matches/{id}/` · `GET /matches/{id}/events/` · WebSocket `ws://.../ws/match/{id}/` | List, detail, event stream, live channel |
| 🔮 **Predictions** | `POST /predictions/` · scored at fulltime by Celery beat | Oracle badge for exact-score predictions |
| 🏆 **Gamification** | `GET /leaderboard/` · `GET /badges/` | Points, levels, achievement unlocks |
| 🤖 **AI** | `POST /ai/caption/` (Bedrock Claude 4.6) | Multilingual fan caption generation |

### Match-tab specific data (shaped client-side, ready for backend hook-up)
- 🏟️ **Standings** — computed from real `FINISHED` matches (W/D/L, GD, points, FIFA tiebreakers).
- 👕 **Lineups** — 11 starters + 7 bench, country-aware rosters (Mbemba/Bakambu for COD, Mbappé/Griezmann for FRA, …) across 4 formations (4-3-3, 4-4-2, 3-5-2, 4-2-3-1).
- 📊 **Stats per match** — possession, shots, shots on target, corners, fouls, yellow/red cards, passes, accuracy.
- ⚽ **Top scorers** — aggregated from match goal attributions, ranked.
- 📺 **Live broadcast** — mp4 + YouTube source switcher.

### [VISUAL]
A clean Swagger-UI screenshot OR the table above as a styled grid.

---

## SLIDE 5 — Market impact + Why we'll win

### Title
**700 M African football fans first. 2 B globally after that.**

### Subtitle
Mobile-first. Multilingual. Built by a fan, for fans.

### Market
- 🌍 **700 M African football fans** — mobile-first, underserved by Western football apps that cater to PL / La Liga audiences.
- 🗣️ **5 languages** at launch: 🇫🇷 French · 🇬🇧 English · 🇪🇸 Spanish · 🇵🇹 Portuguese · 🇩🇪 German. (Lingala / Swahili planned for AI captions.)
- 💰 **TAM ceiling** = 2 B fans × $0.50 ARPU = **$1 B/year**.

### Go-to-market
| Quarter | Milestone |
|---|---|
| Q1 2026 | Launch MVP in DRC, Portugal, Brazil, France (Lusophone + Francophone first). |
| Q2 2026 | "Fan Club" subscription ($1.99/mo) + AR scarf + league partnerships. |
| Q3 2026 | Expand to Anglophone Africa + Argentina + Mexico. |
| Q4 2026 | Stadium partnerships, second-screen sponsored polls. |

### Why we'll win
- ✅ **Working code, real AWS services, demo-ready** — no smoke and mirrors. Live URL: `ec2-63-184-221-33.eu-central-1.compute.amazonaws.com`.
- ✅ **Three pillars actually delivered**: Live arena (WebSocket) · 1-week funny status (auto-expiring) · Bragging rights (predictions + leaderboard + badges).
- ✅ **Built by a fan, for fans** — starting from a continent that lives and breathes football, with country palettes, native player rosters, multilingual captions.
- ✅ **AWS Innovation Sandbox respected** — eu-central-1, free-tier shaped, no over-provisioning.

### Closing line (read live during the video)
> ***"Two billion fans. One match. One arena. FanPitch — built by the people who actually watch."***

### [VISUAL]
Map of Africa with country chips lit up (COD, POR, FRA, BRA, MAR, SEN, CMR, ESP, NGA, ARG).
Below: the three-pillar scorecard (Innovation · Implementation · Market) all green-checked.
