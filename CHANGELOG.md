# Changelog

## 1.1.0 — 2026-10-05

### Added

- `scripts/e2e-postlogin.sh` — authenticated Quest browse/download/upload verification via Drive DB + logcat (Horizon screencap/uiautomator often blank) (`73896a9`, `a855f4a`)
- Patch `0003-quest-unattended-upload-autostart.patch` — UploadTo autostart when deeplink presets parent folder; ProcessIntent presets My files for SEND and accepts cold-start `drive://` VIEW (`a855f4a`)
- Unattended upload path: stage files into app `cache/tmp` + FileProvider `cache_tmp` (Quest `/sdcard` is unreadable to the app), then cold-start `drive://proton.me/upload/...` (`a855f4a`)

### Changed

- Roadmap: auth / browse / download / unattended upload e2e marked done; remaining items scoped to SSO docs, CI APK artifacts, and device-farm CI
- `.gitignore`: ignore all local `downloads/` e2e dumps, build logs, and verdict files
- CI / `tests/test_scripts.sh`: assert patch `0003` presence alongside `0001`/`0002`

### Fixed

- Documented edge cases: no Quest in `adb devices` (exit 1 from `quest-device.sh`), offline wireless stubs, non-writable `/opt/android-sdk` vs `~/Android/Sdk`, JDK 17 requirement for Gradle

## 1.0.0 — 2026-10-03

### Added

- Initial Quest packaging for Proton Drive Android (GPL-3.0 upstream ProtonDriveApps/android-drive)
- Quest product flavor: `applicationIdSuffix` `.quest` → package `me.proton.android.drive.quest`
- Patch `0001-meta-quest-phone-email-auth.patch` — `com.oculus.supportedDevices`, landscape auth activities
- Patch `0002-meta-quest-product-flavor.patch` — Gradle `quest` flavor / `assembleQuestDebug`
- Install, launch, and e2e scripts for Meta Quest 3 (`eureka`)
- Documentation kit (README, docs/, issue & PR templates, SECURITY/SUPPORT)
