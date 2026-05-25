#!/usr/bin/env bash
# FanPitch — build an APK (or IPA) targeting a specific backend environment.
#
# Usage:
#   bash scripts/build.sh apk prod        # release APK pointing at AWS
#   bash scripts/build.sh apk staging     # APK pointing at staging
#   bash scripts/build.sh apk local       # APK pointing at localhost (useful only on emulator)
#   bash scripts/build.sh appbundle prod  # Play Store AAB
#   bash scripts/build.sh ipa prod        # iOS — needs Xcode signing config
#
# Output:
#   build/app/outputs/flutter-apk/app-release.apk       (APK)
#   build/app/outputs/bundle/release/app-release.aab    (AAB)
#   build/ios/ipa/*.ipa                                 (IPA)
#
# After build, the artifact is copied to dist/<env>/ with a versioned name.

set -euo pipefail
cd "$(dirname "$0")/.."

TARGET="${1:-apk}"
ENV="${2:-prod}"

# ─── Backend URLs per env ─────────────────────────────────────────────
case "$ENV" in
  local)
    # Note: localhost on a device APK only works on Android emulator (10.0.2.2).
    API="http://10.0.2.2:8000"
    WS="ws://10.0.2.2:8000"
    BUILD_ENV="local"
    ;;
  dev|staging|prod)
    API="http://ec2-63-184-221-33.eu-central-1.compute.amazonaws.com"
    WS="ws://ec2-63-184-221-33.eu-central-1.compute.amazonaws.com"
    BUILD_ENV="$ENV"
    ;;
  *)
    echo "Unknown env: $ENV"
    echo "Valid envs: local | dev | staging | prod"
    exit 1
    ;;
esac

VERSION=$(grep -E '^version:' pubspec.yaml | awk '{print $2}')
TS=$(date +%Y%m%d-%H%M)
echo "▶ Building $TARGET for $ENV — version $VERSION — $TS"
echo "  API_BASE  = $API"
echo "  BUILD_ENV = $BUILD_ENV"
echo ""

DIST="dist/$ENV"
mkdir -p "$DIST"

case "$TARGET" in
  apk)
    flutter build apk --release \
      --dart-define=API_BASE="$API" \
      --dart-define=WS_BASE="$WS" \
      --dart-define=BUILD_ENV="$BUILD_ENV"
    cp build/app/outputs/flutter-apk/app-release.apk \
       "$DIST/fanpitch-$VERSION-$ENV-$TS.apk"
    ;;
  appbundle)
    flutter build appbundle --release \
      --dart-define=API_BASE="$API" \
      --dart-define=WS_BASE="$WS" \
      --dart-define=BUILD_ENV="$BUILD_ENV"
    cp build/app/outputs/bundle/release/app-release.aab \
       "$DIST/fanpitch-$VERSION-$ENV-$TS.aab"
    ;;
  ipa)
    flutter build ipa --release \
      --dart-define=API_BASE="$API" \
      --dart-define=WS_BASE="$WS" \
      --dart-define=BUILD_ENV="$BUILD_ENV"
    cp build/ios/ipa/*.ipa "$DIST/fanpitch-$VERSION-$ENV-$TS.ipa"
    ;;
  *)
    echo "Unknown target: $TARGET"
    echo "Valid targets: apk | appbundle | ipa"
    exit 1
    ;;
esac

echo ""
echo "✓ Build done — $DIST/fanpitch-$VERSION-$ENV-$TS.${TARGET}"
echo "  Share that file with testers; it will hit:"
echo "    $API"
