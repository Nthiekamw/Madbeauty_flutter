-- Notifications push FCM : déclenchement automatique des Edge Functions
-- (équivalent aux Database Webhooks du dashboard, versionnés en migration).
-- Config : private.webhook_config (rempli par supabase/setup_push_notifications.ps1).

create extension if not exists pg_net with schema extensions;

create schema if not exists private;

create table if not exists private.webhook_config (
  key text primary key,
  value text not null,
  updated_at timestamptz not null default now()
);

revoke all on schema private from public, anon, authenticated;
revoke all on table private.webhook_config from public, anon, authenticated;

insert into private.webhook_config (key, value)
values
  ('functions_base', ''),
  ('booking_webhook_secret', '')
on conflict (key) do nothing;

create or replace function private.get_webhook_config(p_key text)
returns text
language sql
security definer
set search_path = private, public
as $$
  select value from private.webhook_config where key = p_key limit 1;
$$;

create or replace function private.notify_edge_function(
  p_function_name text,
  p_payload jsonb
)
returns void
language plpgsql
security definer
set search_path = private, public, extensions
as $$
declare
  v_base text;
  v_secret text;
  v_headers jsonb;
begin
  v_base := trim(both from coalesce(private.get_webhook_config('functions_base'), ''));
  if v_base = '' then
    return;
  end if;

  v_secret := trim(both from coalesce(private.get_webhook_config('booking_webhook_secret'), ''));
  v_headers := jsonb_build_object('Content-Type', 'application/json');
  if v_secret <> '' then
    v_headers := v_headers || jsonb_build_object('x-webhook-secret', v_secret);
  end if;

  perform net.http_post(
    url := rtrim(v_base, '/') || '/' || p_function_name,
    headers := v_headers,
    body := p_payload
  );
end;
$$;

create or replace function public.trigger_booking_created_push()
returns trigger
language plpgsql
security definer
set search_path = public, private
as $$
begin
  perform private.notify_edge_function(
    'on_booking_created',
    jsonb_build_object(
      'type', 'INSERT',
      'table', 'reservations',
      'schema', 'public',
      'record', to_jsonb(NEW),
      'old_record', null
    )
  );
  return NEW;
end;
$$;

create or replace function public.trigger_booking_updated_push()
returns trigger
language plpgsql
security definer
set search_path = public, private
as $$
begin
  perform private.notify_edge_function(
    'on_booking_updated',
    jsonb_build_object(
      'type', 'UPDATE',
      'table', 'reservations',
      'schema', 'public',
      'record', to_jsonb(NEW),
      'old_record', to_jsonb(OLD)
    )
  );
  return NEW;
end;
$$;

create or replace function public.trigger_booking_deleted_push()
returns trigger
language plpgsql
security definer
set search_path = public, private
as $$
begin
  perform private.notify_edge_function(
    'on_booking_updated',
    jsonb_build_object(
      'type', 'DELETE',
      'table', 'reservations',
      'schema', 'public',
      'record', null,
      'old_record', to_jsonb(OLD)
    )
  );
  return OLD;
end;
$$;

create or replace function public.trigger_message_created_push()
returns trigger
language plpgsql
security definer
set search_path = public, private
as $$
begin
  perform private.notify_edge_function(
    'on_message_created',
    jsonb_build_object(
      'type', 'INSERT',
      'table', 'messages',
      'schema', 'public',
      'record', to_jsonb(NEW),
      'old_record', null
    )
  );
  return NEW;
end;
$$;

drop trigger if exists booking_created_push_trigger on public.reservations;
create trigger booking_created_push_trigger
  after insert on public.reservations
  for each row
  execute function public.trigger_booking_created_push();

drop trigger if exists booking_updated_push_trigger on public.reservations;
create trigger booking_updated_push_trigger
  after update on public.reservations
  for each row
  execute function public.trigger_booking_updated_push();

drop trigger if exists booking_deleted_push_trigger on public.reservations;
create trigger booking_deleted_push_trigger
  after delete on public.reservations
  for each row
  execute function public.trigger_booking_deleted_push();

drop trigger if exists message_created_push_trigger on public.messages;
create trigger message_created_push_trigger
  after insert on public.messages
  for each row
  execute function public.trigger_message_created_push();

comment on table private.webhook_config is
  'URLs et secret pour pg_net → Edge Functions push (setup_push_notifications.ps1).';
