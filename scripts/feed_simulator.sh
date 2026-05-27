#!/usr/bin/env bash
# FanPitch — start the live match feed on the AWS backend.
#
# This SSHs into the EC2 host and runs the match simulator inside the
# web container. The simulator emits MatchEvents (KICKOFF, GOAL, YELLOW,
# RED, HALFTIME, etc.) at 10× real-time speed, and pushes them through
# Django Channels → WebSocket → both phones in the Match Room.
#
# ─── WHEN to run this during recording ────────────────────────────────
#
# Run this LITERALLY 10 SECONDS BEFORE you tap RECORD on ScreenRec.
# The script counts down then starts the feed. By the time you reach the
# 1:30 beat of the video (the Match Hub / 2-phone WebSocket moment), an
# event has either just landed or is about to — both phones will jump.
#
# The simulator runs ~9 minutes of match in ~54 seconds at speed 10.
# Plenty of events will fire across your 3-min recording window.
#
# Press Ctrl+C anytime to stop the simulator.

set -uo pipefail
cd "$(dirname "$0")/.."

KEY=deploy/artifacts/fanpitch-sandbox-key.pem
HOST=ec2-user@ec2-63-184-221-33.eu-central-1.compute.amazonaws.com
MATCH_ID="${1:-1}"   # default match #1 (POR vs COD)
SPEED="${2:-10}"     # default speed 10x

# fanpitch-api lives next to fanpitch-app in your aws_academy folder
API_REPO_KEY=../fanpitch-api/deploy/artifacts/fanpitch-sandbox-key.pem
if [[ -f "$API_REPO_KEY" ]]; then
  KEY="$API_REPO_KEY"
fi

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
RESET='\033[0m'

if [[ ! -f "$KEY" ]]; then
  echo -e "${RED}✗${RESET} SSH key not found at $KEY"
  echo "  Looked at: $API_REPO_KEY"
  echo "  Make sure fanpitch-api repo is cloned next to fanpitch-app."
  exit 1
fi

# ─── Pre-flight ───────────────────────────────────────────────────────
echo -e "${BOLD}═══ Pre-flight ═══${RESET}"
if curl -fsS --max-time 5 http://ec2-63-184-221-33.eu-central-1.compute.amazonaws.com/healthz | grep -q '"status": *"ok"'; then
  echo -e "  ${GREEN}✓${RESET} EC2 backend healthy"
else
  echo -e "  ${RED}✗${RESET} EC2 backend unreachable. Abort."
  exit 1
fi

# ─── Countdown ────────────────────────────────────────────────────────
echo ""
echo -e "${YELLOW}${BOLD}═══ Recording starts in 10 seconds — get your finger on the record button ═══${RESET}"
for i in 10 9 8 7 6 5 4 3 2 1; do
  printf "  ${BOLD}%2d${RESET} — " $i
  case $i in
    10) echo "Make sure ScreenRec window is up";;
    8)  echo "Both emulators visible side by side?";;
    6)  echo "Both logged in?";;
    5)  echo "Tap RECORD on ScreenRec NOW";;
    3)  echo "Match simulator starting in 3...";;
    2)  echo "2...";;
    1)  echo "1... GO";;
    *)  echo;;
  esac
  sleep 1
done

# ─── Launch simulator on EC2 ──────────────────────────────────────────
echo ""
echo -e "${BOLD}═══ Pushing live events to match #$MATCH_ID at speed ${SPEED}× ═══${RESET}"
echo "  (Events stream below. Press Ctrl+C when recording is done.)"
echo ""

ssh -i "$KEY" -o StrictHostKeyChecking=no -t "$HOST" \
  "cd /home/ec2-user/fanpitch-api && \
   sudo docker compose -f docker-compose.prod.yml exec -T web \
   python manage.py run_simulator --match-id $MATCH_ID --speed $SPEED"
