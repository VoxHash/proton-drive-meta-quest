#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
bash -n "$ROOT"/scripts/*.sh
test -s "$ROOT/patches/0001-meta-quest-phone-email-auth.patch"
test -s "$ROOT/patches/0002-meta-quest-product-flavor.patch"
grep -q 'com.oculus.supportedDevices' "$ROOT/patches/0001-meta-quest-phone-email-auth.patch"
grep -q 'LoginTwoStepActivity' "$ROOT/patches/0001-meta-quest-phone-email-auth.patch"
grep -q 'applicationIdSuffix = ".quest"' "$ROOT/patches/0002-meta-quest-product-flavor.patch"
grep -q 'create("quest")' "$ROOT/patches/0002-meta-quest-product-flavor.patch"
grep -q 'assembleQuestDebug' "$ROOT/scripts/build-from-source.sh"
grep -q 'me.proton.android.drive.quest' "$ROOT/scripts/install-quest.sh"
grep -q 'me.proton.android.drive.quest' "$ROOT/scripts/proton-pkg.sh"
grep -q 'MainActivity' "$ROOT/scripts/launch-quest.sh"
grep -q 'db-drive' "$ROOT/scripts/e2e-postlogin.sh"
grep -q 'FileDownloadEntity' "$ROOT/scripts/e2e-postlogin.sh"
echo "OK: script syntax + phone/email + Quest flavor patches present"
