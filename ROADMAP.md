# Roadmap

Unofficial Meta Quest packaging for Proton Drive Android (GPL). Keep milestones small and shippable.

## Done

- Phone / email login path on Quest 3 (Pass-style)
- `com.oculus.supportedDevices` + landscape auth activities
- Quest product flavor / `applicationIdSuffix` `.quest` (`me.proton.android.drive.quest`)
- Install + launch e2e (`e2e-quest.sh`) asserting Drive/auth UI
- Post-login e2e: authenticated browse + download evidence via `db-drive` / logcat (`e2e-postlogin.sh`)
- Unattended upload e2e via FileProvider `cache_tmp` + `drive://` VIEW deeplink (patch `0003`)
- Documentation kit (README, docs/, issue & PR templates, SECURITY/SUPPORT)
- GitHub Release with Quest debug APK asset (when built locally)

## Next

1. **SSO on Horizon** — document browser handoff / deep-link edge cases for accounts that do not use password login
2. **CI APK artifacts** — optional upload of Quest APK when CI runners can assemble `assembleQuestDebug` (needs JDK 17 + SDK + LFS/deps budget)
3. **Device-farm e2e in CI** — wire `e2e-quest.sh` / `e2e-postlogin.sh` when a Quest farm serial is available
4. **Share-intent / picker UX notes** — Horizon document picker often blocks adb `SEND`; keep FileProvider deeplink as the automated path and document manual picker steps for headset users

## Out of scope (for now)

- Play Store / App Lab distribution
- Reimplementing Proton Drive crypto outside the GPL Android app
- Closed-source binary reverse engineering
