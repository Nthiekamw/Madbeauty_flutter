-- Notification push + nom cliente sur les avis (INSERT uniquement).

alter table public.avis
  add column if not exists client_display_name text;

comment on column public.avis.client_display_name is
  'Prénom/nom affiché pour les notifications prestataire (rempli à l''insertion).';

create or replace function public.set_avis_client_display_name()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_user_id uuid;
  v_prenom text;
  v_nom text;
  v_name text;
begin
  select c.user_id into v_user_id
  from public.client_profiles c
  where c.id = NEW.client_id;

  if v_user_id is not null then
    select up.prenom, up.nom into v_prenom, v_nom
    from public.user_profiles up
    where up.user_id = v_user_id;

    v_name := trim(both from concat_ws(
      ' ',
      nullif(trim(v_prenom), ''),
      nullif(trim(v_nom), '')
    ));
    if v_name <> '' then
      NEW.client_display_name := v_name;
    end if;
  end if;

  if NEW.client_display_name is null or trim(NEW.client_display_name) = '' then
    NEW.client_display_name := 'Une cliente';
  end if;

  return NEW;
end;
$$;

drop trigger if exists avis_set_client_display_name on public.avis;
create trigger avis_set_client_display_name
  before insert on public.avis
  for each row execute function public.set_avis_client_display_name();

create or replace function public.trigger_prestataire_reviewed_push()
returns trigger
language plpgsql
security definer
set search_path = public, private
as $$
begin
  perform private.notify_edge_function(
    'on_prestataire_reviewed',
    jsonb_build_object(
      'type', 'INSERT',
      'table', 'avis',
      'schema', 'public',
      'record', to_jsonb(NEW),
      'old_record', null
    )
  );
  return NEW;
end;
$$;

drop trigger if exists prestataire_reviewed_push_trigger on public.avis;
create trigger prestataire_reviewed_push_trigger
  after insert on public.avis
  for each row execute function public.trigger_prestataire_reviewed_push();
