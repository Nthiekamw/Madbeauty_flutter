-- Timeout pg_net 30s pour cold start Deno (défaut 5s trop court).

create or replace function private.invoke_process_scheduled_pushes()
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
    url := rtrim(v_base, '/') || '/process_scheduled_pushes',
    headers := v_headers,
    body := jsonb_build_object(
      'source', 'pg_cron',
      'triggered_at', now()
    ),
    timeout_milliseconds := 30000
  );
end;
$$;

comment on function private.invoke_process_scheduled_pushes() is
  'Appelle l’EF process_scheduled_pushes via pg_net (cron 15 min, timeout 30s).';
