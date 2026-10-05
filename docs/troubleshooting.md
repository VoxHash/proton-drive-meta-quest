# Troubleshooting

| Symptom | Fix |
| --- | --- |
| `No Meta Quest device found` | Enable Developer Mode; wake headset; `adb kill-server && adb devices -l`; accept USB/wireless debug prompt; set `QUEST_SERIAL` to a serial with state `device` |
| Only `offline` entries in `adb devices` | Headset asleep, wrong Wi‑Fi, or stale wireless ADB — reconnect USB or `adb connect <ip>:5555` after authorizing |
| Gradle cannot write SDK | Use writable `~/Android/Sdk` via `scripts/resolve-android-sdk.sh` (non-writable `/opt/android-sdk` is skipped) |
| Wrong password on Quest | Horizon keyboard mangling — `PROTON_PASSWORD='…' ./scripts/quest-enter-password.sh` |
| 2FA stuck | Complete TOTP/U2F on headset; SSO may need PC browser assist |
| Build OOM / Gradle fails on JDK 27 | Ensure `JAVA_HOME` points at **JDK 17**; check `org.gradle.jvmargs` memory |
| App not in library | Confirm `com.oculus.supportedDevices` patch applied; reinstall Quest APK |
| `e2e-postlogin` fails on Login UI | Sign in on the headset first, then re-run |
| Upload via adb `SEND` stuck | Horizon picker often blocks automation — use FileProvider + `drive://` path in `e2e-postlogin.sh` (patch `0003`) |
| Screencap black / empty UI dump | Expected on Horizon spatial panels; trust `VERDICT.txt` + Drive DB summaries under `downloads/` |
