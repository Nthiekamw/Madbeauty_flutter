-- Idempotence : appels concurrents à ensure_user_support_thread (inscription + live sync).

create or replace function public.ensure_user_support_thread()
returns uuid
language plpgsql
security definer
set search_path = public
as $$
declare
  v_uid uuid := auth.uid();
  v_thread_id uuid;
begin
  if v_uid is null then
    raise exception 'Utilisateur non connecté';
  end if;

  select id into v_thread_id
  from public.user_support_threads
  where user_id = v_uid;

  if v_thread_id is not null then
    return v_thread_id;
  end if;

  insert into public.user_support_threads (user_id)
  values (v_uid)
  on conflict (user_id) do nothing
  returning id into v_thread_id;

  if v_thread_id is null then
    select id into v_thread_id
    from public.user_support_threads
    where user_id = v_uid;
  end if;

  if v_thread_id is null then
    raise exception 'support_thread_create_failed';
  end if;

  return v_thread_id;
end;
$$;

grant execute on function public.ensure_user_support_thread() to authenticated;
