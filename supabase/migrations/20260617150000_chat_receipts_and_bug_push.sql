-- Accusés de réception (envoyé / reçu / lu) + push sur nouveaux messages bug.

alter table public.messages
  add column if not exists delivered_at timestamptz;

comment on column public.messages.delivered_at is
  'Horodatage de réception côté destinataire (double check gris).';

alter table public.bug_report_messages
  add column if not exists delivered_at timestamptz,
  add column if not exists is_read boolean not null default false;

comment on column public.bug_report_messages.delivered_at is
  'Horodatage de réception côté destinataire.';
comment on column public.bug_report_messages.is_read is
  'true lorsque le destinataire a lu le message (double check bleu).';

drop policy if exists "bug_report_messages_update_participant"
  on public.bug_report_messages;

create policy "bug_report_messages_update_participant"
on public.bug_report_messages for update to authenticated
using (
  exists (
    select 1 from public.bug_reports br
    where br.id = bug_report_messages.bug_report_id
      and (
        br.reporter_user_id = auth.uid()
        or public.is_admin_user(auth.uid())
      )
  )
)
with check (
  exists (
    select 1 from public.bug_reports br
    where br.id = bug_report_messages.bug_report_id
      and (
        br.reporter_user_id = auth.uid()
        or public.is_admin_user(auth.uid())
      )
  )
);

create or replace function public.trigger_bug_report_message_created_push()
returns trigger
language plpgsql
security definer
set search_path = public, private
as $$
begin
  perform private.notify_edge_function(
    'on_bug_report_message_created',
    jsonb_build_object(
      'type', 'INSERT',
      'table', 'bug_report_messages',
      'schema', 'public',
      'record', to_jsonb(NEW),
      'old_record', null
    )
  );
  return NEW;
end;
$$;

drop trigger if exists bug_report_message_created_push_trigger
  on public.bug_report_messages;

create trigger bug_report_message_created_push_trigger
  after insert on public.bug_report_messages
  for each row
  execute function public.trigger_bug_report_message_created_push();
