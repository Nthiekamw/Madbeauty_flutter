-- Reel MadBeauty : posts photo/vidéo, likes, vues, feed ranké (réservations + ville + catégories + engagement).

create table if not exists public.reel_posts (
  id uuid primary key default gen_random_uuid(),
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  media_type text not null
    check (media_type in ('image', 'video')),
  media_url text not null,
  caption text,
  status text not null default 'published'
    check (status in ('draft', 'published', 'hidden')),
  likes_count integer not null default 0
    check (likes_count >= 0),
  views_count integer not null default 0
    check (views_count >= 0),
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint reel_posts_media_url_nonempty check (length(trim(media_url)) > 0),
  constraint reel_posts_caption_len check (
    caption is null or char_length(caption) <= 500
  )
);

create index if not exists idx_reel_posts_feed
  on public.reel_posts (status, created_at desc, id desc)
  where status = 'published';

create index if not exists idx_reel_posts_prestataire_created
  on public.reel_posts (prestataire_id, created_at desc);

create table if not exists public.reel_likes (
  reel_id uuid not null references public.reel_posts (id) on delete cascade,
  client_id uuid not null references public.client_profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (reel_id, client_id)
);

create index if not exists idx_reel_likes_client
  on public.reel_likes (client_id, created_at desc);

create table if not exists public.reel_views (
  reel_id uuid not null references public.reel_posts (id) on delete cascade,
  viewer_user_id uuid not null references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (reel_id, viewer_user_id)
);

create or replace function public.reel_posts_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at := now();
  return new;
end;
$$;

drop trigger if exists trg_reel_posts_updated_at on public.reel_posts;
create trigger trg_reel_posts_updated_at
before update on public.reel_posts
for each row execute function public.reel_posts_set_updated_at();

create or replace function public.reel_posts_enforce_publisher()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if not exists (
    select 1
    from public.prestataire_profiles p
    where p.id = new.prestataire_id
      and p.user_id = auth.uid()
  ) then
    raise exception 'reel_posts: prestataire non propriétaire';
  end if;

  if new.status = 'published'
     and not public.prestataire_is_catalog_visible(new.prestataire_id) then
    raise exception 'reel_posts: prestataire non validé pour publier';
  end if;

  return new;
end;
$$;

drop trigger if exists trg_reel_posts_enforce_publisher on public.reel_posts;
create trigger trg_reel_posts_enforce_publisher
before insert or update on public.reel_posts
for each row execute function public.reel_posts_enforce_publisher();

create or replace function public.reel_likes_sync_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    update public.reel_posts
    set likes_count = likes_count + 1
    where id = new.reel_id;
    return new;
  elsif tg_op = 'DELETE' then
    update public.reel_posts
    set likes_count = greatest(0, likes_count - 1)
    where id = old.reel_id;
    return old;
  end if;
  return null;
end;
$$;

drop trigger if exists trg_reel_likes_sync_count on public.reel_likes;
create trigger trg_reel_likes_sync_count
after insert or delete on public.reel_likes
for each row execute function public.reel_likes_sync_count();

alter table public.reel_posts enable row level security;
alter table public.reel_likes enable row level security;
alter table public.reel_views enable row level security;

drop policy if exists "reel_posts_select_published" on public.reel_posts;
create policy "reel_posts_select_published"
on public.reel_posts for select
to anon, authenticated
using (
  status = 'published'
  and public.prestataire_is_catalog_visible(prestataire_id)
);

drop policy if exists "reel_posts_select_own" on public.reel_posts;
create policy "reel_posts_select_own"
on public.reel_posts for select
to authenticated
using (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = reel_posts.prestataire_id
      and p.user_id = auth.uid()
  )
);

drop policy if exists "reel_posts_insert_own" on public.reel_posts;
create policy "reel_posts_insert_own"
on public.reel_posts for insert
to authenticated
with check (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = reel_posts.prestataire_id
      and p.user_id = auth.uid()
  )
);

drop policy if exists "reel_posts_update_own" on public.reel_posts;
create policy "reel_posts_update_own"
on public.reel_posts for update
to authenticated
using (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = reel_posts.prestataire_id
      and p.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = reel_posts.prestataire_id
      and p.user_id = auth.uid()
  )
);

drop policy if exists "reel_posts_delete_own" on public.reel_posts;
create policy "reel_posts_delete_own"
on public.reel_posts for delete
to authenticated
using (
  exists (
    select 1 from public.prestataire_profiles p
    where p.id = reel_posts.prestataire_id
      and p.user_id = auth.uid()
  )
);

drop policy if exists "reel_likes_select_own" on public.reel_likes;
create policy "reel_likes_select_own"
on public.reel_likes for select
to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = reel_likes.client_id
      and c.user_id = auth.uid()
  )
);

drop policy if exists "reel_likes_insert_own" on public.reel_likes;
create policy "reel_likes_insert_own"
on public.reel_likes for insert
to authenticated
with check (
  exists (
    select 1 from public.client_profiles c
    where c.id = reel_likes.client_id
      and c.user_id = auth.uid()
  )
);

drop policy if exists "reel_likes_delete_own" on public.reel_likes;
create policy "reel_likes_delete_own"
on public.reel_likes for delete
to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = reel_likes.client_id
      and c.user_id = auth.uid()
  )
);

drop policy if exists "reel_views_insert_own" on public.reel_views;
create policy "reel_views_insert_own"
on public.reel_views for insert
to authenticated
with check (viewer_user_id = auth.uid());

drop policy if exists "reel_views_select_own" on public.reel_views;
create policy "reel_views_select_own"
on public.reel_views for select
to authenticated
using (viewer_user_id = auth.uid());

-- Feed ranké : réservations + ville + catégories + engagement + fraîcheur.
create or replace function public.list_reel_feed(
  p_limit integer default 20,
  p_cursor_score double precision default null,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns table (
  id uuid,
  prestataire_id uuid,
  media_type text,
  media_url text,
  caption text,
  likes_count integer,
  views_count integer,
  created_at timestamptz,
  score double precision,
  liked_by_me boolean,
  salon_name text,
  avatar_url text,
  ville text
)
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_client_id uuid;
  v_client_ville text;
  v_limit integer := greatest(1, least(coalesce(p_limit, 20), 50));
begin
  select c.id, nullif(lower(trim(c.ville)), '')
  into v_client_id, v_client_ville
  from public.client_profiles c
  where c.user_id = auth.uid()
  limit 1;

  return query
  with client_cats as (
    select distinct s.categorie_id
    from public.reservations r
    join public.services_beaute s on s.id = r.service_id
    where v_client_id is not null
      and r.client_id = v_client_id
      and s.categorie_id is not null
      and r.statut in ('confirmee', 'terminee', 'confirmed', 'completed', 'done')
  ),
  ranked as (
    select
      rp.id,
      rp.prestataire_id,
      rp.media_type,
      rp.media_url,
      rp.caption,
      rp.likes_count,
      rp.views_count,
      rp.created_at,
      (
        ln(1 + coalesce((
          select count(*)::double precision
          from public.reservations r
          where r.prestataire_id = rp.prestataire_id
            and r.statut in ('confirmee', 'terminee', 'confirmed', 'completed', 'done')
        ), 0)) * 3.0
        + case
            when v_client_ville is not null
             and nullif(lower(trim(pp.ville)), '') = v_client_ville
            then 5.0
            else 0.0
          end
        + (
            select coalesce(count(*)::double precision, 0) * 2.0
            from public.prestataire_specialites ps
            where ps.prestataire_id = rp.prestataire_id
              and exists (
                select 1 from client_cats cc
                where cc.categorie_id = ps.categorie_id
              )
          )
        + ln(1 + rp.likes_count::double precision) * 1.5
        + ln(1 + rp.views_count::double precision) * 0.5
        + greatest(0.0, 10.0 - extract(epoch from (now() - rp.created_at)) / 86400.0) * 0.3
      ) as score,
      exists (
        select 1
        from public.reel_likes rl
        where rl.reel_id = rp.id
          and v_client_id is not null
          and rl.client_id = v_client_id
      ) as liked_by_me,
      coalesce(
        nullif(trim(pp.nom_affiche), ''),
        nullif(trim(pp.nom_salon), ''),
        'Salon'
      ) as salon_name,
      up.avatar_url,
      pp.ville
    from public.reel_posts rp
    join public.prestataire_profiles pp on pp.id = rp.prestataire_id
    join public.user_profiles up on up.user_id = pp.user_id
    where rp.status = 'published'
      and public.prestataire_is_catalog_visible(rp.prestataire_id)
  )
  select
    r.id,
    r.prestataire_id,
    r.media_type,
    r.media_url,
    r.caption,
    r.likes_count,
    r.views_count,
    r.created_at,
    r.score,
    r.liked_by_me,
    r.salon_name,
    r.avatar_url,
    r.ville
  from ranked r
  where
    p_cursor_score is null
    or p_cursor_created_at is null
    or p_cursor_id is null
    or (r.score, r.created_at, r.id) < (p_cursor_score, p_cursor_created_at, p_cursor_id)
  order by r.score desc, r.created_at desc, r.id desc
  limit v_limit;
end;
$$;

revoke all on function public.list_reel_feed(integer, double precision, timestamptz, uuid) from public;
grant execute on function public.list_reel_feed(integer, double precision, timestamptz, uuid)
  to anon, authenticated;

create or replace function public.record_reel_view(p_reel_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    return;
  end if;

  with ins as (
    insert into public.reel_views (reel_id, viewer_user_id)
    values (p_reel_id, auth.uid())
    on conflict do nothing
    returning 1
  )
  update public.reel_posts rp
  set views_count = views_count + 1
  where rp.id = p_reel_id
    and rp.status = 'published'
    and exists (select 1 from ins);
end;
$$;

revoke all on function public.record_reel_view(uuid) from public;
grant execute on function public.record_reel_view(uuid) to authenticated;

create or replace function public.toggle_reel_like(p_reel_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_client_id uuid;
  v_liked boolean;
begin
  select c.id into v_client_id
  from public.client_profiles c
  where c.user_id = auth.uid()
  limit 1;

  if v_client_id is null then
    raise exception 'toggle_reel_like: profil client requis';
  end if;

  if exists (
    select 1 from public.reel_likes
    where reel_id = p_reel_id and client_id = v_client_id
  ) then
    delete from public.reel_likes
    where reel_id = p_reel_id and client_id = v_client_id;
    v_liked := false;
  else
    insert into public.reel_likes (reel_id, client_id)
    values (p_reel_id, v_client_id);
    v_liked := true;
  end if;

  return v_liked;
end;
$$;

revoke all on function public.toggle_reel_like(uuid) from public;
grant execute on function public.toggle_reel_like(uuid) to authenticated;

-- Storage
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'reel-media',
  'reel-media',
  true,
  52428800,
  null
)
on conflict (id) do update
set
  public = excluded.public,
  file_size_limit = excluded.file_size_limit,
  allowed_mime_types = excluded.allowed_mime_types;

drop policy if exists "reel_media_select_public" on storage.objects;
create policy "reel_media_select_public"
on storage.objects for select
to public
using (bucket_id = 'reel-media');

drop policy if exists "reel_media_insert_own_prestataire" on storage.objects;
create policy "reel_media_insert_own_prestataire"
on storage.objects for insert
to authenticated
with check (
  bucket_id = 'reel-media'
  and exists (
    select 1
    from public.prestataire_profiles p
    where p.id::text = (storage.foldername(name))[1]
      and p.user_id = auth.uid()
      and public.prestataire_is_catalog_visible(p.id)
  )
);

drop policy if exists "reel_media_update_own_prestataire" on storage.objects;
create policy "reel_media_update_own_prestataire"
on storage.objects for update
to authenticated
using (
  bucket_id = 'reel-media'
  and exists (
    select 1
    from public.prestataire_profiles p
    where p.id::text = (storage.foldername(name))[1]
      and p.user_id = auth.uid()
  )
)
with check (
  bucket_id = 'reel-media'
  and exists (
    select 1
    from public.prestataire_profiles p
    where p.id::text = (storage.foldername(name))[1]
      and p.user_id = auth.uid()
  )
);

drop policy if exists "reel_media_delete_own_prestataire" on storage.objects;
create policy "reel_media_delete_own_prestataire"
on storage.objects for delete
to authenticated
using (
  bucket_id = 'reel-media'
  and exists (
    select 1
    from public.prestataire_profiles p
    where p.id::text = (storage.foldername(name))[1]
      and p.user_id = auth.uid()
  )
);
