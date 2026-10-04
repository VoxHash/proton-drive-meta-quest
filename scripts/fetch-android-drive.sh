#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
TARGET="$ROOT/android-drive"
if [[ -d "$TARGET/.git" ]]; then
  echo "android-drive already present"
  exit 0
fi
GIT_LFS_SKIP_SMUDGE=1 git -c filter.lfs.smudge= -c filter.lfs.process= -c filter.lfs.required=false \
  clone --depth 1 https://github.com/ProtonDriveApps/android-drive.git "$TARGET"
# shellcheck source=resolve-android-sdk.sh
source "$ROOT/scripts/resolve-android-sdk.sh"
export ANDROID_HOME="$(resolve_android_sdk)"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
write_local_properties_sdk "$TARGET/local.properties" "$ANDROID_HOME"
"$ROOT/scripts/apply-quest-patch.sh"
