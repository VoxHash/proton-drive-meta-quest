# Roadmap

Unofficial Meta Quest packaging for Proton Drive Android (GPL). Keep milestones small and shippable.

## Done

- Phone / email login path on Quest 3 (Pass-style)
- `com.oculus.supportedDevices` + landscape auth activities
- Quest product flavor / `applicationIdSuffix` `.quest` (`me.proton.android.drive.quest`)
- Install + e2e scripts asserting Drive/auth UI
- Documentation kit (README, docs/, issue & PR templates, SECURITY/SUPPORT)

## Next

1. **SSO on Horizon** — document browser handoff / deep-link edge cases
2. **Upload UX on Quest** — exercise share-intent / picker paths after login
3. **CI APK artifacts** — optional upload of Quest APK when CI can assemble
4. **Device-farm e2e in CI** — wire `e2e-quest.sh` when Quest farm access exists

## Out of scope (for now)

- Play Store / App Lab distribution
- Reimplementing Proton Drive crypto outside the GPL Android app
- Closed-source binary reverse engineering
