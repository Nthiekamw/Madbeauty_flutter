-- Empêcher deux réservations « actives » sur le même créneau minute
-- pour un prestataire + service (protection race condition avec l’INSERT).
--
-- extract(epoch from timestamptz) n’est pas IMMUTABLE pour l’indexeur : on
-- encapsule le calcul dans une fonction SQL marquée IMMUTABLE (même résultat
-- que le client Dart : floor(epoch_seconds / 60)).
-- Même filtre d’exclusion que public.get_booked_booking_slots (statut actif).

create or replace function public.reservation_minute_bucket_utc(p_ts timestamptz)
returns bigint
language sql
immutable
parallel safe
strict
as $$
  select (floor(extract(epoch from p_ts) / 60))::bigint;
$$;

comment on function public.reservation_minute_bucket_utc(timestamptz) is
  'Minute UTC (bucket) pour l’index unique des créneaux réservés ; usage interne.';

revoke all on function public.reservation_minute_bucket_utc(timestamptz) from public;

create unique index if not exists reservations_active_slot_uniq
on public.reservations (
  prestataire_id,
  service_id,
  public.reservation_minute_bucket_utc(date_heure)
)
where statut not in ('annulee', 'cancelled');
