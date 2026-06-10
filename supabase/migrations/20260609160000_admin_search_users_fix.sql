-- Recherche admin : inclure tous les comptes auth (pas seulement user_profiles).

create or replace function public.admin_search_users(
  p_query text default '',
  p_limit integer default 50
)
returns table (
  user_id uuid,
  email text,
  prenom text,
  nom text,
  is_banned boolean,
  banned_at timestamptz,
  ban_reason text,
  roles text[]
)
language sql
security definer
set search_path = public, auth
as $$
  select
    u.id as user_id,
    u.email::text,
    up.prenom,
    up.nom,
    coalesce(up.is_banned, false) as is_banned,
    up.banned_at,
    up.ban_reason,
    coalesce(
      array_agg(distinct ur.role::text) filter (where ur.role is not null),
      '{}'::text[]
    ) as roles
  from auth.users u
  left join public.user_profiles up on up.user_id = u.id
  left join public.user_roles ur on ur.user_id = u.id
  where public.is_admin_user(auth.uid())
    and (
      coalesce(trim(p_query), '') = ''
      or u.email ilike '%' || trim(p_query) || '%'
      or coalesce(up.prenom, '') ilike '%' || trim(p_query) || '%'
      or coalesce(up.nom, '') ilike '%' || trim(p_query) || '%'
      or trim(concat_ws(' ', up.prenom, up.nom)) ilike '%' || trim(p_query) || '%'
      or coalesce(up.telephone, '') ilike '%' || trim(p_query) || '%'
      or u.id::text ilike '%' || trim(p_query) || '%'
    )
  group by
    u.id,
    u.email,
    u.created_at,
    up.prenom,
    up.nom,
    up.is_banned,
    up.banned_at,
    up.ban_reason
  order by u.created_at desc
  limit greatest(1, least(coalesce(p_limit, 50), 200));
$$;

grant execute on function public.admin_search_users(text, integer) to authenticated;
