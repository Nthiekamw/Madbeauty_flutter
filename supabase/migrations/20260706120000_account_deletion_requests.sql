-- Demandes de suppression de compte : utilisateur → validation admin → suppression auth.users.

create table if not exists public.account_deletion_requests (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users (id) on delete cascade,
  status text not null default 'pending'
    check (status in ('pending', 'cancelled')),
  requested_at timestamptz not null default now(),
  processed_at timestamptz,
  processed_by uuid references auth.users (id) on delete set null
);

create index if not exists idx_account_deletion_requests_pending
  on public.account_deletion_requests (requested_at desc)
  where status = 'pending';

alter table public.account_deletion_requests enable row level security;

drop policy if exists account_deletion_requests_select_own
  on public.account_deletion_requests;
create policy account_deletion_requests_select_own
on public.account_deletion_requests
for select to authenticated
using (user_id = auth.uid());

comment on table public.account_deletion_requests is
  'Demandes de suppression définitive de compte, traitées par un admin.';

-- ---------------------------------------------------------------------------
-- Utilisateur : demander la suppression de son propre compte
-- ---------------------------------------------------------------------------

create or replace function public.request_account_deletion()
returns void
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
begin
  if v_uid is null then
    raise exception 'not_authenticated' using errcode = '28000';
  end if;

  if public.is_admin_user(v_uid) then
    raise exception 'admin_account_deletion_forbidden'
      using errcode = '42501';
  end if;

  insert into public.account_deletion_requests (user_id, status, requested_at)
  values (v_uid, 'pending', now())
  on conflict (user_id) do update
  set status = 'pending',
      requested_at = now(),
      processed_at = null,
      processed_by = null
  where public.account_deletion_requests.status <> 'pending';

  perform public.admin_write_audit_log(
    'account_deletion_requested',
    'user',
    v_uid::text,
    null
  );
end;
$$;

grant execute on function public.request_account_deletion() to authenticated;

-- ---------------------------------------------------------------------------
-- Admin : lister les demandes en attente
-- ---------------------------------------------------------------------------

create or replace function public.admin_list_account_deletion_requests()
returns table (
  user_id uuid,
  email text,
  prenom text,
  nom text,
  requested_at timestamptz,
  roles text[]
)
language sql
security definer
set search_path = public, auth
as $$
  select
    r.user_id,
    u.email::text,
    up.prenom,
    up.nom,
    r.requested_at,
    coalesce(
      array_agg(distinct ur.role::text) filter (where ur.role is not null),
      '{}'::text[]
    ) as roles
  from public.account_deletion_requests r
  inner join auth.users u on u.id = r.user_id
  left join public.user_profiles up on up.user_id = r.user_id
  left join public.user_roles ur on ur.user_id = r.user_id
  where r.status = 'pending'
    and public.is_admin_user(auth.uid())
  group by
    r.user_id,
    u.email,
    up.prenom,
    up.nom,
    r.requested_at
  order by r.requested_at asc;
$$;

grant execute on function public.admin_list_account_deletion_requests() to authenticated;

-- ---------------------------------------------------------------------------
-- Nettoyage des références FK où l'utilisateur est acteur admin
-- ---------------------------------------------------------------------------

create or replace function public._cleanup_user_deletion_actor_refs(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.user_profiles
  set banned_by = null
  where banned_by = p_user_id;

  update public.prestataire_profiles
  set hidden_by = null,
      verified_by = null
  where hidden_by = p_user_id
     or verified_by = p_user_id;

  update public.conversations
  set suspended_by = null
  where suspended_by = p_user_id;

  update public.messages
  set deleted_by = null
  where deleted_by = p_user_id;

  update public.content_reports
  set reviewed_by = null
  where reviewed_by = p_user_id;

  update public.bug_reports
  set resolved_by = null
  where resolved_by = p_user_id;

  update public.platform_settings
  set updated_by = null
  where updated_by = p_user_id;

  delete from public.account_moderation_events
  where admin_user_id = p_user_id;

  delete from public.prestataire_verification_events
  where actor_user_id = p_user_id;

  delete from public.admin_audit_log
  where actor_user_id = p_user_id;
end;
$$;

-- ---------------------------------------------------------------------------
-- Admin : exécuter la suppression définitive du compte demandé
-- ---------------------------------------------------------------------------

create or replace function public.admin_execute_account_deletion(p_user_id uuid)
returns void
language plpgsql
security definer
set search_path = public, auth
as $$
declare
  v_admin_id uuid := auth.uid();
begin
  if not public.is_admin_user(v_admin_id) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  if p_user_id is null then
    raise exception 'user_id_required' using errcode = '22023';
  end if;

  if p_user_id = v_admin_id then
    raise exception 'cannot_delete_own_account' using errcode = '42501';
  end if;

  if public.is_admin_user(p_user_id) then
    raise exception 'cannot_delete_admin_account' using errcode = '42501';
  end if;

  if not exists (
    select 1
    from public.account_deletion_requests r
    where r.user_id = p_user_id
      and r.status = 'pending'
  ) then
    raise exception 'no_pending_deletion_request' using errcode = 'P0002';
  end if;

  perform public.admin_write_audit_log(
    'account_deletion_executed',
    'user',
    p_user_id::text,
    null
  );

  update public.account_deletion_requests
  set processed_at = now(),
      processed_by = v_admin_id
  where user_id = p_user_id
    and status = 'pending';

  perform public._cleanup_user_deletion_actor_refs(p_user_id);

  delete from auth.sessions where user_id = p_user_id;

  delete from auth.users where id = p_user_id;
end;
$$;

grant execute on function public.admin_execute_account_deletion(uuid) to authenticated;
