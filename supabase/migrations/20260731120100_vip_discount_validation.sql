-- Validation remise VIP + snapshot sur create_pack_booking + alignement fidélité/parrainage.

create or replace function public.trg_reservation_vip_discount_validate()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_is_vip boolean;
  v_base integer;
  v_after_referral integer;
  v_after_vip integer;
  v_loyalty integer := coalesce(NEW.loyalty_reward_cents, 0);
  v_expected integer;
begin
  if NEW.vip_discount_percent is null or NEW.vip_discount_percent <= 0 then
    return NEW;
  end if;

  if NEW.vip_discount_percent is distinct from 5 then
    raise exception 'vip_discount_percent_invalid'
      using errcode = 'P0001';
  end if;

  if NEW.original_service_price_cents is null or NEW.original_service_price_cents <= 0 then
    raise exception 'original_service_price_required'
      using errcode = 'P0001';
  end if;

  select coalesce(r.is_vip, false) into v_is_vip
  from public.client_prestataire_relations r
  where r.client_id = NEW.client_id
    and r.prestataire_id = NEW.prestataire_id;

  if coalesce(v_is_vip, false) is not true then
    raise exception 'vip_discount_not_available'
      using errcode = 'P0001';
  end if;

  v_base := NEW.original_service_price_cents;
  if NEW.referral_discount_percent is not null and NEW.referral_discount_percent > 0 then
    v_after_referral := round(v_base::numeric * (100 - NEW.referral_discount_percent) / 100.0);
  else
    v_after_referral := v_base;
  end if;

  v_after_vip := round(v_after_referral::numeric * (100 - NEW.vip_discount_percent) / 100.0);
  v_expected := greatest(v_after_vip - v_loyalty, 0);

  if NEW.service_price_cents is distinct from v_expected then
    raise exception 'vip_discount_amount_mismatch'
      using errcode = 'P0001';
  end if;

  return NEW;
end;
$$;

drop trigger if exists trg_reservations_vip_discount_validate on public.reservations;
create trigger trg_reservations_vip_discount_validate
before insert or update of vip_discount_percent, service_price_cents,
  original_service_price_cents, referral_discount_percent, loyalty_reward_cents
on public.reservations
for each row
execute function public.trg_reservation_vip_discount_validate();

create or replace function public.trg_reservation_loyalty_reward_validate()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_balance integer;
  v_max integer := public.loyalty_max_reward_cents();
  v_cost integer := public.loyalty_points_per_reward();
  v_after_discounts integer;
  v_expected_service integer;
  v_base integer;
begin
  if NEW.loyalty_reward_cents is null or NEW.loyalty_reward_cents <= 0 then
    return NEW;
  end if;

  if NEW.loyalty_reward_cents > v_max then
    raise exception 'loyalty_reward_exceeds_max'
      using errcode = 'P0001';
  end if;

  v_base := coalesce(
    NEW.original_service_price_cents,
    coalesce(NEW.service_price_cents, 0) + NEW.loyalty_reward_cents
  );

  if NEW.referral_discount_percent is not null
     and NEW.referral_discount_percent > 0
     and NEW.original_service_price_cents is not null then
    v_after_discounts := round(
      NEW.original_service_price_cents::numeric
        * (100 - NEW.referral_discount_percent)
        / 100.0
    );
  else
    v_after_discounts := v_base;
  end if;

  if NEW.vip_discount_percent is not null and NEW.vip_discount_percent > 0 then
    v_after_discounts := round(
      v_after_discounts::numeric * (100 - NEW.vip_discount_percent) / 100.0
    );
  end if;

  if v_after_discounts is null or v_after_discounts <= 0 then
    raise exception 'loyalty_reward_catalogue_required'
      using errcode = 'P0001';
  end if;

  if NEW.loyalty_reward_cents > v_after_discounts then
    raise exception 'loyalty_reward_exceeds_service'
      using errcode = 'P0001';
  end if;

  v_expected_service := greatest(v_after_discounts - NEW.loyalty_reward_cents, 0);
  if NEW.service_price_cents is distinct from v_expected_service then
    raise exception 'loyalty_reward_amount_mismatch'
      using errcode = 'P0001';
  end if;

  select cp.loyalty_points
  into v_balance
  from public.client_profiles cp
  where cp.id = NEW.client_id
  for update;

  if v_balance is null or v_balance < v_cost then
    raise exception 'loyalty_reward_not_available'
      using errcode = 'P0001';
  end if;

  return NEW;
end;
$$;

create or replace function public.trg_reservation_referral_discount_validate()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_active_percent smallint;
  v_expected integer;
  v_loyalty integer := coalesce(NEW.loyalty_reward_cents, 0);
  v_after_referral integer;
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

  v_after_referral := round(
    NEW.original_service_price_cents::numeric
      * (100 - NEW.referral_discount_percent)
      / 100.0
  );

  if NEW.vip_discount_percent is not null and NEW.vip_discount_percent > 0 then
    v_expected := round(
      v_after_referral::numeric * (100 - NEW.vip_discount_percent) / 100.0
    );
  else
    v_expected := v_after_referral;
  end if;

  v_expected := greatest(v_expected - v_loyalty, 0);

  if NEW.service_price_cents is distinct from v_expected then
    raise exception 'referral_discount_amount_mismatch'
      using errcode = 'P0001';
  end if;

  return NEW;
end;
$$;
