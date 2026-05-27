#!/usr/bin/env bash
# FanPitch — push demo photos into BOTH Android Emulator galleries.
#
# Workflow:
#   1. On your Mac, download whatever photos you want to publish during the
#      demo (Google Images > right-click > Save). Save them in:
#         ~/Downloads/fanpitch_demo_photos/
#      Anything goes — jpg, png, webp. 5-10 photos is plenty.
#
#   2. Make sure both Android emulators are running:
#        bash scripts/launch_demo.sh
#
#   3. Run this script. It will adb push every image to /sdcard/Pictures/ on
#      both emulator-5554 and emulator-5556, then trigger a media scan so the
#      Gallery / image picker sees them immediately.
#
#   4. In FanPitch on either phone:
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

# ─── Push to both Android emulators ───────────────────────────────────
push_to() {
  local serial="$1"
  echo ""
  echo -e "${BOLD}═══ Android Emulator ($serial) ═══${RESET}"
  if ! $ADB devices 2>/dev/null | grep -q "^$serial"; then
    warn "$serial not booted. Run: bash scripts/launch_demo.sh"
    return 0
  fi
  for p in "${PHOTOS[@]}"; do
    fname=$(basename "$p")
    if $ADB -s "$serial" push "$p" "/sdcard/Pictures/$fname" >/dev/null 2>&1; then
      $ADB -s "$serial" shell am broadcast \
        -a android.intent.action.MEDIA_SCANNER_SCAN_FILE \
        -d "file:///sdcard/Pictures/$fname" >/dev/null 2>&1
      ok "Pushed: $fname"
    else
      fail "Push failed for $fname on $serial"
    fi
  done
}

push_to emulator-5554
push_to emulator-5556

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
