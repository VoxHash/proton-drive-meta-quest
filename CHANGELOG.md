# Changelog

## Unreleased

- Add `scripts/e2e-postlogin.sh` for authenticated Quest browse/download verification via Drive DB + logcat (Horizon screencap/uiautomator often blank)

## 1.0.0 — 2026-10-03

- Initial Quest packaging for Proton Drive Android (GPL-3.0 upstream ProtonDriveApps/android-drive)
- Quest product flavor: `applicationIdSuffix` `.quest` → package `me.proton.android.drive.quest`
- Patch `0001-meta-quest-phone-email-auth.patch` — `com.oculus.supportedDevices`, landscape auth activities
- Patch `0002-meta-quest-product-flavor.patch` — Gradle `quest` flavor / `assembleQuestDebug`
- Install, launch, and e2e scripts for Meta Quest 3 (`eureka`)
- Documentation kit (README, docs/, issue & PR templates, SECURITY/SUPPORT)
