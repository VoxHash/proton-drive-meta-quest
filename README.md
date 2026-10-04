# Proton Drive for Meta Quest

[![License: GPL-3.0](https://img.shields.io/badge/license-GPL--3.0-blue.svg)](LICENSE)
[![Platform](https://img.shields.io/badge/platform-Meta%20Quest%203-lightgrey.svg)](#installation)
[![Upstream](https://img.shields.io/badge/upstream-ProtonDriveApps%2Fandroid--drive-6d4aff.svg)](https://github.com/ProtonDriveApps/android-drive)
[![CI](https://img.shields.io/github/actions/workflow/status/VoxHash/proton-drive-meta-quest/ci.yml?branch=main&label=CI)](https://github.com/VoxHash/proton-drive-meta-quest/actions)

Unofficial Meta Quest packaging for **Proton’s official open-source Android Drive app** ([ProtonDriveApps/android-drive](https://github.com/ProtonDriveApps/android-drive), GPL-3.0). Quest has no Play Store Proton Drive listing; this project applies a small Meta Quest patch so the app opens the **phone email/password (and SSO) sign-in** flow — the same approach [Proton Pass](https://github.com/protonpass/android-pass) and [protonvpn-meta-quest](https://github.com/VoxHash/protonvpn-meta-quest) use on Horizon OS.

Not affiliated with Proton AG or Meta Platforms. Proton Drive is a trademark of Proton AG.

## Features

- Builds Proton Drive from source (GPL) with Meta Quest patches
- Quest product flavor (`me.proton.android.drive.quest`, Pass-style `applicationIdSuffix`)
- Production Proton endpoints (`proton.me` / `drive-api`)
- Declares `com.oculus.supportedDevices` and landscape auth activities for headset keyboard
- Real-device e2e script against connected Quest 3
- Core Drive flows from upstream: Proton SRP auth, encrypted volume/share browse, download, upload

## Quick start

```bash
# Developer Mode enabled on Quest; adb devices shows Quest 3
# Requires JDK 17 + Android SDK (see Configuration)
./scripts/install-quest.sh
./scripts/e2e-quest.sh
```

In the headset: sign in with Proton **email and password**. If you get “incorrect password” despite a known-good account, Horizon’s keyboard likely mangled symbols — focus the password field and run `PROTON_PASSWORD='…' ./scripts/quest-enter-password.sh` from this PC.

## Installation

### One-shot (recommended — patched open-source build)

```bash
./scripts/install-quest.sh
```

This applies the Quest patches, builds `assembleQuestDebug` (`applicationIdSuffix` `.quest`), installs `me.proton.android.drive.quest` on the Quest, and launches `MainActivity` → email auth (`AddAccountActivity` / `LoginTwoStepActivity`).

### Build only

```bash
./scripts/build-from-source.sh
```

## How it works (architecture)

Proton Drive Android core (unchanged logic from GPL upstream):

1. **Auth** — Proton account email/password + SRP / SSO via `me.proton.core.auth`
2. **Drive SDK** — volumes, shares, encrypted links (`me.proton.drive` / Drive modules)
3. **Crypto** — OpenPGP / Drive crypto in-process (gopenpgp + Drive crypto usecases)
4. **Transfers** — download / upload workers and DocumentsProvider

Quest adaptation (modeled on Proton Pass / protonvpn-meta-quest):

| Horizon OS fact | Adaptation |
| --- | --- |
| Store listing missing | Sideload GPL build with Quest flavor |
| Auth panels need landscape keyboard | Landscape + `adjustResize` on core auth activities |
| Pass ships `com.oculus.supportedDevices` | Same metadata: `quest2\|questpro\|quest3\|quest3s` |
| Package id collision with Play | `applicationIdSuffix` `.quest` → `me.proton.android.drive.quest` |

Local desktop reference ([proton-drive-desktop](https://github.com/VoxHash/proton-drive-desktop)) wraps Proton’s official CLI; this Quest project instead packages the official Android Drive app itself.

## Configuration

| Variable / flag | Meaning |
| --- | --- |
| `QUEST_SERIAL` | Force ADB serial (otherwise auto-detects `eureka` / Quest 3) |
| `JAVA_HOME` | JDK 17 for from-source builds (default `~/.local/jvm/jdk-17.0.20.1+1`) |
| `ANDROID_HOME` | Android SDK root (writable; default `~/Android/Sdk`) |
| `PROTON_PKG` | Override package id for launch/e2e |

## Examples

- [Install and launch email login on Quest 3](docs/examples/example-01.md)
- [E2E checklist with browse/download](docs/examples/example-02.md)

## Roadmap

See [ROADMAP.md](ROADMAP.md).

## Contributing

See [CONTRIBUTING.md](CONTRIBUTING.md).

## License

GPL-3.0-or-later — same as [ProtonDriveApps/android-drive](https://github.com/ProtonDriveApps/android-drive). See [LICENSE](LICENSE).
