-- Signalements de bugs techniques (formulaire utilisateur + backoffice admin).

create table public.bug_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_user_id uuid not null references auth.users (id) on delete cascade,
  title text not null,
  category text not null,
  description text not null,
  steps_to_reproduce text,
  app_version text,
  platform text,
  device_info text,
  current_screen text,
  status text not null default 'pending',
  admin_notes text,
  resolved_at timestamptz,
  resolved_by uuid references auth.users (id) on delete set null,
  created_at timestamptz not null default now(),
  updated_at timestamptz not null default now(),
  constraint bug_reports_title_len check (char_length(trim(title)) between 3 and 120),
  constraint bug_reports_description_len check (char_length(trim(description)) between 10 and 4000),
  constraint bug_reports_category_check check (
    category in ('auth', 'booking', 'payment', 'messaging', 'profile', 'other')
  ),
  constraint bug_reports_status_check check (
    status in ('pending', 'in_progress', 'resolved', 'closed')
  )
);

create index idx_bug_reports_created
  on public.bug_reports (created_at desc);

create index idx_bug_reports_status_pending
  on public.bug_reports (status, created_at desc)
  where status in ('pending', 'in_progress');

comment on table public.bug_reports is
  'Signalements de bugs techniques soumis par les utilisateurs connectés.';

alter table public.bug_reports enable row level security;

create policy "bug_reports_insert_own"
on public.bug_reports for insert to authenticated
with check (reporter_user_id = auth.uid());

create policy "bug_reports_select_own_or_admin"
on public.bug_reports for select to authenticated
using (
  reporter_user_id = auth.uid()
  or public.is_admin_user(auth.uid())
);

create or replace function public.bug_reports_set_updated_at()
returns trigger
language plpgsql
as $$
begin
  new.updated_at = now();
  if new.status in ('resolved', 'closed') and old.status not in ('resolved', 'closed') then
    new.resolved_at = coalesce(new.resolved_at, now());
  end if;
  return new;
end;
$$;

create trigger trg_bug_reports_updated_at
before update on public.bug_reports
for each row
execute procedure public.bug_reports_set_updated_at();

-- Liste des signalements de l'utilisateur connecté.
create or replace function public.list_my_bug_reports(p_limit integer default 30)
returns table (
  id uuid,
  title text,
  category text,
  description text,
  steps_to_reproduce text,
  status text,
  admin_notes text,
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
    br.admin_notes,
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

-- Backoffice admin.
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
  status text,
  admin_notes text,
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
    br.status,
    br.admin_notes,
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

create or replace function public.admin_update_bug_report(
  p_report_id uuid,
  p_status text,
  p_admin_notes text default null
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

grant execute on function public.admin_list_bug_reports(boolean, integer) to authenticated;
grant execute on function public.admin_update_bug_report(uuid, text, text) to authenticated;
