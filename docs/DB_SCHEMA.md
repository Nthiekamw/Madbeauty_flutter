# Schéma base de données MadBeauty (Supabase / PostgreSQL)

Référence des tables **`public`**, colonnes, relations et **Row Level Security (RLS)** après application des migrations du dépôt.

> Ordre d’application : `20260507140000_init_extensions` → `20260507215055_init_schema` (vide) → `20260508113500_auth_profiles_and_roles` → `20260510120000_domain_schema_core` (remplace `profiles` par `user_profiles`).

---

## Types énumérés

| Type | Valeurs |
|------|---------|
| `public.app_role` | `client`, `prestataire` |

---

## Tables auth / profil global

### `auth.users` (schéma Supabase, non listé ici en détail)

Référence standard Supabase : `id`, `email`, métadonnées, etc.

### `public.user_profiles`

Profil identité (1:1 avec `auth.users`). Remplace l’ancienne table `profiles` après migration `20260510120000`.

| Colonne | Type | Contraintes |
|---------|------|-------------|
| `id` | `uuid` | PK, `default gen_random_uuid()` |
| `user_id` | `uuid` | NOT NULL, UNIQUE, FK → `auth.users(id)` ON DELETE CASCADE |
| `nom` | `text` | nullable |
| `prenom` | `text` | nullable |
| `avatar_url` | `text` | nullable |
| `telephone` | `text` | nullable |
| `updated_at` | `timestamptz` | NOT NULL, default `now()` ; trigger `set_updated_at` |

**Trigger** : `trg_user_profiles_updated_at` → `public.set_updated_at()`.

### `public.user_roles`

Rôles applicatifs (multi-rôle par utilisateur).

| Colonne | Type | Contraintes |
|---------|------|-------------|
| `user_id` | `uuid` | PK (composite), FK → `auth.users(id)` ON DELETE CASCADE |
| `role` | `app_role` | PK (composite) |
| `created_at` | `timestamptz` | NOT NULL, default `now()` |

**Trigger auth** : `handle_new_user` sur `auth.users` insère une ligne `user_profiles` + rôle `client` dans `user_roles`.

---

## Profils métier client / prestataire

### `public.client_profiles`

| Colonne | Type | Contraintes |
|---------|------|-------------|
| `id` | `uuid` | PK |
| `user_id` | `uuid` | NOT NULL, UNIQUE, FK → `auth.users(id)` ON DELETE CASCADE |
| `adresse` | `text` | nullable |
| `created_at` | `timestamptz` | NOT NULL, default `now()` |

### `public.prestataire_profiles`

| Colonne | Type | Contraintes |
|---------|------|-------------|
| `id` | `uuid` | PK |
| `user_id` | `uuid` | NOT NULL, UNIQUE, FK → `auth.users(id)` ON DELETE CASCADE |
| `nom_salon` | `text` | nullable |
| `bio` | `text` | nullable |
| `ville` | `text` | nullable |
| `latitude` | `double precision` | nullable |
| `longitude` | `double precision` | nullable |
| `note_moyenne` | `double precision` | nullable |
| `is_verified` | `boolean` | NOT NULL, default `false` |
| `created_at` | `timestamptz` | NOT NULL, default `now()` |

**Index** : `idx_prestataire_profiles_ville` sur `ville`.

---

## Catalogue

### `public.categories_service`

| Colonne | Type | Contraintes |
|---------|------|-------------|
| `id` | `uuid` | PK |
| `nom` | `text` | NOT NULL |
| `icone` | `text` | nullable |

### `public.prestataire_specialites`

Table de liaison **prestataire ↔ catégorie**.

| Colonne | Type | Contraintes |
|---------|------|-------------|
| `prestataire_id` | `uuid` | PK (composite), FK → `prestataire_profiles(id)` ON DELETE CASCADE |
| `categorie_id` | `uuid` | PK (composite), FK → `categories_service(id)` ON DELETE CASCADE |

### `public.services_beaute`

| Colonne | Type | Contraintes |
|---------|------|-------------|
| `id` | `uuid` | PK |
| `prestataire_id` | `uuid` | NOT NULL, FK → `prestataire_profiles(id)` ON DELETE CASCADE |
| `nom` | `text` | NOT NULL |
| `duree_minutes` | `integer` | NOT NULL, `> 0` |
| `prix` | `numeric(12,2)` | NOT NULL, `>= 0` |
| `is_actif` | `boolean` | NOT NULL, default `true` |

**Index** : `idx_services_beaute_prestataire` sur `prestataire_id`.

---

## Réservations, avis, médias, favoris

### `public.reservations`

| Colonne | Type | Contraintes |
|---------|------|-------------|
| `id` | `uuid` | PK |
| `client_id` | `uuid` | NOT NULL, FK → `client_profiles(id)` ON DELETE CASCADE |
| `prestataire_id` | `uuid` | NOT NULL, FK → `prestataire_profiles(id)` ON DELETE CASCADE |
| `service_id` | `uuid` | NOT NULL, FK → `services_beaute(id)` ON DELETE RESTRICT |
| `date_heure` | `timestamptz` | NOT NULL |
| `statut` | `text` | NOT NULL, default `'en_attente'` |
| `notes_client` | `text` | nullable |
| `created_at` | `timestamptz` | NOT NULL, default `now()` |

**Index** : `date_heure`, `client_id`, `prestataire_id`.

### `public.avis`

| Colonne | Type | Contraintes |
|---------|------|-------------|
| `id` | `uuid` | PK |
| `client_id` | `uuid` | NOT NULL, FK → `client_profiles(id)` ON DELETE CASCADE |
| `prestataire_id` | `uuid` | NOT NULL, FK → `prestataire_profiles(id)` ON DELETE CASCADE |
| `reservation_id` | `uuid` | NOT NULL, UNIQUE, FK → `reservations(id)` ON DELETE CASCADE |
| `note` | `integer` | NOT NULL, entre 1 et 5 |
| `commentaire` | `text` | nullable |
| `created_at` | `timestamptz` | NOT NULL, default `now()` |

### `public.photos_realisation`

| Colonne | Type | Contraintes |
|---------|------|-------------|
| `id` | `uuid` | PK |
| `prestataire_id` | `uuid` | NOT NULL, FK → `prestataire_profiles(id)` ON DELETE CASCADE |
| `url` | `text` | NOT NULL |
| `caption` | `text` | nullable |
| `categorie_id` | `uuid` | nullable, FK → `categories_service(id)` ON DELETE SET NULL |
| `created_at` | `timestamptz` | NOT NULL, default `now()` |

### `public.favoris`

| Colonne | Type | Contraintes |
|---------|------|-------------|
| `client_id` | `uuid` | PK (composite), FK → `client_profiles(id)` ON DELETE CASCADE |
| `prestataire_id` | `uuid` | PK (composite), FK → `prestataire_profiles(id)` ON DELETE CASCADE |
| `created_at` | `timestamptz` | NOT NULL, default `now()` |

---

## Messagerie

### `public.conversations`

| Colonne | Type | Contraintes |
|---------|------|-------------|
| `id` | `uuid` | PK |
| `client_id` | `uuid` | NOT NULL, FK → `client_profiles(id)` ON DELETE CASCADE |
| `prestataire_id` | `uuid` | NOT NULL, FK → `prestataire_profiles(id)` ON DELETE CASCADE |
| `last_message_at` | `timestamptz` | nullable |

**Contrainte UNIQUE** : `(client_id, prestataire_id)`.

### `public.messages`

| Colonne | Type | Contraintes |
|---------|------|-------------|
| `id` | `uuid` | PK |
| `conversation_id` | `uuid` | NOT NULL, FK → `conversations(id)` ON DELETE CASCADE |
| `sender_id` | `uuid` | NOT NULL, FK → `auth.users(id)` ON DELETE CASCADE |
| `contenu` | `text` | NOT NULL |
| `is_read` | `boolean` | NOT NULL, default `false` |
| `created_at` | `timestamptz` | NOT NULL, default `now()` |

**Index** : `idx_messages_conversation` sur `(conversation_id, created_at DESC)`.

---

## Diagramme relationnel (résumé)

```mermaid
erDiagram
  auth_users ||--o| user_profiles : user_id
  auth_users ||--o{ user_roles : user_id
  auth_users ||--o| client_profiles : user_id
  auth_users ||--o| prestataire_profiles : user_id
  prestataire_profiles ||--o{ prestataire_specialites : prestataire_id
  categories_service ||--o{ prestataire_specialites : categorie_id
  prestataire_profiles ||--o{ services_beaute : prestataire_id
  client_profiles ||--o{ reservations : client_id
  prestataire_profiles ||--o{ reservations : prestataire_id
  services_beaute ||--o{ reservations : service_id
  reservations ||--o| avis : reservation_id
  client_profiles ||--o{ avis : client_id
  prestataire_profiles ||--o{ avis : prestataire_id
  prestataire_profiles ||--o{ photos_realisation : prestataire_id
  client_profiles ||--o{ favoris : client_id
  prestataire_profiles ||--o{ favoris : prestataire_id
  client_profiles ||--o{ conversations : client_id
  prestataire_profiles ||--o{ conversations : prestataire_id
  conversations ||--o{ messages : conversation_id
  auth_users ||--o{ messages : sender_id
```

---

## RLS (policies `authenticated` sauf mention)

Toutes les tables listées ci-dessous ont **RLS activé**.

### `user_profiles`

| Policy | Commande | Règle |
|--------|----------|--------|
| `user_profiles_select_own` | SELECT | `auth.uid() = user_id` |
| `user_profiles_insert_own` | INSERT | idem `WITH CHECK` |
| `user_profiles_update_own` | UPDATE | USING + WITH CHECK |

### `user_roles`

| Policy | Commande | Règle |
|--------|----------|--------|
| `user_roles_select_own` | SELECT | `auth.uid() = user_id` |
| `user_roles_insert_own` | INSERT | `WITH CHECK` |
| `user_roles_delete_own` | DELETE | USING |

### `client_profiles`

| Policy | Commande | Règle |
|--------|----------|--------|
| `client_profiles_select_own` | SELECT | `auth.uid() = user_id` |
| `client_profiles_insert_own` | INSERT | `WITH CHECK` |
| `client_profiles_update_own` | UPDATE | USING + WITH CHECK |

### `prestataire_profiles`

| Policy | Commande | Règle |
|--------|----------|--------|
| `prestataire_profiles_select_authenticated` | SELECT | `true` (tous les utilisateurs connectés) |
| `prestataire_profiles_insert_own` | INSERT | `auth.uid() = user_id` |
| `prestataire_profiles_update_own` | UPDATE | USING + WITH CHECK |

### `categories_service`

| Policy | Rôle | Commande | Règle |
|--------|------|----------|--------|
| `categories_service_select_authenticated` | `authenticated` | SELECT | `true` |
| `categories_service_all_service_role` | `service_role` | ALL | `true` |

Les clients **ne peuvent pas** insérer / modifier les catégories via l’API anon/authenticated ; seed / admin via `service_role`.

### `prestataire_specialites`

| Policy | Commande | Règle |
|--------|----------|--------|
| `prestataire_specialites_select_authenticated` | SELECT | `true` |
| `prestataire_specialites_write_own` | ALL | ligne liée à un `prestataire_profiles` dont `user_id = auth.uid()` |

### `services_beaute`

| Policy | Commande | Règle |
|--------|----------|--------|
| `services_beaute_select_authenticated` | SELECT | `true` |
| `services_beaute_write_own` | ALL | prestataire propriétaire (`user_id = auth.uid()`) |

### `reservations`

| Policy | Commande | Règle |
|--------|----------|--------|
| `reservations_select_participant` | SELECT | client ou prestataire de la réservation |
| `reservations_insert_client` | INSERT | `client_id` appartient au client courant |
| `reservations_update_participant` | UPDATE | client ou prestataire participant |

### `avis`

| Policy | Commande | Règle |
|--------|----------|--------|
| `avis_select_authenticated` | SELECT | `true` |
| `avis_insert_own_client` | INSERT | `client_id` = profil client du `auth.uid()` |

(Pas de UPDATE/DELETE explicites : à ajouter si besoin métier.)

### `photos_realisation`

| Policy | Commande | Règle |
|--------|----------|--------|
| `photos_realisation_select_authenticated` | SELECT | `true` |
| `photos_realisation_write_own` | ALL | prestataire propriétaire |

### `favoris`

| Policy | Commande | Règle |
|--------|----------|--------|
| `favoris_select_own` | SELECT | favori du client courant |
| `favoris_write_own` | ALL | idem |

### `conversations`

| Policy | Commande | Règle |
|--------|----------|--------|
| `conversations_select_participant` | SELECT | client ou prestataire de la conversation |
| `conversations_insert_participant` | INSERT | idem (WITH CHECK) |
| `conversations_update_participant` | UPDATE | idem |

### `messages`

| Policy | Commande | Règle |
|--------|----------|--------|
| `messages_select_participant` | SELECT | participant à la conversation |
| `messages_insert_sender` | INSERT | `sender_id = auth.uid()` et participant |
| `messages_update_participant` | UPDATE | participant |

---

## Fonctions / triggers partagés

| Objet | Rôle |
|-------|------|
| `public.set_updated_at()` | Met `updated_at` à `now()` (trigger avant UPDATE). |
| `public.handle_new_user()` | Après création `auth.users` : upsert `user_profiles`, rôle `client` dans `user_roles`. |

---

## Lecture invité (`anon`)

La plupart des policies ci-dessus ciblent **`authenticated`**. Pour afficher catalogue / fiches sans compte, prévoir des policies **`anon`** ciblées (évolution produit).
