# Usage

1. Launch Proton Drive from the Quest library (or `./scripts/launch-quest.sh`).
2. Sign in with Proton email/password (SRP). Complete 2FA on-device if prompted.
3. Browse My files / shares.
4. Open or download files in the headset UI.
5. Uploads: use the app’s share/picker flows where Horizon allows, or run `./scripts/e2e-postlogin.sh` after login for an unattended FileProvider + `drive://` upload probe.
6. If password symbols fail, focus the password field and run `PROTON_PASSWORD='…' ./scripts/quest-enter-password.sh`.
