-- Realtime pour le chat de signalement de bug (messages + statut du fil).

alter table public.bug_report_messages replica identity full;

do $$
begin
  alter publication supabase_realtime add table public.bug_report_messages;
exception
  when duplicate_object then null;
end $$;

alter table public.bug_reports replica identity full;

do $$
begin
  alter publication supabase_realtime add table public.bug_reports;
exception
  when duplicate_object then null;
end $$;
