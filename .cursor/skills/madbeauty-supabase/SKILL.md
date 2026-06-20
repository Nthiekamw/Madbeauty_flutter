---
name: madbeauty-supabase
description: >-
  Backend Supabase MadBeauty : migrations SQL, RLS, Edge Functions TypeScript,
  schéma PostgreSQL. Utiliser pour tables, policies, triggers, fonctions
  serverless, sync Stripe, ou questions sur docs/DB_SCHEMA.md.
---

# Supabase MadBeauty

## Contrainte production

Concevoir chaque changement backend comme pour une application de production à très forte échelle.

- prioriser intégrité des données, idempotence, sécurité et observabilité
- éviter les opérations coûteuses, ambiguës ou risquées sous forte concurrence
- penser indexation, volumétrie, rollback, compatibilité migration et effets de bord
- appliquer des pratiques de backend robustes comparables à celles attendues dans les grandes applications en production

## Emplacements

| Élément | Chemin |
|---------|--------|
| Migrations SQL | `supabase/migrations/` (timestamp + nom) |
| Edge Functions | `supabase/functions/<nom>/index.ts` |
| Helpers partagés | `supabase/functions/_shared/` |
| Schéma documenté | `docs/DB_SCHEMA.md` |
| Commandes CLI | `supabase/MIGRATIONS_COMMANDS.md` |

## Migrations

```powershell
npx supabase migration new <nom_snake_case>
npx supabase db push          # remote (projet lié)
npx supabase db reset         # local — rejoue toutes les migrations
```

- Une migration = une intention (policy, colonne, index…)
- **RLS activée** sur les tables ; toujours définir les policies explicites
- Tester en local avant push (`db reset` + vérif app)
- Nom de fichier : `YYYYMMDDHHMMSS_description.sql`

## Edge Functions

- Runtime **Deno / TypeScript**
- CORS : `supabase/functions/_shared/cors.ts`
- Stripe : `_shared/stripe_connect.ts`
- Déployer selon le README dans `supabase/functions/`

## Tables principales (rappel)

`profiles`, `prestataires`, `services`, `disponibilites`, `bookings`, `reviews`, `messages`, `favoris` — détail et relations dans `docs/DB_SCHEMA.md`.

## Côté Flutter

- Client Supabase via services dans `lib/services/supabase/`
- Init : `SupabaseService` avec `SupabaseTimeoutHttpClient` (10 s HTTP + Realtime) — voir skill `madbeauty-performance`
- Modèles domaine + `SupabaseDomainCodec` — pas de Map bruts dans l’UI
- Après changement de schéma : adapter modèles Freezed + `build_runner`

## Sécurité

- Jamais de `service_role` dans l’app mobile
- Secrets (Stripe webhook, etc.) uniquement en Edge Functions / env Supabase

## Checklist PR SQL

- [ ] Migration idempotente ou ordre clair
- [ ] Policies RLS pour SELECT/INSERT/UPDATE/DELETE selon rôle client/prestataire
- [ ] `docs/DB_SCHEMA.md` mis à jour si changement structurel notable
- [ ] `supabase db reset` OK en local
