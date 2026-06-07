# Notifications push — réservations (FCM + Edge Functions)

Ce document complète l’implémentation **MadBeauty** pour les alertes réservation : stockage du token FCM dans `user_profiles`, envoi depuis **Supabase Edge Functions**, réception dans l’app (**firebase_messaging** + **flutter_local_notifications**) et boîte **locale** dans l’UI.

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
   flutterfire configure
   ```

   Cela régénère `lib/firebase_options.dart`, `android/app/google-services.json`, `ios/Runner/GoogleService-Info.plist`, etc.

2. Sur **iOS** : Active la capacité **Push Notifications** et **Background Modes → Remote notifications** dans Xcode (`Runner`).
3. Démarres l’app avec ton `.env` habituel : `flutter run --dart-define-from-file=.env`

Tant que `isFirebaseConfiguredForPush()` est faux (plateforme hors Android/iOS/Web ou options encore « placeholder »), le SDK push est ignoré ; logique dans `lib/firebase_runtime_helpers.dart` (volontairement à l’écart du fichier généré `lib/firebase_options.dart`).

## 3. Edge Functions (dossier dans ce repo)

| Fonction               | Déclenchée par      | Effet résumé                                               |
|------------------------|---------------------|------------------------------------------------------------|
| `on_booking_created`   | `INSERT reservations` | FCM prestataire : « Nouvelle demande de réservation »     |
| `on_booking_updated`   | `UPDATE reservations`| FCM cliente si statut passe à confirmé ou annulé / refus  |
| `on_message_created`   | `INSERT messages`   | FCM destinataire : aperçu du message (`content` / `contenu`) |

Partagé : `supabase/functions/_shared/booking_notify.ts`

### Déploiement

```bash
npx supabase functions deploy on_booking_created --no-verify-jwt
npx supabase functions deploy on_booking_updated --no-verify-jwt
npx supabase functions deploy on_message_created --no-verify-jwt
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

## 6. Realtime côté app (messagerie)

Le provider Riverpod **`messagesProvider`** (`lib/features/messaging/providers/message_provider.dart`) expose un `StreamProvider` branché sur `MessageService.getMessages(bookingId)` (flux Supabase + canal Postgres). L’écran chat consomme ce flux sans rafraîchissement manuel.
