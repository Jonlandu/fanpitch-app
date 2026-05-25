#!/usr/bin/env bash
# FanPitch — run the Flutter app against a specific backend environment.
#
# Usage:
#   bash scripts/run.sh local           # localhost:8000 (iOS sim / web / desktop)
#   bash scripts/run.sh lan             # http://192.168.1.77:8000 (physical device)
#   bash scripts/run.sh prod            # AWS EC2 (the live sandbox backend)
#
#   bash scripts/run.sh prod android    # second arg = device id substring
#   bash scripts/run.sh prod "iPhone 15"
#
# Defaults: env=local, device=first available

set -euo pipefail
cd "$(dirname "$0")/.."

ENV="${1:-local}"
DEVICE="${2:-}"

# ─── Backend URLs per env ─────────────────────────────────────────────
case "$ENV" in
  local)
    API="http://localhost:8000"
    WS="ws://localhost:8000"
    BUILD_ENV="local"
    ;;
  lan)
    # Edit this if your machine's LAN IP changes.
    HOST_IP=$(ipconfig getifaddr en0 2>/dev/null || ipconfig getifaddr en1 2>/dev/null || echo "192.168.1.77")
    API="http://${HOST_IP}:8000"
    WS="ws://${HOST_IP}:8000"
    BUILD_ENV="local"
    ;;
  dev|staging)
    # Sandbox budget = 1 EC2 only; dev/staging both alias to the live EC2.
    API="http://ec2-63-184-221-33.eu-central-1.compute.amazonaws.com"
    WS="ws://ec2-63-184-221-33.eu-central-1.compute.amazonaws.com"
    BUILD_ENV="$ENV"
    ;;
  prod)
    API="http://ec2-63-184-221-33.eu-central-1.compute.amazonaws.com"
    WS="ws://ec2-63-184-221-33.eu-central-1.compute.amazonaws.com"
    BUILD_ENV="prod"
    ;;
  *)
    echo "Unknown env: $ENV"
    echo "Valid envs: local | lan | dev | staging | prod"
    exit 1
    ;;
esac

echo "▶ Running Flutter against $ENV"
echo "  API_BASE   = $API"
echo "  WS_BASE    = $WS"
echo "  BUILD_ENV  = $BUILD_ENV"
echo ""

DEVICE_FLAG=""
[[ -n "$DEVICE" ]] && DEVICE_FLAG="-d \"$DEVICE\""

# shellcheck disable=SC2086
eval flutter run $DEVICE_FLAG \
  --dart-define=API_BASE="$API" \
  --dart-define=WS_BASE="$WS" \
  --dart-define=BUILD_ENV="$BUILD_ENV"
