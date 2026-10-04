#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/android-drive"

AUTH_PATCH="$ROOT/patches/0001-meta-quest-phone-email-auth.patch"
FLAVOR_PATCH="$ROOT/patches/0002-meta-quest-product-flavor.patch"

if grep -q 'com.oculus.supportedDevices' app/src/main/AndroidManifest.xml && \
   grep -q 'LoginTwoStepActivity' app/src/main/AndroidManifest.xml && \
   grep -q 'android:screenOrientation="landscape"' app/src/main/AndroidManifest.xml; then
  echo "Quest phone/email auth patch already present."
else
  patch -p1 < "$AUTH_PATCH"
  echo "Applied $AUTH_PATCH"
fi

if grep -q 'create("quest")' app/build.gradle.kts && \
   grep -q 'applicationIdSuffix = ".quest"' app/build.gradle.kts; then
  echo "Quest product flavor patch already present."
else
  patch -p1 < "$FLAVOR_PATCH"
  echo "Applied $FLAVOR_PATCH"
fi
