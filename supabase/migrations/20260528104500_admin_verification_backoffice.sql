alter table public.prestataire_profiles
  add column if not exists verification_requested_at timestamptz,
  add column if not exists verified_at timestamptz,
  add column if not exists verified_by uuid references auth.users (id),
  add column if not exists verification_note text;

create table if not exists public.prestataire_verification_events (
  id uuid primary key default gen_random_uuid(),
  prestataire_id uuid not null
    references public.prestataire_profiles (id) on delete cascade,
  actor_user_id uuid not null references auth.users (id),
  action text not null check (action in ('approved', 'revoked')),
  note text,
  created_at timestamptz not null default now()
);

alter table public.prestataire_verification_events enable row level security;

drop policy if exists "prestataire_verification_events_admin_select"
on public.prestataire_verification_events;
create policy "prestataire_verification_events_admin_select"
on public.prestataire_verification_events
for select to authenticated
using (
  exists (
    select 1
    from public.user_roles ur
    where ur.user_id = auth.uid()
      and ur.role = 'admin'
  )
);

create or replace function public.is_admin_user(p_user_id uuid)
returns boolean
language sql
stable
set search_path = public
as $$
  select exists (
    select 1
    from public.user_roles ur
    where ur.user_id = p_user_id
      and ur.role = 'admin'
  );
$$;

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
    trim(concat_ws(' ', up.prenom, up.nom)) as display_name
  from public.prestataire_profiles pp
  left join public.user_profiles up on up.user_id = pp.user_id
  where public.is_admin_user(auth.uid())
    and (not p_only_pending or pp.is_verified = false)
  order by pp.created_at desc;
$$;

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
    raise exception 'forbidden'
      using errcode = '42501';
  end if;

  update public.prestataire_profiles
  set is_verified = true,
      verified_at = now(),
      verified_by = auth.uid(),
      verification_requested_at = coalesce(verification_requested_at, now()),
      verification_note = p_note
  where id = p_prestataire_id;

  if not found then
    raise exception 'prestataire_not_found'
      using errcode = 'P0002';
  end if;

  insert into public.prestataire_verification_events (
    prestataire_id,
    actor_user_id,
    action,
    note
  )
  values (p_prestataire_id, auth.uid(), 'approved', p_note);
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
    raise exception 'forbidden'
      using errcode = '42501';
  end if;

  update public.prestataire_profiles
  set is_verified = false,
      verified_at = null,
      verified_by = auth.uid(),
      verification_note = p_note
  where id = p_prestataire_id;

  if not found then
    raise exception 'prestataire_not_found'
      using errcode = 'P0002';
  end if;

  insert into public.prestataire_verification_events (
    prestataire_id,
    actor_user_id,
    action,
    note
  )
  values (p_prestataire_id, auth.uid(), 'revoked', p_note);
end;
$$;

grant execute on function public.admin_list_prestataire_verification_requests(boolean)
to authenticated;
grant execute on function public.approve_prestataire_verification(uuid, text)
to authenticated;
grant execute on function public.revoke_prestataire_verification(uuid, text)
to authenticated;
