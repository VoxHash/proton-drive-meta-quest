# Support

- Docs: [docs/index.md](docs/index.md)
- Email: contact@voxhash.dev
- Upstream Proton Drive Android: https://github.com/ProtonDriveApps/android-drive

## Fresh-environment checklist

| Requirement | Notes |
| --- | --- |
| Meta Quest 3 (or Quest) with Developer Mode | `adb devices -l` must show state `device` (not `offline` / `unauthorized`) |
| JDK **17** | Set `JAVA_HOME` (default `~/.local/jvm/jdk-17.0.20.1+1`). System JDK 21+ often breaks Android Gradle. |
| Writable Android SDK | Prefer `~/Android/Sdk`. Non-writable `/opt/android-sdk` is skipped by `scripts/resolve-android-sdk.sh`. |
| Network | Clone https://github.com/ProtonDriveApps/android-drive; Gradle resolves Proton deps. |
| Optional tools for post-login e2e | `sqlite3`, `rg` (ripgrep), Python 3 (upload deeplink encoding) |

## Observed script behavior (edge cases)

| Situation | Behavior |
| --- | --- |
| No Quest with state `device` | `quest-device.sh` exits **1**, prints `adb devices -l`; install/e2e scripts fail immediately |
| Wireless ADB stubs `offline` | Treated as no device (same exit 1) until headset is awake/authorized |
| Missing APK path to `install-quest.sh` | Device check runs first; then `APK not found` if device is present |
| Horizon screencap / uiautomator blank | Expected for spatial panels — use `e2e-postlogin.sh` DB/logcat VERDICT |
| Quest `/sdcard` unreadable to app | Upload e2e stages under app `cache/tmp` + FileProvider `cache_tmp` |

See [docs/troubleshooting.md](docs/troubleshooting.md).
