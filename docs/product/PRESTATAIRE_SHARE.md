# Partage fiche prestataire

## Liens courts (recommandé)

Format partagé depuis l’app :

```text
https://madbeauty.pro/@vichy
```

Alias accepté : `https://madbeauty.pro/p/vichy`  
Ancien format (toujours valide) : `https://madbeauty.pro/prestataire/{uuid}`

Le `public_slug` est généré automatiquement depuis le nom affiché / salon
(ex. « Beauty Glow » → `beauty-glow`), unique, et reste stable.

## Configuration prod (`.env`)

```env
SHARE_BASE_URL=https://madbeauty.pro
```

| `SHARE_BASE_URL` | Lien partagé |
|------------------|--------------|
| `https://madbeauty.pro` (défaut) | `{base}/@slug` si slug connu, sinon `/prestataire/UUID` |
| `custom` | `com.madbeauty.madbeauty://@slug` |
| *(vide)* | même défaut prod `https://madbeauty.pro` |

## Comportement visiteur

- **Sans compte** : `/@slug` ou `/prestataire/:uuid` s’ouvre (mode invité).
- **Edge Function** `prestataire_share` : résout le slug et redirige vers `madbeauty.pro/@slug`.

## Déployer

```powershell
npx supabase db push
npx supabase functions deploy prestataire_share --no-verify-jwt --project-ref vjjasrdoyguqkftfhaei
```

Rebuild l’app avec les dart-defines (`.env`) pour que le share n’utilise plus l’URL Supabase longue :

```powershell
flutter run --dart-define-from-file=.env
# web :
powershell -File scripts/deploy_app_netlify.ps1
```

## Tester

1. Fiche prestataire → **Partager**.
2. Le lien doit ressembler à `https://madbeauty.pro/@…`.
3. Ouverture sans compte : fiche OK.
4. Ancien lien Supabase :
   `…/prestataire_share?prestataire_id=UUID` → redirige vers `/@slug`.

## App Links Android

Voir [../store/ANDROID_APP_LINKS.md](../store/ANDROID_APP_LINKS.md).
