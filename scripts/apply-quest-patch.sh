#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
cd "$ROOT/android-drive"

AUTH_PATCH="$ROOT/patches/0001-meta-quest-phone-email-auth.patch"
FLAVOR_PATCH="$ROOT/patches/0002-meta-quest-product-flavor.patch"
UPLOAD_PATCH="$ROOT/patches/0003-quest-unattended-upload-autostart.patch"

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

if grep -q 'autoUploadStarted' \
  app/src/main/kotlin/me/proton/android/drive/ui/viewmodel/UploadToViewModel.kt && \
  grep -q 'getMainShare(userId).toResult()' \
  app/src/main/kotlin/me/proton/android/drive/usecase/ProcessIntent.kt; then
  echo "Quest unattended upload autostart patch already present."
else
  patch -p1 < "$UPLOAD_PATCH"
  echo "Applied $UPLOAD_PATCH"
fi
