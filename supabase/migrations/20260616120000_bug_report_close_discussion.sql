-- Empêche l'envoi de messages sur un signalement résolu ou classé.

drop policy if exists "bug_report_messages_insert_participant"
  on public.bug_report_messages;

create policy "bug_report_messages_insert_participant"
on public.bug_report_messages for insert to authenticated
with check (
  sender_id = auth.uid()
  and exists (
    select 1 from public.bug_reports br
    where br.id = bug_report_messages.bug_report_id
      and br.status not in ('resolved', 'closed')
      and (
        br.reporter_user_id = auth.uid()
        or public.is_admin_user(auth.uid())
      )
  )
);
