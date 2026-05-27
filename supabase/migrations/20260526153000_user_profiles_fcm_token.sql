-- Token FCM par utilisateur (table métier user_profiles ; anciennement profiles).
alter table public.user_profiles
add column if not exists fcm_token text;

alter table public.user_profiles
add column if not exists fcm_token_updated_at timestamptz;

comment on column public.user_profiles.fcm_token is 'Token device Firebase Cloud Messaging (notifications push)';
comment on column public.user_profiles.fcm_token_updated_at is 'Dernière mise à jour du token FCM';

create index if not exists idx_user_profiles_fcm_nonnull
on public.user_profiles (user_id)
where fcm_token is not null;
