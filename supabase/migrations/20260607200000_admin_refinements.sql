-- Raffinements admin : filtres réservations, ban avec motif obligatoire.

create or replace function public.admin_ban_user(
  p_user_id uuid,
  p_reason text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_user_id = auth.uid() then
    raise exception 'cannot_ban_self' using errcode = '42501';
  end if;

  if nullif(trim(coalesce(p_reason, '')), '') is null then
    raise exception 'ban_reason_required' using errcode = 'P0001';
  end if;

  update public.user_profiles
  set is_banned = true,
      banned_at = now(),
      banned_by = auth.uid(),
      ban_reason = trim(p_reason)
  where user_id = p_user_id;

  if not found then
    raise exception 'user_not_found' using errcode = 'P0002';
  end if;

  perform public.admin_write_audit_log(
    'ban_user',
    'user',
    p_user_id::text,
    jsonb_build_object('reason', trim(p_reason))
  );
end;
$$;

drop function if exists public.admin_list_reservations(integer);

create or replace function public.admin_list_reservations(
  p_limit integer default 100,
  p_statut text default null,
  p_payment_status text default null,
  p_from_date timestamptz default null,
  p_to_date timestamptz default null
)
returns table (
  id uuid,
  date_heure timestamptz,
  statut text,
  payment_status text,
  payment_mode text,
  amount_cents integer,
  currency text,
  client_name text,
  prestataire_salon text,
  service_name text,
  stripe_payment_intent_id text,
  paid_at timestamptz
)
language sql
security definer
set search_path = public
as $$
  select
    r.id,
    r.date_heure,
    r.statut,
    r.payment_status,
    r.payment_mode,
    r.amount_cents,
    r.currency,
    trim(concat_ws(' ', cup.prenom, cup.nom)) as client_name,
    pp.nom_salon as prestataire_salon,
    sb.nom as service_name,
    r.stripe_payment_intent_id,
    r.paid_at
  from public.reservations r
  inner join public.client_profiles cp on cp.id = r.client_id
  left join public.user_profiles cup on cup.user_id = cp.user_id
  inner join public.prestataire_profiles pp on pp.id = r.prestataire_id
  left join public.services_beaute sb on sb.id = r.service_id
  where public.is_admin_user(auth.uid())
    and (p_statut is null or trim(p_statut) = '' or r.statut = p_statut)
    and (
      p_payment_status is null
      or trim(p_payment_status) = ''
      or r.payment_status = p_payment_status
    )
    and (p_from_date is null or r.date_heure >= p_from_date)
    and (p_to_date is null or r.date_heure <= p_to_date)
  order by r.date_heure desc
  limit greatest(1, least(coalesce(p_limit, 100), 500));
$$;

grant execute on function public.admin_list_reservations(
  integer,
  text,
  text,
  timestamptz,
  timestamptz
) to authenticated;

-- Nouvelle demande (ou relance) : toujours horodater + notifier via webhook.
create or replace function public.request_prestataire_verification()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_prestataire_id uuid;
begin
  select pp.id
  into v_prestataire_id
  from public.prestataire_profiles pp
  where pp.user_id = auth.uid();

  if v_prestataire_id is null then
    raise exception 'prestataire_profile_not_found'
      using errcode = 'P0002';
  end if;

  if exists (
    select 1
    from public.prestataire_profiles pp
    where pp.id = v_prestataire_id
      and pp.is_verified = true
  ) then
    raise exception 'already_verified'
      using errcode = 'P0002';
  end if;

  update public.prestataire_profiles
  set verification_requested_at = now()
  where id = v_prestataire_id;

  insert into public.prestataire_verification_events (
    prestataire_id,
    actor_user_id,
    action,
    note
  )
  values (v_prestataire_id, auth.uid(), 'requested', null);

  perform public.admin_write_audit_log(
    'verification_requested',
    'prestataire_profile',
    v_prestataire_id::text,
    null
  );
end;
$$;
