-- Reserved slots exposed to the booking flow.
-- This returns only occupied times, not client data.

create or replace function public.get_booked_booking_slots(
  p_prestataire_id uuid,
  p_service_id uuid,
  p_day date
)
returns table (date_heure timestamptz)
language sql
stable
security definer
set search_path = public
as $$
  select r.date_heure
  from public.reservations r
  where r.prestataire_id = p_prestataire_id
    and r.service_id = p_service_id
    and r.date_heure >= p_day::timestamptz
    and r.date_heure < (p_day::timestamptz + interval '1 day')
    and r.statut not in ('annulee', 'cancelled');
$$;

revoke all on function public.get_booked_booking_slots(uuid, uuid, date)
from public;

grant execute on function public.get_booked_booking_slots(uuid, uuid, date)
to anon, authenticated;
