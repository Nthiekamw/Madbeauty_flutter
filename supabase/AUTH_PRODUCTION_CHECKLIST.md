# Authentification Supabase — checklist production

À valider dans le **Dashboard Supabase** (projet hébergé) et dans `supabase/config.toml` (dev local / référence).

## E-mail et mot de passe

- [ ] **Authentication → Providers → Email** : activé.
- [ ] **Confirm email** : activé en production (`auth.email.enable_confirmations = true`).
- [ ] **Minimum password length** : `8` (`auth.minimum_password_length = 8`).
- [ ] **Password requirements** : `letters_digits` (`auth.password_requirements = "letters_digits"`).
- [ ] SMTP configuré (SendGrid, Resend, etc.) — pas le serveur par défaut en prod.

## URLs de redirection

- [ ] **Authentication → URL Configuration → Site URL** : URL publique de l’app ou page web (pas `localhost` en prod).
- [ ] **Redirect URLs** (liste exacte) :
  - `com.madbeauty.madbeauty://login-callback` (valeur de `SUPABASE_EMAIL_REDIRECT_URL` dans `.env`)
  - URLs Stripe / abonnement si utilisées
- [ ] Deep link Android / iOS configuré pour le schéma `com.madbeauty.madbeauty`.

## Google OAuth

- [ ] **Authentication → Providers → Google** : activé.
- [ ] Client OAuth Web + Android (SHA-1/256) + iOS dans Google Cloud Console.
- [ ] Client ID / secret renseignés dans Supabase.
- [ ] Pour le natif mobile : le `serverClientId` dans `GoogleAuthService` correspond au client **Web** Google.

## Apple (Sign in with Apple)

- [ ] App ID `com.nthiekamw.madbeauty` : capability **Sign In with Apple** activée.
- [ ] **Authentication → Providers → Apple** : activé dans Supabase (Services ID, clé `.p8`, Team ID, Key ID).
- [ ] `ios/Runner/Runner.entitlements` : `com.apple.developer.applesignin` présent.
- [ ] Détail : `docs/IOS_APPLE_PUSH_SETUP.md`

## Notifications push iOS

- [ ] `flutterfire configure` → `GoogleService-Info.plist` dans `ios/Runner/`.
- [ ] Clé APNs uploadée dans Firebase Console (Cloud Messaging).
- [ ] Capabilities Xcode : Push Notifications + Remote notifications.
- [ ] `aps-environment` dans `Runner.entitlements` (`development` en dev, `production` en prod).
- [ ] Checklist complète : `docs/BOOKING_PUSH_NOTIFICATIONS.md` + `docs/IOS_APPLE_PUSH_SETUP.md`

## Rate limits

- [ ] **Authentication → Rate limits** : valeurs adaptées au trafic (inscription, reset MDP, e-mails).
- [ ] Référence locale : section `[auth.rate_limit]` dans `config.toml`.
- [ ] En cas d’abus : activer **CAPTCHA** (`[auth.captcha]`).

## Désactivé en production (recommandé)

- [ ] **Phone / SMS** : désactivé (`auth.sms.enable_signup = false`).
- [ ] **Firebase Auth third-party** : désactivé (`auth.third_party.firebase.enabled = false`) — Google passe par le provider Google natif Supabase, pas Firebase Phone.

## Application mobile

- [ ] `.env` : `SUPABASE_URL`, `SUPABASE_ANON_KEY`, `SUPABASE_EMAIL_REDIRECT_URL`.
- [ ] Ne pas embarquer de secrets serveur (mot de passe DB, service role) dans l’app.
- [ ] Lancer avec : `flutter run --dart-define-from-file=.env`

## Après déploiement

- [ ] Tester inscription e-mail → lien de confirmation → reprise wizard.
- [ ] Tester connexion Google (Android + iOS).
- [ ] Tester connexion Apple (iOS).
- [ ] Tester mot de passe oublié → deep link → nouveau mot de passe.
- [ ] Vérifier qu’un compte non confirmé ne peut pas accéder aux routes protégées.
