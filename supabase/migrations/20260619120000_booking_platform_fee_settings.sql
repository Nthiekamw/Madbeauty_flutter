-- Frais plateforme réservation client : réglables par l’admin (défaut 0 €).

insert into public.platform_settings (key, value)
values (
  'booking_platform_fee',
  jsonb_build_object('fee_cents', 0, 'free_booking_count', 2)
)
on conflict (key) do nothing;

create or replace function public.platform_booking_fee_settings()
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (
      select ps.value
      from public.platform_settings ps
      where ps.key = 'booking_platform_fee'
    ),
    jsonb_build_object('fee_cents', 0, 'free_booking_count', 2)
  );
$$;

comment on function public.platform_booking_fee_settings() is
  'Frais MadBeauty par réservation (centimes) + nombre de réservations gratuites.';

grant execute on function public.platform_booking_fee_settings() to authenticated;
grant execute on function public.platform_booking_fee_settings() to anon;
grant execute on function public.platform_booking_fee_settings() to service_role;

create or replace function public.get_booking_platform_fee_settings()
returns jsonb
language sql
stable
security definer
set search_path = public
as $$
  select public.platform_booking_fee_settings();
$$;

grant execute on function public.get_booking_platform_fee_settings() to authenticated;
grant execute on function public.get_booking_platform_fee_settings() to anon;

create or replace function public.admin_get_booking_platform_fee_settings()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v jsonb;
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  v := public.platform_booking_fee_settings();

  return jsonb_build_object(
    'fee_cents', greatest(0, coalesce((v->>'fee_cents')::integer, 0)),
    'free_booking_count', greatest(0, coalesce((v->>'free_booking_count')::integer, 2))
  );
end;
$$;

create or replace function public.admin_update_booking_platform_fee(
  p_fee_cents integer,
  p_free_booking_count integer default 2
)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_fee_cents is null or p_fee_cents < 0 or p_fee_cents > 100000 then
    raise exception 'invalid_fee_cents' using errcode = '22023';
  end if;

  if p_free_booking_count is null or p_free_booking_count < 0 or p_free_booking_count > 100 then
    raise exception 'invalid_free_booking_count' using errcode = '22023';
  end if;

  insert into public.platform_settings (key, value, updated_at, updated_by)
  values (
    'booking_platform_fee',
    jsonb_build_object(
      'fee_cents', p_fee_cents,
      'free_booking_count', p_free_booking_count
    ),
    now(),
    auth.uid()
  )
  on conflict (key) do update
  set
    value = jsonb_build_object(
      'fee_cents', p_fee_cents,
      'free_booking_count', p_free_booking_count
    ),
    updated_at = now(),
    updated_by = auth.uid();

  perform public.admin_write_audit_log(
    'update_booking_platform_fee',
    'platform_settings',
    'booking_platform_fee',
    jsonb_build_object(
      'fee_cents', p_fee_cents,
      'free_booking_count', p_free_booking_count
    )
  );

  return public.admin_get_booking_platform_fee_settings();
end;
$$;
