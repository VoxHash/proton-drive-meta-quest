# Architecture

Modeled on Proton Pass for Meta Quest and VoxHash `protonvpn-meta-quest`: phone `MainActivity` + core email/SSO auth activities.

```
Quest library / adb
        │
        ▼
┌───────────────────────┐
│ Proton Drive (patched)│
│ MainActivity (phone)  │
│  └─ AddAccount/Login* │
│ Drive SDK + crypto    │
│  ├─ volumes / shares  │
│  ├─ list / download   │
│  └─ upload workers    │
│ → drive-api.proton.me │
└───────────────────────┘
```

Quest patches:

1. `patches/0001-meta-quest-phone-email-auth.patch` — `com.oculus.supportedDevices`; landscape + `adjustResize` on MainActivity and core auth activities.
2. `patches/0002-meta-quest-product-flavor.patch` — product flavor `quest` with `applicationIdSuffix = ".quest"`; Gradle target `assembleQuestDebug`.

Upstream crypto and Drive protocol remain inside the GPL Android sources — this repo does not reimplement SRP or OpenPGP.
