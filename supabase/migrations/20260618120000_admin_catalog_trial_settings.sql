-- Essai catalogue prestataire : 3 mois par défaut + réglages admin.

create table if not exists public.platform_settings (
  key text primary key,
  value jsonb not null default '{}'::jsonb,
  updated_at timestamptz not null default now(),
  updated_by uuid references auth.users (id) on delete set null
);

comment on table public.platform_settings is
  'Paramètres plateforme modifiables par les admins (essai catalogue, etc.).';

alter table public.platform_settings enable row level security;

drop policy if exists platform_settings_admin_all on public.platform_settings;
create policy platform_settings_admin_all
  on public.platform_settings
  for all
  to authenticated
  using (public.is_admin_user(auth.uid()))
  with check (public.is_admin_user(auth.uid()));

insert into public.platform_settings (key, value)
values ('catalog_trial', jsonb_build_object('days', 90))
on conflict (key) do nothing;

create or replace function public.platform_catalog_trial_days()
returns integer
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (
      select (ps.value->>'days')::integer
      from public.platform_settings ps
      where ps.key = 'catalog_trial'
    ),
    90
  );
$$;

comment on function public.platform_catalog_trial_days() is
  'Durée d’essai catalogue (jours) pour les nouveaux profils prestataires.';

create or replace function public.get_catalog_trial_days()
returns integer
language sql
stable
security definer
set search_path = public
as $$
  select public.platform_catalog_trial_days();
$$;

grant execute on function public.get_catalog_trial_days() to authenticated;
grant execute on function public.get_catalog_trial_days() to anon;

create or replace function public.prestataire_profiles_set_catalog_trial()
returns trigger
language plpgsql
set search_path = public
as $$
declare
  v_days integer;
begin
  if new.catalog_trial_ends_at is null then
    v_days := public.platform_catalog_trial_days();
    new.catalog_trial_ends_at := now() + make_interval(days => v_days);
  end if;
  return new;
end;
$$;

comment on column public.prestataire_profiles.catalog_trial_ends_at is
  'Fin de l’essai gratuit catalogue (durée configurable — défaut 3 mois).';

comment on function public.prestataire_is_in_catalog_trial(uuid) is
  'True pendant l’essai catalogue gratuit (sans abonnement Stripe).';

-- Prolonger les prestataires non abonnés à la nouvelle durée par défaut.
update public.prestataire_profiles p
set catalog_trial_ends_at = now() + make_interval(days => public.platform_catalog_trial_days())
where coalesce(p.subscription_status, 'none') not in ('active', 'trialing', 'past_due')
  and p.stripe_subscription_id is null;

create or replace function public.admin_get_catalog_trial_settings()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_days integer;
  v_in_trial bigint;
  v_expired bigint;
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  v_days := public.platform_catalog_trial_days();

  select count(*) into v_in_trial
  from public.prestataire_profiles p
  where p.catalog_trial_ends_at is not null
    and p.catalog_trial_ends_at > now()
    and coalesce(p.subscription_status, 'none') not in ('active', 'trialing');

  select count(*) into v_expired
  from public.prestataire_profiles p
  where coalesce(p.subscription_status, 'none') not in ('active', 'trialing', 'past_due')
    and p.stripe_subscription_id is null
    and (p.catalog_trial_ends_at is null or p.catalog_trial_ends_at <= now());

  return jsonb_build_object(
    'catalog_trial_days', v_days,
    'prestataires_in_trial', v_in_trial,
    'prestataires_expired_without_sub', v_expired
  );
end;
$$;

create or replace function public.admin_update_catalog_trial_days(p_days integer)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_days is null or p_days < 1 or p_days > 730 then
    raise exception 'invalid_trial_days' using errcode = '22023';
  end if;

  insert into public.platform_settings (key, value, updated_at, updated_by)
  values (
    'catalog_trial',
    jsonb_build_object('days', p_days),
    now(),
    auth.uid()
  )
  on conflict (key) do update
  set
    value = jsonb_build_object('days', p_days),
    updated_at = now(),
    updated_by = auth.uid();

  perform public.admin_write_audit_log(
    'update_catalog_trial_days',
    'platform_settings',
    'catalog_trial',
    jsonb_build_object('days', p_days)
  );

  return public.admin_get_catalog_trial_settings();
end;
$$;

create or replace function public.admin_apply_default_trial_to_unsubscribed()
returns integer
language plpgsql
security definer
set search_path = public
as $$
declare
  v_days integer;
  v_count integer;
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  v_days := public.platform_catalog_trial_days();

  update public.prestataire_profiles p
  set catalog_trial_ends_at = now() + make_interval(days => v_days)
  where coalesce(p.subscription_status, 'none') not in ('active', 'trialing', 'past_due')
    and p.stripe_subscription_id is null;

  get diagnostics v_count = row_count;

  perform public.admin_write_audit_log(
    'apply_default_catalog_trial',
    'prestataire_profiles',
    null,
    jsonb_build_object('days', v_days, 'updated_count', v_count)
  );

  return v_count;
end;
$$;

create or replace function public.admin_set_prestataire_catalog_trial_ends(
  p_prestataire_id uuid,
  p_ends_at timestamptz
)
returns timestamptz
language plpgsql
security definer
set search_path = public
as $$
declare
  v_ends timestamptz;
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_ends_at is null then
    raise exception 'ends_at_required' using errcode = '22023';
  end if;

  update public.prestataire_profiles p
  set catalog_trial_ends_at = p_ends_at
  where p.id = p_prestataire_id
  returning p.catalog_trial_ends_at into v_ends;

  if v_ends is null then
    raise exception 'prestataire_not_found' using errcode = 'P0002';
  end if;

  perform public.admin_write_audit_log(
    'set_prestataire_catalog_trial',
    'prestataire_profiles',
    p_prestataire_id::text,
    jsonb_build_object('catalog_trial_ends_at', p_ends_at)
  );

  return v_ends;
end;
$$;

create or replace function public.admin_extend_prestataire_catalog_trial(
  p_prestataire_id uuid,
  p_extra_days integer
)
returns timestamptz
language plpgsql
security definer
set search_path = public
as $$
declare
  v_base timestamptz;
  v_ends timestamptz;
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_extra_days is null or p_extra_days < 1 or p_extra_days > 730 then
    raise exception 'invalid_extra_days' using errcode = '22023';
  end if;

  select greatest(
    now(),
    coalesce(p.catalog_trial_ends_at, now())
  )
  into v_base
  from public.prestataire_profiles p
  where p.id = p_prestataire_id;

  if v_base is null then
    raise exception 'prestataire_not_found' using errcode = 'P0002';
  end if;

  v_ends := v_base + make_interval(days => p_extra_days);

  update public.prestataire_profiles p
  set catalog_trial_ends_at = v_ends
  where p.id = p_prestataire_id;

  perform public.admin_write_audit_log(
    'extend_prestataire_catalog_trial',
    'prestataire_profiles',
    p_prestataire_id::text,
    jsonb_build_object('extra_days', p_extra_days, 'catalog_trial_ends_at', v_ends)
  );

  return v_ends;
end;
$$;

create or replace function public.admin_search_prestataire_trials(
  p_query text default '',
  p_limit integer default 30
)
returns table (
  prestataire_id uuid,
  user_id uuid,
  email text,
  display_name text,
  catalog_trial_ends_at timestamptz,
  subscription_status text,
  is_in_trial boolean
)
language sql
security definer
set search_path = public, auth
as $$
  select
    p.id as prestataire_id,
    p.user_id,
    u.email::text,
    trim(concat_ws(' ', up.prenom, up.nom)) as display_name,
    p.catalog_trial_ends_at,
    coalesce(p.subscription_status, 'none') as subscription_status,
    (
      p.catalog_trial_ends_at is not null
      and p.catalog_trial_ends_at > now()
      and coalesce(p.subscription_status, 'none') not in ('active', 'trialing')
    ) as is_in_trial
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
      or p.id::text = trim(p_query)
      or p.user_id::text = trim(p_query)
    )
  order by p.catalog_trial_ends_at nulls last, u.email
  limit greatest(1, least(coalesce(p_limit, 30), 100));
$$;

grant execute on function public.admin_get_catalog_trial_settings() to authenticated;
grant execute on function public.admin_update_catalog_trial_days(integer) to authenticated;
grant execute on function public.admin_apply_default_trial_to_unsubscribed() to authenticated;
grant execute on function public.admin_set_prestataire_catalog_trial_ends(uuid, timestamptz) to authenticated;
grant execute on function public.admin_extend_prestataire_catalog_trial(uuid, integer) to authenticated;
grant execute on function public.admin_search_prestataire_trials(text, integer) to authenticated;
