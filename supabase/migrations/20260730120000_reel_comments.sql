-- Commentaires Reel (style TikTok) : table, compteur, RPCs list/add/delete.

alter table public.reel_posts
  add column if not exists comments_count integer not null default 0
    check (comments_count >= 0);

comment on column public.reel_posts.comments_count is
  'Compteur dénormalisé de commentaires publics.';

create table if not exists public.reel_comments (
  id uuid primary key default gen_random_uuid(),
  reel_id uuid not null references public.reel_posts (id) on delete cascade,
  client_id uuid not null references public.client_profiles (id) on delete cascade,
  body text not null,
  created_at timestamptz not null default now(),
  constraint reel_comments_body_len check (
    char_length(trim(body)) between 1 and 500
  )
);

create index if not exists idx_reel_comments_reel_created
  on public.reel_comments (reel_id, created_at desc);

create index if not exists idx_reel_comments_client_created
  on public.reel_comments (client_id, created_at desc);

comment on table public.reel_comments is
  'Commentaires clients sur les posts Reel.';

create or replace function public.reel_comments_sync_count()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if tg_op = 'INSERT' then
    update public.reel_posts
    set comments_count = comments_count + 1
    where id = new.reel_id;
    return new;
  elsif tg_op = 'DELETE' then
    update public.reel_posts
    set comments_count = greatest(0, comments_count - 1)
    where id = old.reel_id;
    return old;
  end if;
  return null;
end;
$$;

drop trigger if exists trg_reel_comments_sync_count on public.reel_comments;
create trigger trg_reel_comments_sync_count
after insert or delete on public.reel_comments
for each row execute function public.reel_comments_sync_count();

-- Rate-limit soft : max 40 commentaires / jour / client
create or replace function public.trg_reel_comments_rate_limit()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count integer;
begin
  select count(*)::integer into v_count
  from public.reel_comments c
  where c.client_id = new.client_id
    and c.created_at >= (now() - interval '1 day');

  if coalesce(v_count, 0) >= 40 then
    raise exception 'reel_comment_rate_limit'
      using errcode = 'P0001';
  end if;

  return new;
end;
$$;

drop trigger if exists trg_reel_comments_rate_limit on public.reel_comments;
create trigger trg_reel_comments_rate_limit
before insert on public.reel_comments
for each row execute function public.trg_reel_comments_rate_limit();

alter table public.reel_comments enable row level security;

drop policy if exists "reel_comments_select_published" on public.reel_comments;
create policy "reel_comments_select_published"
on public.reel_comments for select
to authenticated, anon
using (
  exists (
    select 1
    from public.reel_posts rp
    where rp.id = reel_comments.reel_id
      and rp.status = 'published'
  )
);

drop policy if exists "reel_comments_insert_own" on public.reel_comments;
create policy "reel_comments_insert_own"
on public.reel_comments for insert
to authenticated
with check (
  exists (
    select 1 from public.client_profiles c
    where c.id = reel_comments.client_id
      and c.user_id = auth.uid()
  )
  and exists (
    select 1
    from public.reel_posts rp
    where rp.id = reel_comments.reel_id
      and rp.status = 'published'
  )
);

drop policy if exists "reel_comments_delete_own" on public.reel_comments;
create policy "reel_comments_delete_own"
on public.reel_comments for delete
to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = reel_comments.client_id
      and c.user_id = auth.uid()
  )
);

-- List comments (cursor by created_at + id)
create or replace function public.list_reel_comments(
  p_reel_id uuid,
  p_limit integer default 30,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns table (
  id uuid,
  reel_id uuid,
  client_id uuid,
  body text,
  created_at timestamptz,
  author_name text,
  author_avatar_url text,
  is_mine boolean
)
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_client_id uuid;
  v_limit integer := greatest(1, least(coalesce(p_limit, 30), 50));
begin
  if p_reel_id is null then
    return;
  end if;

  if not exists (
    select 1 from public.reel_posts rp
    where rp.id = p_reel_id and rp.status = 'published'
  ) then
    return;
  end if;

  select c.id into v_client_id
  from public.client_profiles c
  where c.user_id = auth.uid()
  limit 1;

  return query
  select
    rc.id,
    rc.reel_id,
    rc.client_id,
    rc.body,
    rc.created_at,
    coalesce(
      nullif(trim(concat_ws(' ', up.prenom, up.nom)), ''),
      'Cliente'
    ) as author_name,
    up.avatar_url as author_avatar_url,
    (v_client_id is not null and rc.client_id = v_client_id) as is_mine
  from public.reel_comments rc
  join public.client_profiles cp on cp.id = rc.client_id
  join public.user_profiles up on up.user_id = cp.user_id
  where rc.reel_id = p_reel_id
    and (
      p_cursor_created_at is null
      or p_cursor_id is null
      or (rc.created_at, rc.id) < (p_cursor_created_at, p_cursor_id)
    )
  order by rc.created_at desc, rc.id desc
  limit v_limit;
end;
$$;

revoke all on function public.list_reel_comments(uuid, integer, timestamptz, uuid) from public;
grant execute on function public.list_reel_comments(uuid, integer, timestamptz, uuid)
  to anon, authenticated;

create or replace function public.add_reel_comment(
  p_reel_id uuid,
  p_body text
)
returns table (
  id uuid,
  reel_id uuid,
  client_id uuid,
  body text,
  created_at timestamptz,
  author_name text,
  author_avatar_url text,
  is_mine boolean
)
language plpgsql
security definer
set search_path = public
as $$
declare
  v_client_id uuid;
  v_body text := trim(coalesce(p_body, ''));
  v_id uuid;
begin
  if auth.uid() is null then
    raise exception 'add_reel_comment: auth required';
  end if;

  if char_length(v_body) < 1 or char_length(v_body) > 500 then
    raise exception 'reel_comment_invalid_body'
      using errcode = 'P0001';
  end if;

  select c.id into v_client_id
  from public.client_profiles c
  where c.user_id = auth.uid()
  limit 1;

  if v_client_id is null then
    raise exception 'add_reel_comment: profil client requis';
  end if;

  if not exists (
    select 1 from public.reel_posts rp
    where rp.id = p_reel_id and rp.status = 'published'
  ) then
    raise exception 'reel_comment_not_found'
      using errcode = 'P0001';
  end if;

  insert into public.reel_comments (reel_id, client_id, body)
  values (p_reel_id, v_client_id, v_body)
  returning reel_comments.id into v_id;

  return query
  select
    rc.id,
    rc.reel_id,
    rc.client_id,
    rc.body,
    rc.created_at,
    coalesce(
      nullif(trim(concat_ws(' ', up.prenom, up.nom)), ''),
      'Cliente'
    ) as author_name,
    up.avatar_url as author_avatar_url,
    true as is_mine
  from public.reel_comments rc
  join public.client_profiles cp on cp.id = rc.client_id
  join public.user_profiles up on up.user_id = cp.user_id
  where rc.id = v_id;
end;
$$;

revoke all on function public.add_reel_comment(uuid, text) from public;
grant execute on function public.add_reel_comment(uuid, text) to authenticated;

create or replace function public.delete_reel_comment(p_comment_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_client_id uuid;
begin
  select c.id into v_client_id
  from public.client_profiles c
  where c.user_id = auth.uid()
  limit 1;

  if v_client_id is null then
    raise exception 'delete_reel_comment: profil client requis';
  end if;

  delete from public.reel_comments
  where id = p_comment_id
    and client_id = v_client_id;

  if not found then
    raise exception 'reel_comment_not_found'
      using errcode = 'P0001';
  end if;
end;
$$;

revoke all on function public.delete_reel_comment(uuid) from public;
grant execute on function public.delete_reel_comment(uuid) to authenticated;

-- Recréer list_reel_feed avec comments_count
drop function if exists public.list_reel_feed(integer, double precision, timestamptz, uuid);

create function public.list_reel_feed(
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
  comments_count integer,
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
      rp.comments_count,
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
        + ln(1 + rp.comments_count::double precision) * 1.2
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
    r.comments_count,
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
