#!/usr/bin/env bash
# FanPitch — boot both emulators, install the app, launch it on both.
#
# Run this ~5 minutes BEFORE you start recording. It:
#   1. Boots the iOS Simulator (iPhone 16 Plus) if not already up
#   2. Boots the Android Emulator (Pixel_4a_Light_API35) if not up
#   3. Builds the app for both
#   4. Installs it on both
#   5. Launches it on both
#
# After this, both phones show the FanPitch splash → login. Manually log in:
#   iOS Simulator → congo_general / fanpitch2026
#   Android       → lisbon_lion   / fanpitch2026
#
# Then run scripts/feed_simulator.sh to start the live event stream.

set -uo pipefail
cd "$(dirname "$0")/.."

API="http://ec2-63-184-221-33.eu-central-1.compute.amazonaws.com"
WS="ws://ec2-63-184-221-33.eu-central-1.compute.amazonaws.com"
IOS_DEVICE="iPhone 16 Plus"
ANDROID_AVD="Pixel_4a_Light_API35"
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

# ─── 1. Boot iOS Simulator ────────────────────────────────────────────
step "1/6 · Boot iOS Simulator"
open -a Simulator
if xcrun simctl list devices booted 2>/dev/null | grep -q "$IOS_DEVICE"; then
  ok "$IOS_DEVICE already booted"
else
  xcrun simctl boot "$IOS_DEVICE" 2>/dev/null && ok "Booted $IOS_DEVICE" || warn "Boot returned non-zero (may already be booted)"
  echo "  Waiting for iOS Simulator to be ready..."
  xcrun simctl bootstatus "$IOS_DEVICE" -b >/dev/null 2>&1 && ok "iOS Simulator ready"
fi

# ─── 2. Boot Android Emulator ─────────────────────────────────────────
step "2/6 · Boot Android Emulator"
if $ADB devices 2>/dev/null | grep -q "emulator-5554"; then
  ok "Android emulator already booted"
else
  nohup "$EMU" -avd "$ANDROID_AVD" -no-snapshot-load -no-boot-anim \
    > /tmp/emulator.log 2>&1 &
  echo "  Booting $ANDROID_AVD (≈30s)..."
  for i in {1..40}; do
    sleep 2
    if $ADB devices 2>/dev/null | grep -q "emulator-5554"; then
      ok "Android emulator booted ($((i*2))s)"
      break
    fi
    [[ $i -eq 40 ]] && { fail "Android emulator did not boot in 80s. Check /tmp/emulator.log"; exit 1; }
  done
fi
# Wait for system services
$ADB wait-for-device
$ADB shell 'while [[ $(getprop sys.boot_completed) != 1 ]]; do sleep 1; done'
ok "Android device fully ready"

# ─── 3. Build for both ────────────────────────────────────────────────
step "3/6 · Build Android APK"
flutter build apk --debug \
  --dart-define=API_BASE="$API" \
  --dart-define=WS_BASE="$WS" \
  --dart-define=BUILD_ENV=prod 2>&1 | tail -5 || { fail "Android build failed"; exit 1; }
ok "APK at build/app/outputs/flutter-apk/app-debug.apk"

step "4/6 · Build iOS Simulator app"
flutter build ios --simulator --debug \
  --dart-define=API_BASE="$API" \
  --dart-define=WS_BASE="$WS" \
  --dart-define=BUILD_ENV=prod 2>&1 | tail -5 || { fail "iOS build failed"; exit 1; }
ok "App at build/ios/iphonesimulator/Runner.app"

# ─── 4. Install + launch ──────────────────────────────────────────────
step "5/6 · Install on both devices"
xcrun simctl install booted build/ios/iphonesimulator/Runner.app && ok "Installed on iOS"
$ADB install -r build/app/outputs/flutter-apk/app-debug.apk 2>&1 | tail -3 && ok "Installed on Android"

step "6/6 · Launch the app on both devices"
xcrun simctl launch booted "$APP_ID" >/dev/null && ok "Launched on iOS"
$ADB shell monkey -p "$APP_ID" -c android.intent.category.LAUNCHER 1 >/dev/null 2>&1 && ok "Launched on Android"

# ─── Summary ──────────────────────────────────────────────────────────
echo ""
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}${BOLD}  Both phones ready. Now log in:${RESET}"
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo ""
echo "  📱 iOS Simulator   → congo_general / fanpitch2026"
echo "  🤖 Android Emulator → lisbon_lion   / fanpitch2026"
echo ""
echo "Then arrange the two windows side by side on your screen for ScreenRec."
echo ""
echo "When you are READY to record, run:"
echo "  bash scripts/feed_simulator.sh"
echo "to push live match events into the room."
