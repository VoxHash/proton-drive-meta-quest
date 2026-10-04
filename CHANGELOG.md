# Changelog

## Unreleased

- Add `scripts/e2e-postlogin.sh` for authenticated Quest browse/download/upload verification via Drive DB + logcat (Horizon screencap/uiautomator often blank)
- Patch `0003-quest-unattended-upload-autostart.patch` — UploadTo autostart when deeplink presets parent folder; ProcessIntent presets My files for SEND and accepts cold-start `drive://` VIEW
- E2E upload stages files into app `cache/tmp` + FileProvider `cache_tmp` (Quest `/sdcard` is unreadable to the app)

## 1.0.0 — 2026-10-03

- Initial Quest packaging for Proton Drive Android (GPL-3.0 upstream ProtonDriveApps/android-drive)
- Quest product flavor: `applicationIdSuffix` `.quest` → package `me.proton.android.drive.quest`
- Patch `0001-meta-quest-phone-email-auth.patch` — `com.oculus.supportedDevices`, landscape auth activities
- Patch `0002-meta-quest-product-flavor.patch` — Gradle `quest` flavor / `assembleQuestDebug`
- Install, launch, and e2e scripts for Meta Quest 3 (`eureka`)
- Documentation kit (README, docs/, issue & PR templates, SECURITY/SUPPORT)
