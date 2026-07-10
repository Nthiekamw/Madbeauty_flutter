# Site vitrine MadBeauty (pages légales + présentation)

Hébergement statique Netlify, séparé de l’app Flutter (`madbeauty-app`).

## Pages

| URL | Contenu |
|-----|---------|
| `/` | Accueil — présentation de l’app |
| `/contact.html` | Contact & support |
| `/privacy.html` | Politique de confidentialité |
| `/child-safety.html` | Sécurité des enfants & droits des parents |
| `/cgu.html` | Conditions générales d’utilisation |
| `/mentions-legales.html` | Mentions légales |

## Déploiement Netlify (première fois)

1. Créer un **nouveau site** sur [Netlify](https://app.netlify.com) (ex. nom : `madbeauty` ou `madbeauty-web`).
2. Depuis la racine du dépôt :

```powershell
cd website
npx netlify-cli sites:create --name madbeauty-web
npx netlify-cli deploy --prod --dir=.
```

3. Noter l’URL fournie, par ex. **`https://madbeauty-web.netlify.app`**.

## Déploiements suivants

Depuis la racine du dépôt (recommandé — aligné sur la CI) :

```powershell
# .env : NETLIFY_WEBSITE_SITE_ID=<id site madbeauty-web>
powershell -File scripts/deploy_website_netlify.ps1
```

La CI GitHub (`deploy-website-netlify.yml`) se déclenche sur push `main` / `master` / `features/v2` si `website/**` change.

Manuel depuis `website/` :

```powershell
cd website
npx netlify-cli deploy --prod --dir=.
```

## URLs à renseigner après déploiement

- **App Store / Play Store — politique de confidentialité** : `https://TON-SITE.netlify.app/privacy.html`
- **Play Store — sécurité des enfants** : `https://TON-SITE.netlify.app/child-safety.html`
- **URL marketing** : `https://TON-SITE.netlify.app/`
- **Stripe (site entreprise)** : `https://TON-SITE.netlify.app/` ou fiche prestataire sur l’app web

Mettre à jour Flutter :

```powershell
flutter run --dart-define=PRIVACY_POLICY_URL=https://TON-SITE.netlify.app/privacy.html
```

Et dans GitHub Actions / Netlify app : variable `PRIVACY_POLICY_URL` si utilisée au build.

## Domaine personnalisé (optionnel)

Dans Netlify → Domain management → ajouter `madbeauty.app` ou autre, puis mettre à jour les liens ci-dessus.
