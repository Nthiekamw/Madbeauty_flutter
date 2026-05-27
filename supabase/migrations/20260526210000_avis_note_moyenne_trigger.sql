-- Recalcule prestataire_profiles.note_moyenne à chaque changement sur avis.

create or replace function public.refresh_prestataire_note_moyenne(p_prestataire_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_avg double precision;
begin
  if p_prestataire_id is null then
    return;
  end if;

  select avg(note)::double precision
  into v_avg
  from public.avis
  where prestataire_id = p_prestataire_id;

  update public.prestataire_profiles
  set note_moyenne = v_avg
  where id = p_prestataire_id;
end;
$$;

create or replace function public.trg_avis_refresh_note_moyenne()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_prestataire_id uuid;
begin
  v_prestataire_id := coalesce(
    NEW.prestataire_id,
    OLD.prestataire_id
  );
  perform public.refresh_prestataire_note_moyenne(v_prestataire_id);
  return coalesce(NEW, OLD);
end;
$$;

drop trigger if exists avis_refresh_note_moyenne on public.avis;
create trigger avis_refresh_note_moyenne
after insert or update or delete on public.avis
for each row execute function public.trg_avis_refresh_note_moyenne();

-- Un avis uniquement si la réservation est terminée et appartient au client.
create or replace function public.avis_check_reservation_before_insert()
returns trigger
language plpgsql
as $$
declare
  v_statut text;
  v_client_id uuid;
  v_prestataire_id uuid;
begin
  select
    lower(trim(r.statut)),
    r.client_id,
    r.prestataire_id
  into v_statut, v_client_id, v_prestataire_id
  from public.reservations r
  where r.id = NEW.reservation_id;

  if v_client_id is null then
    raise exception 'Réservation introuvable pour cet avis';
  end if;

  if NEW.client_id <> v_client_id then
    raise exception 'Seul le client de la réservation peut laisser un avis';
  end if;

  if v_statut not in (
    'terminee', 'terminée', 'termine', 'terminé',
    'done', 'completed', 'realisee', 'réalisée'
  ) then
    raise exception 'La réservation doit être terminée pour laisser un avis';
  end if;

  NEW.prestataire_id := v_prestataire_id;
  return NEW;
end;
$$;

drop trigger if exists avis_check_reservation_before_insert on public.avis;
create trigger avis_check_reservation_before_insert
before insert on public.avis
for each row execute function public.avis_check_reservation_before_insert();

-- Rattrapage note_moyenne existante
do $$
declare
  r record;
begin
  for r in select distinct prestataire_id from public.avis
  loop
    perform public.refresh_prestataire_note_moyenne(r.prestataire_id);
  end loop;
end $$;
