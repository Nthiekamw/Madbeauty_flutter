-- Un fil de discussion unique par paire client + prestataire (plus un fil par RDV).

-- ---------------------------------------------------------------------------
-- 1) Fusionner les conversations en double
-- ---------------------------------------------------------------------------

create temp table _conv_merge on commit drop as
with ranked as (
  select
    id,
    client_id,
    prestataire_id,
    row_number() over (
      partition by client_id, prestataire_id
      order by last_message_at desc nulls last, id asc
    ) as rn
  from public.conversations
)
select
  d.id as dupe_id,
  k.id as keep_id
from ranked d
inner join ranked k
  on k.client_id = d.client_id
  and k.prestataire_id = d.prestataire_id
  and k.rn = 1
where d.rn > 1;

update public.messages m
set conversation_id = cm.keep_id
from _conv_merge cm
where m.conversation_id = cm.dupe_id;

delete from public.conversations c
using _conv_merge cm
where c.id = cm.dupe_id;

-- Dernière réservation liée (contexte affichage)
update public.conversations c
set reservation_id = sub.booking_id
from (
  select distinct on (m.conversation_id)
    m.conversation_id,
    m.booking_id
  from public.messages m
  where m.booking_id is not null
    and m.deleted_at is null
  order by m.conversation_id, m.created_at desc
) sub
where c.id = sub.conversation_id;

-- ---------------------------------------------------------------------------
-- 2) Schéma : une conversation par paire
-- ---------------------------------------------------------------------------

drop index if exists public.conversations_reservation_id_uidx;

alter table public.conversations
  drop constraint if exists conversations_client_prestataire_key;

alter table public.conversations
  add constraint conversations_client_prestataire_key
  unique (client_id, prestataire_id);

alter table public.conversations
  alter column reservation_id drop not null;

create index if not exists idx_conversations_reservation_id
  on public.conversations (reservation_id)
  where reservation_id is not null;

-- ---------------------------------------------------------------------------
-- 3) Triggers messages → conversation (par paire / conversation_id)
-- ---------------------------------------------------------------------------

create or replace function public.messages_set_conversation_from_booking()
returns trigger
language plpgsql
as $$
declare
  v_client_id uuid;
  v_prestataire_id uuid;
begin
  if NEW.conversation_id is null and NEW.booking_id is not null then
    select r.client_id, r.prestataire_id
    into v_client_id, v_prestataire_id
    from public.reservations r
    where r.id = NEW.booking_id;

    if v_client_id is not null and v_prestataire_id is not null then
      select c.id into NEW.conversation_id
      from public.conversations c
      where c.client_id = v_client_id
        and c.prestataire_id = v_prestataire_id
      limit 1;
    end if;
  end if;

  if NEW.booking_id is null
    and NEW.conversation_id is not null
    and exists (
      select 1
      from public.conversations c
      where c.id = NEW.conversation_id
        and c.reservation_id is not null
    )
  then
    select c.reservation_id into NEW.booking_id
    from public.conversations c
    where c.id = NEW.conversation_id;
  end if;

  return NEW;
end;
$$;

create or replace function public.messages_touch_conversation()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  if NEW.conversation_id is not null then
    update public.conversations c
    set
      last_message_at = NEW.created_at,
      reservation_id = coalesce(NEW.booking_id, c.reservation_id)
    where c.id = NEW.conversation_id;
  end if;
  return NEW;
end;
$$;

create or replace function public.messages_recompute_conversation_last()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_conversation_id uuid;
begin
  v_conversation_id := coalesce(OLD.conversation_id, NEW.conversation_id);
  if v_conversation_id is null then
    return coalesce(NEW, OLD);
  end if;

  update public.conversations c
  set last_message_at = (
    select max(m.created_at)
    from public.messages m
    where m.conversation_id = v_conversation_id
      and m.deleted_at is null
  )
  where c.id = v_conversation_id;

  return coalesce(NEW, OLD);
end;
$$;

-- ---------------------------------------------------------------------------
-- 4) Suppression : par réservation (messages seuls) ou fil entier
-- ---------------------------------------------------------------------------

create or replace function public.delete_booking_chat(p_booking_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_booking_id is null then
    raise exception 'booking_id_required' using errcode = '22023';
  end if;

  if not (
    exists (
      select 1
      from public.reservations r
      inner join public.client_profiles cp on cp.id = r.client_id
      where r.id = p_booking_id
        and cp.user_id = auth.uid()
    )
    or exists (
      select 1
      from public.reservations r
      inner join public.prestataire_profiles pp on pp.id = r.prestataire_id
      where r.id = p_booking_id
        and pp.user_id = auth.uid()
    )
  ) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  delete from public.messages
  where booking_id = p_booking_id;
end;
$$;

create or replace function public.delete_conversation_chat(p_conversation_id uuid)
returns void
language plpgsql
security definer
set search_path = public
as $$
begin
  if p_conversation_id is null then
    raise exception 'conversation_id_required' using errcode = '22023';
  end if;

  if not (
    exists (
      select 1
      from public.conversations conv
      inner join public.client_profiles cp on cp.id = conv.client_id
      where conv.id = p_conversation_id
        and cp.user_id = auth.uid()
    )
    or exists (
      select 1
      from public.conversations conv
      inner join public.prestataire_profiles pp on pp.id = conv.prestataire_id
      where conv.id = p_conversation_id
        and pp.user_id = auth.uid()
    )
  ) then
    raise exception 'forbidden' using errcode = '42501';
  end if;

  delete from public.messages
  where conversation_id = p_conversation_id;

  delete from public.conversations
  where id = p_conversation_id;
end;
$$;

grant execute on function public.delete_conversation_chat(uuid) to authenticated;

-- ---------------------------------------------------------------------------
-- 5) Vue agrégée (par fil, pas par réservation)
-- ---------------------------------------------------------------------------

create or replace view public.booking_conversations
with (security_invoker = true)
as
select
  c.id,
  c.reservation_id as booking_id,
  c.client_id,
  c.prestataire_id,
  c.last_message_at,
  (
    select m2.content
    from public.messages m2
    where m2.conversation_id = c.id
      and m2.deleted_at is null
    order by m2.created_at desc
    limit 1
  ) as last_message_content,
  (
    select m2.sender_id
    from public.messages m2
    where m2.conversation_id = c.id
      and m2.deleted_at is null
    order by m2.created_at desc
    limit 1
  ) as last_sender_id,
  (
    select count(*)::int
    from public.messages m3
    where m3.conversation_id = c.id
      and m3.deleted_at is null
  ) as message_count
from public.conversations c;

comment on view public.booking_conversations is
  'Agrégat des fils de discussion (une entrée par paire client/prestataire).';
