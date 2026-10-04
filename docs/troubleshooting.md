# Troubleshooting

| Symptom | Fix |
| --- | --- |
| `No Meta Quest device found` | Enable Developer Mode; `adb kill-server && adb devices -l`; set `QUEST_SERIAL` |
| Gradle cannot write SDK | Use writable `~/Android/Sdk` via `resolve-android-sdk.sh` |
| Wrong password on Quest | Horizon keyboard mangling — `PROTON_PASSWORD='…' ./scripts/quest-enter-password.sh` |
| 2FA stuck | Complete TOTP/U2F on headset; SSO may need PC browser assist |
| Build OOM | Ensure `org.gradle.jvmargs` memory; JDK 17 |
| App not in library | Confirm `com.oculus.supportedDevices` patch applied; reinstall Quest APK |
