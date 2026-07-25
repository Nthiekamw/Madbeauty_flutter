# Partage fiche prestataire

## Configuration prod (`.env`)

```env
SHARE_BASE_URL=https://madbeauty.pro
```

L’app partage alors des liens du type :

`https://madbeauty.pro/prestataire/{uuid}`

| `SHARE_BASE_URL` | Lien partagé |
|------------------|--------------|
| `https://madbeauty.pro` | `{base}/prestataire/UUID` (recommandé prod) |
| *(vide, Supabase OK)* | Edge Function Supabase (fallback / anciens liens) |
| `custom` | `com.madbeauty.madbeauty://prestataire/UUID` |

## Comportement visiteur

- **Sans compte** : la fiche `/prestataire/:uuid` s’ouvre directement (mode invité activé pour permettre la réservation ensuite).
- **Edge Function** `prestataire_share` : redirige vers le lien web Netlify (+ lien « Ouvrir dans l’app »).

## Déployer la redirection Supabase (une fois)

```powershell
npx supabase functions deploy prestataire_share --no-verify-jwt --project-ref vjjasrdoyguqkftfhaei
```

`verify_jwt = false` est aussi défini dans `supabase/config.toml`.

## Build & déploiement app

```powershell
flutter run --dart-define-from-file=.env
# ou prod web :
powershell -File scripts/deploy_app_netlify.ps1
```

## Tester

### 1. Partage depuis l’app

1. Fiche prestataire → **Partager**.
2. Envoie-toi le lien (SMS / WhatsApp).
3. Le lien doit être `https://madbeauty.pro/prestataire/...`
4. Sans compte : la fiche s’affiche.

### 2. Deep link app (émulateur / USB)

```powershell
adb shell am start -a android.intent.action.VIEW -d "com.madbeauty.madbeauty://prestataire/UUID"
```

### 3. Ancien lien Supabase (compatibilité)

```text
https://vjjasrdoyguqkftfhaei.supabase.co/functions/v1/prestataire_share?prestataire_id=UUID
```

Doit rediriger vers Netlify sans erreur 401.

## Forcer le schéma app seul

```env
SHARE_BASE_URL=custom
```
