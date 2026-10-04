#!/usr/bin/env bash
# Type a Proton password into the focused field on Quest via ADB.
# Horizon's on-headset keyboard often mangles symbols; Proton's API then
# returns Code 8002 WrongPassword even when the account password is correct.
#
# Usage (password is never printed):
#   1. On Quest: open Proton VPN → enter email → Continue → tap the password field
#   2. On PC:
#        PROTON_PASSWORD='your-password' ./scripts/quest-enter-password.sh
#      or:
#        ./scripts/quest-enter-password.sh   # prompts silently
#   3. Tap Continue / Sign in in the headset
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
SERIAL="$("$ROOT/scripts/quest-device.sh")"

if [[ -n "${PROTON_PASSWORD+x}" && -n "${PROTON_PASSWORD}" ]]; then
  PASS="$PROTON_PASSWORD"
else
  read -r -s -p "Proton password (input hidden): " PASS
  echo
fi

if [[ -z "$PASS" ]]; then
  echo "Empty password." >&2
  exit 1
fi

# adb "input text" treats spaces as %s and rejects many shell metacharacters.
# Send character-by-character with keyevents where needed is fragile; instead
# write to a temp file on device and use an app_process one-liner when possible.
# Fallback: percent-encode and input text for ASCII-safe passwords.

encode_for_input_text() {
  # Escape for `adb shell input text`: space→%s, and quote carefully.
  local s=$1
  s=${s//' '/'%s'}
  s=${s//'%'/'%25'}
  s=${s//'&'/'\%26'}
  s=${s//'<'/'\%3c'}
  s=${s//'>'/'\%3e'}
  s=${s//'|'/'\%7c'}
  s=${s//';'/'\%3b'}
  s=${s//'('/'\%28'}
  s=${s//')'/'\%29'}
  s=${s//'$'/'\%24'}
  s=${s//'\\'/'\\\\'}
  s=${s//'"'/'\"'}
  s=${s//"'"/"\\'"}
  printf '%s' "$s"
}

ENC="$(encode_for_input_text "$PASS")"
# Clear existing field (select-all + delete) then type
adb -s "$SERIAL" shell input keyevent KEYCODE_MOVE_END
adb -s "$SERIAL" shell input keyevent --longpress KEYCODE_DEL KEYCODE_DEL KEYCODE_DEL KEYCODE_DEL KEYCODE_DEL KEYCODE_DEL KEYCODE_DEL KEYCODE_DEL KEYCODE_DEL KEYCODE_DEL || true
# Prefer deleting a long run
for _ in $(seq 1 64); do
  adb -s "$SERIAL" shell input keyevent KEYCODE_DEL >/dev/null 2>&1 || true
done

adb -s "$SERIAL" shell input text "'$ENC'"
unset PASS ENC PROTON_PASSWORD
echo "Password typed into the focused field on $SERIAL."
echo "Tap Sign in / Continue in the headset. If it still fails, re-check the password on account.proton.me and watch for Caps Lock / layout."
