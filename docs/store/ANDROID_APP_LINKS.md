# Android App Links — MadBeauty

Corrige l’erreur Play Console « Échec de la validation de domaine » pour `/prestataire`.

## Diagnostic (prod actuelle)

| Domaine | Problème |
|---------|----------|
| `madbeauty.app` | DNS ≠ Netlify ; `assetlinks.json` **injoignable** → Play échoue (retiré du Manifest) |
| `madbeauty.pro` | Catch-all SPA renvoyait du **HTML** au lieu du JSON |
| `madbeauty-app.netlify.app` | Idem SPA |

Prod partage : `SHARE_BASE_URL=https://madbeauty.pro`.

## 1. Empreinte SHA-256 (obligatoire)

Play Console → **Tester et publier** (ou **Configuration**) → **Intégrité de l’appli** → certificat **Signature d’appli** → copier **Empreinte du certificat SHA-256**.

Mettre à jour le fichier :

```powershell
powershell -File scripts/update_android_assetlinks.ps1 -Sha256 "AA:BB:CC:..."
```

Tu peux passer **plusieurs** empreintes (signature Play + clé d’upload) :

```powershell
powershell -File scripts/update_android_assetlinks.ps1 `
  -Sha256 "PLAY_APP_SIGNING_SHA256","UPLOAD_KEY_SHA256"
```

Fichier généré : `web/well-known/assetlinks.json`  
URL publique après deploy : `https://madbeauty.pro/.well-known/assetlinks.json`

## 2. Déployer le site web app

```powershell
powershell -File scripts/deploy_app_netlify.ps1
```

Vérifier :

1. Navigateur / `curl` : JSON brut, `Content-Type: application/json` (pas la page Flutter).
2. [Statement List Generator](https://developers.google.com/digital-asset-links/tools/generator) avec site `https://madbeauty.pro` et package `com.madbeauty.madbeauty`.

## 3. Nouvelle version Play

1. Build AAB signé (Manifest sans `madbeauty.app`).
2. Publier un correctif / nouvelle version.
3. Play revalide les domaines ; les utilisateurs doivent mettre à jour l’app.

## Fichiers concernés

| Fichier | Rôle |
|---------|------|
| `web/well-known/assetlinks.json` | Déclarations Digital Asset Links |
| `web/_redirects` | `/.well-known/*` → `/well-known/:splat` (contournement Netlify) |
| `web/_headers` | `Content-Type: application/json` |
| `android/.../AndroidManifest.xml` | `autoVerify` sur `madbeauty.pro` (+ Netlify legacy) |

## Réactiver `madbeauty.app` plus tard

Seulement si le domaine pointe vers le **même** site Netlify (ou sert le même `assetlinks.json`), puis rajouter l’`intent-filter` `host="madbeauty.app"` dans le Manifest.
