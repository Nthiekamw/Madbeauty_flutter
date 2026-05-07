-- MadBeauty — première migration (extensions PostgreSQL courantes).
-- Ajoute les tables / RLS dans de nouveaux fichiers : supabase migration new ma_description
-- Puis : supabase db push (projet lié) ou appliquer depuis le dashboard.

create extension if not exists "uuid-ossp";
