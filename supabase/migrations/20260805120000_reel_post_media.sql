-- Galerie multi-médias par Reel (plusieurs photos / slides dans un même post).

create table if not exists public.reel_post_media (
  id uuid primary key default gen_random_uuid(),
  reel_id uuid not null references public.reel_posts (id) on delete cascade,
  media_type text not null
    check (media_type in ('image', 'video')),
  media_url text not null,
  sort_order integer not null default 0
    check (sort_order >= 0),
  created_at timestamptz not null default now(),
  constraint reel_post_media_url_nonempty check (length(trim(media_url)) > 0),
  constraint reel_post_media_reel_sort unique (reel_id, sort_order)
);

create index if not exists idx_reel_post_media_reel_order
  on public.reel_post_media (reel_id, sort_order);

comment on table public.reel_post_media is
  'Médias d’un Reel (galerie horizontale dans le feed vertical).';

-- Backfill depuis le cover existant.
insert into public.reel_post_media (reel_id, media_type, media_url, sort_order)
select rp.id, rp.media_type, rp.media_url, 0
from public.reel_posts rp
where not exists (
  select 1 from public.reel_post_media m where m.reel_id = rp.id
);

-- Max 10 médias / Reel.
create or replace function public.trg_reel_post_media_max_count()
returns trigger
language plpgsql
as $$
declare
  v_count integer;
begin
  select count(*)::integer into v_count
  from public.reel_post_media
  where reel_id = new.reel_id;

  if v_count >= 10 then
    raise exception 'reel_media_limit'
      using errcode = 'P0001',
            message = 'Maximum 10 médias par Reel.';
  end if;
  return new;
end;
$$;

drop trigger if exists trg_reel_post_media_max_count on public.reel_post_media;
create trigger trg_reel_post_media_max_count
before insert on public.reel_post_media
for each row execute function public.trg_reel_post_media_max_count();

-- Garde le cover reel_posts synchronisé avec le 1er média.
create or replace function public.reel_posts_sync_cover_from_media()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_reel_id uuid;
  v_type text;
  v_url text;
begin
  v_reel_id := coalesce(new.reel_id, old.reel_id);

  select m.media_type, m.media_url
  into v_type, v_url
  from public.reel_post_media m
  where m.reel_id = v_reel_id
  order by m.sort_order asc, m.created_at asc
  limit 1;

  if v_url is not null then
    update public.reel_posts
    set media_type = v_type,
        media_url = v_url,
        updated_at = now()
    where id = v_reel_id
      and (media_type is distinct from v_type or media_url is distinct from v_url);
  end if;

  return coalesce(new, old);
end;
$$;

drop trigger if exists trg_reel_post_media_sync_cover on public.reel_post_media;
create trigger trg_reel_post_media_sync_cover
after insert or update or delete on public.reel_post_media
for each row execute function public.reel_posts_sync_cover_from_media();

alter table public.reel_post_media enable row level security;

drop policy if exists "reel_post_media_select_published" on public.reel_post_media;
create policy "reel_post_media_select_published"
on public.reel_post_media for select
to anon, authenticated
using (
  exists (
    select 1
    from public.reel_posts rp
    where rp.id = reel_post_media.reel_id
      and rp.status = 'published'
      and public.prestataire_is_catalog_visible(rp.prestataire_id)
  )
);

drop policy if exists "reel_post_media_select_own" on public.reel_post_media;
create policy "reel_post_media_select_own"
on public.reel_post_media for select
to authenticated
using (
  exists (
    select 1
    from public.reel_posts rp
    join public.prestataire_profiles p on p.id = rp.prestataire_id
    where rp.id = reel_post_media.reel_id
      and p.user_id = auth.uid()
  )
);

drop policy if exists "reel_post_media_insert_own" on public.reel_post_media;
create policy "reel_post_media_insert_own"
on public.reel_post_media for insert
to authenticated
with check (
  exists (
    select 1
    from public.reel_posts rp
    join public.prestataire_profiles p on p.id = rp.prestataire_id
    where rp.id = reel_post_media.reel_id
      and p.user_id = auth.uid()
  )
);

drop policy if exists "reel_post_media_update_own" on public.reel_post_media;
create policy "reel_post_media_update_own"
on public.reel_post_media for update
to authenticated
using (
  exists (
    select 1
    from public.reel_posts rp
    join public.prestataire_profiles p on p.id = rp.prestataire_id
    where rp.id = reel_post_media.reel_id
      and p.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.reel_posts rp
    join public.prestataire_profiles p on p.id = rp.prestataire_id
    where rp.id = reel_post_media.reel_id
      and p.user_id = auth.uid()
  )
);

drop policy if exists "reel_post_media_delete_own" on public.reel_post_media;
create policy "reel_post_media_delete_own"
on public.reel_post_media for delete
to authenticated
using (
  exists (
    select 1
    from public.reel_posts rp
    join public.prestataire_profiles p on p.id = rp.prestataire_id
    where rp.id = reel_post_media.reel_id
      and p.user_id = auth.uid()
  )
);

-- Feed : ajoute la galerie `media` (jsonb).
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
