-- Favoris (bookmarks) Reels + saved_by_me dans le feed + lecture unitaire.

create table if not exists public.reel_favorites (
  reel_id uuid not null references public.reel_posts (id) on delete cascade,
  client_id uuid not null references public.client_profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  primary key (reel_id, client_id)
);

create index if not exists idx_reel_favorites_client_created
  on public.reel_favorites (client_id, created_at desc);

comment on table public.reel_favorites is
  'Reels enregistrés (favoris) par les clients — distinct des likes.';

alter table public.reel_favorites enable row level security;

drop policy if exists "reel_favorites_select_own" on public.reel_favorites;
create policy "reel_favorites_select_own"
on public.reel_favorites for select
to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = reel_favorites.client_id
      and c.user_id = auth.uid()
  )
);

drop policy if exists "reel_favorites_insert_own" on public.reel_favorites;
create policy "reel_favorites_insert_own"
on public.reel_favorites for insert
to authenticated
with check (
  exists (
    select 1 from public.client_profiles c
    where c.id = reel_favorites.client_id
      and c.user_id = auth.uid()
  )
  and exists (
    select 1 from public.reel_posts rp
    where rp.id = reel_favorites.reel_id
      and rp.status = 'published'
  )
);

drop policy if exists "reel_favorites_delete_own" on public.reel_favorites;
create policy "reel_favorites_delete_own"
on public.reel_favorites for delete
to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = reel_favorites.client_id
      and c.user_id = auth.uid()
  )
);

create or replace function public.toggle_reel_favorite(p_reel_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_client_id uuid;
begin
  if auth.uid() is null then
    raise exception 'toggle_reel_favorite: authentification requise';
  end if;

  select c.id into v_client_id
  from public.client_profiles c
  where c.user_id = auth.uid()
  limit 1;

  if v_client_id is null then
    raise exception 'toggle_reel_favorite: profil client requis';
  end if;

  if not exists (
    select 1 from public.reel_posts rp
    where rp.id = p_reel_id and rp.status = 'published'
  ) then
    raise exception 'toggle_reel_favorite: reel introuvable';
  end if;

  if exists (
    select 1 from public.reel_favorites
    where reel_id = p_reel_id and client_id = v_client_id
  ) then
    delete from public.reel_favorites
    where reel_id = p_reel_id and client_id = v_client_id;
    return false;
  end if;

  insert into public.reel_favorites (reel_id, client_id)
  values (p_reel_id, v_client_id);
  return true;
end;
$$;

revoke all on function public.toggle_reel_favorite(uuid) from public;
grant execute on function public.toggle_reel_favorite(uuid) to authenticated;

-- Feed : ajoute saved_by_me
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
  media jsonb,
  caption text,
  likes_count integer,
  comments_count integer,
  views_count integer,
  created_at timestamptz,
  score double precision,
  liked_by_me boolean,
  saved_by_me boolean,
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
      coalesce(
        (
          select jsonb_agg(
            jsonb_build_object(
              'media_type', m.media_type,
              'media_url', m.media_url,
              'sort_order', m.sort_order
            )
            order by m.sort_order asc, m.created_at asc
          )
          from public.reel_post_media m
          where m.reel_id = rp.id
        ),
        jsonb_build_array(
          jsonb_build_object(
            'media_type', rp.media_type,
            'media_url', rp.media_url,
            'sort_order', 0
          )
        )
      ) as media,
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
      exists (
        select 1
        from public.reel_favorites rf
        where rf.reel_id = rp.id
          and v_client_id is not null
          and rf.client_id = v_client_id
      ) as saved_by_me,
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
    r.media,
    r.caption,
    r.likes_count,
    r.comments_count,
    r.views_count,
    r.created_at,
    r.score,
    r.liked_by_me,
    r.saved_by_me,
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

-- Un Reel publié (pour deep link / focus feed).
create or replace function public.get_reel_feed_item(p_reel_id uuid)
returns table (
  id uuid,
  prestataire_id uuid,
  media_type text,
  media_url text,
  media jsonb,
  caption text,
  likes_count integer,
  comments_count integer,
  views_count integer,
  created_at timestamptz,
  score double precision,
  liked_by_me boolean,
  saved_by_me boolean,
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
begin
  if p_reel_id is null then
    return;
  end if;

  select c.id into v_client_id
  from public.client_profiles c
  where c.user_id = auth.uid()
  limit 1;

  return query
  select
    rp.id,
    rp.prestataire_id,
    rp.media_type,
    rp.media_url,
    coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'media_type', m.media_type,
            'media_url', m.media_url,
            'sort_order', m.sort_order
          )
          order by m.sort_order asc, m.created_at asc
        )
        from public.reel_post_media m
        where m.reel_id = rp.id
      ),
      jsonb_build_array(
        jsonb_build_object(
          'media_type', rp.media_type,
          'media_url', rp.media_url,
          'sort_order', 0
        )
      )
    ) as media,
    rp.caption,
    rp.likes_count,
    rp.comments_count,
    rp.views_count,
    rp.created_at,
    0::double precision as score,
    exists (
      select 1 from public.reel_likes rl
      where rl.reel_id = rp.id
        and v_client_id is not null
        and rl.client_id = v_client_id
    ) as liked_by_me,
    exists (
      select 1 from public.reel_favorites rf
      where rf.reel_id = rp.id
        and v_client_id is not null
        and rf.client_id = v_client_id
    ) as saved_by_me,
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
  where rp.id = p_reel_id
    and rp.status = 'published'
    and public.prestataire_is_catalog_visible(rp.prestataire_id)
  limit 1;
end;
$$;

revoke all on function public.get_reel_feed_item(uuid) from public;
grant execute on function public.get_reel_feed_item(uuid) to anon, authenticated;

-- Liste des Reels favoris du client connecté.
create or replace function public.list_reel_favorites(
  p_limit integer default 40,
  p_cursor_created_at timestamptz default null,
  p_cursor_id uuid default null
)
returns table (
  id uuid,
  prestataire_id uuid,
  media_type text,
  media_url text,
  media jsonb,
  caption text,
  likes_count integer,
  comments_count integer,
  views_count integer,
  created_at timestamptz,
  score double precision,
  liked_by_me boolean,
  saved_by_me boolean,
  salon_name text,
  avatar_url text,
  ville text,
  favorited_at timestamptz
)
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_client_id uuid;
  v_limit integer := greatest(1, least(coalesce(p_limit, 40), 80));
begin
  if auth.uid() is null then
    return;
  end if;

  select c.id into v_client_id
  from public.client_profiles c
  where c.user_id = auth.uid()
  limit 1;

  if v_client_id is null then
    return;
  end if;

  return query
  select
    rp.id,
    rp.prestataire_id,
    rp.media_type,
    rp.media_url,
    coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'media_type', m.media_type,
            'media_url', m.media_url,
            'sort_order', m.sort_order
          )
          order by m.sort_order asc, m.created_at asc
        )
        from public.reel_post_media m
        where m.reel_id = rp.id
      ),
      jsonb_build_array(
        jsonb_build_object(
          'media_type', rp.media_type,
          'media_url', rp.media_url,
          'sort_order', 0
        )
      )
    ) as media,
    rp.caption,
    rp.likes_count,
    rp.comments_count,
    rp.views_count,
    rp.created_at,
    0::double precision as score,
    exists (
      select 1 from public.reel_likes rl
      where rl.reel_id = rp.id and rl.client_id = v_client_id
    ) as liked_by_me,
    true as saved_by_me,
    coalesce(
      nullif(trim(pp.nom_affiche), ''),
      nullif(trim(pp.nom_salon), ''),
      'Salon'
    ) as salon_name,
    up.avatar_url,
    pp.ville,
    rf.created_at as favorited_at
  from public.reel_favorites rf
  join public.reel_posts rp on rp.id = rf.reel_id
  join public.prestataire_profiles pp on pp.id = rp.prestataire_id
  join public.user_profiles up on up.user_id = pp.user_id
  where rf.client_id = v_client_id
    and rp.status = 'published'
    and public.prestataire_is_catalog_visible(rp.prestataire_id)
    and (
      p_cursor_created_at is null
      or p_cursor_id is null
      or (rf.created_at, rp.id) < (p_cursor_created_at, p_cursor_id)
    )
  order by rf.created_at desc, rp.id desc
  limit v_limit;
end;
$$;

revoke all on function public.list_reel_favorites(integer, timestamptz, uuid) from public;
grant execute on function public.list_reel_favorites(integer, timestamptz, uuid)
  to authenticated;
