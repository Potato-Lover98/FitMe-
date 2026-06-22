#!/bin/bash
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
ICON="$ROOT/icon.png"

IOS_ASSETS="$ROOT/FitMeApp/Resources/Assets.xcassets/AppIcon.appiconset"
WATCH_ASSETS="$ROOT/FitMeWatch/Resources/Assets.xcassets/AppIcon.appiconset"

mkdir -p "$IOS_ASSETS" "$WATCH_ASSETS"

gen() {
  local size=$1
  local output=$2
  convert "$ICON" \
    -resize "${size}x${size}^" \
    -gravity center \
    -extent "${size}x${size}" \
    "$output"
}

round() {
  printf "%.0f" "$1"
}

echo "--- iOS App Icon ---"
gen 1024 "$IOS_ASSETS/icon-1024.png"
gen 180  "$IOS_ASSETS/icon-180.png"
gen 167  "$IOS_ASSETS/icon-167.png"
gen 152  "$IOS_ASSETS/icon-152.png"
gen 120  "$IOS_ASSETS/icon-120.png"
gen 87   "$IOS_ASSETS/icon-87.png"
gen 80   "$IOS_ASSETS/icon-80.png"
gen 60   "$IOS_ASSETS/icon-60.png"
gen 58   "$IOS_ASSETS/icon-58.png"
gen 40   "$IOS_ASSETS/icon-40.png"

echo "--- watchOS App Icon ---"
gen 1024 "$WATCH_ASSETS/icon-1024.png"
for px in 48 55 58 60 64 66 80 88 92 100 102 108 112 116 120 128 136 152 160 168 172 196 204 216 234 240 264 288 300 344 392 432 468 516; do
  gen $px "$WATCH_ASSETS/icon-${px}.png"
done

echo "Done. Icons generated."