-- Messagerie : messages liés à la réservation (booking) + vue agrégée + Realtime.

-- ---------------------------------------------------------------------------
-- Colonnes booking_id + content sur messages
-- ---------------------------------------------------------------------------

alter table public.messages
  add column if not exists booking_id uuid references public.reservations (id) on delete cascade;

alter table public.messages
  add column if not exists content text;

-- Rétrocompat : remplir booking_id depuis le fil conversation
update public.messages m
set booking_id = c.reservation_id
from public.conversations c
where m.booking_id is null
  and m.conversation_id = c.id
  and c.reservation_id is not null;

update public.messages
set content = contenu
where content is null or content = '';

-- Inserts via booking_id : renseigne conversation_id automatiquement
create or replace function public.messages_set_conversation_from_booking()
returns trigger
language plpgsql
as $$
begin
  if NEW.conversation_id is null and NEW.booking_id is not null then
    select c.id into NEW.conversation_id
    from public.conversations c
    where c.reservation_id = NEW.booking_id
    limit 1;
  end if;
  if NEW.booking_id is null and NEW.conversation_id is not null then
    select c.reservation_id into NEW.booking_id
    from public.conversations c
    where c.id = NEW.conversation_id
    limit 1;
  end if;
  return NEW;
end;
$$;

drop trigger if exists messages_set_conversation_from_booking on public.messages;
create trigger messages_set_conversation_from_booking
before insert on public.messages
for each row execute function public.messages_set_conversation_from_booking();

create index if not exists idx_messages_booking_created
  on public.messages (booking_id, created_at asc);

-- Sync contenu <-> content (legacy)
create or replace function public.messages_sync_content_columns()
returns trigger
language plpgsql
as $$
begin
  if NEW.content is null or btrim(NEW.content) = '' then
    NEW.content := NEW.contenu;
  end if;
  if NEW.contenu is null or btrim(NEW.contenu) = '' then
    NEW.contenu := NEW.content;
  end if;
  return NEW;
end;
$$;

drop trigger if exists messages_sync_content_columns on public.messages;
create trigger messages_sync_content_columns
before insert or update on public.messages
for each row execute function public.messages_sync_content_columns();

-- Met à jour last_message_at sur le fil metadata
create or replace function public.messages_touch_conversation()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
begin
  update public.conversations c
  set last_message_at = NEW.created_at
  where c.reservation_id = NEW.booking_id;
  return NEW;
end;
$$;

drop trigger if exists messages_touch_conversation on public.messages;
create trigger messages_touch_conversation
after insert on public.messages
for each row execute function public.messages_touch_conversation();

-- ---------------------------------------------------------------------------
-- Vue agrégée par réservation (booking) — lecture inbox / getConversations
-- Note : la table public.conversations conserve les métadonnées du fil.
-- ---------------------------------------------------------------------------

create or replace view public.booking_conversations
with (security_invoker = true)
as
select
  c.id,
  m.booking_id,
  r.client_id,
  r.prestataire_id,
  max(m.created_at) as last_message_at,
  (
    select m2.content
    from public.messages m2
    where m2.booking_id = m.booking_id
    order by m2.created_at desc
    limit 1
  ) as last_message_content,
  (
    select m2.sender_id
    from public.messages m2
    where m2.booking_id = m.booking_id
    order by m2.created_at desc
    limit 1
  ) as last_sender_id,
  count(m.id)::int as message_count
from public.messages m
inner join public.reservations r on r.id = m.booking_id
left join public.conversations c on c.reservation_id = m.booking_id
group by c.id, m.booking_id, r.client_id, r.prestataire_id;

comment on view public.booking_conversations is
  'Agrégat des messages par réservation (booking_id).';

grant select on public.booking_conversations to authenticated;

-- ---------------------------------------------------------------------------
-- RLS messages (booking / réservation)
-- ---------------------------------------------------------------------------

drop policy if exists "messages_select_participant" on public.messages;
drop policy if exists "messages_insert_sender" on public.messages;
drop policy if exists "messages_update_participant" on public.messages;

create policy "messages_select_booking_participant"
on public.messages for select to authenticated
using (
  exists (
    select 1
    from public.reservations r
    inner join public.client_profiles cp on cp.id = r.client_id
    where r.id = messages.booking_id
      and cp.user_id = auth.uid()
  )
  or exists (
    select 1
    from public.reservations r
    inner join public.prestataire_profiles pp on pp.id = r.prestataire_id
    where r.id = messages.booking_id
      and pp.user_id = auth.uid()
  )
);

create policy "messages_insert_booking_participant"
on public.messages for insert to authenticated
with check (
  sender_id = auth.uid()
  and booking_id is not null
  and (
    exists (
      select 1
      from public.reservations r
      inner join public.client_profiles cp on cp.id = r.client_id
      where r.id = messages.booking_id
        and cp.user_id = auth.uid()
    )
    or exists (
      select 1
      from public.reservations r
      inner join public.prestataire_profiles pp on pp.id = r.prestataire_id
      where r.id = messages.booking_id
        and pp.user_id = auth.uid()
    )
  )
);

create policy "messages_update_booking_participant"
on public.messages for update to authenticated
using (
  exists (
    select 1
    from public.reservations r
    inner join public.client_profiles cp on cp.id = r.client_id
    where r.id = messages.booking_id
      and cp.user_id = auth.uid()
  )
  or exists (
    select 1
    from public.reservations r
    inner join public.prestataire_profiles pp on pp.id = r.prestataire_id
    where r.id = messages.booking_id
      and pp.user_id = auth.uid()
  )
)
with check (
  exists (
    select 1
    from public.reservations r
    inner join public.client_profiles cp on cp.id = r.client_id
    where r.id = messages.booking_id
      and cp.user_id = auth.uid()
  )
  or exists (
    select 1
    from public.reservations r
    inner join public.prestataire_profiles pp on pp.id = r.prestataire_id
    where r.id = messages.booking_id
      and pp.user_id = auth.uid()
  )
);

-- ---------------------------------------------------------------------------
-- Supabase Realtime
-- ---------------------------------------------------------------------------

alter table public.messages replica identity full;

do $$
begin
  alter publication supabase_realtime add table public.messages;
exception
  when duplicate_object then null;
end $$;
