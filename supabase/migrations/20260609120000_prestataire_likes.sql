-- Likes prestataire (client → prestataire) + compteur + notification push.

create table if not exists public.prestataire_likes (
  client_id uuid not null references public.client_profiles (id) on delete cascade,
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  client_display_name text,
  created_at timestamptz not null default now(),
  primary key (client_id, prestataire_id)
);

create or replace function public.set_prestataire_like_client_name()
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

    v_name := trim(both from concat_ws(' ', nullif(trim(v_prenom), ''), nullif(trim(v_nom), '')));
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

drop trigger if exists prestataire_like_set_client_name on public.prestataire_likes;
create trigger prestataire_like_set_client_name
  before insert on public.prestataire_likes
  for each row execute function public.set_prestataire_like_client_name();

create index if not exists idx_prestataire_likes_prestataire_created
  on public.prestataire_likes (prestataire_id, created_at desc);

alter table public.prestataire_profiles
  add column if not exists likes_count integer not null default 0;

alter table public.prestataire_profiles
  drop constraint if exists prestataire_profiles_likes_count_nonneg;

alter table public.prestataire_profiles
  add constraint prestataire_profiles_likes_count_nonneg
  check (likes_count >= 0);

comment on column public.prestataire_profiles.likes_count is
  'Nombre de likes reçus de la part des clientes (dénormalisé).';

alter table public.prestataire_likes enable row level security;

create policy prestataire_likes_select_own
on public.prestataire_likes for select to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = prestataire_likes.client_id and c.user_id = auth.uid()
  )
);

create policy prestataire_likes_select_for_prestataire
on public.prestataire_likes for select to authenticated
using (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = prestataire_likes.prestataire_id and p.user_id = auth.uid()
  )
);

create policy prestataire_likes_insert_own
on public.prestataire_likes for insert to authenticated
with check (
  exists (
    select 1 from public.client_profiles c
    where c.id = client_id and c.user_id = auth.uid()
  )
  and not exists (
    select 1 from public.prestataire_profiles p
    where p.id = prestataire_id and p.user_id = auth.uid()
  )
);

create policy prestataire_likes_delete_own
on public.prestataire_likes for delete to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = prestataire_likes.client_id and c.user_id = auth.uid()
  )
);

create or replace function public.sync_prestataire_likes_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if TG_OP = 'INSERT' then
    update public.prestataire_profiles
    set likes_count = likes_count + 1
    where id = NEW.prestataire_id;
    return NEW;
  elsif TG_OP = 'DELETE' then
    update public.prestataire_profiles
    set likes_count = greatest(likes_count - 1, 0)
    where id = OLD.prestataire_id;
    return OLD;
  end if;
  return null;
end;
$$;

drop trigger if exists prestataire_likes_count_trigger on public.prestataire_likes;
create trigger prestataire_likes_count_trigger
  after insert or delete on public.prestataire_likes
  for each row execute function public.sync_prestataire_likes_count();

create or replace function public.trigger_prestataire_liked_push()
returns trigger
language plpgsql
security definer
set search_path = public, private
as $$
begin
  perform private.notify_edge_function(
    'on_prestataire_liked',
    jsonb_build_object(
      'type', 'INSERT',
      'table', 'prestataire_likes',
      'schema', 'public',
      'record', to_jsonb(NEW),
      'old_record', null
    )
  );
  return NEW;
end;
$$;

drop trigger if exists prestataire_liked_push_trigger on public.prestataire_likes;
create trigger prestataire_liked_push_trigger
  after insert on public.prestataire_likes
  for each row execute function public.trigger_prestataire_liked_push();
