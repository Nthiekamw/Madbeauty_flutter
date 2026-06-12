-- Chat bug, capture d'écran et message personnalisé admin → reporter.

alter table public.bug_reports
  add column if not exists screenshot_url text,
  add column if not exists reporter_message text;

comment on column public.bug_reports.screenshot_url is
  'Capture d''écran jointe au signalement (bucket bug-report-screenshots).';
comment on column public.bug_reports.reporter_message is
  'Dernier message visible par l''utilisateur (résolution / suivi).';

create table public.bug_report_messages (
  id uuid primary key default gen_random_uuid(),
  bug_report_id uuid not null references public.bug_reports (id) on delete cascade,
  sender_id uuid not null references auth.users (id) on delete cascade,
  content text not null,
  created_at timestamptz not null default now(),
  constraint bug_report_messages_content_len
    check (char_length(trim(content)) between 1 and 2000)
);

create index idx_bug_report_messages_thread
  on public.bug_report_messages (bug_report_id, created_at asc);

comment on table public.bug_report_messages is
  'Fil de discussion admin ↔ reporter pour un signalement de bug.';

alter table public.bug_report_messages enable row level security;

create policy "bug_report_messages_select_participant"
on public.bug_report_messages for select to authenticated
using (
  exists (
    select 1 from public.bug_reports br
    where br.id = bug_report_messages.bug_report_id
      and (
        br.reporter_user_id = auth.uid()
        or public.is_admin_user(auth.uid())
      )
  )
);

create policy "bug_report_messages_insert_participant"
on public.bug_report_messages for insert to authenticated
with check (
  sender_id = auth.uid()
  and exists (
    select 1 from public.bug_reports br
    where br.id = bug_report_messages.bug_report_id
      and (
        br.reporter_user_id = auth.uid()
        or public.is_admin_user(auth.uid())
      )
  )
);

-- Bucket captures d'écran
insert into storage.buckets (id, name, public, file_size_limit, allowed_mime_types)
values (
  'bug-report-screenshots',
  'bug-report-screenshots',
  true,
  5242880,
  array['image/jpeg', 'image/png', 'image/webp']
)
on conflict (id) do nothing;

create policy "bug_report_screenshots_select_public"
on storage.objects for select to public
using (bucket_id = 'bug-report-screenshots');

create policy "bug_report_screenshots_insert_own"
on storage.objects for insert to authenticated
with check (
  bucket_id = 'bug-report-screenshots'
  and (storage.foldername(name))[1] = auth.uid()::text
);

create policy "bug_report_screenshots_update_own"
on storage.objects for update to authenticated
using (
  bucket_id = 'bug-report-screenshots'
  and (storage.foldername(name))[1] = auth.uid()::text
);

-- list_my_bug_reports enrichi
drop function if exists public.list_my_bug_reports(integer);

create or replace function public.list_my_bug_reports(p_limit integer default 30)
returns table (
  id uuid,
  title text,
  category text,
  description text,
  steps_to_reproduce text,
  status text,
  reporter_message text,
  screenshot_url text,
  app_version text,
  platform text,
  created_at timestamptz,
  updated_at timestamptz,
  resolved_at timestamptz
)
language sql
stable
security invoker
set search_path = public
as $$
  select
    br.id,
    br.title,
    br.category,
    br.description,
    br.steps_to_reproduce,
    br.status,
    br.reporter_message,
    br.screenshot_url,
    br.app_version,
    br.platform,
    br.created_at,
    br.updated_at,
    br.resolved_at
  from public.bug_reports br
  where br.reporter_user_id = auth.uid()
  order by br.created_at desc
  limit greatest(1, least(coalesce(p_limit, 30), 100));
$$;

grant execute on function public.list_my_bug_reports(integer) to authenticated;

-- admin_list_bug_reports enrichi
drop function if exists public.admin_list_bug_reports(boolean, integer);

create or replace function public.admin_list_bug_reports(
  p_only_pending boolean default true,
  p_limit integer default 100
)
returns table (
  id uuid,
  reporter_user_id uuid,
  reporter_email text,
  reporter_display_name text,
  title text,
  category text,
  description text,
  steps_to_reproduce text,
  app_version text,
  platform text,
  device_info text,
  current_screen text,
  screenshot_url text,
  status text,
  admin_notes text,
  reporter_message text,
  created_at timestamptz,
  updated_at timestamptz,
  resolved_at timestamptz
)
language sql
security definer
set search_path = public
as $$
  select
    br.id,
    br.reporter_user_id,
    u.email::text as reporter_email,
    trim(concat_ws(' ', up.prenom, up.nom)) as reporter_display_name,
    br.title,
    br.category,
    br.description,
    br.steps_to_reproduce,
    br.app_version,
    br.platform,
    br.device_info,
    br.current_screen,
    br.screenshot_url,
    br.status,
    br.admin_notes,
    br.reporter_message,
    br.created_at,
    br.updated_at,
    br.resolved_at
  from public.bug_reports br
  left join auth.users u on u.id = br.reporter_user_id
  left join public.user_profiles up on up.user_id = br.reporter_user_id
  where public.is_admin_user(auth.uid())
    and (
      not p_only_pending
      or br.status in ('pending', 'in_progress')
    )
  order by br.created_at desc
  limit greatest(1, least(coalesce(p_limit, 100), 500));
$$;

grant execute on function public.admin_list_bug_reports(boolean, integer) to authenticated;

-- Mise à jour admin avec message utilisateur séparé
drop function if exists public.admin_update_bug_report(uuid, text, text);

create or replace function public.admin_update_bug_report(
  p_report_id uuid,
  p_status text,
  p_admin_notes text default null,
  p_reporter_message text default null
)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if not public.is_admin_user(auth.uid()) then
    raise exception 'Accès refusé';
  end if;

  if p_status not in ('pending', 'in_progress', 'resolved', 'closed') then
    raise exception 'Statut invalide';
  end if;

  update public.bug_reports
  set
    status = p_status,
    admin_notes = coalesce(nullif(trim(p_admin_notes), ''), admin_notes),
    reporter_message = coalesce(
      nullif(trim(p_reporter_message), ''),
      reporter_message
    ),
    resolved_by = case
      when p_status in ('resolved', 'closed') then auth.uid()
      else resolved_by
    end,
    resolved_at = case
      when p_status in ('resolved', 'closed') then coalesce(resolved_at, now())
      else null
    end
  where id = p_report_id;

  if not found then
    raise exception 'Signalement introuvable';
  end if;
end;
$$;

grant execute on function public.admin_update_bug_report(uuid, text, text, text) to authenticated;

create or replace function public.set_bug_report_screenshot(
  p_report_id uuid,
  p_screenshot_url text
)
returns void
language plpgsql
security invoker
set search_path = public
as $$
begin
  update public.bug_reports
  set screenshot_url = nullif(trim(p_screenshot_url), '')
  where id = p_report_id
    and reporter_user_id = auth.uid();

  if not found then
    raise exception 'Signalement introuvable';
  end if;
end;
$$;

grant execute on function public.set_bug_report_screenshot(uuid, text) to authenticated;
