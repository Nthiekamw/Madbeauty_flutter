-- Reel likes / commentaires / favoris : assurer un profil client pour tout
-- utilisateur authentifié (ex. prestataire sans rôle client).

create or replace function public.ensure_client_profile_for_auth()
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_client_id uuid;
begin
  if v_uid is null then
    raise exception 'ensure_client_profile_for_auth: authentification requise'
      using errcode = 'P0001';
  end if;

  insert into public.user_profiles (user_id, updated_at)
  values (v_uid, now())
  on conflict (user_id) do nothing;

  -- Dual-rôle : un prestataire peut liker / commenter comme cliente.
  insert into public.user_roles (user_id, role)
  values (v_uid, 'client')
  on conflict (user_id, role) do nothing;

  insert into public.client_profiles (user_id)
  values (v_uid)
  on conflict (user_id) do nothing;

  select c.id into v_client_id
  from public.client_profiles c
  where c.user_id = v_uid
  limit 1;

  if v_client_id is null then
    raise exception 'ensure_client_profile_for_auth: profil client introuvable'
      using errcode = 'P0001';
  end if;

  return v_client_id;
end;
$$;

revoke all on function public.ensure_client_profile_for_auth() from public;
grant execute on function public.ensure_client_profile_for_auth() to authenticated;

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
  v_client_id := public.ensure_client_profile_for_auth();

  if not exists (
    select 1 from public.reel_posts rp
    where rp.id = p_reel_id and rp.status = 'published'
  ) then
    raise exception 'toggle_reel_like: reel introuvable'
      using errcode = 'P0001';
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

create or replace function public.toggle_reel_favorite(p_reel_id uuid)
returns boolean
language plpgsql
security definer
set search_path = public
as $$
declare
  v_client_id uuid;
begin
  v_client_id := public.ensure_client_profile_for_auth();

  if not exists (
    select 1 from public.reel_posts rp
    where rp.id = p_reel_id and rp.status = 'published'
  ) then
    raise exception 'toggle_reel_favorite: reel introuvable'
      using errcode = 'P0001';
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
    raise exception 'add_reel_comment: auth required'
      using errcode = 'P0001';
  end if;

  if char_length(v_body) < 1 or char_length(v_body) > 500 then
    raise exception 'reel_comment_invalid_body'
      using errcode = 'P0001';
  end if;

  v_client_id := public.ensure_client_profile_for_auth();

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
  v_client_id := public.ensure_client_profile_for_auth();

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
