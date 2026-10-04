#!/usr/bin/env bash
set -euo pipefail
# Prefer USB Quest 3 (eureka), then any Quest / wireless Quest
if [[ -n "${QUEST_SERIAL:-}" ]]; then
  echo "$QUEST_SERIAL"
  exit 0
fi

# adb may use tabs or spaces between serial and state
mapfile -t lines < <(adb devices -l | awk 'NR>1 && $2=="device" {print}')
for line in "${lines[@]}"; do
  if echo "$line" | grep -qiE 'model:Quest_3|product:eureka|device:eureka'; then
    echo "$line" | awk '{print $1}'
    exit 0
  fi
done
for line in "${lines[@]}"; do
  if echo "$line" | grep -qiE 'model:Quest|product:eureka|product:panther|product:hollywood|product:seacliff|product:monterey'; then
    echo "$line" | awk '{print $1}'
    exit 0
  fi
done
echo "No Meta Quest device found in: adb devices" >&2
adb devices -l >&2
exit 1
