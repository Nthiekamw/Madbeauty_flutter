-- Overrides de capacité par tranche horaire (récurrence hebdomadaire).
-- Exemple: mercredi 09:00-11:00 => 1, 12:00-14:00 => 3, 15:00-18:00 => 2.

create table if not exists public.disponibilite_capacity_overrides (
  id uuid primary key default gen_random_uuid(),
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  jour_semaine smallint not null,
  heure_debut time not null,
  heure_fin time not null,
  capacite_simultanee smallint not null default 1,
  constraint disponibilite_capacity_overrides_jour_check
    check (jour_semaine >= 0 and jour_semaine <= 6),
  constraint disponibilite_capacity_overrides_hours_check
    check (heure_fin > heure_debut),
  constraint disponibilite_capacity_overrides_cap_check
    check (capacite_simultanee >= 1 and capacite_simultanee <= 10)
);

create index if not exists idx_dispo_capacity_overrides_presta_day
  on public.disponibilite_capacity_overrides (prestataire_id, jour_semaine, heure_debut);

comment on table public.disponibilite_capacity_overrides is
  'Surcharge de capacité simultanée par tranches horaires hebdomadaires.';

alter table public.disponibilite_capacity_overrides enable row level security;

create policy "dispo_capacity_overrides_select_authenticated"
on public.disponibilite_capacity_overrides for select to authenticated
using (true);

create policy "dispo_capacity_overrides_write_own"
on public.disponibilite_capacity_overrides for all to authenticated
using (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = disponibilite_capacity_overrides.prestataire_id
      and p.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = disponibilite_capacity_overrides.prestataire_id
      and p.user_id = auth.uid()
  )
);
