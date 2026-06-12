-- Présence utilisateur (chat : en ligne / dernière activité).

alter table public.user_profiles
  add column if not exists last_seen_at timestamptz;

comment on column public.user_profiles.last_seen_at is
  'Dernière activité app (heartbeat client).';

create index if not exists idx_user_profiles_last_seen_at
  on public.user_profiles (last_seen_at desc nulls last);
