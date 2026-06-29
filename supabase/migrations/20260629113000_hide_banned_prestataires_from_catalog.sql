-- Exclure immédiatement les prestataires bannis du catalogue et des lectures publiques.

create or replace function public.prestataire_is_catalog_visible(p_prestataire_id uuid)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select exists (
    select 1
    from public.prestataire_profiles p
    join public.user_profiles up on up.user_id = p.user_id
    where p.id = p_prestataire_id
      and coalesce(p.is_hidden, false) = false
      and coalesce(up.is_banned, false) = false
      and (
        p.subscription_status in ('active', 'trialing')
        or (
          p.catalog_trial_ends_at is not null
          and p.catalog_trial_ends_at > now()
        )
      )
  );
$$;

create or replace function public.admin_ban_user(
  p_user_id uuid,
  p_reason text default null
)
returns void
language plpgsql
security definer
set search_path = public, auth
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

  update public.prestataire_profiles
  set is_hidden = true
  where user_id = p_user_id;

  delete from auth.sessions where user_id = p_user_id;

  perform public.admin_write_audit_log(
    'ban_user',
    'user',
    p_user_id::text,
    jsonb_build_object('reason', trim(p_reason), 'catalog_hidden', true)
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
