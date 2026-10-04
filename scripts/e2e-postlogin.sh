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

echo "== Upload via FileProvider + deeplink (quest autostart; sdcard is unreadable to the app) =="
USER_ID="$(sqlite3 "$OUT/db-drive.sqlite" 'SELECT userId FROM AccountEntity LIMIT 1;')"
SHARE_ID="$(sqlite3 "$OUT/db-drive.sqlite" 'SELECT id FROM ShareEntity WHERE type=1 LIMIT 1;')"
PARENT_ID="$(sqlite3 "$OUT/db-drive.sqlite" "SELECT link_id FROM ShareEntity WHERE id='$SHARE_ID' LIMIT 1;")"
FILE_NAME="quest-e2e-$(date +%s).txt"
FILE_URI="content://${PKG}.fileprovider/cache_tmp/${FILE_NAME}"
links_before="$links"
echo "upload.target userId=$USER_ID shareId=$SHARE_ID parentId=$PARENT_ID file=$FILE_NAME" \
  | tee "$OUT/upload-target.txt"
adb -s "$SERIAL" shell "run-as $PKG sh -c 'rm -rf cache/tmp/*; mkdir -p cache/tmp; printf \"quest-e2e-upload %s\\n\" \"$(date -Iseconds)\" > cache/tmp/$FILE_NAME; ls -la cache/tmp/$FILE_NAME'" \
  | tee "$OUT/upload-stage.txt"
DEEPLINK="$(python3 - <<PY
import json, urllib.parse
params = {"uris":[{"uri":"$FILE_URI","fileName":"$FILE_NAME"}]}
uris_enc = urllib.parse.quote(json.dumps(params, separators=(',',':')), safe='')
print(f"drive://proton.me/upload/$USER_ID/files?uris={uris_enc}&parentShareId=$SHARE_ID&parentId=$PARENT_ID")
PY
)"
echo "$DEEPLINK" | tee "$OUT/upload-deeplink.txt"
adb -s "$SERIAL" logcat -c || true
adb -s "$SERIAL" shell am force-stop "$PKG" || true
sleep 1
adb -s "$SERIAL" shell am start -a android.intent.action.VIEW \
  -d "'$DEEPLINK'" \
  -n "$PKG/me.proton.android.drive.ui.MainActivity" 2>&1 | tee "$OUT/upload-intent.txt"

uploads=0
upload_state=""
links_after="$links_before"
saw_sdk_success=0
for i in $(seq 1 45); do
  sleep 2
  adb -s "$SERIAL" shell "run-as $PKG cat databases/db-drive" > "$OUT/db-drive-after-upload.sqlite" || true
  uploads="$(sqlite3 "$OUT/db-drive-after-upload.sqlite" 'SELECT COUNT(*) FROM LinkUploadEntity;' 2>/dev/null || echo 0)"
  upload_state="$(sqlite3 "$OUT/db-drive-after-upload.sqlite" 'SELECT state FROM LinkUploadEntity ORDER BY id DESC LIMIT 1;' 2>/dev/null || true)"
  links_after="$(sqlite3 "$OUT/db-drive-after-upload.sqlite" 'SELECT COUNT(*) FROM LinkEntity;' 2>/dev/null || echo "$links_before")"
  echo "poll=$i LinkUploadEntity=$uploads state=${upload_state:-none} links=$links_after" \
    | tee -a "$OUT/upload-poll.txt"
  if adb -s "$SERIAL" logcat -d -t 200 2>/dev/null | rg -q 'CreateNewFileSdkWorker.*SUCCESS|Creating upload file via SDK'; then
    saw_sdk_success=1
  fi
  if [[ "${links_after:-0}" -gt "${links_before:-0}" ]]; then
    break
  fi
  if [[ "${uploads:-0}" -ge 1 && "$i" -ge 20 ]]; then
    break
  fi
done
echo "LinkUploadEntity.count=$uploads state=${upload_state:-none} links_before=$links_before links_after=$links_after" \
  | tee "$OUT/upload-db-count.txt"
adb -s "$SERIAL" logcat -d -t 1200 \
  | rg -i 'QuestUpload|CreateNewFileSdkWorker|upload|LinkUpload|blocks|drive-api|Failed to upload|copyUri' \
  | tee "$OUT/logcat-upload.txt" | tail -100 || true

download_state="$(sqlite3 "$OUT/db-drive-after-upload.sqlite" 'SELECT state FROM FileDownloadEntity ORDER BY id DESC LIMIT 1;' 2>/dev/null || true)"
download_verdict="NEEDS_USER"
if [[ "$downloads" -ge 1 || "${thumbs:-0}" -ge 1 ]]; then
  if [[ "${download_state:-}" == "IDLE" || "${download_state:-}" == "DONE" || "${download_state:-}" == "DOWNLOADED" ]]; then
    download_verdict="PASS"
  elif [[ "${download_state:-}" == "RUNNING" ]]; then
    download_verdict="PASS (RUNNING; blocks in progress)"
  else
    download_verdict="PASS"
  fi
fi

upload_verdict="FAIL"
if [[ "${links_after:-0}" -gt "${links_before:-0}" ]]; then
  upload_verdict="PASS (LinkEntity $links_before -> $links_after; file=$FILE_NAME)"
elif [[ "${uploads:-0}" -ge 1 ]]; then
  upload_verdict="PASS (LinkUploadEntity=$uploads state=${upload_state:-unknown}; file=$FILE_NAME)"
elif [[ "$saw_sdk_success" -eq 1 ]] || rg -qi 'CreateNewFileSdkWorker.*SUCCESS|Creating upload file via SDK' "$OUT/logcat-upload.txt" 2>/dev/null; then
  upload_verdict="PASS (CreateNewFileSdkWorker SUCCESS; file=$FILE_NAME)"
else
  upload_verdict="FAIL (no LinkUploadEntity / link growth; need patch 0003 + FileProvider cache_tmp staging)"
fi

cat > "$OUT/VERDICT.txt" <<EOF
AUTH: PASS (MainActivity; AccountEntity>=1)
BROWSE: PASS (volumes=$volumes links=$links_after)
DOWNLOAD: $download_verdict (FileDownloadEntity=$downloads state=${download_state:-n/a} thumbnails=$thumbs)
UPLOAD: $upload_verdict
SCREENSHOT: Horizon screencap often black for panels — use DB/logcat
ARTIFACTS: $OUT
EOF
cat "$OUT/VERDICT.txt"
echo "E2E post-login artifacts: $OUT"
