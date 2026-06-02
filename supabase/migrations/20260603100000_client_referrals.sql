-- Parrainage client : code unique + filleul enregistré une fois.
-- gen_random_uuid() (pas pgcrypto) pour compatibilité Supabase remote.

alter table public.client_profiles
  add column if not exists referral_code text;

create unique index if not exists idx_client_profiles_referral_code
  on public.client_profiles (referral_code)
  where referral_code is not null;

create table if not exists public.client_referrals (
  id uuid primary key default gen_random_uuid(),
  referrer_client_id uuid not null references public.client_profiles (id) on delete cascade,
  referred_client_id uuid not null references public.client_profiles (id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint client_referrals_referred_unique unique (referred_client_id),
  constraint client_referrals_no_self check (referrer_client_id <> referred_client_id)
);

create index if not exists idx_client_referrals_referrer
  on public.client_referrals (referrer_client_id);

comment on table public.client_referrals is
  'Lien parrain → filleul (une seule attribution par compte cliente).';

alter table public.client_referrals enable row level security;

create policy "client_referrals_select_as_referrer"
on public.client_referrals for select to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = client_referrals.referrer_client_id
      and c.user_id = auth.uid()
  )
);

-- Génère un code MB + 6 caractères hex.
create or replace function public.generate_referral_code()
returns text
language plpgsql
as $$
declare
  v_code text;
  v_try integer := 0;
begin
  loop
    v_try := v_try + 1;
    v_code := 'MB' || upper(
      substr(replace(gen_random_uuid()::text, '-', ''), 1, 6)
    );
    exit when not exists (
      select 1 from public.client_profiles where referral_code = v_code
    );
    if v_try > 20 then
      raise exception 'Impossible de générer un code parrainage unique';
    end if;
  end loop;
  return v_code;
end;
$$;

create or replace function public.trg_client_profiles_referral_code()
returns trigger
language plpgsql
as $$
begin
  if new.referral_code is null or trim(new.referral_code) = '' then
    new.referral_code := public.generate_referral_code();
  else
    new.referral_code := upper(trim(new.referral_code));
  end if;
  return new;
end;
$$;

drop trigger if exists trg_client_profiles_referral_code on public.client_profiles;
create trigger trg_client_profiles_referral_code
before insert on public.client_profiles
for each row
execute function public.trg_client_profiles_referral_code();

-- Rétro-remplissage des profils existants.
update public.client_profiles
set referral_code = public.generate_referral_code()
where referral_code is null;

alter table public.client_profiles
  alter column referral_code set not null;

-- Infos parrainage pour la cliente connectée.
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
begin
  select c.id, c.referral_code
  into v_client_id, v_code
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

  return jsonb_build_object(
    'code', v_code,
    'invitations_count', v_count,
    'has_referrer', v_has_referrer
  );
end;
$$;

-- Applique un code parrain (filleul).
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

  return jsonb_build_object('ok', true);
end;
$$;

grant execute on function public.get_my_referral_info() to authenticated;
grant execute on function public.apply_referral_code(text) to authenticated;
