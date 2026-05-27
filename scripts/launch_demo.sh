#!/usr/bin/env bash
# FanPitch — boot TWO lightweight Android emulators, install the app, launch it.
#
# Why 2 Androids and not iPhone + Android?
#   The iPhone 16 Simulator on an 8 GB Mac is RAM-hungry and crashes mid-record.
#   Two Pixel_4a_Light AVDs (2 GB RAM each, arm64-native on Apple silicon) are
#   much lighter and leave headroom for VS Code + ScreenRec.
#
# Run this ~5 minutes BEFORE you start recording. It:
#   1. Boots emulator A (Pixel_4a_Light_API35   → emulator-5554)
#   2. Boots emulator B (Pixel_4a_Light_B_API35 → emulator-5556)
#   3. Waits for both to finish booting
#   4. Builds ONE release APK (no DEBUG banner in the video)
#   5. Installs on both
#   6. Launches the app on both
#
# After this, both phones show the FanPitch splash → login. Log in:
#   Phone A (emulator-5554) → congo_general / fanpitch2026
#   Phone B (emulator-5556) → lisbon_lion   / fanpitch2026
#
# Then run scripts/feed_simulator.sh to push live match events into the room.

set -uo pipefail
cd "$(dirname "$0")/.."

API="http://ec2-63-184-221-33.eu-central-1.compute.amazonaws.com"
WS="ws://ec2-63-184-221-33.eu-central-1.compute.amazonaws.com"
AVD_A="Pixel_4a_Light_API35"
AVD_B="Pixel_4a_Light_B_API35"
SERIAL_A="emulator-5554"
SERIAL_B="emulator-5556"
APP_ID="com.fanpitch.fanpitch"

ADB=~/Library/Android/sdk/platform-tools/adb
EMU=~/Library/Android/sdk/emulator/emulator

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
RESET='\033[0m'

step() { echo -e "\n${BOLD}═══ $* ═══${RESET}"; }
ok()   { echo -e "  ${GREEN}✓${RESET} $*"; }
warn() { echo -e "  ${YELLOW}⚠${RESET} $*"; }
fail() { echo -e "  ${RED}✗${RESET} $*"; }

# ─── Helpers ──────────────────────────────────────────────────────────
boot_avd() {
  local avd="$1" port="$2" serial="$3" logfile="$4"
  if $ADB devices 2>/dev/null | grep -q "^$serial"; then
    ok "$serial already booted"
    return 0
  fi
  nohup "$EMU" -avd "$avd" -port "$port" \
       -no-snapshot-load -no-boot-anim -no-audio \
       > "$logfile" 2>&1 &
  echo "  Booting $avd on $serial (≈45s)..."
  for i in {1..60}; do
    sleep 2
    if $ADB devices 2>/dev/null | grep -q "^$serial"; then
      ok "$serial visible in adb ($((i*2))s)"
      return 0
    fi
    [[ $i -eq 60 ]] && { fail "$avd did not boot in 120s. Check $logfile"; return 1; }
  done
}

wait_ready() {
  local serial="$1"
  $ADB -s "$serial" wait-for-device
  $ADB -s "$serial" shell 'while [[ $(getprop sys.boot_completed) != 1 ]]; do sleep 1; done'
  ok "$serial fully ready"
}

# ─── 1. Verify the second AVD exists ──────────────────────────────────
step "1/6 · Verify both AVDs exist"
if ! "$EMU" -list-avds 2>/dev/null | grep -qx "$AVD_A"; then
  fail "AVD $AVD_A missing. Open Android Studio → AVD Manager to create it."
  exit 1
fi
ok "Found $AVD_A"
if ! "$EMU" -list-avds 2>/dev/null | grep -qx "$AVD_B"; then
  fail "AVD $AVD_B missing. Run: bash scripts/launch_demo.sh first creates it,"
  echo "  or duplicate $AVD_A in ~/.android/avd/ → see scripts/launch_demo.sh comments."
  exit 1
fi
ok "Found $AVD_B"

# ─── 2. Boot both emulators in parallel ───────────────────────────────
step "2/6 · Boot both Android emulators"
boot_avd "$AVD_A" 5554 "$SERIAL_A" /tmp/emulator-A.log || exit 1
boot_avd "$AVD_B" 5556 "$SERIAL_B" /tmp/emulator-B.log || exit 1

# ─── 3. Wait for system services on both ──────────────────────────────
step "3/6 · Wait for Android system services"
wait_ready "$SERIAL_A"
wait_ready "$SERIAL_B"

# ─── 4. Build the release APK with PROD backend baked in ──────────────
# Always rebuild: dart-defines are baked at compile time, and mtime alone
# can't tell us whether the existing APK was built with the right backend.
# Better to spend ~3 min recompiling than to demo against the wrong server.
step "4/6 · Build release APK against PROD backend"
echo "  API → $API"
echo "  WS  → $WS"
APK=build/app/outputs/flutter-apk/app-release.apk
rm -f "$APK"
flutter build apk --release \
  --dart-define=API_BASE="$API" \
  --dart-define=WS_BASE="$WS" \
  --dart-define=BUILD_ENV=prod 2>&1 | tail -5 || { fail "APK build failed"; exit 1; }
[[ -f "$APK" ]] || { fail "APK not produced at $APK"; exit 1; }
ok "APK built at $APK (PROD)"

# ─── 5. Install on both ───────────────────────────────────────────────
step "5/6 · Install on both phones"
$ADB -s "$SERIAL_A" install -r "$APK" 2>&1 | tail -2 && ok "Installed on $SERIAL_A"
$ADB -s "$SERIAL_B" install -r "$APK" 2>&1 | tail -2 && ok "Installed on $SERIAL_B"

# ─── 6. Launch the app on both ────────────────────────────────────────
step "6/6 · Launch FanPitch on both phones"
$ADB -s "$SERIAL_A" shell monkey -p "$APP_ID" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 && ok "Launched on $SERIAL_A"
$ADB -s "$SERIAL_B" shell monkey -p "$APP_ID" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 && ok "Launched on $SERIAL_B"

# ─── Summary ──────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}${BOLD}  Both phones ready. Now log in:${RESET}"
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo ""
echo "  📱 Phone A ($SERIAL_A) → congo_general / fanpitch2026"
echo "  📱 Phone B ($SERIAL_B) → lisbon_lion   / fanpitch2026"
echo ""
echo "Arrange the two emulator windows side by side on your screen for ScreenRec."
echo ""
echo "When you are READY to record, run:"
echo "  bash scripts/feed_simulator.sh"
echo "to push live match events into the room."
