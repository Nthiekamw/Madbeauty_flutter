-- Cron toutes les 15 min → Edge process_scheduled_pushes (aftercare + rebook).
-- Réutilise private.notify_edge_function (functions_base dans private.webhook_config).

create extension if not exists pg_cron with schema extensions;
create extension if not exists pg_net with schema extensions;

create or replace function private.invoke_process_scheduled_pushes()
returns void
language plpgsql
security definer
set search_path = private, public, extensions
as $$
begin
  perform private.notify_edge_function(
    'process_scheduled_pushes',
    jsonb_build_object(
      'source', 'pg_cron',
      'triggered_at', now()
    )
  );
end;
$$;

revoke all on function private.invoke_process_scheduled_pushes() from public;
grant execute on function private.invoke_process_scheduled_pushes() to postgres;

comment on function private.invoke_process_scheduled_pushes() is
  'Appelle l’EF process_scheduled_pushes via pg_net (cron 15 min).';

-- Idempotent : retire l’ancien job s’il existe puis recrée
do $$
declare
  v_jobid bigint;
begin
  select j.jobid into v_jobid
  from cron.job j
  where j.jobname = 'process-scheduled-pushes'
  limit 1;

  if v_jobid is not null then
    perform cron.unschedule(v_jobid);
  end if;

  perform cron.schedule(
    'process-scheduled-pushes',
    '*/15 * * * *',
    $cron$select private.invoke_process_scheduled_pushes()$cron$
  );
end;
$$;
