-- Admin web : utilisateurs par pays (clients distincts) + résumé forfaits Stripe.

create or replace function public.admin_get_reservations_by_country()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'Accès refusé';
  end if;

  return coalesce(
    (
      select jsonb_agg(
        jsonb_build_object(
          'country_code', country_code,
          'reservations_total', reservations_total,
          'reservations_this_month', reservations_this_month,
          'prestataires_count', prestataires_count,
          'clients_count', clients_count,
          'revenue_captured_cents', revenue_captured_cents
        )
        order by reservations_total desc, country_code asc
      )
      from (
        select
          public.admin_prestataire_country_code(pp.pays, pp.code_postal) as country_code,
          count(r.id)::int as reservations_total,
          count(r.id) filter (
            where r.date_heure >= date_trunc('month', now())
          )::int as reservations_this_month,
          count(distinct pp.id)::int as prestataires_count,
          count(distinct r.client_id)::int as clients_count,
          coalesce(
            sum(r.amount_cents) filter (where r.payment_status = 'captured'),
            0
          )::bigint as revenue_captured_cents
        from public.prestataire_profiles pp
        left join public.reservations r on r.prestataire_id = pp.id
        group by 1
      ) aggregated
      where country_code is not null
    ),
    '[]'::jsonb
  );
end;
$$;

create or replace function public.admin_get_subscription_plans_summary()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_trial jsonb;
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'Accès refusé';
  end if;

  select public.admin_get_catalog_trial_settings() into v_trial;

  return jsonb_build_object(
    'catalog_trial', coalesce(v_trial, '{}'::jsonb),
    'plans', coalesce(
      (
        select jsonb_agg(
          jsonb_build_object(
            'tier', tier,
            'interval', interval_key,
            'active_count', active_count,
            'total_count', total_count
          )
          order by tier asc, interval_key asc
        )
        from (
          select
            coalesce(p.subscription_tier, 'none') as tier,
            coalesce(p.subscription_interval, 'none') as interval_key,
            count(*) filter (
              where coalesce(p.subscription_status, 'none') in ('active', 'trialing')
            )::int as active_count,
            count(*)::int as total_count
          from public.prestataire_profiles p
          where p.subscription_tier is not null
            and p.subscription_interval is not null
          group by 1, 2
        ) grouped
      ),
      '[]'::jsonb
    ),
    'status_counts', coalesce(
      (
        select jsonb_object_agg(status_key, cnt)
        from (
          select
            coalesce(subscription_status, 'none') as status_key,
            count(*)::int as cnt
          from public.prestataire_profiles
          group by 1
        ) s
      ),
      '{}'::jsonb
    )
  );
end;
$$;

grant execute on function public.admin_get_subscription_plans_summary() to authenticated;
