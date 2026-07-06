-- Lecture des messages par fil (conversation_id), en complément de booking_id.

create policy "messages_select_conversation_participant"
on public.messages for select to authenticated
using (
  messages.conversation_id is not null
  and (
    exists (
      select 1
      from public.conversations conv
      inner join public.client_profiles cp on cp.id = conv.client_id
      where conv.id = messages.conversation_id
        and cp.user_id = auth.uid()
    )
    or exists (
      select 1
      from public.conversations conv
      inner join public.prestataire_profiles pp on pp.id = conv.prestataire_id
      where conv.id = messages.conversation_id
        and pp.user_id = auth.uid()
    )
  )
);

comment on policy "messages_select_conversation_participant" on public.messages is
  'Lecture des messages via le fil client/prestataire (modèle fil unique par paire).';
