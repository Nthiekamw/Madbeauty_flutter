# Partage fiche prestataire (sans site web)

## Comportement

| Configuration | Lien partagé |
|---------------|--------------|
| Rien dans `.env` (Supabase OK) | `https://VOTRE_PROJECT.supabase.co/functions/v1/prestataire_share?prestataire_id=UUID` |
| `SHARE_BASE_URL=custom` | `com.madbeauty.madbeauty://prestataire/UUID` |
| `SHARE_BASE_URL=https://app.com` | `https://app.com/prestataire/UUID` (quand tu auras un site) |

Le lien Supabase ouvre une mini-page qui redirige vers l’app → même effet qu’un `https://app.com/prestataire/:id` sans héberger de site.

## Déployer la redirection (une fois)

```powershell
npx supabase functions deploy prestataire_share --no-verify-jwt --project-ref vjjasrdoyguqkftfhaei
```

## Lancer l’app

```powershell
flutter run --dart-define-from-file=.env
```

## Tester

### 1. Partage depuis l’app

1. Ouvre une fiche prestataire → **Partager**.
2. Envoie-toi le lien (SMS / WhatsApp).
3. Sur le téléphone : touche le lien → page Supabase → ouverture MadBeauty sur la fiche.

### 2. Deep link direct (émulateur / USB)

Remplace `UUID` par un vrai `prestataire_profiles.id` :

```powershell
adb shell am start -a android.intent.action.VIEW -d "com.madbeauty.madbeauty://prestataire/UUID"
```

### 3. Lien HTTPS Supabase (navigateur)

```text
https://vjjasrdoyguqkftfhaei.supabase.co/functions/v1/prestataire_share?prestataire_id=UUID
```

## Forcer le schéma app seul (pas de HTTPS)

Dans `.env` :

```env
SHARE_BASE_URL=custom
```
