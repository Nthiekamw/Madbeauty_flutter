-- Abonnement prestataire (Stripe Billing / Subscriptions).

alter table public.prestataire_profiles
  add column if not exists stripe_billing_customer_id text,
  add column if not exists stripe_subscription_id text,
  add column if not exists subscription_status text not null default 'none'
    check (
      subscription_status in (
        'none',
        'active',
        'trialing',
        'past_due',
        'canceled',
        'incomplete',
        'unpaid',
        'incomplete_expired',
        'paused'
      )
    ),
  add column if not exists subscription_tier text
    check (subscription_tier is null or subscription_tier in ('solo', 'multi')),
  add column if not exists subscription_interval text
    check (
      subscription_interval is null
      or subscription_interval in ('month', 'year')
    ),
  add column if not exists subscription_current_period_end timestamptz,
  add column if not exists subscription_updated_at timestamptz;

create unique index if not exists idx_prestataire_stripe_subscription_id
  on public.prestataire_profiles (stripe_subscription_id)
  where stripe_subscription_id is not null;

comment on column public.prestataire_profiles.stripe_billing_customer_id is
  'Client Stripe Billing (cus_...) pour l’abonnement plateforme.';
comment on column public.prestataire_profiles.subscription_status is
  'Statut abonnement MadBeauty ; none = jamais abonné ou résilié.';
