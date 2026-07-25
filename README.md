# MadBeauty - application Flutter

MadBeauty est une application mobile de reservation beaute, specialisee en coiffure afro : tresses, locks, cheveux crepus et boucles.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?logo=supabase)](https://supabase.com)
[![Riverpod](https://img.shields.io/badge/State-Riverpod_2-00B4D8)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-Proprietary-red)](LICENSE)

---

## Presentation

MadBeauty met en relation des clients et des prestataires specialises en coiffure afro, manucure, maquillage et pedicure. Les clients trouvent et reservent un prestataire selon leurs besoins et leur localisation. Les prestataires gerent leur agenda, leur profil et leurs revenus directement depuis l'application.

---

## Stack technique

| Couche | Technologie |
| --- | --- |
| Mobile | Flutter 3.x (iOS + Android) |
| State management | Riverpod 2 |
| Navigation | go_router |
| Base de donnees | Supabase (PostgreSQL) |
| Authentification | Supabase Auth (Email + Google OAuth) |
| Stockage fichiers | Supabase Storage |
| Temps reel | Supabase Realtime |
| Paiement | Stripe + Stripe Connect |
| Notifications | Supabase Edge Functions + FCM |
| Crash reporting | Sentry |

---

## Prerequis

Avant de commencer, assure-toi d'avoir :

- [Flutter SDK](https://docs.flutter.dev/get-started/install) >= 3.0
- [Dart SDK](https://dart.dev/get-dart) >= 3.0 (inclus avec Flutter)
- [Android Studio](https://developer.android.com/studio) ou [VS Code](https://code.visualstudio.com) avec l'extension Flutter
- Sur Android : le **NDK 27.0.12077973** (Android Studio → *Settings* → *Languages & Frameworks* → *Android SDK* → onglet *SDK Tools*, coche **NDK (Side by side)** et sélectionne la version utilisée dans `android/app/build.gradle.kts`, champ `ndkVersion`). Sans cette version installée localement, Gradle peut échouer ou afficher des avertissements de version entre plugins Flutter.
- Un emulateur Android ou simulateur iOS configure (ou un vrai device)
- Un compte [Supabase](https://supabase.com) avec un projet cree
- Un compte [Stripe](https://stripe.com) (pour le module paiement)

---

## Installation

### 1. Cloner le repo

```bash
git clone https://github.com/TON_ORG/madbeauty.git
cd madbeauty
```

### 2. Configurer les variables d'environnement

A la racine du projet, copie le modele puis edite les valeurs :

```bash
cp .env.example .env
```

Le fichier `.env` est ignore par Git : ne le commit pas.

Exemple :

```env
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
STRIPE_PUBLISHABLE_KEY=pk_test_...
SUPABASE_EMAIL_REDIRECT_URL=com.madbeauty.madbeauty://login-callback
```

Important pour la confirmation e-mail Supabase:

- Checklist complete : `supabase/AUTH_PRODUCTION_CHECKLIST.md`
- Dans Supabase Dashboard -> Authentication -> URL Configuration:
  - **Site URL**: ne pas laisser `http://localhost:3000` en production/mobile.
  - **Redirect URLs**: ajouter la valeur de `SUPABASE_EMAIL_REDIRECT_URL`
    (ex: `com.madbeauty.madbeauty://login-callback`).
  - **Confirm email** : active en production.
  - **Password** : minimum 8 caracteres, `letters_digits`.

Pour lancer l'app avec ce fichier :

```bash
flutter run --dart-define-from-file=.env
```

Sous Windows / PowerShell :

```powershell
flutter run --dart-define-from-file=.env
```

Avec VS Code / Cursor, tu peux utiliser la configuration `MadBeauty (avec .env)` dans `.vscode/launch.json`.

Tu peux aussi definir les valeurs une par une :

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGci... \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_...
```

### 3. Installer les dependances

```bash
flutter pub get
```

### 4. Generer les fichiers de code (Freezed)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Lancer l'application

```bash
flutter run --dart-define-from-file=.env
```

### 6. Migrations SQL (Supabase CLI)

Le schéma Postgres est versionné dans **`supabase/migrations/`** (voir la section [Base de donnees Supabase (migrations)](#base-de-donnees-supabase-migrations) plus bas).

---

## Structure du projet

```text
lib/
|-- core/
|   |-- constants/
|   |-- errors/
|   `-- extensions/
|-- shared/
|   |-- theme/
|   |   |-- app_colors.dart
|   |   |-- app_text_styles.dart
|   |   `-- app_theme.dart
|   `-- widgets/
|-- services/
|   |-- supabase/
|   |   `-- supabase_service.dart
|   |-- auth/
|   |   `-- auth_service.dart
|   |-- storage/
|   |   `-- storage_service.dart
|   |-- stripe/
|   |   `-- stripe_service.dart
|   `-- notification/
|       `-- notification_service.dart
`-- features/
    |-- auth/
    |   |-- providers/
    |   |   `-- auth_notifier.dart
    |   |-- login/
    |   |   |-- routes/
    |   |   |   `-- login_route.dart
    |   |   |-- screens/
    |   |   |   `-- login_page.dart
    |   |   |-- providers/
    |   |   |   `-- login_controller.dart
    |   |   |-- models/
    |   |   |   `-- login_view_state.dart
    |   |   `-- logic/
    |   |       `-- login_validators.dart
    |   `-- register/            # meme decoupage que login/ (inscription, verification...)
    |-- search/
    |-- prestataire/
    |-- booking/
    |-- messaging/
    |-- reviews/
    |-- stats/
    `-- profile/
supabase/                      # CLI Supabase : migrations SQL (hors Flutter)
|-- config.toml
|-- seed.sql
`-- migrations/
    `-- 20260507140000_init_extensions.sql
```

Chaque feature suit en general : `screens/`, `widgets/`, `providers/`, `models/`, et si besoin `routes/`, `logic/`.

**Auth** est un cas particulier : plusieurs **flux** (connexion, inscription, recuperation de mot de passe, etc.) sous `features/auth/<flux>/` avec le meme decoupage ; **`features/auth/providers/`** garde uniquement la **session globale** (`auth_notifier`, acces `AuthService`).

```text
features/auth/
|-- providers/           # Session : AuthNotifier, authServiceProvider
|-- login/               # Connexion
|   |-- routes/
|   |-- screens/
|   |-- providers/
|   |-- models/
|   `-- logic/
|-- register/            # Inscription (a creer, meme structure)
`-- ...                  # ex. forgot_password/, verify_email/
```

---

## Base de donnees Supabase (migrations)

Le dossier **`supabase/`** à la racine sert au [**Supabase CLI**](https://supabase.com/docs/guides/cli) : schéma versionné en SQL (**pas** depuis l’app Flutter).

| Chemin | Rôle |
| --- | --- |
| `supabase/config.toml` | Config du projet local (`supabase start`) et repère CLI |
| `supabase/migrations/*.sql` | Migrations ordonnées (timestamp + nom) |
| `supabase/seed.sql` | Données de dev optionnelles après `db reset` |

### Prérequis CLI

- [Node.js](https://nodejs.org/) (pour **`npx`**)
- **Ne pas utiliser** `npm install -g supabase` : le paquet npm **refuse** l’installation globale et affiche *« Installing Supabase CLI as a global module is not supported »*.

**Option A — recommandée sur ce repo (sans install système)** : depuis la racine du projet, toutes les commandes avec le préfixe **`npx`** (déjà utilisé pour `supabase init`, `login`, `db push`).

```powershell
npx supabase --version
```

**Option B — Windows : commande `supabase` via [Scoop](https://scoop.sh)** (facultatif).  
Il faut **d’abord installer Scoop** (voir [install](https://scoop.sh/#install)), puis :

```powershell
scoop bucket add supabase https://github.com/supabase/scoop-bucket.git
scoop install supabase
```

Si `scoop` n’est pas reconnu, tu n’as pas encore Scoop : **reste sur l’option A** (`npx supabase`).

**Option C — dépendance npm locale** (dans un dossier qui a un `package.json`) : `npm i supabase --save-dev`, puis `npx supabase …`.  

Voir aussi la [doc officielle d’installation](https://github.com/supabase/cli#install-the-cli).

### Commandes utiles

Sous Windows, si **`supabase`** n’est pas reconnu, utilise **`npx supabase …`** (option A ci-dessus).

```bash
# Authentification aupres de Supabase
npx supabase login

# Lier ce repo au projet cloud (project_ref : Settings → General dans le dashboard)
npx supabase link --project-ref <project_ref>

# Nouvelle migration (fichier dans supabase/migrations/)
npx supabase migration new description_courte

# Appliquer les migrations sur le projet lié
npx supabase db push

# En local : Postgres + API + Studio (voir les ports dans config.toml)
npx supabase start
```

Si la CLI est installée via **Scoop** (ou autre méthode supportée) et que `supabase` est dans ton `PATH`, tu peux omettre le préfixe `npx `.

**Important :** la version Postgres dans `config.toml` (`[db].major_version`) doit **correspondre** à celle du projet distant (dashboard → *Database* → *Settings*) pour limiter les écarts au `db push`.

Les clés **`SUPABASE_URL`** / **`SUPABASE_ANON_KEY`** du `.env` servent au **client Flutter** uniquement. Les migrations passent par le CLI (ne jamais embarquer la *service role key* dans l’app).

### Schema metier (documentation)

Le détail des tables / relations / RLS est dans [`docs/backend/DB_SCHEMA.md`](docs/backend/DB_SCHEMA.md) — à **aligner** avec le SQL des migrations au fil du temps.

Tables principales : `user_profiles`, `prestataire_profiles`, `services`, `disponibilites`, `reservations`, `avis`, `messages`, `favoris`.

> Row Level Security (RLS) doit rester active sur les tables exposées à l’API ; les politiques se definissent dans le SQL des migrations ou le SQL Editor.

---

## Documentation

Index : [`docs/README.md`](docs/README.md).

| Document | Contenu |
| --- | --- |
| `docs/ARCHITECTURE.md` | Choix techniques, structure du code, patterns |
| `docs/backend/DB_SCHEMA.md` | Schema Supabase, relations, RLS |
| `docs/product/FEATURES.md` | Etat produit / prochaines etapes |
| `docs/notifications/PUSH.md` | Push FCM, Edge Functions, webhooks |
| `docs/payments/` | Stripe Connect, abonnements, tests |
| `docs/CONTRIBUTING.md` | Conventions Git, workflow, regles de PR |
| `CHANGELOG.md` | Historique des versions |

---

## Workflow Git

```text
main        <- production stable
develop     <- integration continue
feature/xxx <- developpement d'une feature
fix/xxx     <- correction de bug
```

### Conventions de commits

```text
feat: ajout de l'ecran de reservation
fix: correction bug auth Google sur iOS
docs: mise a jour DB_SCHEMA
refactor: extraction du BookingService
chore: mise a jour flutter pub
```

### Regles

- Toujours partir de `develop` pour creer une branche
- Pull Request obligatoire avant de merger sur `develop`
- `main` ne recoit que des merges depuis `develop` via PR validee
- Max 2 reviewers par PR

---

## Variables d'environnement

| Variable | Description | Requis |
| --- | --- | --- |
| `SUPABASE_URL` | URL du projet Supabase | Oui pour l'app complete |
| `SUPABASE_ANON_KEY` | Cle publique Supabase | Oui pour l'app complete |
| `STRIPE_PUBLISHABLE_KEY` | Cle publique Stripe | Oui pour les paiements |
| `SUPABASE_EMAIL_REDIRECT_URL` | Deep link auth (confirmation e-mail, recovery) | Oui en production |

> La cle secrete Stripe (`sk_...`) et la cle `service_role` Supabase ne doivent jamais figurer dans le code Flutter ni dans un depot public.

---

## Build et deploiement

### Android

```bash
flutter build apk --release --dart-define-from-file=.env
flutter build appbundle --release --dart-define-from-file=.env
```

### iOS

```bash
flutter build ipa --release --dart-define-from-file=.env
```

---

## Tests

```bash
flutter test
flutter test integration_test/
```

---

## Equipe

| Role | Responsable |
| --- | --- |
| Dev Flutter (client + auth + UI) | Jason |
| Dev Flutter (backend + Supabase + data) | William |

---

## Licence

Projet proprietaire - tous droits reserves.
# MadBeauty   application Flutter

MadBeauty est une application mobile de r�servation beaut�, sp�cialis�e coiffure afro : tresses, locks, cheveux cr�pus et boucl�s.

[![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?logo=flutter)](https://flutter.dev)
[![Supabase](https://img.shields.io/badge/Supabase-PostgreSQL-3ECF8E?logo=supabase)](https://supabase.com)
[![Riverpod](https://img.shields.io/badge/State-Riverpod_2-00B4D8)](https://riverpod.dev)
[![License](https://img.shields.io/badge/License-Proprietary-red)](LICENSE)

---

## Pr�sentation

MadBeauty met en relation clients et prestataires sp�cialis�s en coiffure afro. Les clients trouvent et r�servent un prestataire selon leur type de cheveux et leur localisation. Les prestataires g�rent leur agenda, leur profil et leurs revenus directement depuis l application.

---

## Stack technique

| Couche | Technologie |
| --- | --- |
| Mobile | Flutter 3.x (iOS + Android) |
| State management | Riverpod 2 |
| Navigation | go_router |
| Base de donn�es | Supabase (PostgreSQL) |
| Authentification | Supabase Auth (Email + Google OAuth) |
| Stockage fichiers | Supabase Storage |
| Temps r�el | Supabase Realtime |
| Paiement | Stripe + Stripe Connect |
| Notifications | Supabase Edge Functions + FCM |
| Crash reporting | Sentry |

---

## Pr�requis

Avant de commencer, assure-toi d avoir :

- [Flutter SDK](https://docs.flutter.dev/get-started/install) e" 3.0
- [Dart SDK](https://dart.dev/get-dart) e" 3.0 (inclus avec Flutter)
- [Android Studio](https://developer.android.com/studio) ou [VS Code](https://code.visualstudio.com) avec l extension Flutter
- Un �mulateur Android ou simulateur iOS configur� (ou un vrai device)
- Un compte [Supabase](https://supabase.com) avec un projet cr��
- Un compte [Stripe](https://stripe.com) (pour le module paiement)

---

## Installation

### 1. Cloner le repo

```bash
git clone https://github.com/TON_ORG/madbeauty.git
cd madbeauty
```

(Remplace `TON_ORG` par ton organisation ou ton nom d utilisateur GitHub.)

### 2. Configurer les variables d environnement

� la racine du projet, copie le mod�le puis �dite les valeurs :

```bash
cp .env.example .env
```

Le fichier `.env` est ignor� par Git : ne le commite pas. Exemple de contenu :

```env
SUPABASE_URL=https://xxxx.supabase.co
SUPABASE_ANON_KEY=eyJhbGci...
STRIPE_PUBLISHABLE_KEY=pk_test_...
FIREBASE_DATABASE_PASSWORD="ton_mot_de_passe"
```

Pour que Flutter lise ce fichier au lancement, utilise **`--dart-define-from-file`** (recommand�) :

```bash
flutter run --dart-define-from-file=.env
```

Sous Windows (PowerShell), m�me commande depuis le dossier du projet :

```powershell
flutter run --dart-define-from-file=.env
```

Avec **VS Code** / Cursor, tu peux utiliser la configuration de lancement **� MadBeauty (avec .env) �** (fichier `.vscode/launch.json`).

Tu peux aussi d�finir les cl�s une par une avec `--dart-define` :

```bash
flutter run \
  --dart-define=SUPABASE_URL=https://xxxx.supabase.co \
  --dart-define=SUPABASE_ANON_KEY=eyJhbGci... \
  --dart-define=STRIPE_PUBLISHABLE_KEY=pk_test_... \
  --dart-define=FIREBASE_DATABASE_PASSWORD="ton_mot_de_passe"
```

### 3. Installer les d�pendances

```bash
flutter pub get
```

### 4. G�n�rer les fichiers de code (Freezed)

```bash
dart run build_runner build --delete-conflicting-outputs
```

### 5. Lancer l application

```bash
# Debug (pense � ajouter --dart-define-from-file=.env si tu utilises un .env)
flutter run --dart-define-from-file=.env

# Release
flutter run --release --dart-define-from-file=.env
```

---

## Structure du projet

```
lib/
%%% core/                   # Constantes, extensions, gestion des erreurs
%   %%% constants/
%   %%% errors/
%   %%% extensions/
%%% shared/                 # Widgets communs, th�me, design system
%   %%% theme/
%   %   %%% app_colors.dart
%   %   %%% app_text_styles.dart
%   %   %%% app_theme.dart
%   %%% widgets/
%%% services/               # Couche d abstraction Supabase
%   %%% supabase/
%   %   %%% supabase_service.dart
%   %%% auth/
%   %   %%% auth_service.dart
%   %%% storage/
%   %   %%% storage_service.dart
%   %%% stripe/
%   %   %%% stripe_service.dart
%   %%% notification/
%   %   %%% notification_service.dart
%%% features/               # Modules m�tier
    %%% auth/               # Inscription, connexion, choix du r�le
    %%% search/             # Listing, filtres, carte
    %%% prestataire/        # Profil, services, disponibilit�s
    %%% booking/            # R�servation, historique, dashboard
    %%% messaging/          # Chat temps r�el
    %%% reviews/            # Avis et notations
    %%% stats/              # Dashboard statistiques prestataire
    %%% profile/            # Profil utilisateur
```

Chaque feature suit la structure :

```
features/[feature]/
%%% screens/
%%% widgets/
%%% providers/
%%% models/
```

---

## Base de donn�es

Le schéma complet est documenté dans [`docs/backend/DB_SCHEMA.md`](docs/backend/DB_SCHEMA.md).

Tables principales : `user_profiles`, `prestataire_profiles`, `services`, `disponibilites`, `reservations`, `avis`, `messages`, `favoris`.

> **Row Level Security (RLS)** est activée sur toutes les tables. Les politiques sont définies dans le SQL des migrations Supabase.

---

## Documentation

Index : [`docs/README.md`](docs/README.md).

| Document | Contenu |
| --- | --- |
| [`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) | Choix techniques, structure du code, patterns |
| [`docs/backend/DB_SCHEMA.md`](docs/backend/DB_SCHEMA.md) | Schéma Supabase, relations, RLS |
| [`docs/product/FEATURES.md`](docs/product/FEATURES.md) | État produit / prochaines étapes |
| [`docs/CONTRIBUTING.md`](docs/CONTRIBUTING.md) | Conventions Git, workflow, règles de PR |
| [`CHANGELOG.md`](CHANGELOG.md) | Historique des versions |

---

## Workflow Git

```
main          �! production stable
develop       �! int�gration continue
feature/xxx   �! d�veloppement d une feature
fix/xxx       �! correction de bug
```

### Conventions de commits

```
feat: ajout de l �cran de r�servation
fix: correction bug auth Google sur iOS
docs: mise � jour DB_SCHEMA
refactor: extraction du BookingService
chore: mise � jour flutter pub
```

### R�gles

- Toujours partir de `develop` pour cr�er une branche
- Pull Request obligatoire avant de merger sur `develop`
- `main` ne re�oit que des merges depuis `develop` via PR valid�e
- Max 2 reviewers par PR

---

## Variables d environnement

| Variable | Description | Requis |
| --- | --- | --- |
| `SUPABASE_URL` | URL du projet Supabase | Oui pour l app compl�te |
| `SUPABASE_ANON_KEY` | Cl� publique Supabase | Oui pour l app compl�te |
| `STRIPE_PUBLISHABLE_KEY` | Cl� publique Stripe | Oui pour les paiements |
| `FIREBASE_DATABASE_PASSWORD` | Mot de passe base / acc�s Firebase selon ton setup | Selon ton infra |

> La cl� secr�te Stripe (`sk_...`) et la cl� `service_role` Supabase ne doivent **jamais** figurer dans le code Flutter ni dans un d�p�t public. En production, privil�gie des secrets c�t� serveur (Edge Functions, backend) plut�t qu un mot de passe de base dans l app mobile.

---

## Build et d�ploiement

### Android

```bash
flutter build apk --release --dart-define-from-file=.env
# ou pour le Play Store
flutter build appbundle --release --dart-define-from-file=.env
```

### iOS

```bash
flutter build ipa --release --dart-define-from-file=.env
```

> Les configurations de signature sont dans `android/app/build.gradle.kts` et `ios/Runner.xcodeproj`.

---

## Tests

```bash
# Tests unitaires
flutter test

# Tests d int�gration
flutter test integration_test/
```

---

## �quipe

| R�le | Responsable |
| --- | --- |
| Dev Flutter (client + auth + UI) | Jason |
| Dev Flutter (backend + Supabase + data) | William |

---

## Licence

Projet propri�taire   tous droits r�serv�s � 2025 Lionel Ngako.

---

*Projet MadBeauty   v1.0*
