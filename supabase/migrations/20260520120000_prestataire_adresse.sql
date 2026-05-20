-- Adresse postale du salon (complément à ville + géolocalisation).
alter table public.prestataire_profiles
  add column if not exists adresse text;

comment on column public.prestataire_profiles.adresse is
  'Adresse postale du salon (rue, numéro, complément).';
