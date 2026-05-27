# FanPitch — 3-minute video script (podium edition)

> **Constraints (hard from the brief):**
> - **Max 3 minutes** (3:00 is the absolute cap — judges stop watching).
> - **Max 720p** (1280×720). QuickTime / OBS / Loom — all default to ≤720p.
> - **Format**: mp4. Audio must be clean (lavalier or close mic).
> - **Focus**: a *demo* or *KPI explanation*. We go demo, KPI overlay in slide 5.
> - **Judging weights**: 34 % Technical Innovation · 33 % Implementation · 33 % Market.

## Pick your plan before recording

### Plan A — with 2 phones (recommended, +5 pts technical innovation)
The killer "WebSocket fan-out" demo: a goal hits both phones in <300 ms. This is the moment that makes judges remember you.

> **Setup (15 min):**
> 1. Both phones on the same Wi-Fi.
> 2. Backend up: `bash scripts/run.sh prod` shows the EC2 healthy.
> 3. SSH to EC2 and start the simulator: `python manage.py run_simulator --match-id 1 --speed 10`.
> 4. Device A (your iPhone) logged in as `congo_general / fanpitch2026`.
> 5. Device B (second phone / emulator) logged in as `lisbon_lion / fanpitch2026`.
> 6. Both devices on the **Match Room** of match #1.
> 7. Lay them side by side. Frame the camera so both screens fit in the shot.
> 8. Recording at 1280×720, 30 fps, single take.

### Plan B — solo (still solid, just doesn't claim multi-device live)
> Use the **Live tab → ARG vs FRA YouTube card** as your wow. Real football, real video, plays in-app. Skip the multi-device beat at 1:45.

---

## Beat-by-beat (3:00 total · Plan A)

### 0:00 — 0:15 · HOOK (15 s)

**Visual**: Black slide with big white text: *"Two billion people watch football."* Fade to *"None of them really watch alone."*

**Voiceover**:
> *"Two billion people watch football. None of them really watch alone. Yet the social experience is scattered across screenshots, group chats, and silence. We built FanPitch to fix that."*

### 0:15 — 0:30 · THE 4 TABS (15 s)

**Visual**: Phone screen with the bottom nav bar — slowly pan across the 4 tabs: 📲 Pour toi · 🔴 Live · ⚽ Matchs · 👤 Moi. Tap each briefly so the judges register the surfaces exist.

**Voiceover**:
> *"One mobile app. Four surfaces. One heartbeat — the live match. Two minutes, four scenes."*

### 0:30 — 0:55 · TAB 1 · FOR YOU FEED (25 s)

**Visual**: Open Pour toi. Vertical-scroll reels of fan posts (image + caption + reactions). Tap 🔥 on one — watch the count rise. Scroll to next post — show the AI Caption Studio button visible at the bottom of one.

**Voiceover**:
> *"For You — TikTok-style reels of fan posts that auto-expire after a week. Reactions, comments, dwell-time impressions are all tracked. Posts can be generated with our AI Caption Studio — Bedrock Claude, four languages, French, English, Lingala and Swahili."*

### 0:55 — 1:30 · TAB 2 · LIVE — THE BROADCAST SURFACE (35 s)

**Visual**:
- Tap Live tab. Show the live broadcast cards (every match flagged LIVE on the backend).
- Tap one card → the broadcast player opens.
- The video plays in 16:9 with the LIVE badge pulsing top-left, score bug top-right.
- Scroll the commentary timeline below — show goals/cards/subs.

**Voiceover**:
> *"Live. Every match flagged live on the backend shows as a broadcast card here. Tap one — full-screen player, pulsing LIVE badge, score bug, commentary timeline below. Two video pipelines under the hood: video_player for our simulated streams and youtube_player_flutter for licensed broadcasts. Same Flutter widget, switches automatically per source."*

### 1:30 — 2:15 · TAB 3 · MATCH HUB + 2-PHONE WEBSOCKET MOMENT (45 s)

**Visual** (the camera widens to show BOTH phones in frame):
- Tap Matchs tab on Device A. Quick pan: hero carousel → live tiles with possession bar → upcoming → standings table → top scorers podium.
- Tap a LIVE match on Device A → land on the Match Room.
- Device B (already on the same match): show the same score.
- **The killer beat**: the simulator pushes a goal event. Score jumps on **BOTH phones simultaneously**. Reactions fly on both.
- Tap 🔥 on Device A; counter increments on Device B.

**Voiceover**:
> *"Match Hub. Everything 1xBet gives you, with the social layer on top: carousel, live tiles with possession bars, upcoming, standings calculated live from real match results, top scorers. Tap a live match — both phones land in the same room. Watch — a goal just hit the wire. Both screens jumped in under 300 milliseconds. WebSocket fan-out through Django Channels. The fan on the left taps a flame; the fan on the right sees the count rise. That's the live arena, not a marketing claim."*

### 2:15 — 2:40 · MARKET (25 s)

**Visual**: Slide overlay or talking head. Map of Africa with country chips lit up (COD, POR, FRA, BRA, MAR, SEN, CMR, ESP, NGA). Show one phone with the language picker open.

**Voiceover**:
> *"FanPitch ships in five languages: French, English, Spanish, Portuguese, German. Launches first in Francophone and Lusophone Africa — 700 million fans, mobile-first, underserved by Western football apps. Total addressable market: 2 billion fans times 50 cents — 1 billion dollars a year. Built by a fan, for fans, from a continent that lives and breathes football."*

### 2:40 — 3:00 · CLOSE (20 s)

**Visual**: FanPitch logo on the FanPitch green background. Tag line appears: *"Live the match. Together. Out loud."* Hold for 4 seconds. Fade.

**Voiceover**:
> *"FanPitch. Two billion fans. One match. One arena. Thank you, judges — see you in Frankfurt."*

---

## Plan B — solo recording, no second phone

Replace beat 1:30 — 2:15 with:

**Visual**: Tap Matchs tab. Scroll the full hub: carousel → live tiles with possession bars → upcoming → finished → standings table → top scorers podium. Tap a live match. Show the Match Room with its event timeline. Pull up the bottom reaction bar — tap 🔥 — counter jumps.

**Voiceover**:
> *"Match Hub. Everything a fan needs, calculated live from real match results: carousel of featured matches, live tiles with possession bars, the full standings table, top scorers. Tap any live match — this is the room. WebSocket fan-out: when the simulator pushes an event from the server, every connected device updates in under 300 milliseconds. Reactions, comments, polls — all live, all multiplayer."*

(Same length, no multi-device beat. The 2-phone story stays in the executive summary.)

---

## Quick wins / pitfalls

✅ **Do**
- Single take if possible — re-record only if it's a hard fail.
- Lavalier mic or AirPods Pro for clean audio.
- Screen record at exactly 1280×720 — don't downscale 4K (you'll waste bitrate on artifacts).
- Speak slowly. 3 min feels long when speaking, short when watching.
- For Plan A, **practice the 2-phone framing twice** before recording. The shot only works if both screens are visible.

❌ **Don't**
- Show the IDE, terminal, or any code (judges care about the experience).
- Linger on transitions — every cut should advance the story.
- Promise features you haven't built — they verify against the repo.
- Tap the AI Caption Studio "Generate" button mid-recording — Sandbox blocks Bedrock Marketplace, you'd show the fallback. Just show the **button + the language chips** and move on.

## Tools that will work

- **macOS QuickTime** → File > New Movie Recording → mirror iPhone via Lightning, record at 720p.
- **OBS Studio** → set canvas 1280×720, capture iPhone display via USB capture device.
- **Loom Desktop** → records ≤720p by default; export as mp4.
- **iPhone Screen Recording** (Control Center) + iMovie to cut → export 720p.
- **For the 2-phone shot**: stand a 4K phone on a small tripod above both screens; trim to 720p in iMovie.

## Backup plan if simulator hiccups on stage

The featured **ARG vs FRA card uses a fixed YouTube video** — it will always play even if the backend simulator is unreachable. Open that card first if anything feels off; pivot to "the architecture is robust, even our broadcast layer is decoupled".

## Pre-record checklist (3 minutes)

- [ ] EC2 backend healthy: `curl http://ec2-63-184-221-33.eu-central-1.compute.amazonaws.com/healthz` returns `{"status":"ok"}`
- [ ] Simulator running on EC2 for match #1
- [ ] Device A logged in as `congo_general / fanpitch2026`
- [ ] Device B logged in as `lisbon_lion / fanpitch2026` (Plan A only)
- [ ] Phone airplane mode OFF, notifications OFF (no banner pop-ups mid-recording)
- [ ] Battery >50 % on both phones
- [ ] Recording app set to 1280×720, 30 fps
- [ ] Mic test: speak the hook line, play it back, confirm levels
