-- Liste d'attente créneaux, signalements, temps de réponse moyen.

-- ---------------------------------------------------------------------------
-- slot_waitlist — client alerté quand un jour redevient réservable
-- ---------------------------------------------------------------------------

create table public.slot_waitlist (
  id uuid primary key default gen_random_uuid(),
  client_id uuid not null references public.client_profiles (id) on delete cascade,
  prestataire_id uuid not null references public.prestataire_profiles (id) on delete cascade,
  service_id uuid not null references public.services_beaute (id) on delete cascade,
  date_jour date not null,
  created_at timestamptz not null default now(),
  constraint slot_waitlist_unique unique (
    client_id,
    prestataire_id,
    service_id,
    date_jour
  )
);

create index idx_slot_waitlist_prestataire_date
  on public.slot_waitlist (prestataire_id, date_jour);

comment on table public.slot_waitlist is
  'Clients en attente d’un créneau sur un jour donné (notification manuelle / future).';

alter table public.slot_waitlist enable row level security;

create policy "slot_waitlist_select_own_or_presta"
on public.slot_waitlist for select to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = slot_waitlist.client_id and c.user_id = auth.uid()
  )
  or exists (
    select 1 from public.prestataire_profiles p
    where p.id = slot_waitlist.prestataire_id and p.user_id = auth.uid()
  )
);

create policy "slot_waitlist_insert_client"
on public.slot_waitlist for insert to authenticated
with check (
  exists (
    select 1 from public.client_profiles c
    where c.id = slot_waitlist.client_id and c.user_id = auth.uid()
  )
);

create policy "slot_waitlist_delete_own"
on public.slot_waitlist for delete to authenticated
using (
  exists (
    select 1 from public.client_profiles c
    where c.id = slot_waitlist.client_id and c.user_id = auth.uid()
  )
);

-- ---------------------------------------------------------------------------
-- content_reports — signalements utilisateurs
-- ---------------------------------------------------------------------------

create table public.content_reports (
  id uuid primary key default gen_random_uuid(),
  reporter_user_id uuid not null references auth.users (id) on delete cascade,
  target_type text not null,
  target_id text not null,
  reason text not null,
  details text,
  created_at timestamptz not null default now(),
  constraint content_reports_target_type_check
    check (target_type in ('prestataire_profile', 'conversation', 'message'))
);

create index idx_content_reports_created
  on public.content_reports (created_at desc);

comment on table public.content_reports is
  'Signalements profil / messagerie pour modération.';

alter table public.content_reports enable row level security;

create policy "content_reports_insert_own"
on public.content_reports for insert to authenticated
with check (reporter_user_id = auth.uid());

-- ---------------------------------------------------------------------------
-- Temps de réponse moyen (30 derniers jours) pour badge fiche publique
-- ---------------------------------------------------------------------------

create or replace function public.get_prestataire_avg_response_minutes(
  p_prestataire_id uuid
)
returns integer
language sql
stable
security invoker
set search_path = public
as $$
  with presta as (
    select user_id
    from public.prestataire_profiles
    where id = p_prestataire_id
  ),
  client_msgs as (
    select
      m.conversation_id,
      m.created_at as asked_at
    from public.messages m
    inner join public.conversations c on c.id = m.conversation_id
    inner join public.client_profiles cp on cp.id = c.client_id
    where c.prestataire_id = p_prestataire_id
      and m.sender_id = cp.user_id
      and m.created_at > now() - interval '30 days'
  ),
  deltas as (
    select
      extract(
        epoch from (
          (
            select min(m2.created_at)
            from public.messages m2
            where m2.conversation_id = cm.conversation_id
              and m2.sender_id = (select user_id from presta)
              and m2.created_at > cm.asked_at
          ) - cm.asked_at
        )
      ) / 60.0 as minutes
    from client_msgs cm
  )
  select
    case
      when count(*) filter (where minutes is not null and minutes between 0 and 1440) = 0
        then null::integer
      else round(
        avg(minutes) filter (where minutes is not null and minutes between 0 and 1440)
      )::integer
    end
  from deltas;
$$;

comment on function public.get_prestataire_avg_response_minutes(uuid) is
  'Moyenne en minutes entre un message client et la réponse prestataire (30 j).';

grant execute on function public.get_prestataire_avg_response_minutes(uuid) to authenticated;
