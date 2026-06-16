-- Suppression de messages et de conversations par les participants.

-- ---------------------------------------------------------------------------
-- RLS : l’expéditeur peut supprimer son propre message.
-- ---------------------------------------------------------------------------

drop policy if exists "messages_delete_own" on public.messages;

create policy "messages_delete_own"
on public.messages for delete to authenticated
using (
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

-- ---------------------------------------------------------------------------
-- Recalcule last_message_at après suppression d’un message.
-- ---------------------------------------------------------------------------

create or replace function public.messages_recompute_conversation_last()
returns trigger
language plpgsql
security definer
set search_path = public
as $$
declare
  v_booking_id uuid;
begin
  v_booking_id := coalesce(OLD.booking_id, NEW.booking_id);
  if v_booking_id is null then
    return coalesce(NEW, OLD);
  end if;

  update public.conversations c
  set last_message_at = (
    select max(m.created_at)
    from public.messages m
    where m.booking_id = v_booking_id
      and m.deleted_at is null
  )
  where c.reservation_id = v_booking_id;

  return coalesce(NEW, OLD);
end;
$$;

drop trigger if exists messages_recompute_conversation_last_trigger
  on public.messages;

create trigger messages_recompute_conversation_last_trigger
after delete on public.messages
for each row
execute function public.messages_recompute_conversation_last();

-- ---------------------------------------------------------------------------
-- Supprimer toute la conversation d’une réservation (participant).
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

  delete from public.conversations
  where reservation_id = p_booking_id;
end;
$$;

grant execute on function public.delete_booking_chat(uuid) to authenticated;
