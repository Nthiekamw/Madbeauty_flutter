-- Chat support utilisateur ↔ admin (distinct des signalements de bugs).

create table public.user_support_threads (
  id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references auth.users (id) on delete cascade,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now()
);

create index idx_user_support_threads_updated
  on public.user_support_threads (updated_at desc);

comment on table public.user_support_threads is
  'Fil de discussion support entre un utilisateur et l''équipe admin (un fil par utilisateur).';

create table public.user_support_messages (
  id uuid primary key default gen_random_uuid(),
  thread_id uuid not null references public.user_support_threads (id) on delete cascade,
  sender_id uuid not null references auth.users (id) on delete cascade,
  content text not null,
  delivered_at timestamptz,
  is_read boolean not null default false,
  created_at timestamptz not null default now(),
  constraint user_support_messages_content_len check (
    char_length(trim(content)) between 1 and 4000
  )
);

create index idx_user_support_messages_thread
  on public.user_support_messages (thread_id, created_at asc);

comment on table public.user_support_messages is
  'Messages du chat support utilisateur ↔ admin.';

alter table public.user_support_threads enable row level security;
alter table public.user_support_messages enable row level security;

create policy "user_support_threads_select_own_or_admin"
on public.user_support_threads for select to authenticated
using (
  user_id = auth.uid()
  or public.is_admin_user(auth.uid())
);

create policy "user_support_threads_insert_own"
on public.user_support_threads for insert to authenticated
with check (user_id = auth.uid());

create policy "user_support_messages_select_participant"
on public.user_support_messages for select to authenticated
using (
  exists (
    select 1 from public.user_support_threads t
    where t.id = user_support_messages.thread_id
      and (
        t.user_id = auth.uid()
        or public.is_admin_user(auth.uid())
      )
  )
);

create policy "user_support_messages_insert_participant"
on public.user_support_messages for insert to authenticated
with check (
  sender_id = auth.uid()
  and exists (
    select 1 from public.user_support_threads t
    where t.id = user_support_messages.thread_id
      and (
        t.user_id = auth.uid()
        or public.is_admin_user(auth.uid())
      )
  )
);

create policy "user_support_messages_update_participant"
on public.user_support_messages for update to authenticated
using (
  exists (
    select 1 from public.user_support_threads t
    where t.id = user_support_messages.thread_id
      and (
        t.user_id = auth.uid()
        or public.is_admin_user(auth.uid())
      )
  )
)
with check (
  exists (
    select 1 from public.user_support_threads t
    where t.id = user_support_messages.thread_id
      and (
        t.user_id = auth.uid()
        or public.is_admin_user(auth.uid())
      )
  )
);

create or replace function public.user_support_threads_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  return new;
end;
$$;

create trigger trg_user_support_threads_updated_at
before update on public.user_support_threads
for each row
execute procedure public.user_support_threads_set_updated_at();

create or replace function public.user_support_messages_touch_thread()
returns trigger
language plpgsql
as $$
begin
  update public.user_support_threads
  set updated_at = now()
  where id = new.thread_id;
  return new;
end;
$$;

create trigger trg_user_support_messages_touch_thread
after insert on public.user_support_messages
for each row
execute procedure public.user_support_messages_touch_thread();

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

  if v_thread_id is null then
    insert into public.user_support_threads (user_id)
    values (v_uid)
    returning id into v_thread_id;
  end if;

  return v_thread_id;
end;
$$;

grant execute on function public.ensure_user_support_thread() to authenticated;

create or replace function public.admin_list_user_support_threads(
  p_limit integer default 50
)
returns table (
  thread_id uuid,
  user_id uuid,
  user_email text,
  user_display_name text,
  last_message text,
  last_message_at timestamptz,
  unread_count bigint,
  updated_at timestamptz
)
language sql
security definer
set search_path = public
as $$
  select
    t.id as thread_id,
    t.user_id,
    u.email::text as user_email,
    trim(concat_ws(' ', up.prenom, up.nom)) as user_display_name,
    lm.content as last_message,
    lm.created_at as last_message_at,
    coalesce(uc.cnt, 0) as unread_count,
    t.updated_at
  from public.user_support_threads t
  left join auth.users u on u.id = t.user_id
  left join public.user_profiles up on up.user_id = t.user_id
  left join lateral (
    select m.content, m.created_at
    from public.user_support_messages m
    where m.thread_id = t.id
    order by m.created_at desc
    limit 1
  ) lm on true
  left join lateral (
    select count(*)::bigint as cnt
    from public.user_support_messages m
    where m.thread_id = t.id
      and m.sender_id = t.user_id
      and m.is_read = false
  ) uc on true
  where public.is_admin_user(auth.uid())
  order by coalesce(lm.created_at, t.updated_at) desc
  limit greatest(1, least(coalesce(p_limit, 50), 200));
$$;

grant execute on function public.admin_list_user_support_threads(integer) to authenticated;

alter table public.user_support_messages replica identity full;

do $$
begin
  alter publication supabase_realtime add table public.user_support_messages;
exception
  when duplicate_object then null;
end $$;
