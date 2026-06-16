-- Dashboard admin : agrégation des réservations par pays (salon prestataire).

alter table public.prestataire_profiles
  add column if not exists pays char(2);

comment on column public.prestataire_profiles.pays is
  'Code pays ISO 3166-1 alpha-2 du salon (ex. FR, BE).';

update public.prestataire_profiles
set pays = 'FR'
where pays is null
  and trim(coalesce(code_postal, '')) ~ '^[0-9]{5}$';

update public.prestataire_profiles
set pays = 'BE'
where pays is null
  and trim(coalesce(code_postal, '')) ~ '^[0-9]{4}$';

update public.prestataire_profiles
set pays = 'CH'
where pays is null
  and trim(coalesce(code_postal, '')) ~ '^[1-9][0-9]{3}$';

update public.prestataire_profiles
set pays = 'NL'
where pays is null
  and upper(trim(coalesce(code_postal, ''))) ~ '^[1-9][0-9]{3}\s?[A-Z]{2}$';

create or replace function public.admin_prestataire_country_code(
  p_pays text,
  p_code_postal text
)
returns text
language sql
immutable
parallel safe
as $$
  select coalesce(
    nullif(upper(trim(p_pays)), ''),
    case
      when trim(coalesce(p_code_postal, '')) ~ '^[0-9]{5}$' then 'FR'
      when upper(trim(coalesce(p_code_postal, ''))) ~ '^[1-9][0-9]{3}\s?[A-Z]{2}$' then 'NL'
      when trim(coalesce(p_code_postal, '')) ~ '^[1-9][0-9]{4}$' then 'CH'
      when trim(coalesce(p_code_postal, '')) ~ '^[0-9]{4}$' then 'BE'
      else 'XX'
    end
  );
$$;

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
          coalesce(
            sum(r.amount_cents) filter (where r.payment_status = 'captured'),
            0
          )::bigint as revenue_captured_cents
        from public.reservations r
        inner join public.prestataire_profiles pp on pp.id = r.prestataire_id
        group by 1
      ) aggregated
    ),
    '[]'::jsonb
  );
end;
$$;

grant execute on function public.admin_get_reservations_by_country() to authenticated;
