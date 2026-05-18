-- Créneaux récurrents (horaires de travail) et indisponibilités ponctuelles (congés).
-- Prérequis : prestataire_profiles (20260510120000_domain_schema_core).

-- ---------------------------------------------------------------------------
-- disponibilites — plages horaires par jour de semaine
-- jour_semaine : 0 = dimanche … 6 = samedi (comme extract(dow from timestamp) en PG)
-- ---------------------------------------------------------------------------

create table public.disponibilites (
  id uuid primary key default gen_random_uuid(),
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  jour_semaine smallint not null,
  heure_debut time not null,
  heure_fin time not null,
  constraint disponibilites_jour_semaine_check
    check (jour_semaine >= 0 and jour_semaine <= 6),
  constraint disponibilites_heures_check
    check (heure_fin > heure_debut)
);

create index idx_disponibilites_prestataire
  on public.disponibilites (prestataire_id);

create index idx_disponibilites_prestataire_jour
  on public.disponibilites (prestataire_id, jour_semaine);

comment on table public.disponibilites is
  'Plages horaires récurrentes du prestataire (base des créneaux réservables).';

comment on column public.disponibilites.jour_semaine is
  '0 = dimanche, 1 = lundi, …, 6 = samedi (convention PostgreSQL DOW).';

-- ---------------------------------------------------------------------------
-- indisponibilites — congés / fermetures exceptionnelles
-- ---------------------------------------------------------------------------

create table public.indisponibilites (
  id uuid primary key default gen_random_uuid(),
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  date_debut timestamptz not null,
  date_fin timestamptz not null,
  constraint indisponibilites_dates_check
    check (date_fin > date_debut)
);

create index idx_indisponibilites_prestataire
  on public.indisponibilites (prestataire_id);

create index idx_indisponibilites_plage
  on public.indisponibilites (prestataire_id, date_debut, date_fin);

comment on table public.indisponibilites is
  'Périodes où le prestataire n''accepte pas de réservation (congés, jour off).';

-- ---------------------------------------------------------------------------
-- RLS
-- ---------------------------------------------------------------------------

alter table public.disponibilites enable row level security;
alter table public.indisponibilites enable row level security;

-- Lecture par tout utilisateur connecté (client qui réserve, prestataire qui gère).
create policy "disponibilites_select_authenticated"
on public.disponibilites for select to authenticated
using (true);

create policy "disponibilites_write_own"
on public.disponibilites for all to authenticated
using (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = disponibilites.prestataire_id
      and p.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = disponibilites.prestataire_id
      and p.user_id = auth.uid()
  )
);

create policy "indisponibilites_select_authenticated"
on public.indisponibilites for select to authenticated
using (true);

create policy "indisponibilites_write_own"
on public.indisponibilites for all to authenticated
using (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = indisponibilites.prestataire_id
      and p.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = indisponibilites.prestataire_id
      and p.user_id = auth.uid()
  )
);
