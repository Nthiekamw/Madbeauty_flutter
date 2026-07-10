-- Admin web : détails utilisateurs enrichis (liste + fiche détaillée).

drop function if exists public.admin_search_users(text, integer);

create or replace function public.admin_search_users(
  p_query text default '',
  p_limit integer default 50
)
returns table (
  user_id uuid,
  email text,
  prenom text,
  nom text,
  telephone text,
  avatar_url text,
  created_at timestamptz,
  last_sign_in_at timestamptz,
  has_fcm_token boolean,
  is_banned boolean,
  banned_at timestamptz,
  ban_reason text,
  roles text[],
  has_client_profile boolean,
  has_prestataire_profile boolean,
  client_ville text,
  client_code_postal text,
  client_pays char(2),
  presta_nom_salon text,
  presta_ville text,
  presta_is_verified boolean,
  reservations_count bigint
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
    up.telephone,
    up.avatar_url,
    u.created_at,
    u.last_sign_in_at,
    (up.fcm_token is not null and btrim(up.fcm_token) <> '') as has_fcm_token,
    coalesce(up.is_banned, false) as is_banned,
    up.banned_at,
    up.ban_reason,
    coalesce(
      array_agg(distinct ur.role::text) filter (where ur.role is not null),
      '{}'::text[]
    ) as roles,
    (cp.id is not null) as has_client_profile,
    (pp.id is not null) as has_prestataire_profile,
    cp.ville as client_ville,
    cp.code_postal as client_code_postal,
    cp.pays as client_pays,
    pp.nom_salon as presta_nom_salon,
    pp.ville as presta_ville,
    coalesce(pp.is_verified, false) as presta_is_verified,
    (
      select count(*)::bigint
      from public.reservations r
      where (cp.id is not null and r.client_id = cp.id)
         or (pp.id is not null and r.prestataire_id = pp.id)
    ) as reservations_count
  from auth.users u
  left join public.user_profiles up on up.user_id = u.id
  left join public.user_roles ur on ur.user_id = u.id
  left join public.client_profiles cp on cp.user_id = u.id
  left join public.prestataire_profiles pp on pp.user_id = u.id
  where public.is_admin_user(auth.uid())
    and (
      coalesce(trim(p_query), '') = ''
      or u.email ilike '%' || trim(p_query) || '%'
      or coalesce(up.prenom, '') ilike '%' || trim(p_query) || '%'
      or coalesce(up.nom, '') ilike '%' || trim(p_query) || '%'
      or trim(concat_ws(' ', up.prenom, up.nom)) ilike '%' || trim(p_query) || '%'
      or coalesce(up.telephone, '') ilike '%' || trim(p_query) || '%'
      or coalesce(cp.ville, '') ilike '%' || trim(p_query) || '%'
      or coalesce(pp.nom_salon, '') ilike '%' || trim(p_query) || '%'
      or coalesce(pp.ville, '') ilike '%' || trim(p_query) || '%'
      or u.id::text ilike '%' || trim(p_query) || '%'
    )
  group by
    u.id,
    u.email,
    u.created_at,
    u.last_sign_in_at,
    up.prenom,
    up.nom,
    up.telephone,
    up.avatar_url,
    up.fcm_token,
    up.is_banned,
    up.banned_at,
    up.ban_reason,
    cp.id,
    cp.ville,
    cp.code_postal,
    cp.pays,
    pp.id,
    pp.nom_salon,
    pp.ville,
    pp.is_verified
  order by u.created_at desc
  limit greatest(1, least(coalesce(p_limit, 50), 200));
$$;

create or replace function public.admin_get_user_details(p_user_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  result jsonb;
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'Accès admin requis';
  end if;

  select jsonb_build_object(
    'user_id', u.id,
    'email', u.email,
    'email_confirmed_at', u.email_confirmed_at,
    'created_at', u.created_at,
    'last_sign_in_at', u.last_sign_in_at,
    'profile', jsonb_build_object(
      'prenom', up.prenom,
      'nom', up.nom,
      'telephone', up.telephone,
      'avatar_url', up.avatar_url,
      'has_fcm_token', (up.fcm_token is not null and btrim(up.fcm_token) <> ''),
      'fcm_token_updated_at', up.fcm_token_updated_at,
      'last_seen_at', up.last_seen_at,
      'is_banned', coalesce(up.is_banned, false),
      'banned_at', up.banned_at,
      'ban_reason', up.ban_reason,
      'updated_at', up.updated_at
    ),
    'roles', coalesce(
      (
        select jsonb_agg(r.role order by r.role)
        from (
          select distinct ur.role::text as role
          from public.user_roles ur
          where ur.user_id = u.id
        ) r
      ),
      '[]'::jsonb
    ),
    'client_profile', (
      select jsonb_build_object(
        'id', cp.id,
        'adresse', cp.adresse,
        'ville', cp.ville,
        'code_postal', cp.code_postal,
        'pays', cp.pays,
        'voie_type', cp.voie_type,
        'voie_nom', cp.voie_nom,
        'numero_rue', cp.numero_rue,
        'latitude', cp.latitude,
        'longitude', cp.longitude,
        'stripe_customer_id', cp.stripe_customer_id,
        'created_at', cp.created_at,
        'reservations_count', (
          select count(*)::int from public.reservations r where r.client_id = cp.id
        )
      )
      from public.client_profiles cp
      where cp.user_id = u.id
    ),
    'prestataire_profile', (
      select jsonb_build_object(
        'id', pp.id,
        'nom_salon', pp.nom_salon,
        'bio', pp.bio,
        'adresse', pp.adresse,
        'ville', pp.ville,
        'latitude', pp.latitude,
        'longitude', pp.longitude,
        'note_moyenne', pp.note_moyenne,
        'is_verified', coalesce(pp.is_verified, false),
        'is_hidden', coalesce(pp.is_hidden, false),
        'hidden_at', pp.hidden_at,
        'stripe_connect_account_id', pp.stripe_connect_account_id,
        'stripe_connect_onboarding_status', pp.stripe_connect_onboarding_status,
        'stripe_connect_charges_enabled', coalesce(pp.stripe_connect_charges_enabled, false),
        'stripe_connect_payouts_enabled', coalesce(pp.stripe_connect_payouts_enabled, false),
        'subscription_status', pp.subscription_status,
        'subscription_tier', pp.subscription_tier,
        'subscription_interval', pp.subscription_interval,
        'subscription_current_period_end', pp.subscription_current_period_end,
        'catalog_trial_ends_at', pp.catalog_trial_ends_at,
        'created_at', pp.created_at,
        'reservations_count', (
          select count(*)::int from public.reservations r where r.prestataire_id = pp.id
        ),
        'services_count', (
          select count(*)::int from public.services_beaute s where s.prestataire_id = pp.id
        )
      )
      from public.prestataire_profiles pp
      where pp.user_id = u.id
    ),
    'auth_providers', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'provider', i.provider,
            'created_at', i.created_at,
            'last_sign_in_at', i.last_sign_in_at
          )
          order by i.created_at
        )
        from auth.identities i
        where i.user_id = u.id
      ),
      '[]'::jsonb
    )
  )
  into result
  from auth.users u
  left join public.user_profiles up on up.user_id = u.id
  where u.id = p_user_id;

  return result;
end;
$$;

grant execute on function public.admin_search_users(text, integer) to authenticated;
grant execute on function public.admin_get_user_details(uuid) to authenticated;
