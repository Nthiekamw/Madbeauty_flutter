-- Back-office admin complet : sécurité rôles, utilisateurs, modération, analytics, audit.

-- ---------------------------------------------------------------------------
-- 1) Bannissement utilisateurs
-- ---------------------------------------------------------------------------
alter table public.user_profiles
  add column if not exists is_banned boolean not null default false,
  add column if not exists banned_at timestamptz,
  add column if not exists banned_by uuid references auth.users (id),
  add column if not exists ban_reason text;

create index if not exists idx_user_profiles_banned
  on public.user_profiles (is_banned)
  where is_banned = true;

-- ---------------------------------------------------------------------------
-- 2) Modération contenu (masquer profil, suspendre conversation, supprimer message)
-- ---------------------------------------------------------------------------
alter table public.prestataire_profiles
  add column if not exists is_hidden boolean not null default false,
  add column if not exists hidden_at timestamptz,
  add column if not exists hidden_by uuid references auth.users (id);

alter table public.conversations
  add column if not exists is_suspended boolean not null default false,
  add column if not exists suspended_at timestamptz,
  add column if not exists suspended_by uuid references auth.users (id);

alter table public.messages
  add column if not exists deleted_at timestamptz,
  add column if not exists deleted_by uuid references auth.users (id);

alter table public.content_reports
  add column if not exists action_taken text,
  add column if not exists action_note text;

-- ---------------------------------------------------------------------------
-- 3) Journal d'audit admin (générique)
-- ---------------------------------------------------------------------------
create table if not exists public.admin_audit_log (
  id uuid primary key default gen_random_uuid(),
  actor_user_id uuid not null references auth.users (id),
  action text not null,
  entity_type text not null,
  entity_id text not null,
  metadata jsonb,
  created_at timestamptz not null default now()
);

create index if not exists idx_admin_audit_log_created
  on public.admin_audit_log (created_at desc);

alter table public.admin_audit_log enable row level security;

drop policy if exists "admin_audit_log_admin_select" on public.admin_audit_log;
create policy "admin_audit_log_admin_select"
on public.admin_audit_log
for select to authenticated
using (public.is_admin_user(auth.uid()));

-- Étendre les événements de vérification prestataire
alter table public.prestataire_verification_events
  drop constraint if exists prestataire_verification_events_action_check;

alter table public.prestataire_verification_events
  add constraint prestataire_verification_events_action_check
  check (action in ('requested', 'approved', 'revoked'));

-- ---------------------------------------------------------------------------
-- 4) Sécurité user_roles : pas d'auto-promotion admin
-- ---------------------------------------------------------------------------
drop policy if exists "user_roles_insert_own" on public.user_roles;
create policy "user_roles_insert_own"
on public.user_roles
for insert to authenticated
with check (
  auth.uid() = user_id
  and role in ('client', 'prestataire')
);

drop policy if exists "user_roles_update_own" on public.user_roles;
create policy "user_roles_update_own"
on public.user_roles
for update to authenticated
using (auth.uid() = user_id)
with check (
  auth.uid() = user_id
  and role in ('client', 'prestataire')
);

-- ---------------------------------------------------------------------------
-- 5) Helpers audit
-- ---------------------------------------------------------------------------
create or replace function public.admin_write_audit_log(
  p_action text,
  p_entity_type text,
  p_entity_id text,
  p_metadata jsonb default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if auth.uid() is null then
    return;
  end if;
  insert into public.admin_audit_log (
    actor_user_id,
    action,
    entity_type,
    entity_id,
    metadata
  )
  values (auth.uid(), p_action, p_entity_type, p_entity_id, p_metadata);
end;
$$;

-- ---------------------------------------------------------------------------
-- 6) Demande de vérification prestataire
-- ---------------------------------------------------------------------------
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
  where id = v_prestataire_id
    and verification_requested_at is null;

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

grant execute on function public.request_prestataire_verification() to authenticated;

-- ---------------------------------------------------------------------------
-- 7) Liste vérifications (filtre vraies demandes)
-- ---------------------------------------------------------------------------
-- PostgreSQL interdit de changer le type de retour avec CREATE OR REPLACE seul.
drop function if exists public.admin_list_prestataire_verification_requests(boolean);

create or replace function public.admin_list_prestataire_verification_requests(
  p_only_pending boolean default true
)
returns table (
  id uuid,
  user_id uuid,
  nom_salon text,
  ville text,
  is_verified boolean,
  verified_at timestamptz,
  verification_requested_at timestamptz,
  display_name text
)
language sql
security definer
set search_path = public
as $$
  select
    pp.id,
    pp.user_id,
    pp.nom_salon,
    pp.ville,
    pp.is_verified,
    pp.verified_at,
    pp.verification_requested_at,
    trim(concat_ws(' ', up.prenom, up.nom)) as display_name
  from public.prestataire_profiles pp
  left join public.user_profiles up on up.user_id = pp.user_id
  where public.is_admin_user(auth.uid())
    and (
      not p_only_pending
      or (
        pp.is_verified = false
        and pp.verification_requested_at is not null
      )
    )
  order by pp.verification_requested_at desc nulls last, pp.created_at desc;
$$;

-- ---------------------------------------------------------------------------
-- 8) Gestion utilisateurs admin
-- ---------------------------------------------------------------------------
create or replace function public.admin_search_users(
  p_query text default '',
  p_limit integer default 50
)
returns table (
  user_id uuid,
  email text,
  prenom text,
  nom text,
  is_banned boolean,
  banned_at timestamptz,
  ban_reason text,
  roles text[]
)
language sql
security definer
set search_path = public
as $$
  select
    up.user_id,
    u.email::text,
    up.prenom,
    up.nom,
    coalesce(up.is_banned, false) as is_banned,
    up.banned_at,
    up.ban_reason,
    coalesce(
      array_agg(distinct ur.role::text) filter (where ur.role is not null),
      '{}'::text[]
    ) as roles
  from public.user_profiles up
  inner join auth.users u on u.id = up.user_id
  left join public.user_roles ur on ur.user_id = up.user_id
  where public.is_admin_user(auth.uid())
    and (
      coalesce(trim(p_query), '') = ''
      or u.email ilike '%' || trim(p_query) || '%'
      or up.prenom ilike '%' || trim(p_query) || '%'
      or up.nom ilike '%' || trim(p_query) || '%'
      or up.user_id::text = trim(p_query)
    )
  group by up.user_id, u.email, up.prenom, up.nom, up.is_banned, up.banned_at, up.ban_reason
  order by up.prenom nulls last, up.nom nulls last
  limit greatest(1, least(coalesce(p_limit, 50), 200));
$$;

create or replace function public.admin_set_user_role(
  p_user_id uuid,
  p_role text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_role public.app_role;
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_user_id = auth.uid() and p_role = 'admin' then
    raise exception 'cannot_self_promote' using errcode = '42501';
  end if;

  v_role := p_role::public.app_role;

  if v_role = 'admin' then
    insert into public.user_roles (user_id, role)
    values (p_user_id, 'admin')
    on conflict (user_id, role) do nothing;
  else
    delete from public.user_roles
    where user_id = p_user_id
      and role = 'admin';

    insert into public.user_roles (user_id, role)
    values (p_user_id, v_role)
    on conflict (user_id, role) do nothing;
  end if;

  perform public.admin_write_audit_log(
    'set_user_role',
    'user',
    p_user_id::text,
    jsonb_build_object('role', p_role)
  );
end;
$$;

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

  update public.user_profiles
  set is_banned = true,
      banned_at = now(),
      banned_by = auth.uid(),
      ban_reason = nullif(trim(p_reason), '')
  where user_id = p_user_id;

  if not found then
    raise exception 'user_not_found' using errcode = 'P0002';
  end if;

  perform public.admin_write_audit_log(
    'ban_user',
    'user',
    p_user_id::text,
    jsonb_build_object('reason', p_reason)
  );
end;
$$;

create or replace function public.admin_unban_user(
  p_user_id uuid
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

  update public.user_profiles
  set is_banned = false,
      banned_at = null,
      banned_by = null,
      ban_reason = null
  where user_id = p_user_id;

  if not found then
    raise exception 'user_not_found' using errcode = 'P0002';
  end if;

  perform public.admin_write_audit_log(
    'unban_user',
    'user',
    p_user_id::text,
    null
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- 9) Modération signalements
-- ---------------------------------------------------------------------------
create or replace function public.admin_moderate_content_report(
  p_report_id uuid,
  p_action text,
  p_note text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_report public.content_reports%rowtype;
  v_prestataire_id uuid;
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  select * into v_report
  from public.content_reports
  where id = p_report_id;

  if not found then
    raise exception 'report_not_found' using errcode = 'P0002';
  end if;

  case p_action
    when 'hide_prestataire' then
      if v_report.target_type <> 'prestataire_profile' then
        raise exception 'invalid_action_for_target' using errcode = 'P0002';
      end if;
      v_prestataire_id := v_report.target_id::uuid;
      update public.prestataire_profiles
      set is_hidden = true,
          hidden_at = now(),
          hidden_by = auth.uid()
      where id = v_prestataire_id;

    when 'suspend_conversation' then
      if v_report.target_type <> 'conversation' then
        raise exception 'invalid_action_for_target' using errcode = 'P0002';
      end if;
      update public.conversations
      set is_suspended = true,
          suspended_at = now(),
          suspended_by = auth.uid()
      where id = v_report.target_id::uuid;

    when 'delete_message' then
      if v_report.target_type <> 'message' then
        raise exception 'invalid_action_for_target' using errcode = 'P0002';
      end if;
      update public.messages
      set deleted_at = now(),
          deleted_by = auth.uid(),
          contenu = '[Message supprimé par la modération]'
      where id = v_report.target_id::uuid;

    when 'dismiss' then
      null;

    else
      raise exception 'unknown_action' using errcode = 'P0002';
  end case;

  update public.content_reports
  set reviewed_at = coalesce(reviewed_at, now()),
      reviewed_by = coalesce(reviewed_by, auth.uid()),
      action_taken = p_action,
      action_note = nullif(trim(p_note), '')
  where id = p_report_id;

  perform public.admin_write_audit_log(
    'moderate_report',
    'content_report',
    p_report_id::text,
    jsonb_build_object(
      'action', p_action,
      'target_type', v_report.target_type,
      'target_id', v_report.target_id
    )
  );
end;
$$;

-- Liste signalements enrichie
drop function if exists public.admin_list_content_reports(boolean, integer);

create or replace function public.admin_list_content_reports(
  p_only_pending boolean default true,
  p_limit integer default 100
)
returns table (
  id uuid,
  reporter_user_id uuid,
  reporter_email text,
  reporter_display_name text,
  target_type text,
  target_id text,
  target_label text,
  reason text,
  details text,
  created_at timestamptz,
  reviewed_at timestamptz,
  action_taken text,
  action_note text
)
language sql
security definer
set search_path = public
as $$
  select
    cr.id,
    cr.reporter_user_id,
    u.email::text as reporter_email,
    trim(concat_ws(' ', up.prenom, up.nom)) as reporter_display_name,
    cr.target_type,
    cr.target_id,
    case cr.target_type
      when 'prestataire_profile' then coalesce(
        nullif(trim(pp.nom_salon), ''),
        trim(concat_ws(' ', tpp.prenom, tpp.nom)),
        cr.target_id
      )
      when 'conversation' then 'Conversation ' || left(cr.target_id, 8)
      when 'message' then 'Message ' || left(cr.target_id, 8)
      else cr.target_id
    end as target_label,
    cr.reason,
    cr.details,
    cr.created_at,
    cr.reviewed_at,
    cr.action_taken,
    cr.action_note
  from public.content_reports cr
  left join auth.users u on u.id = cr.reporter_user_id
  left join public.user_profiles up on up.user_id = cr.reporter_user_id
  left join public.prestataire_profiles pp
    on cr.target_type = 'prestataire_profile'
    and pp.id::text = cr.target_id
  left join public.user_profiles tpp on tpp.user_id = pp.user_id
  where public.is_admin_user(auth.uid())
    and (not p_only_pending or cr.reviewed_at is null)
  order by cr.created_at desc
  limit greatest(1, least(coalesce(p_limit, 100), 500));
$$;

-- ---------------------------------------------------------------------------
-- 10) Réservations / paiements admin
-- ---------------------------------------------------------------------------
create or replace function public.admin_list_reservations(
  p_limit integer default 100
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
  order by r.date_heure desc
  limit greatest(1, least(coalesce(p_limit, 100), 500));
$$;

-- ---------------------------------------------------------------------------
-- 11) Analytics admin
-- ---------------------------------------------------------------------------
create or replace function public.admin_get_analytics_summary()
returns jsonb
language sql
security definer
set search_path = public
as $$
  select jsonb_build_object(
    'users_total', (select count(*)::int from public.user_profiles),
    'users_banned', (
      select count(*)::int from public.user_profiles where is_banned = true
    ),
    'prestataires_total', (select count(*)::int from public.prestataire_profiles),
    'prestataires_verified', (
      select count(*)::int from public.prestataire_profiles where is_verified = true
    ),
    'verification_pending', (
      select count(*)::int
      from public.prestataire_profiles
      where is_verified = false
        and verification_requested_at is not null
    ),
    'reports_pending', (
      select count(*)::int
      from public.content_reports
      where reviewed_at is null
    ),
    'reservations_total', (select count(*)::int from public.reservations),
    'reservations_this_month', (
      select count(*)::int
      from public.reservations
      where date_heure >= date_trunc('month', now())
    ),
    'revenue_captured_cents', (
      select coalesce(sum(amount_cents), 0)::bigint
      from public.reservations
      where payment_status = 'captured'
    ),
    'revenue_this_month_cents', (
      select coalesce(sum(amount_cents), 0)::bigint
      from public.reservations
      where payment_status = 'captured'
        and paid_at >= date_trunc('month', now())
    )
  )
  where public.is_admin_user(auth.uid());
$$;

-- ---------------------------------------------------------------------------
-- 12) Audit : journal générique + événements vérification
-- ---------------------------------------------------------------------------
create or replace function public.admin_list_audit_log(
  p_limit integer default 100
)
returns table (
  id uuid,
  actor_user_id uuid,
  actor_display_name text,
  action text,
  entity_type text,
  entity_id text,
  metadata jsonb,
  created_at timestamptz
)
language sql
security definer
set search_path = public
as $$
  select
    al.id,
    al.actor_user_id,
    trim(concat_ws(' ', up.prenom, up.nom)) as actor_display_name,
    al.action,
    al.entity_type,
    al.entity_id,
    al.metadata,
    al.created_at
  from public.admin_audit_log al
  left join public.user_profiles up on up.user_id = al.actor_user_id
  where public.is_admin_user(auth.uid())
  order by al.created_at desc
  limit greatest(1, least(coalesce(p_limit, 100), 500));
$$;

create or replace function public.admin_list_verification_events(
  p_limit integer default 100
)
returns table (
  id uuid,
  prestataire_id uuid,
  nom_salon text,
  actor_user_id uuid,
  actor_display_name text,
  action text,
  note text,
  created_at timestamptz
)
language sql
security definer
set search_path = public
as $$
  select
    e.id,
    e.prestataire_id,
    pp.nom_salon,
    e.actor_user_id,
    trim(concat_ws(' ', up.prenom, up.nom)) as actor_display_name,
    e.action,
    e.note,
    e.created_at
  from public.prestataire_verification_events e
  inner join public.prestataire_profiles pp on pp.id = e.prestataire_id
  left join public.user_profiles up on up.user_id = e.actor_user_id
  where public.is_admin_user(auth.uid())
  order by e.created_at desc
  limit greatest(1, least(coalesce(p_limit, 100), 500));
$$;

-- Audit sur approve/revoke existants
create or replace function public.approve_prestataire_verification(
  p_prestataire_id uuid,
  p_note text default null
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

  update public.prestataire_profiles
  set is_verified = true,
      verified_at = now(),
      verified_by = auth.uid(),
      verification_requested_at = coalesce(verification_requested_at, now()),
      verification_note = p_note
  where id = p_prestataire_id;

  if not found then
    raise exception 'prestataire_not_found' using errcode = 'P0002';
  end if;

  insert into public.prestataire_verification_events (
    prestataire_id, actor_user_id, action, note
  )
  values (p_prestataire_id, auth.uid(), 'approved', p_note);

  perform public.admin_write_audit_log(
    'approve_verification',
    'prestataire_profile',
    p_prestataire_id::text,
    jsonb_build_object('note', p_note)
  );
end;
$$;

create or replace function public.revoke_prestataire_verification(
  p_prestataire_id uuid,
  p_note text default null
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

  update public.prestataire_profiles
  set is_verified = false,
      verified_at = null,
      verified_by = auth.uid(),
      verification_note = p_note
  where id = p_prestataire_id;

  if not found then
    raise exception 'prestataire_not_found' using errcode = 'P0002';
  end if;

  insert into public.prestataire_verification_events (
    prestataire_id, actor_user_id, action, note
  )
  values (p_prestataire_id, auth.uid(), 'revoked', p_note);

  perform public.admin_write_audit_log(
    'revoke_verification',
    'prestataire_profile',
    p_prestataire_id::text,
    jsonb_build_object('note', p_note)
  );
end;
$$;

-- ---------------------------------------------------------------------------
-- Grants
-- ---------------------------------------------------------------------------
grant execute on function public.admin_search_users(text, integer) to authenticated;
grant execute on function public.admin_set_user_role(uuid, text) to authenticated;
grant execute on function public.admin_ban_user(uuid, text) to authenticated;
create or replace function public.admin_remove_user_role(
  p_user_id uuid,
  p_role text
)
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_role public.app_role;
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_user_id = auth.uid() and p_role = 'admin' then
    raise exception 'cannot_demote_self' using errcode = '42501';
  end if;

  v_role := p_role::public.app_role;

  delete from public.user_roles
  where user_id = p_user_id
    and role = v_role;

  perform public.admin_write_audit_log(
    'remove_user_role',
    'user',
    p_user_id::text,
    jsonb_build_object('role', p_role)
  );
end;
$$;

grant execute on function public.admin_unban_user(uuid) to authenticated;
grant execute on function public.admin_remove_user_role(uuid, text) to authenticated;
grant execute on function public.admin_moderate_content_report(uuid, text, text) to authenticated;
grant execute on function public.admin_list_reservations(integer) to authenticated;
grant execute on function public.admin_get_analytics_summary() to authenticated;
grant execute on function public.admin_list_audit_log(integer) to authenticated;
grant execute on function public.admin_list_verification_events(integer) to authenticated;
