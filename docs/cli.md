# CLI (scripts)

| Script | Purpose |
| --- | --- |
| `scripts/fetch-android-drive.sh` | Shallow-clone GPL upstream |
| `scripts/apply-quest-patch.sh` | Apply Quest patches |
| `scripts/build-from-source.sh` | `assembleQuestDebug` |
| `scripts/install-quest.sh` | Build (optional) + adb install + launch |
| `scripts/launch-quest.sh` | Start MainActivity |
| `scripts/e2e-quest.sh` | Device checks, logcat, screenshot |
| `scripts/e2e-postlogin.sh` | After sign-in: MainActivity + Drive DB browse/download evidence |
| `scripts/quest-device.sh` | Resolve Quest serial |
| `scripts/quest-enter-password.sh` | Type password via adb |
| `scripts/proton-pkg.sh` | Resolve installed package id |

Desktop Proton Drive CLI (`proton-drive`) is separate — see VoxHash `proton-drive-desktop`.
