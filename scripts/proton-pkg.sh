#!/usr/bin/env bash
set -euo pipefail
# Resolve installed Proton Drive package on device (prefer Quest flavor).
SERIAL="${1:-}"
if [[ -z "$SERIAL" ]]; then
  ROOT="$(cd "$(dirname "$0")/.." && pwd)"
  SERIAL="$("$ROOT/scripts/quest-device.sh")"
fi
for pkg in me.proton.android.drive.quest me.proton.android.drive; do
  if adb -s "$SERIAL" shell pm path "$pkg" >/dev/null 2>&1; then
    echo "$pkg"
    exit 0
  fi
done
echo "me.proton.android.drive.quest"
