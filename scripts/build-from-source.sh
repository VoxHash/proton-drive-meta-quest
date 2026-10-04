#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
# shellcheck source=resolve-android-sdk.sh
source "$ROOT/scripts/resolve-android-sdk.sh"
export JAVA_HOME="${JAVA_HOME:-$HOME/.local/jvm/jdk-17.0.20.1+1}"
export ANDROID_HOME="$(resolve_android_sdk)"
export ANDROID_SDK_ROOT="$ANDROID_HOME"
export PATH="$JAVA_HOME/bin:$PATH"

if [[ ! -d "$ROOT/android-drive/.git" ]]; then
  "$ROOT/scripts/fetch-android-drive.sh"
fi

cd "$ROOT/android-drive"
if [[ -f local.properties ]] && grep -qE '^sdk\.dir=.+' local.properties; then
  existing="$(sed -n 's/^sdk\.dir=//p' local.properties | head -1 | sed 's/\\:/:/g; s/\\\\/\\/g')"
  if ! _android_sdk_usable "$existing"; then
    write_local_properties_sdk local.properties "$ANDROID_HOME"
  fi
else
  write_local_properties_sdk local.properties "$ANDROID_HOME"
fi

"$ROOT/scripts/apply-quest-patch.sh"
echo "Building assembleQuestDebug (GPL Quest flavor + phone auth, applicationIdSuffix .quest) ..."
./gradlew --no-daemon assembleQuestDebug
APK="$(find app/build/outputs/apk -name '*quest*debug*.apk' | head -1)"
if [[ -z "$APK" || ! -f "$APK" ]]; then
  APK="$(find app/build/outputs/apk -path '*quest*' -name '*.apk' | head -1)"
fi
if [[ -z "$APK" || ! -f "$APK" ]]; then
  echo "Quest APK not found under app/build/outputs/apk" >&2
  find app/build/outputs/apk -type f -name '*.apk' 2>/dev/null || true
  exit 1
fi
echo "Built: $APK"
echo "$APK"
