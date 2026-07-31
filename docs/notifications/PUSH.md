# Notifications push — MadBeauty (FCM + Edge Functions)

Alertes **réservation** et **messagerie** : token FCM dans `user_profiles`, envoi depuis **Supabase Edge Functions**, réception (**firebase_messaging** + **flutter_local_notifications**), boîte **locale** in-app.

Setup iOS (capabilities, APNs, Sign in with Apple) : [../store/IOS_SETUP.md](../store/IOS_SETUP.md).

## Toggle profil iOS

Sur iOS, l’activation des notifications passe par **Firebase Messaging** (APNs), pas uniquement `permission_handler`.  
Le `Podfile` active aussi `PERMISSION_NOTIFICATIONS=1`.

Rebuild iOS : `cd ios && pod install` puis relancer l’app sur appareil physique.

## Prérequis

- Projet Firebase avec **Cloud Messaging** activé pour **Android + iOS**
- Application Flutter avec **Firebase** configurée (**FlutterFire CLI** recommandée)
- Projet Supabase lié (**`npx supabase link`**)
- Droits pour créer les **secrets** Edge Functions et les **Database Webhooks**

## 1. Base de données (migration)

Le fichier :

`supabase/migrations/20260526153000_user_profiles_fcm_token.sql`

ajoute :

- `user_profiles.fcm_token` (texte)
- `user_profiles.fcm_token_updated_at` (timestamptz)

À appliquer sur le projet cloud :

```bash
npx supabase db push
```

## 2. Application Flutter — Firebase & FCM

1. À la racine du repo Flutter :

   ```bash
   dart pub global activate flutterfire_cli
   export PATH="$PATH:$HOME/.pub-cache/bin"
   flutterfire configure --ios-bundle-id=com.nthiekamw.madbeauty
   ```

   Si `flutterfire` est introuvable, ajoutez `$HOME/.pub-cache/bin` à votre `~/.zshrc`, ou lancez :
   `dart pub global run flutterfire_cli:flutterfire configure`

   Si vous voyez `cannot load such file -- xcodeproj`, installez le gem Ruby puis relancez :

   ```bash
   gem install xcodeproj --user-install
   export GEM_HOME="$HOME/.gem/ruby/2.6.0"
   flutterfire configure --ios-bundle-id=com.nthiekamw.madbeauty --yes
   ```

   Cela régénère `lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, etc.

2. Sur **iOS** : Active la capacité **Push Notifications** et **Background Modes → Remote notifications** dans Xcode (`Runner`).
3. Démarres l’app avec ton `.env` habituel : `flutter run --dart-define-from-file=.env`

Tant que `isFirebaseConfiguredForPush()` est faux (plateforme hors Android/iOS/Web ou options encore « placeholder »), le SDK push est ignoré ; logique dans `lib/firebase_runtime_helpers.dart` (volontairement à l’écart du fichier généré `lib/firebase_options.dart`).

### Flutter Web (PWA + Web Push)

1. **PWA** : `web/manifest.json` (`display: standalone`) + bandeau « Installer » (`PwaInstallBanner`).
2. **Web Push** :
   - Firebase Console → **Cloud Messaging** → **Certificats Web Push** → générer une paire de clés.
   - Copier la **clé publique VAPID** dans `.env` : `FIREBASE_WEB_VAPID_KEY=...`
   - Même variable dans les secrets Netlify / CI (`build_flutter_web_ci.ps1` utilise `--dart-define-from-file`).
   - Service worker : `web/firebase-messaging-sw.js` (notifications en arrière-plan).
3. **Test** : `flutter run -d chrome --web-port=7357 --dart-define-from-file=.env` → accepter les notifications → vérifier `user_profiles.fcm_token` en base.

Sans `FIREBASE_WEB_VAPID_KEY`, le web retombe sur les notifications in-app (session ouverte uniquement).

## 3. Edge Functions (dossier dans ce repo)

| Fonction               | Déclenchée par      | Effet résumé                                               |
|------------------------|---------------------|------------------------------------------------------------|
| `on_booking_created`   | `INSERT reservations` | FCM prestataire : « Nouvelle demande de réservation »     |
| `on_booking_updated`   | `UPDATE reservations`| FCM cliente si statut passe à confirmé ou annulé / refus  |
| `on_message_created`   | `INSERT messages`   | FCM destinataire : aperçu du message (`content` / `contenu`) |
| `on_boutique_order_created` | `INSERT` / `paid` boutique | FCM prestataire : nouvelle commande boutique |
| `on_boutique_order_updated` | `UPDATE statut boutique` | FCM cliente : préparation / prêt / terminé / annulé |

Partagé : `supabase/functions/_shared/booking_notify.ts`

### Déploiement

```bash
npx supabase functions deploy on_booking_created --no-verify-jwt
npx supabase functions deploy on_booking_updated --no-verify-jwt
npx supabase functions deploy on_message_created --no-verify-jwt
npx supabase functions deploy on_boutique_order_created --no-verify-jwt
npx supabase functions deploy on_boutique_order_updated --no-verify-jwt
```

`--no-verify-jwt` est adapté lorsque les appels viennent des **Database Webhooks** (pas de JWT utilisateur dans le corps de la requête).

### Secrets (Dashboard → Edge Functions → Secrets ou CLI)

Configure au minimum :

| Secret                             | Description |
|-----------------------------------|-------------|
| `FIREBASE_SERVICE_ACCOUNT_JSON`   | JSON du **compte de service** Firebase, sur **une ligne** ; dans `private_key`, remplacer les vraies sauts de ligne par `\n` |
| `BOOKING_WEBHOOK_SECRET`          | Chaîne aléatoire longue ; doit être envoyée tel quel dans l’entête **`x-webhook-secret`** depuis chaque webhook |
| `SUPABASE_SERVICE_ROLE_KEY`       | Souvent déjà disponible comme secret de projet pour les fonctions ; utilisé pour lire `prestataire_profiles`, `client_profiles`, `user_profiles` |

Sans `BOOKING_WEBHOOK_SECRET`, le code déploie encore accepte les appels (**à éviter en production**).

## 4. Déclenchement automatique (recommandé — migration SQL)

Une migration crée des **triggers PostgreSQL + pg_net** qui appellent les Edge Functions (équivalent aux Database Webhooks du dashboard, **sans clic manuel**).

```powershell
# Depuis la racine du repo (projet Supabase déjà lié)
.\supabase\setup_push_notifications.ps1
```

Le script :
- applique la migration `20260608120000_booking_push_pg_net_triggers.sql` ;
- configure `private.webhook_config` (URL + secret) ;
- définit `BOOKING_WEBHOOK_SECRET` ;
- déploie `on_booking_created`, `on_booking_updated`, `on_message_created`.

**Firebase (une seule action manuelle)** : placer le JSON du compte de service dans  
`supabase/firebase-service-account.json` (voir `firebase-service-account.json.example`), puis relancer le script.

---

## 4 bis. Database Webhooks (alternative dashboard)

Si tu préfères l’UI Supabase (**Integrations → Database Webhooks**), configure **deux webhooks HTTP POST** vers les URLs :

`https://<PROJECT_REF>.supabase.co/functions/v1/on_booking_created`  
`https://<PROJECT_REF>.supabase.co/functions/v1/on_booking_updated`  
`https://<PROJECT_REF>.supabase.co/functions/v1/on_message_created`

Exemple avec `PROJECT_REF` = **`vjjasrdoyguqkftfhaei`** :

- `https://vjjasrdoyguqkftfhaei.supabase.co/functions/v1/on_booking_created`
- `https://vjjasrdoyguqkftfhaei.supabase.co/functions/v1/on_booking_updated`
- `https://vjjasrdoyguqkftfhaei.supabase.co/functions/v1/on_message_created`

Réglages typiques :

- **Schéma** `public`
- **Table** `reservations`
- **Événements** : webhook 1 = **INSERT uniquement**, webhook 2 = **UPDATE uniquement**
- **HTTP Headers** (les deux) :

  ```
  Content-Type: application/json
  x-webhook-secret: <même valeur que BOOKING_WEBHOOK_SECRET>
  ```

Le corps reprend le format des webhooks Supabase (`type`, `table`, `record`, `old_record` pour UPDATE).

### Messagerie (`on_message_created`)

- **Table** `messages`, événement **INSERT uniquement**
- Même entête `x-webhook-secret` que les webhooks réservation
- Résout le destinataire via `booking_id` → `reservations` → `client_profiles` / `prestataire_profiles` (utilisateur ≠ `sender_id`)
- Payload FCM `data` : `type=message`, `booking_id=<uuid>` (navigation future possible)

### Statuts métier (`on_booking_updated`)

La fonction normalise le texte : `confirmee`, `confirmed`, `validee`… déclenchent **« Votre réservation est confirmée✅ »** ; `annulee`, `cancelled`, `refusee`… déclenchent **« Votre réservation a été refusée »** (voir `booking_notify.ts`).

**Note** : le passage à `terminee` ne déclenche **pas** de push immédiat ; l’aftercare J+1 passe par `scheduled_pushes` + `process_scheduled_pushes`.

## 4bis. File planifiée — `process_scheduled_pushes`

Table `scheduled_pushes` (`aftercare`, `rebook_reminder`). Edge Function **`process_scheduled_pushes`** (`--no-verify-jwt`) :

```bash
npx supabase functions deploy process_scheduled_pushes --no-verify-jwt
```

**Cron** : job `pg_cron` `process-scheduled-pushes` toutes les 15 min (migration `20260731130000_process_scheduled_pushes_cron.sql`) → `private.invoke_process_scheduled_pushes()` → pg_net vers l’EF. Prérequis : `private.webhook_config.functions_base` (script `setup_push_notifications.ps1`).

Détail : [`supabase/functions/process_scheduled_pushes/README.md`](../../supabase/functions/process_scheduled_pushes/README.md).

Deep links app : `type=aftercare` → détail résa client ; `type=rebook_reminder` → flow booking (`prestataire_id` / `service_id`).

## 5. Comportement côté app

- À la connexion, le token FCM est enregistré via `ProfileService.upsertFcmToken` (voir `BookingPushCoordinator` + `booking_push_notifications.dart`).
- Les messages entrants alimentent la liste locale (**`InAppNotificationsNotifier`**) et apparaissent dans la cloche : **accueil client** et **tableau de bord prestataire**.
- À la **déconnexion** après une session authentifiée, le stockage local des notifications affichées est purgé (`purgeForLogout`).

## Vérifications rapides

1. Migrer la base → utilisateur ouvre l’app connecté avec notifications autorisées → une ligne mise à jour sur `user_profiles` avec `fcm_token`.
2. Créer une réservation depuis le client → le prestataire reçoit la push si le webhook **INSERT** est actif et les secrets sont bons.
3. Accepter / refuser côté prestataire → la cliente reçoit la push si le webhook **UPDATE** est actif.
4. Envoyer un message dans un fil lié à une réservation → l’autre participant reçoit la push si le webhook **INSERT messages** est actif.

Pour les erreurs **FCM 404 / Unauthorized**, vérifier le JSON du compte de service, l’activation de l’API FCM dans Google Cloud pour le projet lié au même Firebase, et les tokens enregistrés.

**`UNREGISTERED` / `NotRegistered`** : le `fcm_token` en base est mort (app désinstallée, cache vidé, permission retirée). L’Edge Function `admin_send_push` efface alors le token. Solution utilisateur : rouvrir MadBeauty avec les notifications autorisées pour enregistrer un nouveau token.

## 6. Realtime côté app (messagerie)

Le provider Riverpod **`messagesProvider`** (`lib/features/messaging/providers/message_provider.dart`) expose un `StreamProvider` branché sur `MessageService.getMessages(bookingId)` (flux Supabase + canal Postgres). L’écran chat consomme ce flux sans rafraîchissement manuel.
