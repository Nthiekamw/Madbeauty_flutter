-- Stripe Connect (onboarding prestataire) + journal webhooks (idempotence).

alter table public.prestataire_profiles
  add column if not exists stripe_connect_onboarding_status text
    default 'not_started'
    check (
      stripe_connect_onboarding_status in (
        'not_started',
        'pending',
        'complete',
        'restricted'
      )
    ),
  add column if not exists stripe_connect_charges_enabled boolean not null default false,
  add column if not exists stripe_connect_payouts_enabled boolean not null default false,
  add column if not exists stripe_connect_details_submitted boolean not null default false,
  add column if not exists stripe_connect_updated_at timestamptz;

create table if not exists public.stripe_webhook_events (
  id text primary key,
  type text not null,
  payload jsonb,
  processed_at timestamptz not null default now()
);

create index if not exists idx_stripe_webhook_events_processed
  on public.stripe_webhook_events (processed_at desc);

alter table public.stripe_webhook_events enable row level security;

-- Aucune policy : lecture/écriture réservées au service_role (Edge Functions).

comment on table public.stripe_webhook_events is
  'Événements Stripe déjà traités (évite le double traitement des webhooks).';
