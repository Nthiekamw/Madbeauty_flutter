-- Admin web : liste des abonnements prestataires (recherche + filtres).

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
  ville text,
  subscription_status text,
  subscription_tier text,
  subscription_interval text,
  subscription_current_period_end timestamptz,
  catalog_trial_ends_at timestamptz,
  stripe_subscription_id text,
  stripe_billing_customer_id text,
  is_catalog_trial boolean,
  has_catalog_access boolean,
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
    p.ville,
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
      or coalesce(p.ville, '') ilike '%' || trim(p_query) || '%'
      or p.id::text = trim(p_query)
      or p.user_id::text = trim(p_query)
      or coalesce(p.stripe_subscription_id, '') ilike '%' || trim(p_query) || '%'
    )
    and (
      coalesce(trim(p_status), 'all') = 'all'
      or (
        trim(p_status) = 'catalog_trial'
        and p.catalog_trial_ends_at is not null
        and p.catalog_trial_ends_at > now()
        and coalesce(p.subscription_status, 'none') not in ('active', 'trialing')
      )
      or (
        trim(p_status) = 'active_paid'
        and coalesce(p.subscription_status, 'none') in ('active', 'trialing')
      )
      or (
        trim(p_status) = 'attention'
        and coalesce(p.subscription_status, 'none') in ('past_due', 'unpaid', 'incomplete')
      )
      or (
        trim(p_status) not in ('all', 'catalog_trial', 'active_paid', 'attention')
        and coalesce(p.subscription_status, 'none') = trim(p_status)
      )
    )
  order by
    case coalesce(p.subscription_status, 'none')
      when 'past_due' then 0
      when 'unpaid' then 1
      when 'incomplete' then 2
      when 'active' then 3
      when 'trialing' then 4
      when 'canceled' then 5
      else 6
    end,
    p.subscription_current_period_end desc nulls last,
    p.created_at desc
  limit greatest(1, least(coalesce(p_limit, 200), 500))
  offset greatest(coalesce(p_offset, 0), 0);
$$;

grant execute on function public.admin_search_prestataire_subscriptions(text, text, integer, integer)
  to authenticated;

comment on function public.admin_search_prestataire_subscriptions(text, text, integer, integer) is
  'Admin : liste prestataires avec statut abonnement Stripe / essai catalogue.';
