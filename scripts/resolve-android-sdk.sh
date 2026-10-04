#!/usr/bin/env bash
# Resolve a writable Android SDK root for Gradle builds.
# Prefer ANDROID_HOME / ANDROID_SDK_ROOT when usable; never stick to a
# non-writable system install such as /opt/android-sdk when $HOME/Android/Sdk exists.
#
# Usage: source this file, then: export ANDROID_HOME="$(resolve_android_sdk)"

_android_sdk_usable() {
  local dir="$1"
  [[ -n "$dir" && -d "$dir" && -w "$dir" ]] || return 1
  [[ -d "$dir/platforms" || -d "$dir/build-tools" || -d "$dir/cmdline-tools" || -d "$dir/platform-tools" ]]
}

resolve_android_sdk() {
  local cand
  for cand in "${ANDROID_HOME:-}" "${ANDROID_SDK_ROOT:-}" "${HOME}/Android/Sdk"; do
    [[ -z "$cand" ]] && continue
    if _android_sdk_usable "$cand"; then
      printf '%s\n' "$cand"
      return 0
    fi
  done
  if [[ -d "${HOME}/Android/Sdk" ]]; then
    printf '%s\n' "${HOME}/Android/Sdk"
    return 0
  fi
  printf '%s\n' "${ANDROID_HOME:-${ANDROID_SDK_ROOT:-${HOME}/Android/Sdk}}"
  return 1
}

# Write sdk.dir into local.properties (Java properties escaping for : and \).
write_local_properties_sdk() {
  local props_file="$1"
  local sdk_dir="${2:-}"
  if [[ -z "$sdk_dir" ]]; then
    sdk_dir="$(resolve_android_sdk)"
  fi
  local escaped="${sdk_dir//\\/\\\\}"
  escaped="${escaped//:/\\:}"
  printf 'sdk.dir=%s\n' "$escaped" >"$props_file"
}
