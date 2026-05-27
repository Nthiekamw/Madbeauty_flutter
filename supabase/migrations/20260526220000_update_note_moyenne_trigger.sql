-- Trigger update_note_moyenne : après INSERT sur avis (domaine « reviews »).
-- Recalcule prestataire_profiles.note_moyenne (alias métier : prestataires.note_moyenne).

create or replace function public.update_note_moyenne()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_avg double precision;
  v_prestataire_id uuid;
begin
  v_prestataire_id := NEW.prestataire_id;

  select avg(note)::double precision
  into v_avg
  from public.avis
  where prestataire_id = v_prestataire_id;

  update public.prestataire_profiles
  set note_moyenne = v_avg
  where id = v_prestataire_id;

  return NEW;
end;
$$;

comment on function public.update_note_moyenne() is
  'Recalcule note_moyenne du prestataire après un nouvel avis (INSERT avis / reviews).';

drop trigger if exists update_note_moyenne on public.avis;
create trigger update_note_moyenne
after insert on public.avis
for each row execute function public.update_note_moyenne();

-- INSERT géré par update_note_moyenne ; UPDATE/DELETE par l’ancien refresh.
drop trigger if exists avis_refresh_note_moyenne on public.avis;
create trigger avis_refresh_note_moyenne
after update or delete on public.avis
for each row execute function public.trg_avis_refresh_note_moyenne();

-- Vue lecture « reviews » (table physique : avis)
create or replace view public.reviews
with (security_invoker = true)
as
select
  id,
  client_id,
  prestataire_id,
  reservation_id as booking_id,
  note,
  commentaire,
  created_at
from public.avis;

comment on view public.reviews is
  'Alias lecture des avis clients (table public.avis).';

grant select on public.reviews to authenticated, anon;

-- Realtime : note_moyenne sur la fiche prestataire
alter table public.prestataire_profiles replica identity full;

do $$
begin
  alter publication supabase_realtime add table public.prestataire_profiles;
exception
  when duplicate_object then null;
end $$;
