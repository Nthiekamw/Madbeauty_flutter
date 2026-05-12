# Feuille de route MadBeauty — MVP vs V2

Synthèse **MVP** (première version utilisable) vs **V2** (extensions et maturité prod), alignée sur le plan produit technique (auth, rôles, réservation, offline, qualité).

## MVP (objectif : parcours client / prestataire crédible)

### Authentification & compte

- [x] Splash avec vérification de session
- [x] Connexion e-mail / mot de passe (Supabase Auth)
- [x] Inscription avec validation et gestion erreurs (dont e-mail non confirmé)
- [x] Persistance de session + déconnexion
- [x] Choix du rôle client / prestataire (UI + persistance locale + table `user_roles`)
- [ ] OAuth Google (config dashboard + flux app) — *prévu README, pas forcément branché*
- [ ] Création automatique ou guidée des lignes `client_profiles` / `prestataire_profiles` à l’activation métier

### Navigation & UX

- [x] `go_router` avec garde d’auth et routes nommées
- [x] Thème client (vert) / prestataire (bleu) + dark mode
- [x] Widgets de base : `AppButton`, `AppTextField`, `AppAvatar`
- [x] Chaînes centralisées (`CoreStrings`, `AuthStrings`, `ShellStrings`, `DiscoveryStrings` + `app_strings.dart`)

### Données & backend

- [x] Migrations Supabase : profils, rôles, schéma métier (réservations, avis, messagerie, etc.)
- [x] Modèles domaine Freezed + JSON + helpers Supabase (`SupabaseDomainCodec`)
- [x] Service auth + rôles (lecture / upsert `user_roles`)

### Offline & performance (fondations)

- [x] Détection connectivité + comportement dégradé si plugin absent (tests)
- [x] Cache local (`SharedPreferences`) : e-mail, rôle choisi, snapshot profil accueil
- [ ] Stratégie offline-first **par feature** (réservations, messages, etc.) — *à étendre au fil des écrans*

### Qualité

- [x] Tests unitaires : validateurs, contrôleurs auth, providers clés, codec domaine
- [x] Test de flux logique auth + rôle (sans UI device)
- [ ] Tests d’intégration / E2E sur émulateur avec backend de staging

### Écrans métier (stubs → MVP réel)

- [x] Accueil client, hub prestataire (placeholders)
- [ ] Recherche prestataires (filtres catégorie / ville)
- [ ] Fiche prestataire + services + disponibilités simplifiées
- [ ] Réservation création / liste / statut
- [ ] Profil utilisateur éditable aligné `user_profiles`

---

## V2 (croissance, revenus, scale ~1000+ utilisateurs)

### Réservation & planning

- Agenda prestataire (créneaux, indisponibilités, fuseaux)
- Rappels / annulations / no-show
- Règles métier `statut` réservation (enum + transitions côté DB ou Edge Function)

### Paiements & prestataire

- Stripe / Stripe Connect : acompte, solde, commissions
- Écran revenus & stats (agrégations, exports)

### Social & confiance

- Avis modérés, signalement
- Portfolio `photos_realisation` + stockage Supabase Storage
- Badge `is_verified` (process manuel ou intégration tierce)

### Messagerie & notifications

- Messagerie temps réel (Supabase Realtime) + push FCM
- Préférences notification

### Découverte & SEO mobile

- Carte / géolocalisation fine, recherche multi-critères
- Deep links complets (réservation, profil, reset password)
- Politiques RLS `anon` pour consultation catalogue sans compte (si produit l’exige)

### Offline & robustesse

- Files d’actions hors ligne + synchronisation (conflits)
- Cache images & politiques d’expiration
- Observabilité : Sentry, logs structurés

### Admin & conformité

- Outil admin (rôles, litiges, catégories)
- RGPD / export / suppression compte

---

## Légende

- **[x]** : déjà largement en place dans le dépôt à date de rédaction.
- **[ ]** : prévu ou partiel ; détail dans les issues / PR.

Pour l’architecture technique, voir [ARCHITECTURE.md](./ARCHITECTURE.md). Pour la base : [DB_SCHEMA.md](./DB_SCHEMA.md).
