#!/usr/bin/env bash
# FanPitch — push demo photos into iOS Simulator + Android Emulator galleries.
#
# Workflow:
#   1. On your Mac, download whatever photos you want to publish during the
#      demo (Google Images > right-click > Save). Save them in:
#         ~/Downloads/fanpitch_demo_photos/
#      Anything goes — jpg, png, webp. 5-10 photos is plenty.
#
#   2. Make sure both emulators are running (`bash scripts/launch_demo.sh`).
#
#   3. Run this script. It will:
#      - addmedia every image into the iOS Simulator Photos library
#      - adb push every image into the Android Emulator /sdcard/Pictures/
#      - trigger a media scan so the Gallery picks them up immediately
#
#   4. In FanPitch on either device:
#      Tap (+) New Post > Add image > the photos are at the top of the gallery.

set -o pipefail
cd "$(dirname "$0")/.."

PHOTOS_DIR="${1:-$HOME/Downloads/fanpitch_demo_photos}"
ADB=~/Library/Android/sdk/platform-tools/adb

GREEN='\033[0;32m'
RED='\033[0;31m'
YELLOW='\033[0;33m'
BOLD='\033[1m'
RESET='\033[0m'

ok()   { echo -e "  ${GREEN}✓${RESET} $*"; }
warn() { echo -e "  ${YELLOW}⚠${RESET} $*"; }
fail() { echo -e "  ${RED}✗${RESET} $*"; }

# ─── Sanity ───────────────────────────────────────────────────────────
if [[ ! -d "$PHOTOS_DIR" ]]; then
  echo -e "${RED}✗${RESET} Photos folder not found: $PHOTOS_DIR"
  echo ""
  echo "  Create it and drop a few jpg/png in there first:"
  echo "    mkdir -p $PHOTOS_DIR"
  echo "    # then download photos via Safari and save to that folder"
  exit 1
fi

# Find all images (bash 3-compatible — no mapfile)
PHOTOS=()
while IFS= read -r -d '' p; do
  PHOTOS+=("$p")
done < <(find "$PHOTOS_DIR" -maxdepth 1 -type f \
  \( -iname "*.jpg" -o -iname "*.jpeg" -o -iname "*.png" -o -iname "*.webp" -o -iname "*.heic" \) \
  -print0)

if [[ ${#PHOTOS[@]} -eq 0 ]]; then
  echo -e "${RED}✗${RESET} No images found in $PHOTOS_DIR"
  echo "  Drop some .jpg/.png in there, then re-run."
  exit 1
fi

echo -e "${BOLD}═══ Found ${#PHOTOS[@]} photo(s) in $PHOTOS_DIR ═══${RESET}"
for p in "${PHOTOS[@]}"; do echo "  - $(basename "$p")"; done

# ─── iOS Simulator ────────────────────────────────────────────────────
echo ""
echo -e "${BOLD}═══ iOS Simulator (booted) ═══${RESET}"
if xcrun simctl list devices booted 2>/dev/null | grep -q "Booted"; then
  for p in "${PHOTOS[@]}"; do
    if xcrun simctl addmedia booted "$p" 2>&1; then
      ok "Added: $(basename "$p")"
    else
      fail "iOS addmedia failed for $(basename "$p")"
    fi
  done
else
  warn "No iOS Simulator booted. Run: bash scripts/launch_demo.sh"
fi

# ─── Android Emulator ─────────────────────────────────────────────────
echo ""
echo -e "${BOLD}═══ Android Emulator (emulator-5554) ═══${RESET}"
if $ADB devices 2>/dev/null | grep -q "emulator-5554"; then
  for p in "${PHOTOS[@]}"; do
    fname=$(basename "$p")
    if $ADB push "$p" "/sdcard/Pictures/$fname" >/dev/null 2>&1; then
      # Trigger media scan so the Gallery / image picker sees the file
      $ADB shell am broadcast \
        -a android.intent.action.MEDIA_SCANNER_SCAN_FILE \
        -d "file:///sdcard/Pictures/$fname" >/dev/null 2>&1
      ok "Pushed: $fname"
    else
      fail "Android push failed for $fname"
    fi
  done
else
  warn "No Android emulator booted. Run: bash scripts/launch_demo.sh"
fi

echo ""
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo -e "${GREEN}${BOLD}  Done. Open FanPitch on either device:${RESET}"
echo -e "${GREEN}${BOLD}═══════════════════════════════════════════════════════════════${RESET}"
echo ""
echo "  1. Bottom nav → tap (+) or 'Nouvelle publication'"
echo "  2. Tap 'Ajouter une image' / 'Add image'"
echo "  3. Your photos are at the top of the gallery."
echo ""
echo "Re-run this script anytime you add more photos to:"
echo "  $PHOTOS_DIR"
