-- Fidélité client : +2 pts par résa acompte (deposit_20) terminée ;
-- 200 pts = 1 prestation offerte (plafond 50 €) chez n'importe quel presta.

-- ---------------------------------------------------------------------------
-- Profil client
-- ---------------------------------------------------------------------------

alter table public.client_profiles
  add column if not exists loyalty_points integer not null default 0,
  add column if not exists loyalty_points_earned_total integer not null default 0,
  add column if not exists loyalty_rewards_redeemed integer not null default 0;

alter table public.client_profiles
  drop constraint if exists client_profiles_loyalty_points_check;
alter table public.client_profiles
  add constraint client_profiles_loyalty_points_check
  check (loyalty_points >= 0);

alter table public.client_profiles
  drop constraint if exists client_profiles_loyalty_earned_check;
alter table public.client_profiles
  add constraint client_profiles_loyalty_earned_check
  check (loyalty_points_earned_total >= 0);

alter table public.client_profiles
  drop constraint if exists client_profiles_loyalty_redeemed_check;
alter table public.client_profiles
  add constraint client_profiles_loyalty_redeemed_check
  check (loyalty_rewards_redeemed >= 0);

comment on column public.client_profiles.loyalty_points is
  'Solde de points fidélité (2 pts / résa acompte terminée ; −200 à la récompense).';
comment on column public.client_profiles.loyalty_points_earned_total is
  'Total de points gagnés (lifetime, pour badges).';
comment on column public.client_profiles.loyalty_rewards_redeemed is
  'Nombre de prestations offertes déjà utilisées.';

-- ---------------------------------------------------------------------------
-- Snapshot sur réservations
-- ---------------------------------------------------------------------------

alter table public.reservations
  add column if not exists loyalty_points_earned smallint,
  add column if not exists loyalty_reward_cents integer;

comment on column public.reservations.loyalty_points_earned is
  'Points crédités à la clôture (2 si éligible).';
comment on column public.reservations.loyalty_reward_cents is
  'Montant prestation couvert par la récompense fidélité (centimes, max 5000).';

alter table public.reservations
  drop constraint if exists reservations_loyalty_reward_cents_check;
alter table public.reservations
  add constraint reservations_loyalty_reward_cents_check
  check (
    loyalty_reward_cents is null
    or (loyalty_reward_cents > 0 and loyalty_reward_cents <= 5000)
  );

-- ---------------------------------------------------------------------------
-- Ledger audit
-- ---------------------------------------------------------------------------

create table if not exists public.loyalty_ledger (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.client_profiles (id) on delete cascade,
  reservation_id uuid references public.reservations (id) on delete set null,
  delta_points integer not null,
  kind text not null,
  balance_after integer not null,
  created_at timestamptz not null default now(),
  constraint loyalty_ledger_kind_check check (
    kind in ('earn', 'redeem', 'adjust')
  ),
  constraint loyalty_ledger_delta_check check (delta_points <> 0)
);

create index if not exists idx_loyalty_ledger_client_created
  on public.loyalty_ledger (client_id, created_at desc);

create unique index if not exists idx_loyalty_ledger_earn_reservation
  on public.loyalty_ledger (reservation_id)
  where kind = 'earn' and reservation_id is not null;

create unique index if not exists idx_loyalty_ledger_redeem_reservation
  on public.loyalty_ledger (reservation_id)
  where kind = 'redeem' and reservation_id is not null;

comment on table public.loyalty_ledger is
  'Historique des mouvements de points fidélité.';

alter table public.loyalty_ledger enable row level security;

drop policy if exists "loyalty_ledger_select_own" on public.loyalty_ledger;
create policy "loyalty_ledger_select_own"
  on public.loyalty_ledger for select to authenticated
  using (
    exists (
      select 1
      from public.client_profiles cp
      where cp.id = loyalty_ledger.client_id
        and cp.user_id = auth.uid()
    )
  );

-- Pas d'insert/update/delete client : uniquement via triggers SECURITY DEFINER.

-- ---------------------------------------------------------------------------
-- Constantes métier (fonctions)
-- ---------------------------------------------------------------------------

create or replace function public.loyalty_points_per_booking()
returns integer
language sql
immutable
as $$ select 2 $$;

create or replace function public.loyalty_points_per_reward()
returns integer
language sql
immutable
as $$ select 200 $$;

create or replace function public.loyalty_max_reward_cents()
returns integer
language sql
immutable
as $$ select 5000 $$;

-- ---------------------------------------------------------------------------
-- Gain : résa acompte (deposit_20 + PI) → terminée
-- ---------------------------------------------------------------------------

create or replace function public.trg_reservation_loyalty_earn()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_points integer := public.loyalty_points_per_booking();
  v_new_balance integer;
begin
  if TG_OP <> 'UPDATE' then
    return NEW;
  end if;

  if NEW.statut is distinct from 'terminee' then
    return NEW;
  end if;

  if OLD.statut is not distinct from 'terminee' then
    return NEW;
  end if;

  -- Déjà crédité
  if coalesce(NEW.loyalty_points_earned, 0) > 0 then
    return NEW;
  end if;

  -- Uniquement acompte app + paiement Stripe associé
  if NEW.payment_mode is distinct from 'deposit_20' then
    return NEW;
  end if;

  if NEW.stripe_payment_intent_id is null
     or length(trim(NEW.stripe_payment_intent_id)) = 0 then
    return NEW;
  end if;

  if exists (
    select 1
    from public.loyalty_ledger l
    where l.reservation_id = NEW.id
      and l.kind = 'earn'
  ) then
    NEW.loyalty_points_earned := v_points;
    return NEW;
  end if;

  update public.client_profiles
  set
    loyalty_points = loyalty_points + v_points,
    loyalty_points_earned_total = loyalty_points_earned_total + v_points
  where id = NEW.client_id
  returning loyalty_points into v_new_balance;

  if v_new_balance is null then
    return NEW;
  end if;

  insert into public.loyalty_ledger (
    client_id,
    reservation_id,
    delta_points,
    kind,
    balance_after
  ) values (
    NEW.client_id,
    NEW.id,
    v_points,
    'earn',
    v_new_balance
  );

  NEW.loyalty_points_earned := v_points;
  return NEW;
end;
$$;

drop trigger if exists trg_reservations_loyalty_earn on public.reservations;
create trigger trg_reservations_loyalty_earn
before update of statut on public.reservations
for each row
execute function public.trg_reservation_loyalty_earn();

-- ---------------------------------------------------------------------------
-- Redeem : validate + consume à l'insert
-- ---------------------------------------------------------------------------

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
begin
  if NEW.loyalty_reward_cents is null or NEW.loyalty_reward_cents <= 0 then
    return NEW;
  end if;

  if NEW.loyalty_reward_cents > v_max then
    raise exception 'loyalty_reward_exceeds_max'
      using errcode = 'P0001';
  end if;

  -- Prix après remise parrainage (si présente), sinon catalogue via original / reconstruit.
  if NEW.referral_discount_percent is not null
     and NEW.referral_discount_percent > 0
     and NEW.original_service_price_cents is not null then
    v_after_discounts := round(
      NEW.original_service_price_cents::numeric
        * (100 - NEW.referral_discount_percent)
        / 100.0
    );
  else
    v_after_discounts := coalesce(
      NEW.original_service_price_cents,
      coalesce(NEW.service_price_cents, 0) + NEW.loyalty_reward_cents
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

-- Parrainage : autoriser service_price = prix remisé − couverture fidélité.
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
  v_expected := greatest(v_expected - v_loyalty, 0);

  if NEW.service_price_cents is distinct from v_expected then
    raise exception 'referral_discount_amount_mismatch'
      using errcode = 'P0001';
  end if;

  return NEW;
end;
$$;

create or replace function public.trg_reservation_loyalty_reward_consume()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_cost integer := public.loyalty_points_per_reward();
  v_new_balance integer;
begin
  if NEW.loyalty_reward_cents is null or NEW.loyalty_reward_cents <= 0 then
    return NEW;
  end if;

  update public.client_profiles
  set
    loyalty_points = loyalty_points - v_cost,
    loyalty_rewards_redeemed = loyalty_rewards_redeemed + 1
  where id = NEW.client_id
    and loyalty_points >= v_cost
  returning loyalty_points into v_new_balance;

  if v_new_balance is null then
    raise exception 'loyalty_reward_not_available'
      using errcode = 'P0001';
  end if;

  insert into public.loyalty_ledger (
    client_id,
    reservation_id,
    delta_points,
    kind,
    balance_after
  ) values (
    NEW.client_id,
    NEW.id,
    -v_cost,
    'redeem',
    v_new_balance
  );

  return NEW;
end;
$$;

drop trigger if exists trg_reservations_loyalty_reward_validate on public.reservations;
create trigger trg_reservations_loyalty_reward_validate
before insert on public.reservations
for each row
execute function public.trg_reservation_loyalty_reward_validate();

drop trigger if exists trg_reservations_loyalty_reward_consume on public.reservations;
create trigger trg_reservations_loyalty_reward_consume
after insert on public.reservations
for each row
execute function public.trg_reservation_loyalty_reward_consume();

-- ---------------------------------------------------------------------------
-- RPC lecture
-- ---------------------------------------------------------------------------

create or replace function public.get_my_loyalty_info()
returns jsonb
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_client_id uuid;
  v_points integer;
  v_earned integer;
  v_redeemed integer;
  v_need integer := public.loyalty_points_per_reward();
  v_per integer := public.loyalty_points_per_booking();
  v_max_cents integer := public.loyalty_max_reward_cents();
  v_progress integer;
  v_can_redeem boolean;
begin
  if v_uid is null then
    return jsonb_build_object('error', 'not_authenticated');
  end if;

  select cp.id, cp.loyalty_points, cp.loyalty_points_earned_total, cp.loyalty_rewards_redeemed
  into v_client_id, v_points, v_earned, v_redeemed
  from public.client_profiles cp
  where cp.user_id = v_uid;

  if v_client_id is null then
    return jsonb_build_object('error', 'client_not_found');
  end if;

  v_progress := least(v_points, v_need);
  v_can_redeem := v_points >= v_need;

  return jsonb_build_object(
    'points', v_points,
    'points_earned_total', v_earned,
    'rewards_redeemed', v_redeemed,
    'points_per_booking', v_per,
    'points_per_reward', v_need,
    'max_reward_cents', v_max_cents,
    'progress_points', v_progress,
    'points_remaining', greatest(v_need - v_points, 0),
    'can_redeem', v_can_redeem,
    'eligible_payment_mode', 'deposit_20',
    'badges', jsonb_build_array(
      jsonb_build_object(
        'id', 'steps',
        'threshold', 50,
        'unlocked', v_earned >= 50
      ),
      jsonb_build_object(
        'id', 'loyal',
        'threshold', 100,
        'unlocked', v_earned >= 100
      ),
      jsonb_build_object(
        'id', 'vip',
        'threshold', 150,
        'unlocked', v_earned >= 150
      ),
      jsonb_build_object(
        'id', 'reward',
        'threshold', 200,
        'unlocked', v_earned >= 200
      )
    )
  );
end;
$$;

revoke all on function public.get_my_loyalty_info() from public;
grant execute on function public.get_my_loyalty_info() to authenticated;

comment on function public.get_my_loyalty_info() is
  'Solde, progression et badges fidélité du client connecté.';
