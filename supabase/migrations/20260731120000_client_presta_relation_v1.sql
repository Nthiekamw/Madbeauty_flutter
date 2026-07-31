-- Relation client ↔ prestataire V1 :
-- VIP par salon, scheduled_pushes (aftercare + rebook), messages result_media.

-- =============================================================================
-- 1) Relations VIP
-- =============================================================================

create table if not exists public.client_prestataire_relations (
  client_id uuid not null references public.client_profiles (id) on delete cascade,
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  completed_count integer not null default 0
    check (completed_count >= 0),
  is_vip boolean not null default false,
  vip_since timestamptz,
  updated_at timestamptz not null default now(),
  primary key (client_id, prestataire_id)
);

create index if not exists idx_client_presta_relations_presta_vip
  on public.client_prestataire_relations (prestataire_id, is_vip)
  where is_vip = true;

comment on table public.client_prestataire_relations is
  'Relation client↔salon : compteur RDV terminés + statut VIP (≥ 3).';

alter table public.client_prestataire_relations enable row level security;

drop policy if exists "client_presta_relations_select_participant"
  on public.client_prestataire_relations;
create policy "client_presta_relations_select_participant"
  on public.client_prestataire_relations for select to authenticated
  using (
    exists (
      select 1 from public.client_profiles cp
      where cp.id = client_prestataire_relations.client_id
        and cp.user_id = auth.uid()
    )
    or exists (
      select 1 from public.prestataire_profiles pp
      where pp.id = client_prestataire_relations.prestataire_id
        and pp.user_id = auth.uid()
    )
  );

-- Snapshot remise VIP sur réservation
alter table public.reservations
  add column if not exists vip_discount_percent smallint;

alter table public.reservations
  drop constraint if exists reservations_vip_discount_percent_check;
alter table public.reservations
  add constraint reservations_vip_discount_percent_check
  check (
    vip_discount_percent is null
    or (vip_discount_percent > 0 and vip_discount_percent <= 100)
  );

comment on column public.reservations.vip_discount_percent is
  'Remise VIP salon appliquée au checkout (ex. 5).';

create or replace function public.sync_client_presta_relation_on_terminee()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_count integer;
  v_was_vip boolean;
  v_is_vip boolean;
begin
  if TG_OP <> 'UPDATE' then
    return NEW;
  end if;
  if NEW.statut is not distinct from OLD.statut then
    return NEW;
  end if;
  if NEW.statut not in ('terminee', 'completed', 'done') then
    return NEW;
  end if;
  if OLD.statut in ('terminee', 'completed', 'done') then
    return NEW;
  end if;

  select count(*)::integer into v_count
  from public.reservations r
  where r.client_id = NEW.client_id
    and r.prestataire_id = NEW.prestataire_id
    and r.statut in ('terminee', 'completed', 'done');

  select coalesce(is_vip, false) into v_was_vip
  from public.client_prestataire_relations
  where client_id = NEW.client_id
    and prestataire_id = NEW.prestataire_id;

  v_is_vip := coalesce(v_count, 0) >= 3;

  insert into public.client_prestataire_relations as rel (
    client_id,
    prestataire_id,
    completed_count,
    is_vip,
    vip_since,
    updated_at
  ) values (
    NEW.client_id,
    NEW.prestataire_id,
    coalesce(v_count, 0),
    v_is_vip,
    case when v_is_vip then now() else null end,
    now()
  )
  on conflict (client_id, prestataire_id) do update
  set
    completed_count = excluded.completed_count,
    is_vip = excluded.is_vip,
    vip_since = case
      when rel.is_vip then rel.vip_since
      when excluded.is_vip then now()
      else null
    end,
    updated_at = now();

  return NEW;
end;
$$;

drop trigger if exists trg_sync_client_presta_relation_on_terminee
  on public.reservations;
create trigger trg_sync_client_presta_relation_on_terminee
after update of statut on public.reservations
for each row
execute function public.sync_client_presta_relation_on_terminee();

create or replace function public.is_client_vip_at_prestataire(
  p_client_id uuid,
  p_prestataire_id uuid
)
returns boolean
language sql
stable
security definer
set search_path = public
as $$
  select coalesce(
    (
      select r.is_vip
      from public.client_prestataire_relations r
      where r.client_id = p_client_id
        and r.prestataire_id = p_prestataire_id
    ),
    false
  );
$$;

revoke all on function public.is_client_vip_at_prestataire(uuid, uuid) from public;
grant execute on function public.is_client_vip_at_prestataire(uuid, uuid)
  to authenticated, service_role;

-- Backfill relations depuis résas déjà terminées
insert into public.client_prestataire_relations (
  client_id, prestataire_id, completed_count, is_vip, vip_since, updated_at
)
select
  r.client_id,
  r.prestataire_id,
  count(*)::integer,
  count(*)::integer >= 3,
  case when count(*)::integer >= 3 then min(r.date_heure) else null end,
  now()
from public.reservations r
where r.statut in ('terminee', 'completed', 'done')
group by r.client_id, r.prestataire_id
on conflict (client_id, prestataire_id) do update
set
  completed_count = excluded.completed_count,
  is_vip = excluded.is_vip,
  vip_since = coalesce(
    public.client_prestataire_relations.vip_since,
    excluded.vip_since
  ),
  updated_at = now();

-- =============================================================================
-- 2) File de push planifiés (aftercare + rebook)
-- =============================================================================

create table if not exists public.scheduled_pushes (
  id uuid primary key default gen_random_uuid(),
  type text not null,
  send_at timestamptz not null,
  status text not null default 'pending',
  client_id uuid references public.client_profiles (id) on delete cascade,
  prestataire_id uuid references public.prestataire_profiles (id) on delete set null,
  reservation_id uuid references public.reservations (id) on delete cascade,
  payload jsonb not null default '{}'::jsonb,
  created_at timestamptz not null default now(),
  sent_at timestamptz,
  constraint scheduled_pushes_type_check
    check (type in ('aftercare', 'rebook_reminder')),
  constraint scheduled_pushes_status_check
    check (status in ('pending', 'sent', 'cancelled', 'failed'))
);

create index if not exists idx_scheduled_pushes_pending_send
  on public.scheduled_pushes (send_at asc)
  where status = 'pending';

create unique index if not exists idx_scheduled_pushes_aftercare_once
  on public.scheduled_pushes (reservation_id)
  where type = 'aftercare' and status in ('pending', 'sent');

comment on table public.scheduled_pushes is
  'File FCM planifiée (aftercare J+1, rappels rebook). Traitée par Edge process_scheduled_pushes.';

alter table public.scheduled_pushes enable row level security;
-- Pas de policy client : service_role / EF uniquement.

create or replace function public.schedule_aftercare_on_terminee()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if TG_OP <> 'UPDATE' then
    return NEW;
  end if;
  if NEW.statut is not distinct from OLD.statut then
    return NEW;
  end if;
  if NEW.statut not in ('terminee', 'completed', 'done') then
    return NEW;
  end if;
  if OLD.statut in ('terminee', 'completed', 'done') then
    return NEW;
  end if;

  if exists (
    select 1 from public.scheduled_pushes sp
    where sp.reservation_id = NEW.id
      and sp.type = 'aftercare'
      and sp.status in ('pending', 'sent')
  ) then
    return NEW;
  end if;

  insert into public.scheduled_pushes (
    type, send_at, status, client_id, prestataire_id, reservation_id, payload
  ) values (
    'aftercare',
    now() + interval '24 hours',
    'pending',
    NEW.client_id,
    NEW.prestataire_id,
    NEW.id,
    jsonb_build_object(
      'reservation_id', NEW.id,
      'prestataire_id', NEW.prestataire_id,
      'service_id', NEW.service_id
    )
  );

  return NEW;
end;
$$;

drop trigger if exists trg_schedule_aftercare_on_terminee on public.reservations;
create trigger trg_schedule_aftercare_on_terminee
after update of statut on public.reservations
for each row
execute function public.schedule_aftercare_on_terminee();

-- =============================================================================
-- 3) Rappels rebook 4 / 6 semaines
-- =============================================================================

create table if not exists public.booking_rebook_reminders (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.client_profiles (id) on delete cascade,
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  service_id uuid references public.services_beaute (id) on delete set null,
  source_reservation_id uuid not null references public.reservations (id) on delete cascade,
  interval_weeks smallint not null,
  remind_at timestamptz not null,
  status text not null default 'scheduled',
  scheduled_push_id uuid references public.scheduled_pushes (id) on delete set null,
  created_at timestamptz not null default now(),
  constraint booking_rebook_reminders_interval_check
    check (interval_weeks in (4, 6)),
  constraint booking_rebook_reminders_status_check
    check (status in ('scheduled', 'sent', 'cancelled'))
);

create index if not exists idx_booking_rebook_reminders_client
  on public.booking_rebook_reminders (client_id, status, remind_at);

create unique index if not exists idx_booking_rebook_one_active_per_source
  on public.booking_rebook_reminders (source_reservation_id)
  where status = 'scheduled';

alter table public.booking_rebook_reminders enable row level security;

drop policy if exists "rebook_reminders_select_own" on public.booking_rebook_reminders;
create policy "rebook_reminders_select_own"
  on public.booking_rebook_reminders for select to authenticated
  using (
    exists (
      select 1 from public.client_profiles cp
      where cp.id = booking_rebook_reminders.client_id
        and cp.user_id = auth.uid()
    )
  );

create or replace function public.schedule_rebook_reminder(
  p_reservation_id uuid,
  p_interval_weeks smallint
)
returns public.booking_rebook_reminders
language plpgsql
security definer
set search_path = public
as $$
declare
  v_client_id uuid;
  v_uid uuid := auth.uid();
  v_row public.reservations;
  v_remind_at timestamptz;
  v_push_id uuid;
  v_reminder public.booking_rebook_reminders;
begin
  if v_uid is null then
    raise exception 'auth_required';
  end if;
  if p_interval_weeks not in (4, 6) then
    raise exception 'invalid_interval';
  end if;

  select * into v_row
  from public.reservations
  where id = p_reservation_id;

  if v_row.id is null then
    raise exception 'reservation_not_found';
  end if;

  select cp.id into v_client_id
  from public.client_profiles cp
  where cp.user_id = v_uid
  limit 1;

  if v_client_id is null or v_client_id is distinct from v_row.client_id then
    raise exception 'forbidden';
  end if;

  if v_row.statut not in ('terminee', 'completed', 'done', 'confirmee', 'confirmed') then
    raise exception 'reservation_not_eligible';
  end if;

  -- Annule un rappel actif précédent sur la même source
  update public.booking_rebook_reminders
  set status = 'cancelled'
  where source_reservation_id = p_reservation_id
    and status = 'scheduled';

  update public.scheduled_pushes sp
  set status = 'cancelled'
  where sp.id in (
    select scheduled_push_id from public.booking_rebook_reminders
    where source_reservation_id = p_reservation_id
      and scheduled_push_id is not null
  )
  and sp.status = 'pending';

  v_remind_at := now() + make_interval(weeks => p_interval_weeks);

  insert into public.scheduled_pushes (
    type, send_at, status, client_id, prestataire_id, reservation_id, payload
  ) values (
    'rebook_reminder',
    v_remind_at,
    'pending',
    v_row.client_id,
    v_row.prestataire_id,
    v_row.id,
    jsonb_build_object(
      'reservation_id', v_row.id,
      'prestataire_id', v_row.prestataire_id,
      'service_id', v_row.service_id,
      'interval_weeks', p_interval_weeks
    )
  )
  returning id into v_push_id;

  insert into public.booking_rebook_reminders (
    client_id,
    prestataire_id,
    service_id,
    source_reservation_id,
    interval_weeks,
    remind_at,
    status,
    scheduled_push_id
  ) values (
    v_row.client_id,
    v_row.prestataire_id,
    v_row.service_id,
    v_row.id,
    p_interval_weeks,
    v_remind_at,
    'scheduled',
    v_push_id
  )
  returning * into v_reminder;

  return v_reminder;
end;
$$;

revoke all on function public.schedule_rebook_reminder(uuid, smallint) from public;
grant execute on function public.schedule_rebook_reminder(uuid, smallint) to authenticated;

-- =============================================================================
-- 4) Messages rendu (before / after)
-- =============================================================================

alter table public.messages
  add column if not exists kind text not null default 'text';

alter table public.messages
  drop constraint if exists messages_kind_check;
alter table public.messages
  add constraint messages_kind_check
  check (kind in ('text', 'image', 'result_media'));

alter table public.messages
  add column if not exists result_label text;

alter table public.messages
  drop constraint if exists messages_result_label_check;
alter table public.messages
  add constraint messages_result_label_check
  check (
    result_label is null
    or result_label in ('before', 'after', 'result')
  );

comment on column public.messages.kind is
  'text | image | result_media (rendu avant/après presta).';
comment on column public.messages.result_label is
  'before | after | result — uniquement si kind = result_media.';

-- Aligne kind=image si image_url sans kind legacy
update public.messages
set kind = 'image'
where image_url is not null
  and kind = 'text'
  and coalesce(trim(content), '') = '';
