-- Corrige l'appel grant_referral_booking_discount (integer vs smallint → 42883).

drop function if exists public.grant_referral_booking_discount(uuid, text, smallint);

create or replace function public.grant_referral_booking_discount(
  p_client_id uuid,
  p_reason text,
  p_percent integer default 10
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.client_profiles
  set
    referral_discount_percent = p_percent::smallint,
    referral_discount_reason = p_reason,
    referral_discount_granted_at = now(),
    referral_discount_used_at = null
  where id = p_client_id;
end;
$$;

create or replace function public.apply_referral_code(p_code text)
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_referred_id uuid;
  v_referrer_id uuid;
  v_normalized text := upper(trim(coalesce(p_code, '')));
begin
  if length(v_normalized) < 4 then
    return jsonb_build_object('ok', false, 'error', 'invalid_code');
  end if;

  select c.id into v_referred_id
  from public.client_profiles c
  where c.user_id = auth.uid();

  if v_referred_id is null then
    return jsonb_build_object('ok', false, 'error', 'client_not_found');
  end if;

  if exists (
    select 1 from public.client_referrals r
    where r.referred_client_id = v_referred_id
  ) then
    return jsonb_build_object('ok', false, 'error', 'already_referred');
  end if;

  select c.id into v_referrer_id
  from public.client_profiles c
  where c.referral_code = v_normalized;

  if v_referrer_id is null then
    return jsonb_build_object('ok', false, 'error', 'code_not_found');
  end if;

  if v_referrer_id = v_referred_id then
    return jsonb_build_object('ok', false, 'error', 'self_referral');
  end if;

  insert into public.client_referrals (referrer_client_id, referred_client_id)
  values (v_referrer_id, v_referred_id);

  perform public.grant_referral_booking_discount(
    v_referred_id,
    'referred',
    10
  );

  return jsonb_build_object('ok', true, 'discount_percent', 10);
end;
$$;

grant execute on function public.grant_referral_booking_discount(uuid, text, integer)
  to service_role;
grant execute on function public.apply_referral_code(text) to authenticated;
