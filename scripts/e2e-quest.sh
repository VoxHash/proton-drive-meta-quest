#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERIAL="$("$ROOT/scripts/quest-device.sh")"
PKG="${PROTON_PKG:-$("$ROOT/scripts/proton-pkg.sh" "$SERIAL")}"
OUT="$ROOT/downloads/e2e-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"

echo "== Device =="
adb -s "$SERIAL" shell getprop ro.product.model | tee "$OUT/model.txt"
adb -s "$SERIAL" shell getprop ro.product.device | tee "$OUT/device.txt"
adb -s "$SERIAL" shell getprop ro.product.manufacturer | tee "$OUT/manufacturer.txt"
echo "serial=$SERIAL" | tee "$OUT/serial.txt"

echo "== Package =="
adb -s "$SERIAL" shell pm path "$PKG" | tee "$OUT/package-path.txt"
adb -s "$SERIAL" shell dumpsys package "$PKG" | grep -E 'versionName|versionCode|targetSdk|minSdk' | head -20 | tee "$OUT/package-meta.txt"

echo "== Launch MainActivity / email login UI =="
"$ROOT/scripts/launch-quest.sh" | tee "$OUT/launch.txt"
sleep 8
pid="$(adb -s "$SERIAL" shell pidof "$PKG" || true)"
echo "pid=$pid" | tee "$OUT/pid.txt"
[[ -n "$pid" ]]

echo "== Top activity =="
adb -s "$SERIAL" shell dumpsys activity activities > "$OUT/activity-raw.txt"
grep -E 'proton\.android\.drive|topResumedActivity|MainActivity|AddAccount|Login' "$OUT/activity-raw.txt" | head -80 > "$OUT/activity.txt" || true
cat "$OUT/activity.txt"

if ! grep -Eq 'MainActivity|AddAccountActivity|LoginTwoStepActivity|LoginActivity' "$OUT/activity.txt"; then
  echo "FAIL: expected Drive MainActivity or core email auth activity." >&2
  exit 1
fi

echo "== logcat (Drive / Proton, last 200 lines matching) =="
adb -s "$SERIAL" logcat -d -t 400 | grep -iE 'proton|drive|me\.proton' | tail -200 | tee "$OUT/logcat-drive.txt" || true

echo "== Screenshot =="
adb -s "$SERIAL" exec-out screencap -p > "$OUT/screen.png" || true
ls -la "$OUT/screen.png" 2>/dev/null || true

echo "== UI dump =="
adb -s "$SERIAL" shell uiautomator dump /sdcard/drive-ui.xml >/dev/null 2>&1 || true
adb -s "$SERIAL" pull /sdcard/drive-ui.xml "$OUT/ui.xml" >/dev/null 2>&1 || true
if [[ -f "$OUT/ui.xml" ]]; then
  grep -oE 'text="[^"]+"' "$OUT/ui.xml" | head -80 | tee "$OUT/ui-texts.txt" || true
fi

echo "E2E artifacts: $OUT"
echo "OK: package installed, launched, Drive/auth activity present."
