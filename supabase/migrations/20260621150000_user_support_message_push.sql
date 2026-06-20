-- Push FCM quand un message support utilisateur ↔ admin est créé.

create or replace function public.trigger_user_support_message_created_push()
returns trigger
language plpgsql
security definer
set search_path = public, private
as $$
begin
  perform private.notify_edge_function(
    'on_user_support_message_created',
    jsonb_build_object(
      'type', 'INSERT',
      'table', 'user_support_messages',
      'schema', 'public',
      'record', to_jsonb(NEW),
      'old_record', null
    )
  );
  return NEW;
end;
$$;

drop trigger if exists user_support_message_created_push_trigger
  on public.user_support_messages;

create trigger user_support_message_created_push_trigger
  after insert on public.user_support_messages
  for each row
  execute function public.trigger_user_support_message_created_push();
