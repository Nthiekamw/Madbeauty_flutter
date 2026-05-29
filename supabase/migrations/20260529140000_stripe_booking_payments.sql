-- Paiements Stripe (Connect) : compte prestataire, reçu réservation, client Stripe.

alter table public.prestataire_profiles
  add column if not exists stripe_connect_account_id text;

alter table public.client_profiles
  add column if not exists stripe_customer_id text;

alter table public.reservations
  add column if not exists amount_cents integer check (amount_cents is null or amount_cents >= 0),
  add column if not exists currency text default 'eur',
  add column if not exists stripe_payment_intent_id text,
  add column if not exists payment_status text
    check (
      payment_status is null
      or payment_status in ('authorized', 'captured', 'failed', 'canceled')
    ),
  add column if not exists paid_at timestamptz;

create unique index if not exists idx_reservations_stripe_payment_intent
  on public.reservations (stripe_payment_intent_id)
  where stripe_payment_intent_id is not null;

comment on column public.prestataire_profiles.stripe_connect_account_id is
  'Compte Stripe Connect (acct_...) du prestataire.';
comment on column public.reservations.payment_status is
  'authorized = paiement autorisé (capture différée), captured = fonds versés au prestataire.';
