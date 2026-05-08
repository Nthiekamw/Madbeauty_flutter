# Commandes Supabase - Migrations (MadBeauty)

## Prerequis

- Etre a la racine du projet (`MadBeauty`).
- Etre connecte a Supabase CLI.
- Projet lie (`supabase link`) avant `db push`.

## 1) Initialiser Supabase en local (si pas deja fait)

```powershell
npx supabase init
```

## 2) Se connecter et lier le projet

```powershell
npx supabase login
npx supabase link --project-ref <PROJECT_REF>
```

## 3) Creer une nouvelle migration

```powershell
npx supabase migration new <nom_de_migration>
```

Exemple:

```powershell
npx supabase migration new add_user_roles
```

## 4) Appliquer les migrations sur le projet lie (remote)

```powershell
npx supabase db push
```

## 5) Rejouer toutes les migrations en local (dev)

```powershell
npx supabase db reset
```

## 6) Verifier l'etat des migrations

```powershell
npx supabase migration list
```

## 7) Generer un diff schema -> migration (optionnel)

```powershell
npx supabase db diff --schema public -f <nom_de_migration>
```

## 8) Pull du schema remote vers local (optionnel, attention)

```powershell
npx supabase db pull
```

## Workflow conseille

1. Creer migration: `npx supabase migration new ...`
2. Ecrire SQL dans `supabase/migrations/...sql`
3. Tester local: `npx supabase db reset`
4. Push remote: `npx supabase db push`
5. Verifier: `npx supabase migration list`

## Migration actuelle a appliquer

Pour la feature multi-role ajoutee:

```powershell
npx supabase db push
```

