#!/usr/bin/env bash
# FanPitch — pre-record video health check.
#
# Run this 5 minutes before you start recording the 3-min hackathon video.
# It verifies the live AWS backend is up, the seeded users can log in, the
# simulator has matches in the right states, and your local tools (Flutter,
# iOS Simulator, Chrome, ffmpeg, iMovie) are ready.
#
# Exit code 0 = all good, hit record.
# Exit code 1 = one or more critical checks failed — fix before recording.
#
# Usage:
#   bash scripts/pre_record_check.sh

set -uo pipefail
cd "$(dirname "$0")/.."

API="http://ec2-63-184-221-33.eu-central-1.compute.amazonaws.com"
USER1="congo_general"
USER2="lisbon_lion"
PASS="fanpitch2026"

# ─── Pretty-print helpers ─────────────────────────────────────────────
GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
RESET='\033[0m'

PASS_COUNT=0
FAIL_COUNT=0
WARN_COUNT=0

ok()    { echo -e "  ${GREEN}✓${RESET} $*"; PASS_COUNT=$((PASS_COUNT+1)); }
fail()  { echo -e "  ${RED}✗${RESET} $*"; FAIL_COUNT=$((FAIL_COUNT+1)); }
warn()  { echo -e "  ${YELLOW}⚠${RESET} $*"; WARN_COUNT=$((WARN_COUNT+1)); }
section() { echo -e "\n${BOLD}$*${RESET}"; }

require_cmd() {
  local cmd="$1"
  local hint="${2:-}"
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$cmd installed"
  else
    fail "$cmd not found${hint:+ — $hint}"
  fi
}

optional_cmd() {
  local cmd="$1"
  local hint="${2:-}"
  if command -v "$cmd" >/dev/null 2>&1; then
    ok "$cmd installed"
  else
    warn "$cmd not found${hint:+ — $hint}"
  fi
}

# ─── 1. Backend health ────────────────────────────────────────────────
section "1. Live AWS backend (eu-central-1)"

if HEALTH=$(curl -fsS --max-time 5 "$API/healthz" 2>/dev/null); then
  if echo "$HEALTH" | grep -q '"status": *"ok"'; then
    ok "API healthz returns ok: $HEALTH"
  else
    fail "API healthz returned unexpected: $HEALTH"
  fi
else
  fail "API unreachable at $API — abort, fix EC2 before recording"
fi

if SWAGGER=$(curl -fsS --max-time 5 -o /dev/null -w "%{http_code}" "$API/api/docs/" 2>/dev/null); then
  if [[ "$SWAGGER" == "200" ]]; then
    ok "Swagger UI live at $API/api/docs/"
  else
    warn "Swagger /api/docs/ returned HTTP $SWAGGER"
  fi
fi

# ─── 2. Auth flow for the 2 demo accounts ─────────────────────────────
section "2. Demo accounts ($USER1 and $USER2 with password 'fanpitch2026')"

check_login() {
  local username="$1"
  local response
  response=$(curl -fsS --max-time 5 -X POST "$API/api/v1/auth/login/" \
    -H "Content-Type: application/json" \
    -d "{\"username\":\"$username\",\"password\":\"$PASS\"}" 2>/dev/null) || {
    fail "login failed for $username (network or 401)"
    return 1
  }
  # JWT pair shape: { "access": "...", "refresh": "..." }
  if echo "$response" | grep -q '"access"'; then
    ok "$username logs in (JWT received)"
    return 0
  else
    fail "$username login response missing 'access' token: $response"
    return 1
  fi
}

check_login "$USER1"
check_login "$USER2"

# ─── 3. Match data sanity ─────────────────────────────────────────────
section "3. Match data — at least one LIVE and one UPCOMING"

# Use the user1 token for /matches/ list
TOKEN=$(curl -fsS --max-time 5 -X POST "$API/api/v1/auth/login/" \
  -H "Content-Type: application/json" \
  -d "{\"username\":\"$USER1\",\"password\":\"$PASS\"}" 2>/dev/null \
  | python3 -c "import sys,json; print(json.load(sys.stdin)['access'])" 2>/dev/null)

if [[ -n "$TOKEN" ]]; then
  MATCHES=$(curl -fsS --max-time 5 -H "Authorization: Bearer $TOKEN" "$API/api/v1/matches/" 2>/dev/null)
  LIVE_COUNT=$(echo "$MATCHES" | python3 -c "import sys,json; d=json.load(sys.stdin); items=d.get('results',d) if isinstance(d,dict) else d; print(sum(1 for m in items if m.get('status')=='LIVE'))" 2>/dev/null || echo "0")
  UPCOMING_COUNT=$(echo "$MATCHES" | python3 -c "import sys,json; d=json.load(sys.stdin); items=d.get('results',d) if isinstance(d,dict) else d; print(sum(1 for m in items if m.get('status')=='UPCOMING'))" 2>/dev/null || echo "0")
  FINISHED_COUNT=$(echo "$MATCHES" | python3 -c "import sys,json; d=json.load(sys.stdin); items=d.get('results',d) if isinstance(d,dict) else d; print(sum(1 for m in items if m.get('status')=='FINISHED'))" 2>/dev/null || echo "0")

  if [[ "$LIVE_COUNT" -gt 0 ]]; then
    ok "$LIVE_COUNT LIVE match(es) — the Match Hub Live tiles will populate"
  else
    warn "No LIVE matches — Live tab will only show the featured ARG vs FRA. SSH EC2 and run: python manage.py run_simulator --match-id 1 --speed 10"
  fi

  if [[ "$UPCOMING_COUNT" -gt 0 ]]; then
    ok "$UPCOMING_COUNT UPCOMING match(es) — Upcoming carousel will populate"
  else
    warn "No UPCOMING matches — reseed with: python manage.py seed_world_cup"
  fi

  if [[ "$FINISHED_COUNT" -gt 0 ]]; then
    ok "$FINISHED_COUNT FINISHED match(es) — standings + top scorers will compute"
  else
    warn "No FINISHED matches — standings table will be empty"
  fi
else
  fail "Could not extract JWT token to query matches"
fi

# ─── 4. Local Flutter ─────────────────────────────────────────────────
section "4. Local Flutter toolchain"

require_cmd flutter "brew install --cask flutter, or follow flutter.dev/docs/get-started"

if command -v flutter >/dev/null 2>&1; then
  if flutter doctor 2>&1 | grep -q "\[✓\] Flutter"; then
    ok "flutter doctor reports Flutter OK"
  else
    warn "flutter doctor has warnings — run 'flutter doctor -v' to inspect"
  fi
fi

# ─── 5. iOS Simulator ─────────────────────────────────────────────────
section "5. iOS Simulator (needed for the 2-phone shot)"

if command -v xcrun >/dev/null 2>&1; then
  if xcrun simctl list devices available 2>/dev/null | grep -q "iPhone 16"; then
    ok "iPhone 16 Simulator family available"
  else
    warn "iPhone 16 family not found — install via Xcode > Settings > Platforms"
  fi
  BOOTED=$(xcrun simctl list devices booted 2>/dev/null | grep -c "Booted" || echo "0")
  if [[ "$BOOTED" -gt 0 ]]; then
    ok "$BOOTED iOS Simulator(s) currently booted"
  else
    warn "No Simulator booted — open Simulator.app or run: xcrun simctl boot 'iPhone 16 Plus'"
  fi
else
  fail "xcrun not found — install Xcode from the App Store"
fi

# ─── 6. Recording tools ───────────────────────────────────────────────
section "6. Recording tools"

# QuickTime Player is bundled with macOS
if [[ -d "/System/Applications/QuickTime Player.app" ]] || [[ -d "/Applications/QuickTime Player.app" ]]; then
  ok "QuickTime Player available (for iPhone mirroring via USB)"
else
  warn "QuickTime Player not found — reinstall macOS or use Loom"
fi

# Screen Recording shortcut (Cmd+Shift+5) is built into macOS — assume OK
ok "macOS Screenshot tool available (Cmd+Shift+5 for screen recording)"

# Loom (optional)
if [[ -d "/Applications/Loom.app" ]]; then
  ok "Loom Desktop installed (easiest mp4 export at 720p)"
else
  warn "Loom not installed — optional. Get it at https://www.loom.com/download"
fi

# ─── 7. Video post-processing ─────────────────────────────────────────
section "7. Video post-processing (to enforce 720p mp4)"

if [[ -d "/Applications/iMovie.app" ]]; then
  ok "iMovie installed (File > Share > File > 720p)"
else
  warn "iMovie not installed — get it free from the App Store"
fi

optional_cmd ffmpeg "brew install ffmpeg — needed only if you want CLI conversion"

# ─── Summary ──────────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo -e "  ${GREEN}✓ $PASS_COUNT passed${RESET}   ${YELLOW}⚠ $WARN_COUNT warnings${RESET}   ${RED}✗ $FAIL_COUNT failures${RESET}"
echo -e "${BOLD}═══════════════════════════════════════════════════════════════${RESET}"

if [[ "$FAIL_COUNT" -gt 0 ]]; then
  echo ""
  echo -e "${RED}${BOLD}One or more critical checks failed.${RESET}"
  echo "Fix the failures above before recording. The warnings are softer —"
  echo "they won't stop you from recording, but they may degrade the demo."
  exit 1
fi

echo ""
echo -e "${GREEN}${BOLD}All critical checks passed. You're ready to record.${RESET}"
echo ""
echo "Next steps:"
echo "  1. Open Simulator.app and boot 'iPhone 16 Plus'"
echo "  2. Mirror your real iPhone via QuickTime > New Movie Recording"
echo "  3. Run the app:  bash scripts/run.sh prod"
echo "  4. Log in:       $USER1 (Simulator), $USER2 (iPhone) — password: $PASS"
echo "  5. Start macOS screen recording (⌘+Shift+5), follow deliverables/video_script.md"
echo ""
if [[ "$WARN_COUNT" -gt 0 ]]; then
  echo -e "${YELLOW}You have $WARN_COUNT warnings — review them above if anything matters for your shot.${RESET}"
fi
exit 0
