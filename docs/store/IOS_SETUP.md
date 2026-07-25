# iOS — Sign in with Apple & capabilities

Checklist Xcode / Apple Developer pour **Sign in with Apple**, **push (APNs)** et **localisation**.  
Guide push complet (FCM, Edge Functions, webhooks) : [../notifications/PUSH.md](../notifications/PUSH.md).

## Prérequis Xcode

1. Ouvrir `ios/Runner.xcworkspace`
2. Cible **Runner** → **Signing & Capabilities**
3. **Team** = compte Developer ; bundle **`com.nthiekamw.madbeauty`**
4. Capabilities :
   - **Sign in with Apple**
   - **Push Notifications**
   - **Background Modes** → *Remote notifications*

Entitlements : `ios/Runner/Runner.entitlements` (`applesignin`, `aps-environment`).  
App Store : `aps-environment` = `production` (ou géré par Xcode à l’archive).

## Sign in with Apple

### Apple Developer

1. [developer.apple.com](https://developer.apple.com) → **Identifiers** → App ID `com.nthiekamw.madbeauty`
2. Activer **Sign In with Apple**

### Supabase

1. **Authentication → Providers → Apple** : activer
2. **Services ID**, clé `.p8` (Key ID + Team ID), redirect URL dashboard
3. Guide : [Supabase — Login with Apple](https://supabase.com/docs/guides/auth/social-login/auth-apple)

### App Flutter

- `sign_in_with_apple` + `AppleAuthService`
- Boutons **Continuer avec Apple** (iOS uniquement)

Checklist dashboard élargie : [`supabase/AUTH_PRODUCTION_CHECKLIST.md`](../../supabase/AUTH_PRODUCTION_CHECKLIST.md).

## Push iOS (APNs → FCM)

1. `flutterfire configure` → `ios/Runner/GoogleService-Info.plist`
2. Apple **Keys** → APNs (`.p8`, une fois)
3. Firebase Console → **Cloud Messaging** → uploader la clé APNs
4. Backend : secrets + functions — [../notifications/PUSH.md](../notifications/PUSH.md)
5. Tester sur **appareil physique** (`./scripts/sync_ios_dart_defines.sh`) ; vérifier `user_profiles.fcm_token`

## Cartes & localisation

Pas de capability Apple Maps : **OpenStreetMap** (`flutter_map`) + `geolocator`.  
`Info.plist` : `NSLocationWhenInUseUsageDescription` (+ Always si un SDK le référence).

## App Store

Textes, confidentialité, notes review : [APP_STORE_CONNECT.md](./APP_STORE_CONNECT.md).
