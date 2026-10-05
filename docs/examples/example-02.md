# Example 02 — E2E checklist

```bash
./scripts/e2e-quest.sh
# After login on headset:
./scripts/e2e-postlogin.sh
# Confirms MainActivity (not Login), Account/Volume/Link rows in db-drive,
# FileDownloadEntity and/or thumbnail.dec cache, and unattended upload via
# FileProvider cache_tmp + drive:// VIEW (patch 0003).
# Horizon screencap is often black — trust VERDICT.txt + db-browse-summary.txt.
ls downloads/e2e-postlogin-*/VERDICT.txt
```
