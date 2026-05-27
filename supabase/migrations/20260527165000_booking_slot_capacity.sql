-- Capacité simultanée par plage horaire prestataire.
-- Permet d'accepter N réservations sur le même créneau minute.

alter table public.disponibilites
  add column if not exists capacite_simultanee smallint not null default 1;

alter table public.disponibilites
  drop constraint if exists disponibilites_capacite_simultanee_check;

alter table public.disponibilites
  add constraint disponibilites_capacite_simultanee_check
  check (capacite_simultanee >= 1 and capacite_simultanee <= 5);

comment on column public.disponibilites.capacite_simultanee is
  'Nombre maximal de clients acceptés en simultané sur la plage.';

-- L'unicité "1 réservation active par créneau" ne convient plus avec la capacité > 1.
drop index if exists public.reservations_active_slot_uniq;

create index if not exists reservations_active_slot_lookup_idx
on public.reservations (
  prestataire_id,
  public.reservation_minute_bucket_utc(date_heure)
)
where statut not in ('annulee', 'cancelled');
