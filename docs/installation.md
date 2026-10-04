# Installation

## Prerequisites

- Meta Quest 3 with USB debugging authorized
- JDK 17 (`JAVA_HOME`, default `~/.local/jvm/jdk-17.0.20.1+1`)
- Android SDK with platform 36 / build-tools (writable SDK root)
- Network access to clone https://github.com/ProtonDriveApps/android-drive

## Install

```bash
./scripts/install-quest.sh
```

Optional: pass an existing APK path:

```bash
./scripts/install-quest.sh /path/to/ProtonDrive-*-quest-debug.apk
```

Package id: `me.proton.android.drive.quest`.
