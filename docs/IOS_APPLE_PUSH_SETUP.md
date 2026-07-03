# iOS — Sign in with Apple & notifications push

Checklist pour activer **Apple**, **push FCM** et vérifier **cartes** sur un compte Apple Developer payant.

## Prérequis Xcode

1. Ouvrir `ios/Runner.xcworkspace`
2. Cible **Runner** → **Signing & Capabilities**
3. Vérifier **Team** = votre compte Developer et bundle **`com.nthiekamw.madbeauty`**
4. Capabilities (ajouter si absentes) :
   - **Sign in with Apple**
   - **Push Notifications**
   - **Background Modes** → *Remote notifications* (déjà dans `Info.plist`)

Les entitlements sont dans `ios/Runner/Runner.entitlements` (`applesignin`, `aps-environment`).

Pour l’**App Store**, remplacer `aps-environment` par `production` ou laisser Xcode le gérer à l’archive.

## Sign in with Apple

### Apple Developer

1. [developer.apple.com](https://developer.apple.com) → **Identifiers** → App ID `com.nthiekamw.madbeauty`
2. Activer **Sign In with Apple**

### Supabase

1. **Authentication → Providers → Apple** : activer
2. Renseigner :
   - **Services ID** (ex. `com.nthiekamw.madbeauty.auth`)
   - **Secret Key** (fichier `.p8` + Key ID + Team ID)
3. Redirect URL Supabase : copier depuis le dashboard Apple provider

Guide : [Supabase — Login with Apple](https://supabase.com/docs/guides/auth/social-login/auth-apple)

### App Flutter

- Package `sign_in_with_apple` + `AppleAuthService`
- Boutons **Continuer avec Apple** sur connexion et inscription (iOS uniquement)

## Notifications push (FCM → APNs)

### Firebase

```bash
dart pub global activate flutterfire_cli
flutterfire configure
```

Génère `ios/Runner/GoogleService-Info.plist` (manquant tant que non exécuté).

### Apple — clé APNs

1. **Keys** → **+** → **Apple Push Notifications service (APNs)**
2. Télécharger la clé `.p8` (une seule fois)

### Firebase Console

**Project Settings → Cloud Messaging → Apple app configuration** : uploader la clé APNs (Key ID, Team ID, `.p8`).

### Supabase (backend)

Voir `docs/BOOKING_PUSH_NOTIFICATIONS.md` : migration FCM, Edge Functions, secret `FIREBASE_SERVICE_ACCOUNT_JSON`.

### Test

1. `./scripts/sync_ios_dart_defines.sh` puis build sur **appareil physique** (push peu fiable sur simulateur)
2. Accepter la permission notifications au premier lancement
3. Vérifier `user_profiles.fcm_token` rempli dans Supabase

## Cartes

Aucune capability Apple Maps requise : l’app utilise **OpenStreetMap** (`flutter_map`) + **géolocalisation** (`geolocator`).

Permission déjà déclarée : `NSLocationWhenInUseUsageDescription` dans `Info.plist`.
