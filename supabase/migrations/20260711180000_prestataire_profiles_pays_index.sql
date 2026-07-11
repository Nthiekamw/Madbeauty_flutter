-- Index catalogue par pays (filtrage marché côté app).
create index if not exists idx_prestataire_profiles_pays
  on public.prestataire_profiles (pays);

create index if not exists idx_client_profiles_pays
  on public.client_profiles (pays);

comment on index public.idx_prestataire_profiles_pays is
  'Accélère le filtrage catalogue par marché (pays ISO).';
