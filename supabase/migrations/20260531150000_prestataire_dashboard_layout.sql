-- Préférences dashboard prestataire : ordre des sections + sections repliées.
alter table public.prestataire_profiles
  add column if not exists dashboard_layout jsonb;

comment on column public.prestataire_profiles.dashboard_layout is
  'JSON { order: string[], collapsed: string[] } pour le dashboard prestataire.';
