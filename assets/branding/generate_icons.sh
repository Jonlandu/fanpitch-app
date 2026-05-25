#!/usr/bin/env bash
# FanPitch — generate all iOS + Android app icon sizes from app_icon.svg
#
# Prereqs:  brew install librsvg
# Usage:    bash assets/branding/generate_icons.sh
# Output:   ios/Runner/Assets.xcassets/AppIcon.appiconset/*.png
#           android/app/src/main/res/mipmap-*/ic_launcher.png

set -euo pipefail

cd "$(dirname "$0")/../.."   # repo root (fanpitch-app)
SRC="assets/branding/app_icon.svg"

if [[ ! -f $SRC ]]; then
  echo "✗ Missing $SRC" >&2
  exit 1
fi

if ! command -v rsvg-convert >/dev/null 2>&1; then
  echo "✗ rsvg-convert not found. Install with: brew install librsvg" >&2
  exit 1
fi

gen() { rsvg-convert -w "$1" -h "$1" "$SRC" -o "$2" && echo "  ✓ $2 (${1}px)"; }

echo "▶ Generating iOS app icons …"
IOS_DIR="ios/Runner/Assets.xcassets/AppIcon.appiconset"
mkdir -p "$IOS_DIR"

# Standard iPhone + iPad sizes, per the existing Contents.json
gen 40   "$IOS_DIR/Icon-App-20x20@2x.png"
gen 60   "$IOS_DIR/Icon-App-20x20@3x.png"
gen 20   "$IOS_DIR/Icon-App-20x20@1x.png"
gen 29   "$IOS_DIR/Icon-App-29x29@1x.png"
gen 58   "$IOS_DIR/Icon-App-29x29@2x.png"
gen 87   "$IOS_DIR/Icon-App-29x29@3x.png"
gen 40   "$IOS_DIR/Icon-App-40x40@1x.png"
gen 80   "$IOS_DIR/Icon-App-40x40@2x.png"
gen 120  "$IOS_DIR/Icon-App-40x40@3x.png"
gen 120  "$IOS_DIR/Icon-App-60x60@2x.png"
gen 180  "$IOS_DIR/Icon-App-60x60@3x.png"
gen 76   "$IOS_DIR/Icon-App-76x76@1x.png"
gen 152  "$IOS_DIR/Icon-App-76x76@2x.png"
gen 167  "$IOS_DIR/Icon-App-83.5x83.5@2x.png"
gen 1024 "$IOS_DIR/Icon-App-1024x1024@1x.png"

echo ""
echo "▶ Generating Android app icons …"
# bash 3.2 (macOS default) has no associative arrays — use parallel arrays.
ANDROID_DENSITIES=("mdpi" "hdpi" "xhdpi" "xxhdpi" "xxxhdpi")
ANDROID_SIZES=(48 72 96 144 192)
for i in "${!ANDROID_DENSITIES[@]}"; do
  DENSITY=${ANDROID_DENSITIES[$i]}
  SIZE=${ANDROID_SIZES[$i]}
  DIR="android/app/src/main/res/mipmap-$DENSITY"
  mkdir -p "$DIR"
  gen "$SIZE" "$DIR/ic_launcher.png"
done

echo ""
echo "▶ Generating Android adaptive-icon foreground (2× the launcher size) …"
for i in "${!ANDROID_DENSITIES[@]}"; do
  DENSITY=${ANDROID_DENSITIES[$i]}
  SIZE=$(( ${ANDROID_SIZES[$i]} * 2 ))
  DIR="android/app/src/main/res/mipmap-$DENSITY"
  gen "$SIZE" "$DIR/ic_launcher_foreground.png"
done

echo ""
echo "▶ Generating preview PNGs for README / pitch deck …"
mkdir -p assets/branding/previews
rsvg-convert -w 1024 -h 1024 assets/branding/app_icon.svg          -o assets/branding/previews/app_icon_1024.png
rsvg-convert -w 512  -h 512  assets/branding/logo_mark.svg         -o assets/branding/previews/logo_mark_512.png
rsvg-convert -w 1400 -h 400  assets/branding/logo_horizontal.svg   -o assets/branding/previews/logo_horizontal_1400.png
rsvg-convert -w 1400 -h 400  assets/branding/logo_horizontal_dark.svg -o assets/branding/previews/logo_horizontal_dark_1400.png
rsvg-convert -w 800  -h 1000 assets/branding/logo_stacked.svg      -o assets/branding/previews/logo_stacked_800.png
echo "  ✓ Previews → assets/branding/previews/"

echo ""
echo "✓ Done. iOS + Android icons regenerated from app_icon.svg."
echo "  Re-run this script after any tweak to the master SVG."
