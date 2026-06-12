-- Révoque les sessions Supabase lors d'un bannissement admin.

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

  delete from auth.sessions where user_id = p_user_id;

  perform public.admin_write_audit_log(
    'ban_user',
    'user',
    p_user_id::text,
    jsonb_build_object('reason', trim(p_reason))
  );
end;
$$;
