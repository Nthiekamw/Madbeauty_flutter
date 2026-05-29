-- Statistiques prestataire : vue agrégée + RPC paramétrée par période.

-- Normalise statut réservation (é → e, minuscules).
create or replace function public.normalize_reservation_statut(p_statut text)
returns text
language sql
immutable
as $$
  select lower(replace(trim(coalesce(p_statut, '')), 'é', 'e'));
$$;

-- CA en centimes : Stripe capturé OU prix service si confirmée / terminée.
create or replace function public.reservation_revenue_cents(
  p_amount_cents integer,
  p_payment_status text,
  p_statut text,
  p_service_prix numeric
)
returns bigint
language sql
immutable
as $$
  select case
    when lower(trim(coalesce(p_payment_status, ''))) = 'captured'
      and coalesce(p_amount_cents, 0) > 0
      then p_amount_cents::bigint
    when public.normalize_reservation_statut(p_statut) in (
      'confirmee', 'confirmed', 'terminee', 'completed'
    )
      then greatest(0, round(coalesce(p_service_prix, 0) * 100))::bigint
    else 0::bigint
  end;
$$;

-- Créneaux de 30 min dans une plage horaire.
create or replace function public.disponibilite_slot_count(
  p_heure_debut time,
  p_heure_fin time,
  p_capacite integer
)
returns integer
language sql
immutable
as $$
  select greatest(
    0,
    (extract(epoch from (p_heure_fin - p_heure_debut))::int / 1800)
      * greatest(1, coalesce(p_capacite, 1))
  );
$$;

-- Stats dynamiques (période glissante en jours).
create or replace function public.get_prestataire_stats(
  p_prestataire_id uuid,
  p_period_days integer default 30
)
returns jsonb
language plpgsql
stable
security invoker
set search_path = public
as $$
declare
  v_period_days integer := greatest(1, least(coalesce(p_period_days, 30), 365));
  v_period_start timestamptz;
  v_period_end timestamptz;
  v_prev_start timestamptz;
  v_prev_end timestamptz;
  v_ca_period bigint := 0;
  v_ca_prev bigint := 0;
  v_pending integer := 0;
  v_confirmed integer := 0;
  v_done integer := 0;
  v_cancelled integer := 0;
  v_total integer := 0;
  v_capacity bigint := 0;
  v_booked bigint := 0;
  v_occupancy numeric := 0;
  v_weekly jsonb := '[]'::jsonb;
  v_chart jsonb := '[]'::jsonb;
  v_heatmap jsonb := '[0,0,0,0,0,0,0]'::jsonb;
  v_busiest int := null;
  v_dow int;
  v_cnt numeric;
  v_dow_counts numeric[] := array[0, 0, 0, 0, 0, 0, 0];
  v_max_count numeric := 0;
begin
  v_period_end := date_trunc('day', now()) + interval '1 day';
  v_period_start := v_period_end - make_interval(days => v_period_days);
  v_prev_end := v_period_start;
  v_prev_start := v_prev_end - make_interval(days => v_period_days);

  select
    coalesce(sum(
      case when r.date_heure >= v_period_start and r.date_heure < v_period_end
        then public.reservation_revenue_cents(
          r.amount_cents, r.payment_status, r.statut, s.prix
        ) else 0 end
    ), 0),
    coalesce(sum(
      case when r.date_heure >= v_prev_start and r.date_heure < v_prev_end
        then public.reservation_revenue_cents(
          r.amount_cents, r.payment_status, r.statut, s.prix
        ) else 0 end
    ), 0)
  into v_ca_period, v_ca_prev
  from public.reservations r
  join public.services_beaute s on s.id = r.service_id
  where r.prestataire_id = p_prestataire_id;

  select
    count(*) filter (
      where public.normalize_reservation_statut(r.statut) in ('en_attente', 'pending')
    ),
    count(*) filter (
      where public.normalize_reservation_statut(r.statut) in ('confirmee', 'confirmed')
    ),
    count(*) filter (
      where public.normalize_reservation_statut(r.statut) in ('terminee', 'completed')
    ),
    count(*) filter (
      where public.normalize_reservation_statut(r.statut) in ('annulee', 'cancelled', 'canceled')
    ),
    count(*)
  into v_pending, v_confirmed, v_done, v_cancelled, v_total
  from public.reservations r
  where r.prestataire_id = p_prestataire_id
    and r.date_heure >= v_period_start
    and r.date_heure < v_period_end;

  with days as (
    select generate_series(
      date_trunc('day', v_period_start)::date,
      (v_period_end - interval '1 day')::date,
      interval '1 day'
    )::date as d
  ),
  cap as (
    select coalesce(sum(
      public.disponibilite_slot_count(disp.heure_debut, disp.heure_fin, disp.capacite_simultanee)
    ), 0)::bigint as slots
    from days
    join public.disponibilites disp
      on disp.prestataire_id = p_prestataire_id
     and disp.jour_semaine = extract(dow from days.d)::int
  ),
  booked as (
    select count(*)::bigint as slots
    from public.reservations r
    where r.prestataire_id = p_prestataire_id
      and r.date_heure >= v_period_start
      and r.date_heure < v_period_end
      and public.normalize_reservation_statut(r.statut) in (
        'en_attente', 'pending', 'confirmee', 'confirmed', 'terminee', 'completed'
      )
  )
  select cap.slots, booked.slots into v_capacity, v_booked from cap, booked;

  if v_capacity > 0 then
    v_occupancy := round((v_booked::numeric / v_capacity::numeric) * 100, 1);
  end if;

  select coalesce(jsonb_agg(
    jsonb_build_object(
      'week_start', w.week_start,
      'label', w.label,
      'revenue_cents', w.revenue_cents
    ) order by w.week_start
  ), '[]'::jsonb)
  into v_weekly
  from (
    select
      date_trunc('week', r.date_heure)::date as week_start,
      'S' || row_number() over (order by date_trunc('week', r.date_heure)) as label,
      sum(public.reservation_revenue_cents(
        r.amount_cents, r.payment_status, r.statut, s.prix
      ))::bigint as revenue_cents
    from public.reservations r
    join public.services_beaute s on s.id = r.service_id
    where r.prestataire_id = p_prestataire_id
      and r.date_heure >= v_period_end - interval '90 days'
      and r.date_heure < v_period_end
    group by date_trunc('week', r.date_heure)
  ) w;

  if v_period_days <= 7 then
    select coalesce(jsonb_agg(
      jsonb_build_object(
        'label', to_char(d.d, 'Dy'),
        'revenue_cents', coalesce(d.rev, 0)
      ) order by d.d
    ), '[]'::jsonb)
    into v_chart
    from (
      select
        gs.d::date as d,
        (
          select sum(public.reservation_revenue_cents(
            r.amount_cents, r.payment_status, r.statut, s.prix
          ))
          from public.reservations r
          join public.services_beaute s on s.id = r.service_id
          where r.prestataire_id = p_prestataire_id
            and r.date_heure >= gs.d
            and r.date_heure < gs.d + interval '1 day'
        )::bigint as rev
      from generate_series(
        (v_period_end - make_interval(days => v_period_days))::date,
        (v_period_end - interval '1 day')::date,
        interval '1 day'
      ) gs(d)
    ) d;
  elsif v_period_days <= 31 then
    select coalesce(jsonb_agg(
      jsonb_build_object(
        'label', c.label,
        'revenue_cents', c.revenue_cents
      ) order by c.week_start
    ), '[]'::jsonb)
    into v_chart
    from (
      select
        date_trunc('week', r.date_heure)::date as week_start,
        'S' || row_number() over (order by date_trunc('week', r.date_heure)) as label,
        sum(public.reservation_revenue_cents(
          r.amount_cents, r.payment_status, r.statut, s.prix
        ))::bigint as revenue_cents
      from public.reservations r
      join public.services_beaute s on s.id = r.service_id
      where r.prestataire_id = p_prestataire_id
        and r.date_heure >= v_period_start
        and r.date_heure < v_period_end
      group by date_trunc('week', r.date_heure)
    ) c;
  else
    select coalesce(jsonb_agg(
      jsonb_build_object(
        'label', c.label,
        'revenue_cents', c.revenue_cents
      ) order by c.month_start
    ), '[]'::jsonb)
    into v_chart
    from (
      select
        date_trunc('month', r.date_heure)::date as month_start,
        'M' || extract(month from date_trunc('month', r.date_heure))::text as label,
        sum(public.reservation_revenue_cents(
          r.amount_cents, r.payment_status, r.statut, s.prix
        ))::bigint as revenue_cents
      from public.reservations r
      join public.services_beaute s on s.id = r.service_id
      where r.prestataire_id = p_prestataire_id
        and r.date_heure >= v_period_start
        and r.date_heure < v_period_end
      group by date_trunc('month', r.date_heure)
    ) c;
  end if;

  for v_dow, v_cnt in
    select
      extract(isodow from r.date_heure)::int,
      count(*)::numeric
    from public.reservations r
    where r.prestataire_id = p_prestataire_id
      and r.date_heure >= v_period_start
      and r.date_heure < v_period_end
      and public.normalize_reservation_statut(r.statut) in (
        'en_attente', 'pending', 'confirmee', 'confirmed', 'terminee', 'completed'
      )
    group by extract(isodow from r.date_heure)
  loop
    if v_dow between 1 and 7 then
      v_dow_counts[v_dow] := v_cnt;
    end if;
  end loop;

  select coalesce(max(c), 0) into v_max_count from unnest(v_dow_counts) c;

  if v_max_count > 0 then
    select jsonb_agg(round((c / v_max_count)::numeric, 4) order by g)
    into v_heatmap
    from unnest(v_dow_counts) with ordinality as t(c, g);
  end if;

  select isodow into v_busiest
  from (
    select isodow, cnt
    from (
      select
        extract(isodow from r.date_heure)::int as isodow,
        count(*) as cnt
      from public.reservations r
      where r.prestataire_id = p_prestataire_id
        and r.date_heure >= v_period_start
        and r.date_heure < v_period_end
        and public.normalize_reservation_statut(r.statut) in (
          'en_attente', 'pending', 'confirmee', 'confirmed', 'terminee', 'completed'
        )
      group by extract(isodow from r.date_heure)
    ) x
    order by cnt desc, isodow
    limit 1
  ) t;

  return jsonb_build_object(
    'prestataire_id', p_prestataire_id,
    'period_days', v_period_days,
    'ca_period_cents', v_ca_period,
    'ca_previous_period_cents', v_ca_prev,
    'bookings_pending', v_pending,
    'bookings_confirmed', v_confirmed,
    'bookings_done', v_done,
    'bookings_cancelled', v_cancelled,
    'bookings_total', v_total,
    'occupancy_percent', v_occupancy,
    'capacity_slots', v_capacity,
    'booked_slots', v_booked,
    'weekday_heatmap', coalesce(v_heatmap, '[0,0,0,0,0,0,0]'::jsonb),
    'busiest_weekday', v_busiest,
    'weekly_revenue_3m', coalesce(v_weekly, '[]'::jsonb),
    'chart', coalesce(v_chart, '[]'::jsonb)
  );
end;
$$;

comment on function public.get_prestataire_stats(uuid, integer) is
  'Stats prestataire pour une période glissante (jours). RLS via security invoker.';

-- Vue : mois calendaire en cours + précédent (lecture rapide).
create or replace view public.stats_prestataire as
with bounds as (
  select
    date_trunc('month', now()) as month_start,
    date_trunc('month', now()) + interval '1 month' as month_end,
    date_trunc('month', now()) - interval '1 month' as prev_month_start
)
select
  p.id as prestataire_id,
  coalesce((
    select sum(public.reservation_revenue_cents(
      r.amount_cents, r.payment_status, r.statut, s.prix
    ))
    from public.reservations r
    join public.services_beaute s on s.id = r.service_id
    cross join bounds b
    where r.prestataire_id = p.id
      and r.date_heure >= b.month_start
      and r.date_heure < b.month_end
  ), 0)::bigint as ca_current_month_cents,
  coalesce((
    select sum(public.reservation_revenue_cents(
      r.amount_cents, r.payment_status, r.statut, s.prix
    ))
    from public.reservations r
    join public.services_beaute s on s.id = r.service_id
    cross join bounds b
    where r.prestataire_id = p.id
      and r.date_heure >= b.prev_month_start
      and r.date_heure < b.month_start
  ), 0)::bigint as ca_previous_month_cents,
  coalesce((
    select count(*) filter (
      where public.normalize_reservation_statut(r.statut) in ('en_attente', 'pending')
    )
    from public.reservations r
    cross join bounds b
    where r.prestataire_id = p.id
      and r.date_heure >= b.month_start
      and r.date_heure < b.month_end
  ), 0)::integer as bookings_pending,
  coalesce((
    select count(*) filter (
      where public.normalize_reservation_statut(r.statut) in ('confirmee', 'confirmed')
    )
    from public.reservations r
    cross join bounds b
    where r.prestataire_id = p.id
      and r.date_heure >= b.month_start
      and r.date_heure < b.month_end
  ), 0)::integer as bookings_confirmed,
  coalesce((
    select count(*) filter (
      where public.normalize_reservation_statut(r.statut) in ('terminee', 'completed')
    )
    from public.reservations r
    cross join bounds b
    where r.prestataire_id = p.id
      and r.date_heure >= b.month_start
      and r.date_heure < b.month_end
  ), 0)::integer as bookings_done,
  coalesce((
    select count(*) filter (
      where public.normalize_reservation_statut(r.statut) in ('annulee', 'cancelled', 'canceled')
    )
    from public.reservations r
    cross join bounds b
    where r.prestataire_id = p.id
      and r.date_heure >= b.month_start
      and r.date_heure < b.month_end
  ), 0)::integer as bookings_cancelled,
  coalesce((
    select count(*)
    from public.reservations r
    cross join bounds b
    where r.prestataire_id = p.id
      and r.date_heure >= b.month_start
      and r.date_heure < b.month_end
  ), 0)::integer as bookings_total
from public.prestataire_profiles p;

comment on view public.stats_prestataire is
  'Agrégats mois calendaire par prestataire. Période glissante : get_prestataire_stats().';

grant select on public.stats_prestataire to authenticated;
grant execute on function public.get_prestataire_stats(uuid, integer) to authenticated;
