-- Motif de refus / note prestataire + Realtime sur les réservations.
alter table public.reservations
  add column if not exists notes_prestataire text;

comment on column public.reservations.notes_prestataire is
  'Note ou motif saisi par le prestataire (ex. refus).';

alter table public.reservations replica identity full;

do $$
begin
  alter publication supabase_realtime add table public.reservations;
exception
  when duplicate_object then null;
end $$;
