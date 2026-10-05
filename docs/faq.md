# FAQ

**Is this official Proton software?**  
No. It packages Proton’s GPL Android Drive sources with Quest patches. Not affiliated with Proton AG.

**Why GPL instead of MIT?**  
Upstream [android-drive](https://github.com/ProtonDriveApps/android-drive) is GPL-3.0; derivative packaging must remain GPL-compatible.

**Does this reverse-engineer Proton APKs?**  
No. Builds are from published open-source repositories only.

**How does this relate to proton-drive-desktop?**  
Desktop wraps Proton’s official CLI. Quest packages the official Android Drive app.

**Why does upload e2e avoid `/sdcard`?**  
On Quest the Drive app cannot read arbitrary sdcard paths for this flow; e2e stages files under the app’s `cache/tmp` and exposes them via FileProvider `cache_tmp`.

**Why is screencap black?**  
Horizon spatial panels often do not appear in `screencap` / uiautomator dumps. Prefer Drive DB + logcat VERDICT files.
