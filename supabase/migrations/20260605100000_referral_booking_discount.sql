-- Remise parrainage −10 % sur la prochaine réservation (filleule + ambassadrice).

alter table public.client_profiles
  add column if not exists referral_discount_percent smallint,
  add column if not exists referral_discount_reason text,
  add column if not exists referral_discount_granted_at timestamptz,
  add column if not exists referral_discount_used_at timestamptz;

comment on column public.client_profiles.referral_discount_percent is
  'Pourcentage de remise active sur la prochaine réservation (ex. 10).';
comment on column public.client_profiles.referral_discount_reason is
  'Origine de la remise : referred | ambassador.';
comment on column public.client_profiles.referral_discount_used_at is
  'Date de consommation de la remise sur une réservation.';

alter table public.reservations
  add column if not exists original_service_price_cents integer,
  add column if not exists referral_discount_percent smallint;

comment on column public.reservations.original_service_price_cents is
  'Prix catalogue du service (centimes) avant remise parrainage.';
comment on column public.reservations.referral_discount_percent is
  'Remise parrainage appliquée sur cette réservation (pourcentage entier).';

-- ---------------------------------------------------------------------------
-- Validation + consommation automatique à l’insertion réservation
-- ---------------------------------------------------------------------------

create or replace function public.trg_reservation_referral_discount_validate()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_active_percent smallint;
  v_expected integer;
begin
  if NEW.referral_discount_percent is null or NEW.referral_discount_percent <= 0 then
    return NEW;
  end if;

  if NEW.original_service_price_cents is null or NEW.original_service_price_cents <= 0 then
    raise exception 'original_service_price_required'
      using errcode = 'P0001';
  end if;

  select cp.referral_discount_percent
  into v_active_percent
  from public.client_profiles cp
  where cp.id = NEW.client_id
    and cp.referral_discount_percent = NEW.referral_discount_percent
    and cp.referral_discount_used_at is null;

  if v_active_percent is null then
    raise exception 'referral_discount_not_available'
      using errcode = 'P0001';
  end if;

  v_expected := round(
    NEW.original_service_price_cents::numeric
      * (100 - NEW.referral_discount_percent)
      / 100.0
  );

  if NEW.service_price_cents is distinct from v_expected then
    raise exception 'referral_discount_amount_mismatch'
      using errcode = 'P0001';
  end if;

  return NEW;
end;
$$;

create or replace function public.trg_reservation_referral_discount_consume()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if NEW.referral_discount_percent is null or NEW.referral_discount_percent <= 0 then
    return NEW;
  end if;

  update public.client_profiles
  set referral_discount_used_at = now()
  where id = NEW.client_id
    and referral_discount_percent is not null
    and referral_discount_used_at is null;

  return NEW;
end;
$$;

drop trigger if exists trg_reservations_referral_discount_validate on public.reservations;
create trigger trg_reservations_referral_discount_validate
before insert on public.reservations
for each row
execute function public.trg_reservation_referral_discount_validate();

drop trigger if exists trg_reservations_referral_discount_consume on public.reservations;
create trigger trg_reservations_referral_discount_consume
after insert on public.reservations
for each row
execute function public.trg_reservation_referral_discount_consume();

-- ---------------------------------------------------------------------------
-- Accorder remise filleule + ambassadrice
-- ---------------------------------------------------------------------------

create or replace function public.grant_referral_booking_discount(
  p_client_id uuid,
  p_reason text,
  p_percent smallint default 10
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.client_profiles
  set
    referral_discount_percent = p_percent,
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

  perform public.grant_referral_booking_discount(v_referred_id, 'referred', 10);

  return jsonb_build_object('ok', true, 'discount_percent', 10);
end;
$$;

create or replace function public.trg_check_referral_ambassador()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count integer;
begin
  select count(*)::integer
  into v_count
  from public.client_referrals
  where referrer_client_id = new.referrer_client_id;

  if v_count >= 3 then
    update public.client_profiles
    set referral_ambassador_at = coalesce(referral_ambassador_at, now())
    where id = new.referrer_client_id;

    update public.client_profiles
    set
      referral_discount_percent = 10,
      referral_discount_reason = 'ambassador',
      referral_discount_granted_at = now(),
      referral_discount_used_at = null
    where id = new.referrer_client_id
      and (
        referral_discount_percent is null
        or referral_discount_used_at is not null
      );
  end if;
  return new;
end;
$$;

-- ---------------------------------------------------------------------------
-- Infos parrainage (remise incluse)
-- ---------------------------------------------------------------------------

create or replace function public.get_my_referral_info()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_client_id uuid;
  v_code text;
  v_count integer;
  v_has_referrer boolean;
  v_ambassador_at timestamptz;
  v_tier text;
  v_next integer;
  v_reward text;
  v_disc_pct smallint;
  v_disc_reason text;
  v_disc_used timestamptz;
  v_disc_available boolean;
  v_disc_label text;
begin
  select
    c.id,
    c.referral_code,
    c.referral_ambassador_at,
    c.referral_discount_percent,
    c.referral_discount_reason,
    c.referral_discount_used_at
  into
    v_client_id,
    v_code,
    v_ambassador_at,
    v_disc_pct,
    v_disc_reason,
    v_disc_used
  from public.client_profiles c
  where c.user_id = auth.uid();

  if v_client_id is null then
    return jsonb_build_object('error', 'client_not_found');
  end if;

  select count(*)::integer
  into v_count
  from public.client_referrals r
  where r.referrer_client_id = v_client_id;

  select exists (
    select 1 from public.client_referrals r
    where r.referred_client_id = v_client_id
  )
  into v_has_referrer;

  v_disc_available := v_disc_pct is not null
    and v_disc_pct > 0
    and v_disc_used is null;

  if v_disc_available then
    v_disc_label := case v_disc_reason
      when 'referred' then format(
        '−%s %% sur ta prochaine réservation (bienvenue)',
        v_disc_pct
      )
      when 'ambassador' then format(
        '−%s %% sur ta prochaine réservation (Ambassadrice)',
        v_disc_pct
      )
      else format('−%s %% sur ta prochaine réservation', v_disc_pct)
    end;
  end if;

  if v_count >= 3 or v_ambassador_at is not null then
    v_tier := 'ambassador';
    v_next := null;
    v_reward := case
      when v_disc_available then
        'Badge Ambassadrice débloqué ! ' || v_disc_label || '.'
      else
        'Badge Ambassadrice MadBeauty débloqué ! Merci de faire grandir la communauté.'
    end;
  elsif v_count >= 1 then
    v_tier := 'friend';
    v_next := 3 - v_count;
    v_reward := case
      when v_disc_available then v_disc_label
      else format(
        'Encore %s amie(s) pour débloquer le badge Ambassadrice (−10 %% sur ta prochaine résa).',
        greatest(v_next, 0)
      )
    end;
  else
    v_tier := 'none';
    v_next := 1;
    v_reward := case
      when v_disc_available then v_disc_label
      else
        'Parraine ta première amie pour débloquer des récompenses (−10 %% pour elle, badge pour toi).'
    end;
  end if;

  return jsonb_build_object(
    'code', v_code,
    'invitations_count', v_count,
    'has_referrer', v_has_referrer,
    'is_ambassador', v_tier = 'ambassador',
    'tier', v_tier,
    'next_milestone', v_next,
    'reward_message', v_reward,
    'discount', jsonb_build_object(
      'available', v_disc_available,
      'percent', coalesce(v_disc_pct, 0),
      'reason', v_disc_reason,
      'label', coalesce(v_disc_label, '')
    )
  );
end;
$$;

grant execute on function public.grant_referral_booking_discount(uuid, text, smallint) to service_role;
