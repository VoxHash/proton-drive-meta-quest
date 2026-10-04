#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERIAL="$("$ROOT/scripts/quest-device.sh")"
PKG="${PROTON_PKG:-$("$ROOT/scripts/proton-pkg.sh" "$SERIAL")}"
ACT=me.proton.android.drive.ui.MainActivity
adb -s "$SERIAL" shell input keyevent KEYCODE_WAKEUP || true
adb -s "$SERIAL" shell am force-stop "$PKG" || true
adb -s "$SERIAL" shell am start -a android.intent.action.MAIN \
  -c android.intent.category.LAUNCHER -n "$PKG/$ACT" | tee /tmp/protondrive-launch.out
echo "Launched $PKG/$ACT on $SERIAL"
