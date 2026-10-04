#!/usr/bin/env bash
# Post-login Quest e2e: prove authenticated Drive browse + download activity.
# Horizon screencap/uiautomator often cannot see spatial panels — prefer DB + logcat.
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERIAL="$("$ROOT/scripts/quest-device.sh")"
PKG="${PROTON_PKG:-$("$ROOT/scripts/proton-pkg.sh" "$SERIAL")}"
OUT="$ROOT/downloads/e2e-postlogin-$(date +%Y%m%d-%H%M%S)"
mkdir -p "$OUT"

echo "== Device =="
adb -s "$SERIAL" shell getprop ro.product.model | tee "$OUT/model.txt"
echo "serial=$SERIAL" | tee "$OUT/serial.txt"
echo "package=$PKG" | tee "$OUT/package.txt"

echo "== Launch MainActivity =="
adb -s "$SERIAL" shell input keyevent KEYCODE_WAKEUP || true
adb -s "$SERIAL" shell am start -a android.intent.action.MAIN \
  -c android.intent.category.LAUNCHER \
  -n "$PKG/me.proton.android.drive.ui.MainActivity" | tee "$OUT/launch.txt"
sleep 5

echo "== Activity (must be MainActivity, not Login) =="
adb -s "$SERIAL" shell dumpsys activity activities > "$OUT/activity-raw.txt"
rg -n 'drive\.quest|topResumedActivity|Login|AddAccount|MainActivity' "$OUT/activity-raw.txt" \
  | head -80 | tee "$OUT/activity.txt"
if grep -Eq 'LoginActivity|AddAccountActivity|LoginTwoStepActivity' "$OUT/activity.txt" \
  && ! grep -Eq 'me\.proton\.android\.drive\.ui\.MainActivity' "$OUT/activity.txt"; then
  echo "FAIL: still on auth UI; sign in on the headset first." >&2
  exit 1
fi
if ! grep -Eq 'me\.proton\.android\.drive\.ui\.MainActivity' "$OUT/activity.txt"; then
  echo "FAIL: Drive MainActivity not present." >&2
  exit 1
fi

echo "== Authenticated API / volumes (logcat) =="
adb -s "$SERIAL" logcat -d -t 600 \
  | rg -i 'drive-api\.proton\.me|EventManager.*Volume|Block downloader|zrh-storage|/storage/blocks' \
  | tee "$OUT/logcat-drive.txt" | tail -80 || true
if ! rg -q 'drive-api\.proton\.me|EventManager.*Volume' "$OUT/logcat-drive.txt"; then
  echo "WARN: no recent drive-api/volume lines in logcat window; continuing with DB checks."
fi

echo "== Local Drive DB browse summary =="
adb -s "$SERIAL" shell "run-as $PKG cat databases/db-drive" > "$OUT/db-drive.sqlite"
sqlite3 "$OUT/db-drive.sqlite" <<'SQL' | tee "$OUT/db-browse-summary.txt"
.mode line
SELECT COUNT(*) AS accounts FROM AccountEntity;
SELECT COUNT(*) AS volumes FROM VolumeEntity;
SELECT COUNT(*) AS shares FROM ShareEntity;
SELECT COUNT(*) AS links FROM LinkEntity;
SELECT type, COUNT(*) AS n FROM LinkEntity GROUP BY type;
SELECT COUNT(*) AS file_props FROM LinkFilePropertiesEntity;
SELECT COUNT(*) AS file_downloads FROM FileDownloadEntity;
SELECT COUNT(*) AS uploads FROM LinkUploadEntity;
SQL
accounts="$(sqlite3 "$OUT/db-drive.sqlite" 'SELECT COUNT(*) FROM AccountEntity;')"
links="$(sqlite3 "$OUT/db-drive.sqlite" 'SELECT COUNT(*) FROM LinkEntity;')"
volumes="$(sqlite3 "$OUT/db-drive.sqlite" 'SELECT COUNT(*) FROM VolumeEntity;')"
[[ "$accounts" -ge 1 ]]
[[ "$volumes" -ge 1 ]]
[[ "$links" -ge 1 ]]

echo "== Download tmp / cache =="
adb -s "$SERIAL" shell "run-as $PKG sh -c 'du -sh files/tmp cache 2>/dev/null; find files/tmp -type f 2>/dev/null | head -20; find cache -name \"thumbnail*.dec\" 2>/dev/null | wc -l'" \
  | tee "$OUT/download-cache.txt"
downloads="$(sqlite3 "$OUT/db-drive.sqlite" 'SELECT COUNT(*) FROM FileDownloadEntity;')"
thumbs="$(adb -s "$SERIAL" shell "run-as $PKG sh -c 'find cache -name \"thumbnail*.dec\" 2>/dev/null | wc -l'" | tr -d '\r')"
if [[ "$downloads" -lt 1 && "${thumbs:-0}" -lt 1 ]]; then
  echo "WARN: no FileDownloadEntity and no thumbnail.dec yet — open a file/folder in the headset if needed."
fi

echo "== Screenshot (often black on Horizon panels) =="
adb -s "$SERIAL" exec-out screencap -p > "$OUT/screen.png" || true

echo "== Optional upload probe (may open system chooser; does not auto-confirm) =="
printf 'quest-e2e-upload %s\n' "$(date -Iseconds)" > /tmp/quest-drive-upload-test.txt
adb -s "$SERIAL" push /tmp/quest-drive-upload-test.txt /sdcard/Download/quest-drive-upload-test.txt \
  | tee "$OUT/upload-push.txt" || true
adb -s "$SERIAL" shell am start -a android.intent.action.SEND -t text/plain \
  --eu android.intent.extra.STREAM "file:///sdcard/Download/quest-drive-upload-test.txt" \
  -n "$PKG/me.proton.android.drive.ui.MainActivity" 2>&1 | tee "$OUT/upload-intent.txt" || true
sleep 3
adb -s "$SERIAL" shell "run-as $PKG cat databases/db-drive" > "$OUT/db-drive-after-upload.sqlite" || true
uploads="$(sqlite3 "$OUT/db-drive-after-upload.sqlite" 'SELECT COUNT(*) FROM LinkUploadEntity;' 2>/dev/null || echo 0)"
echo "LinkUploadEntity.count=$uploads" | tee "$OUT/upload-db-count.txt"

download_verdict="NEEDS_USER"
if [[ "$downloads" -ge 1 || "${thumbs:-0}" -ge 1 ]]; then
  download_verdict="PASS"
fi

cat > "$OUT/VERDICT.txt" <<EOF
AUTH: PASS (MainActivity; AccountEntity>=1)
BROWSE: PASS (volumes=$volumes links=$links)
DOWNLOAD: $download_verdict (FileDownloadEntity=$downloads thumbnails=$thumbs)
UPLOAD: NEEDS_USER (adb SEND cannot complete Horizon picker; LinkUploadEntity=$uploads)
SCREENSHOT: Horizon screencap often black for panels — use DB/logcat
ARTIFACTS: $OUT
EOF
cat "$OUT/VERDICT.txt"
echo "E2E post-login artifacts: $OUT"
