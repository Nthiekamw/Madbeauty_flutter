-- Admin web : complétude profil prestataire + adresses clients/prestataires.

create or replace function public.admin_prestataire_profile_completeness(p_prestataire_id uuid)
returns jsonb
language plpgsql
stable
security definer
set search_path = public
as $$
declare
  v_missing jsonb := '[]'::jsonb;
  v_p public.prestataire_profiles%rowtype;
  v_avatar text;
  v_banned boolean;
  v_spec_count integer := 0;
  v_valid_svc_count integer := 0;
  v_is_complete boolean;
  v_is_visible boolean;
  v_has_access boolean;
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'Accès admin requis';
  end if;

  select p.*
  into v_p
  from public.prestataire_profiles p
  where p.id = p_prestataire_id;

  if not found then
    return jsonb_build_object('found', false);
  end if;

  select up.avatar_url, coalesce(up.is_banned, false)
  into v_avatar, v_banned
  from public.user_profiles up
  where up.user_id = v_p.user_id;

  if coalesce(trim(v_p.nom_salon), '') = '' then
    v_missing := v_missing || jsonb_build_array('Nom du salon');
  end if;
  if coalesce(trim(v_p.ville), '') = '' then
    v_missing := v_missing || jsonb_build_array('Ville');
  end if;
  if coalesce(trim(v_p.adresse), '') = '' then
    v_missing := v_missing || jsonb_build_array('Adresse');
  end if;
  if coalesce(trim(v_p.code_postal), '') = '' then
    v_missing := v_missing || jsonb_build_array('Code postal');
  end if;
  if v_p.lieu_travail is null then
    v_missing := v_missing || jsonb_build_array('Lieu de travail');
  end if;
  if coalesce(trim(v_p.description), '') = '' then
    v_missing := v_missing || jsonb_build_array('Description');
  end if;
  if coalesce(trim(v_avatar), '') = '' then
    v_missing := v_missing || jsonb_build_array('Photo de profil');
  end if;

  select count(*)::integer
  into v_spec_count
  from public.prestataire_specialites ps
  where ps.prestataire_id = p_prestataire_id;

  if v_spec_count = 0 then
    v_missing := v_missing || jsonb_build_array('Spécialité (au moins une)');
  end if;

  select count(*)::integer
  into v_valid_svc_count
  from public.services_beaute s
  where s.prestataire_id = p_prestataire_id
    and coalesce(s.is_actif, true) = true
    and coalesce(trim(s.nom), '') <> ''
    and s.categorie_id is not null
    and coalesce(s.prix, 0) >= 1
    and coalesce(s.duree_minutes, 0) > 0;

  if v_valid_svc_count = 0 then
    v_missing := v_missing || jsonb_build_array('Service actif (nom, catégorie, prix, durée)');
  end if;

  v_is_complete := public.prestataire_is_professionally_complete(p_prestataire_id);
  v_is_visible := public.prestataire_is_catalog_visible(p_prestataire_id);
  v_has_access := coalesce(v_p.subscription_status, 'none') in ('active', 'trialing')
    or (
      v_p.catalog_trial_ends_at is not null
      and v_p.catalog_trial_ends_at > now()
    );

  if v_banned then
    v_missing := v_missing || jsonb_build_array('Compte banni');
  end if;
  if coalesce(v_p.is_hidden, false) then
    v_missing := v_missing || jsonb_build_array('Profil masqué du catalogue');
  end if;
  if v_is_complete and not v_has_access then
    v_missing := v_missing || jsonb_build_array('Abonnement ou essai catalogue expiré');
  end if;

  return jsonb_build_object(
    'found', true,
    'is_professionally_complete', v_is_complete,
    'is_catalog_visible', v_is_visible,
    'has_catalog_access', v_has_access,
    'specialties_count', v_spec_count,
    'valid_services_count', v_valid_svc_count,
    'missing', v_missing
  );
end;
$$;

comment on function public.admin_prestataire_profile_completeness(uuid) is
  'Rapport admin : profil prestataire complet, visible catalogue, éléments manquants.';

grant execute on function public.admin_prestataire_profile_completeness(uuid) to authenticated;

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
  client_adresse text,
  client_ville text,
  client_code_postal text,
  client_pays char(2),
  presta_id uuid,
  presta_nom_salon text,
  presta_adresse text,
  presta_ville text,
  presta_code_postal text,
  presta_pays char(2),
  presta_is_verified boolean,
  presta_is_profile_complete boolean,
  presta_is_catalog_visible boolean,
  presta_missing_labels text[],
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
    cp.adresse as client_adresse,
    cp.ville as client_ville,
    cp.code_postal as client_code_postal,
    cp.pays as client_pays,
    pp.id as presta_id,
    pp.nom_salon as presta_nom_salon,
    pp.adresse as presta_adresse,
    pp.ville as presta_ville,
    pp.code_postal as presta_code_postal,
    pp.pays as presta_pays,
    coalesce(pp.is_verified, false) as presta_is_verified,
    case
      when pp.id is null then null
      else public.prestataire_is_professionally_complete(pp.id)
    end as presta_is_profile_complete,
    case
      when pp.id is null then null
      else public.prestataire_is_catalog_visible(pp.id)
    end as presta_is_catalog_visible,
    case
      when pp.id is null then null
      else coalesce(
        (
          select array_agg(value order by ord)
          from jsonb_array_elements_text(
            public.admin_prestataire_profile_completeness(pp.id)->'missing'
          ) with ordinality as t(value, ord)
        ),
        '{}'::text[]
      )
    end as presta_missing_labels,
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
      or coalesce(cp.adresse, '') ilike '%' || trim(p_query) || '%'
      or coalesce(cp.ville, '') ilike '%' || trim(p_query) || '%'
      or coalesce(pp.adresse, '') ilike '%' || trim(p_query) || '%'
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
    cp.adresse,
    cp.ville,
    cp.code_postal,
    cp.pays,
    pp.id,
    pp.nom_salon,
    pp.adresse,
    pp.ville,
    pp.code_postal,
    pp.pays,
    pp.is_verified
  order by u.created_at desc
  limit greatest(1, least(coalesce(p_limit, 50), 200));
$$;

grant execute on function public.admin_search_users(text, integer) to authenticated;

create or replace function public.admin_get_user_details(p_user_id uuid)
returns jsonb
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  result jsonb;
  v_presta_id uuid;
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'Accès admin requis';
  end if;

  select pp.id into v_presta_id
  from public.prestataire_profiles pp
  where pp.user_id = p_user_id;

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
        'nom_affiche', pp.nom_affiche,
        'bio', pp.bio,
        'adresse', pp.adresse,
        'ville', pp.ville,
        'code_postal', pp.code_postal,
        'pays', pp.pays,
        'lieu_travail', pp.lieu_travail,
        'description', pp.description,
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
        ),
        'specialties_count', (
          select count(*)::int from public.prestataire_specialites ps where ps.prestataire_id = pp.id
        ),
        'completeness', public.admin_prestataire_profile_completeness(pp.id)
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

grant execute on function public.admin_get_user_details(uuid) to authenticated;

drop function if exists public.admin_search_prestataire_subscriptions(text, text, integer, integer);

create or replace function public.admin_search_prestataire_subscriptions(
  p_query text default '',
  p_status text default 'all',
  p_limit integer default 200,
  p_offset integer default 0
)
returns table (
  user_id uuid,
  prestataire_id uuid,
  email text,
  display_name text,
  nom_salon text,
  adresse text,
  ville text,
  code_postal text,
  pays char(2),
  subscription_status text,
  subscription_tier text,
  subscription_interval text,
  subscription_current_period_end timestamptz,
  catalog_trial_ends_at timestamptz,
  stripe_subscription_id text,
  stripe_billing_customer_id text,
  is_catalog_trial boolean,
  has_catalog_access boolean,
  is_profile_complete boolean,
  is_catalog_visible boolean,
  missing_labels text[],
  services_count bigint,
  created_at timestamptz
)
language sql
security definer
set search_path = public, auth
stable
as $$
  select
    p.user_id,
    p.id as prestataire_id,
    u.email::text,
    nullif(trim(concat_ws(' ', up.prenom, up.nom)), '') as display_name,
    p.nom_salon,
    p.adresse,
    p.ville,
    p.code_postal,
    p.pays,
    coalesce(p.subscription_status, 'none') as subscription_status,
    p.subscription_tier,
    p.subscription_interval,
    p.subscription_current_period_end,
    p.catalog_trial_ends_at,
    p.stripe_subscription_id,
    p.stripe_billing_customer_id,
    (
      p.catalog_trial_ends_at is not null
      and p.catalog_trial_ends_at > now()
      and coalesce(p.subscription_status, 'none') not in ('active', 'trialing')
    ) as is_catalog_trial,
    (
      coalesce(p.subscription_status, 'none') in ('active', 'trialing')
      or (
        p.catalog_trial_ends_at is not null
        and p.catalog_trial_ends_at > now()
      )
    ) as has_catalog_access,
    public.prestataire_is_professionally_complete(p.id) as is_profile_complete,
    public.prestataire_is_catalog_visible(p.id) as is_catalog_visible,
    coalesce(
      (
        select array_agg(value order by ord)
        from jsonb_array_elements_text(
          public.admin_prestataire_profile_completeness(p.id)->'missing'
        ) with ordinality as t(value, ord)
      ),
      '{}'::text[]
    ) as missing_labels,
    (
      select count(*)::bigint
      from public.services_beaute s
      where s.prestataire_id = p.id
    ) as services_count,
    p.created_at
  from public.prestataire_profiles p
  inner join auth.users u on u.id = p.user_id
  left join public.user_profiles up on up.user_id = p.user_id
  where public.is_admin_user(auth.uid())
    and (
      coalesce(trim(p_query), '') = ''
      or u.email ilike '%' || trim(p_query) || '%'
      or coalesce(up.prenom, '') ilike '%' || trim(p_query) || '%'
      or coalesce(up.nom, '') ilike '%' || trim(p_query) || '%'
      or trim(concat_ws(' ', up.prenom, up.nom)) ilike '%' || trim(p_query) || '%'
      or coalesce(p.nom_salon, '') ilike '%' || trim(p_query) || '%'
      or coalesce(p.adresse, '') ilike '%' || trim(p_query) || '%'
      or coalesce(p.ville, '') ilike '%' || trim(p_query) || '%'
      or p.id::text = trim(p_query)
      or p.user_id::text = trim(p_query)
      or coalesce(p.stripe_subscription_id, '') ilike '%' || trim(p_query) || '%'
    )
    and (
      coalesce(trim(p_status), 'all') = 'all'
      or (p_status = 'active_paid' and coalesce(p.subscription_status, 'none') in ('active', 'trialing'))
      or (p_status = 'catalog_trial' and p.catalog_trial_ends_at is not null and p.catalog_trial_ends_at > now()
          and coalesce(p.subscription_status, 'none') not in ('active', 'trialing'))
      or (p_status = 'attention' and coalesce(p.subscription_status, 'none') in ('past_due', 'unpaid', 'incomplete'))
      or (p_status = 'incomplete_profile' and not public.prestataire_is_professionally_complete(p.id))
      or (p_status = 'hidden_catalog' and not public.prestataire_is_catalog_visible(p.id))
      or coalesce(p.subscription_status, 'none') = p_status
    )
  order by p.created_at desc
  limit greatest(1, least(coalesce(p_limit, 200), 500))
  offset greatest(coalesce(p_offset, 0), 0);
$$;

grant execute on function public.admin_search_prestataire_subscriptions(text, text, integer, integer)
  to authenticated;

comment on function public.admin_search_prestataire_subscriptions(text, text, integer, integer) is
  'Admin : abonnements prestataires avec adresse et complétude profil.';
